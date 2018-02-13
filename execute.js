const opn = require('opn');
const fetch = require('node-fetch')
const FormData = require('form-data');
const fs = require('fs')
const pathLib = require('path');
const stateFileName = __dirname + "/state.json";
const DEBUG = false;
const DraftLog = require('draftlog');
DraftLog(console)


let state = {};
try {
  if (fs.existsSync(stateFileName)) {
    state = JSON.parse(fs.readFileSync(stateFileName, "utf-8"));
  }
} catch (e) {
  console.log("Error while reading state file", e);
}
if (!state.input) {
  state.input = {};
}
if (!state.mappingInput) {
  state.mappingInput = {};
}
const timbuctoo_url = process.env.timbuctooUrl || "https://repository.huygens.knaw.nl"

function graphql(query, authId) {
  return fetch(timbuctoo_url + "/v5/graphql", {
    method: "POST",
    body: JSON.stringify({
      query: query
    }),
    headers: {
      "content-type": "application/json",
      Authorization: authId
    }
  })
  .then(r => r.json())
  .then(json => {
    if (json.errors && json.errors.length > 0) {
      throw new Error(JSON.stringify(json.errors));
    } else {
      return json.data
    }
  });
}

function graphqlDataSet(userInfo, datasetId, query) {
  return graphql(`
    {
      dataSets {
         ${datasetId} {
          ${query}
        }
      }
    }
    `, userInfo.authorization).then(result => result.dataSets[datasetId])
}

async function executeAndPoll(userInfo, datasetId, promise) {
  var draft = console.draft("\n".repeat(14))
  const updatePoll = setInterval(function () {
    graphql(`{
      dataSetMetadata(dataSetId: "${datasetId}") {
        currentImportStatus {
          messages 
        }
      }
    }
    `, userInfo.authorization)
    .then(data => {
      if (data.dataSetMetadata != null) {
        const msgs = data.dataSetMetadata.currentImportStatus.messages;
      if (msgs.length < 15) {
        msgs.length = 15;
      }
        const width = process.stdout.columns;
        draft(msgs.slice(-15).map(x => x.length < width ? x + " ".repeat(width - x.length) : x.substr(0, width)).join("\n"))//.slice(prev.length)
      }
    })
    .catch(function (arguments) { console.log(arguments) });
  }, 1000);
  try {
    return await promise;
  } finally {
    clearInterval(updatePoll);
  }
}

function csvUpload(userInfo, datasetId, fileName, delimiter, quoteChar) {
  const form = new FormData();
  form.append('file', fs.createReadStream(fileName));
  form.append("fileMimeTypeOverride", "text/csv");
  form.append("delimiter", delimiter );
  form.append("quoteChar", quoteChar);
  console.log("Uploading CSV:");

  const [userPart, dataSetPart] = datasetId.split("__");
  const promise = fetch(timbuctoo_url + `/v5/${userPart}/${dataSetPart}/upload/table?forceCreation=true`, {
    method: "POST",
    body: form,
    headers: {
      Authorization: userInfo.authorization
    }
  })
  .catch(function (e) {
    console.log("Upload failed?", e);
  });
  // return promise;
  return executeAndPoll(userInfo, datasetId, promise);
}

function getUserInfo(authorization) {
  return graphql("{aboutMe{id}}", authorization)
  .then(function (data) {
    if (data.aboutMe == null) {
      return null;
    } else {
      return data.aboutMe.id;
    }
  })
  .catch(function (e) {
    console.log("Error while fetching user info: ", e);
    return null;
  })
}

function logInUser() {
  return new Promise(function (resolve, reject) {
    let url = require('url');
    var server = require('http').createServer(function (req, resp) {
      const path = url.parse(req.url, true);

      if (path.pathname === "/" || path.pathname === "" || path.pathname === null) {
        resp.end(`
          <body onload="document.forms[0].submit()">
            Redirecting&hellip;
            <form style="display:none" method="POST" action="https://secure.huygens.knaw.nl/saml2/login">
              <input id="hsurl" name="hsurl" value="http://localhost:${port}/afterLogin">
            </form>
          </body>`)
      } else if (path.pathname === "/afterLogin") {
        var hsid = path.query.hsid;
        getUserInfo(hsid).then(userId => resolve({authorization: hsid, userId: userId}));
        resp.end('<body>You can close this window</body>');
        console.log("closing")
        server.close(() => "server closed");
      } else {
        resp.statusCode = 404;
        resp.end("Unknown path");
      }
    });
    var port;
  
    server.listen(0, function () {
      port = server.address().port;
      opn("http://localhost:" + port);
    });
  });
}

function makeLines(str) {
  if (!str) {
    return [];
  }
  const lines = str.split("\n")
  let i = lines.length;
  while (lines[i - 1] === "") {
    i--
  }
  return lines.slice(0, i)
}

var child_process = require("child_process");

function exec(command, ...args) {
  if (DEBUG) {
    console.log("CMD: " + command, args)
  }
  return new Promise(function executor(resolve, reject) {
    const result = child_process.spawn(command, args.filter(x => x != null), {
      shell: false,
      env: {
        "LANG": "C.UTF-8"
      },
      encoding: "utf-8"
    });
    let stderr = ""
    let stdout = "";
  
    result.stdout.on('data', (data) => {
      stdout += data;
    });
  
    result.stderr.on('data', (data) => {
      stderr += data;
    });
  
    result.on('close', (code) => {
      const retVal = {
        success: code == 0,
        status: code,
        stdout: makeLines(stdout),
        stderr: makeLines(stderr)
      }
      if (DEBUG) {
        console.log("  SUC: " + retVal.success)
        console.log("  ST:  " + retVal.status)
        console.log("  OUT: " + JSON.stringify(retVal.stdout, undefined, "  ").split("\n").map((x, i) => (i > 0 ? "  " : "") + x).join("\n"))
        console.log("  ERR: " + JSON.stringify(retVal.stderr, undefined, "  ").split("\n").map((x, i) => (i > 0 ? "  " : "") + x).join("\n"))
      }
      resolve(retVal);
    });
  });
}

function loop(objectOrArray, cb) {
  if (Array.isArray(objectOrArray)) {
    return objectOrArray.map(cb);
  } else {
    return [objectOrArray].map(cb);
  }
}

async function loopAsync(objectOrArray, cb) {
  if (Array.isArray(objectOrArray)) {
    for (let i = 0; i < objectOrArray.length; i++) {
      await cb(objectOrArray[i], i, objectOrArray);
    }
  } else {
    await cb(objectOrArray, 0, [objectOrArray]);
  }
}


function checkColumns(jsonLdDoc, rawCollections) {
  let result = true;
  const dym = require("didyoumean")

  function checkColumn(collectionUri, columnName, customColumns) {
    if (!rawCollections[collectionUri][columnName] && !customColumns[columnName]) {
      const closeMatch = dym(columnName, Object.keys(rawCollections[collectionUri]));
      console.log("Column", columnName, "does not exist." + (closeMatch != null ? " Did you mean " + JSON.stringify(closeMatch) + "?" : ""));
      result = false;
    }
  }

  function getTemplates(templ, cb) {
    let i = 0;
    while (i < templ.length) {
      if (templ[i] === "\\") {
        i++; //skip next token
      } else if (templ[i] === "{" && templ[i+1] !== "}") {
        let match = "";
        i++
        while (i < templ.length) {
          if (templ[i] === "\\" && templ[i+1] === "}") {
            match += "}";
            i += 2;
          } else if (templ[i] === "}") {
            cb(match);
            i++
            break;
          } else if (templ[i] === "\\") {
            i++
            match += templ[i];
            i++
          } else {
            match += templ[i];
            i++
          }
        }
      }
      i++
    }
  }

  function checkSource(source, omap, customColumns) {
    if (omap["rr:column"]) {
      checkColumn(source, omap["rr:column"], customColumns);
    } else if (omap["rr:template"]) {
      getTemplates(omap["rr:template"], col => checkColumn(source, col, customColumns));
    }
  }
    
  // [
  //   "http://jan/{}",
  //   "http://jan/{foo}",
  //   "http://jan/{fo\\}o}",
  //   "http://jan/{fo\\}o\\\\}",
  //   "http://jan/{fo\\}o\\\\\\}}",
  //   "http://jan/{fo\\}o\\\\\\\\}}",
  //   "http://jan/{foo}/{bar}",
  //   "http://jan/{foo}/{bar}?really=\\{as}",
  //   "http://jan/{foo}/{bar}?really=\\\\{as}",
  // ].forEach(str => getTemplates(str, match => console.log(str, match)))
  loop(jsonLdDoc["@graph"], mapping => {
    const customColumns = {};
    if (mapping["rml:logicalSource"]["rml:source"]["tim:customField"]) {
      loop(mapping["rml:logicalSource"]["rml:source"]["tim:customField"], customField => customColumns[customField["tim:name"]] = true);
    }
    
    const source = mapping["rml:logicalSource"]["rml:source"]["tim:rawCollectionUri"]["@id"];
    if (!rawCollections[source]) {
      console.log("The sheet", JSON.stringify(source), " is not available!");
      result = false;
      return
    }
    checkSource(source, mapping["rr:subjectMap"], customColumns);
    loop(mapping["rr:predicateObjectMap"], function (pomap) {
      checkSource(source, pomap["rr:objectMap"], customColumns)
    });
  });
  return result;
}

async function getCsvFiles(userInfo, datasetId) {
  const availableTypes = await graphql(`{
    dataSetMetadata(dataSetId: "${datasetId}") {
      uri
    }
    __schema {
      types {
        name
      }
    }
  }`, state.userInfo.authorization);
  if (!availableTypes.__schema.types.some(x => x.name === `${datasetId}_http___timbuctoo_huygens_knaw_nl_static_v5_types_tabularCollection`)) {
    return { 
      dataSetUri: availableTypes.dataSetMetadata != null ? availableTypes.dataSetMetadata.uri : undefined,
      uploadedFiles: [],
      uploadedFilePickList: [],
      mostRecentlyUploadedFile: undefined
    }
  }
  const info = (await graphqlDataSet(state.userInfo, datasetId, `
    metadata {
      uri
    }
    http___timbuctoo_huygens_knaw_nl_static_v5_types_tabularFileList {
      items {
        uri
        rdfs_label { value }
        prov_atTime { value }
        tim_hasCollection {
          ... on ${datasetId}_http___timbuctoo_huygens_knaw_nl_static_v5_types_tabularCollection {
            uri
            rdfs_label { value }
            tim_hasPropertyList {
              items {
                rdfs_label { value }
              }
            }
          }
        }
      }
    }`
  ));
  const uploadedFiles = info.http___timbuctoo_huygens_knaw_nl_static_v5_types_tabularFileList.items;
  const dataSetUri = info.metadata.uri;

  const uploadedFilePickList = {};
  for (const file of uploadedFiles) {
    const label = file.rdfs_label.value + " ( " + file.prov_atTime.value + " )";
    if (label in uploadedFilePickList) {
      label = label + " - " + file.uri;
    }
    uploadedFilePickList[label] = file.uri;
    file.label = label
  }

  uploadedFiles.sort((a,b) => a.prov_atTime.value < b.prov_atTime.value ? -1 : 1)
  
  return {
    dataSetUri,
    uploadedFiles,
    uploadedFilePickList,
    mostRecentlyUploadedFile: uploadedFiles[0]
  }

}

async function execute() {
  console.log("Using timbuctoo server at", timbuctoo_url);
  try {
    const result = await graphql('{aboutMe{id}}', undefined);
    if (!"aboutMe" in result) {
      throw new Error("result is not what I expected");
    }
  } catch (e) {
    console.log(e);
    console.log(`Could not communicate to the timbuctoo server. Please verify whether ${timbuctoo_url}/v5/graphql?query=${encodeURIComponent("{aboutMe{id}}")}&accept=application/json works in your browser.`)
    process.exit(1);
  }


  let userId = null;
  if (state.userInfo && state.userInfo.authorization) {
    userId = await getUserInfo(state.userInfo.authorization); //already logged in
  }
  if (userId === null) {
    state.userInfo = await logInUser();
  }
  var inquirer = require('inquirer');
  let PathPrompt = require('inquirer-path').PathPrompt;
  inquirer.prompt.registerPrompt('path', PathPrompt);
    
  state.input.dataSetId = (await inquirer.prompt([
    {
      name: "dataSetId",
      message: "What dataSet are we working with?",
      type: "input",
      default: state.input.dataSetId != null ? state.input.dataSetId.split("__")[1] : undefined
    },
  ])).dataSetId;

  if (state.input.dataSetId.indexOf("__") < 0) {
    state.input.dataSetId = "u" + state.userInfo.userId + "__" + state.input.dataSetId;
  }

  let {dataSetUri, mostRecentlyUploadedFile, uploadedFilePickList, uploadedFiles} = await getCsvFiles(state.userInfo, state.input.dataSetId);
  let isFinished = false;
  while (!isFinished) {
    const action = (await inquirer.prompt([
      {
        name: "action",
        message: "What do you want to do?",
        type: "list",
        choices: [
          "Upload a new csv", 
          "run a mapping file", 
          "stop this program"
        ],
        default: "run a mapping file",
      },
    ])).action;
    if (action === "run a mapping file") {
      let prevPickedCsv = undefined;
    
      state.mappingInput = await inquirer.prompt([
        {
          name: "mappingFile",
          message: "where is the mapping file?",
          type: "path",
          default: state.mappingInput.mappingFile == null ? process.cwd() : pathLib.dirname(state.mappingInput.mappingFile),
        },
      ]);
      //if it's jsonnet then try to turn it into json
      let jsonnetLocation;
      try {
        jsonnetLocation = child_process.execSync("which jsonnet", {encoding: "utf-8"}).split("\n")[0];
      } catch (e) {
        console.log("Jsonnet not found on this system");
      }
      
      const generatedFile = JSON.parse((await exec(jsonnetLocation, "--ext-str", `dataseturi=${dataSetUri}`, state.mappingInput.mappingFile)).stdout.join("\n"));
      
      const rawCollections = {};
      for (var file of uploadedFiles) {
        const collection = file.tim_hasCollection;
        const columns = {};
        for (var prop of collection.tim_hasPropertyList.items) {
          columns[prop.rdfs_label.value] = true;
        }
        rawCollections[collection.uri] = columns;
      }
    
      const jsonld = require("jsonld");
      const framedFile = await jsonld.frame(generatedFile, {
        "@context": {
          "rml": "http://semweb.mmlab.be/ns/rml#",
          "rr": "http://www.w3.org/ns/r2rml#",
          "tim": "http://timbuctoo.huygens.knaw.nl/mapping#"
        },
        "@graph": {
          "rml:logicalSource": {
            
          },
          "rr:predicateObjectMap": {
            
          }
        }
      });

      const pickedCsvFiles = {};
      if (!state.csvFiles) {
        state.csvFiles = {};
      }
      await loopAsync(framedFile["@graph"], async function (mapping) {
        if (mapping["rml:logicalSource"] && mapping["rml:logicalSource"]["rml:source"] && mapping["rml:logicalSource"]["rml:source"]["tim:rawCollectionUri"]) {
          if ("tim:csvFileId" in mapping["rml:logicalSource"]["rml:source"]["tim:rawCollectionUri"]) {
            const csvFileId = mapping["rml:logicalSource"]["rml:source"]["tim:rawCollectionUri"]["tim:csvFileId"];
            let uri;
            if (pickedCsvFiles[csvFileId]) {
              uri = pickedCsvFiles[csvFileId]
            } else {
              const prevUri = state.csvFiles[csvFileId];
              const labelOfPrevUri = (uploadedFiles.find(x => x.uri === prevUri) || {label: undefined}).label
      
              const answer = await inquirer.prompt([
                {
                  name: "csvFile",
                  message: "What csv file should we use for " + csvFileId + "?",
                  type: "list",
                  choices: uploadedFiles.map(x => x.label),
                  default: labelOfPrevUri,
                  filter: choice => uploadedFilePickList[choice]
                },
              ])
              uri = answer.csvFile;
            }
            state.csvFiles[csvFileId] = uri;
            pickedCsvFiles[csvFileId] = uri;
            const sourceUri = mapping["rml:logicalSource"]["rml:source"]["tim:rawCollectionUri"];
            sourceUri["@id"] = uri + "collections/" + sourceUri["tim:index"]
            delete sourceUri["tim:csvFileId"];
            delete sourceUri["tim:index"];
          }
        }
      });

      if (checkColumns(framedFile, rawCollections)) {
        console.log("Executing mapping file...")
        
        const [userPart, dataSetPart] = state.input.dataSetId.split("__");
        const promise = fetch(timbuctoo_url + `/v5/${userPart}/${dataSetPart}/rml`, {
          method: "POST",
          body: JSON.stringify(generatedFile, undefined, 2),
          headers: {
            Authorization: state.userInfo.authorization
          }
        })
        .then(function (r) {
          if (r.status > 299) {
            console.log("Upload failed")
          }
        })
        .catch(function (e) {
          console.log("Upload failed?", e);
        });
        await executeAndPoll(state.userInfo, state.input.dataSetId, promise);
      }
    } else if (action === "Upload a new csv") {
      const csvUploadData = await inquirer.prompt([
        {
          name: "csvFile",
          message: "What csv file should we upload",
          type: "path",
          default: state.input.csvFile == null ? process.cwd() : pathLib.dirname(state.input.csvFile),
        },
        {
          name: "delimiter",
          message: "What is the character used to separate fields?",
          type: "input",
          default: state.input.delimiter == null ? ';' : state.input.delimiter,
        },
        {
          name: "quoteChar",
          message: "What character is used for quoting fields (if any is used)",
          type: "input",
          default: state.input.quoteChar == null ? '"' : state.input.quoteChar,
        },
      ]);
      state.input.delimiter = csvUploadData.delimiter;
      state.input.quoteChar = csvUploadData.quoteChar;
      state.input.csvFile = csvUploadData.csvFile;
      await csvUpload(state.userInfo, state.input.dataSetId, state.input.csvFile, state.input.delimiter, state.input.quoteChar);

      ({dataSetUri, mostRecentlyUploadedFile, uploadedFilePickList, uploadedFiles} = await getCsvFiles(state.userInfo, state.input.dataSetId));

    } else if (action === "stop this program") {
      isFinished = true;
    } else {
      throw new Error("Unknown action " + action);
    }
  }
  

}

execute()
.catch(x => console.log(x))
.then(function () {
  fs.writeFileSync(__dirname + "/state.json", JSON.stringify(state), "utf-8")
})

