local datasetUri = std.extVar("dataseturi");

local mappings(mappings) = {
  "@context": {
    "rr": "http://www.w3.org/ns/r2rml#",
    "rml": "http://semweb.mmlab.be/ns/rml#",
    "tim": "http://timbuctoo.huygens.knaw.nl/mapping#"
  },
  "@graph": mappings
};

local mappingName(localName) = "http://example.org/mapping/" + localName;

local field(termType, dataType, source) = {
  "rr:objectMap": {
    "rr:termType": {
      "@id": if termType == "rr:IRI" || termType == "rr:Literal" then termType else error "Termtype must be rr:IRI or rr:Literal, " + termType + " is not a valid value. (Don't generate blank nodes)"
    }
  } + source + if dataType == null then {} else {
    "rr:datatype": {"@id": dataType}
  },
};

local objectMapOrReference(predicate, omap) = {
  "rr:objectMap": if "tim:expression" in omap
                  then {
                    "rr:column": omap["tim:name"],
                  } + {
                    [key]: omap[key] for key in std.objectFields(omap) if key != "tim:expression" && key != "tim:name"
                  }
                  else omap,
  "rr:predicate": { "@id": predicate }
};

local expressionOrNull(map) = 
  if "tim:expression" in map then
    {"tim:expression": map["tim:expression"], "tim:name": map["tim:name"]}
  else
    null;

local mapping(name, filename, index, subjectMapSource, classSource, objectMaps) = {
  "@id": mappingName(name),
  "rml:logicalSource": {
    "rml:source": {
      "tim:rawCollectionUri": {
        "@id": datasetUri + "rawData/" + filename + "/collections/"  + index
      },
      "tim:customField": std.prune(std.flattenArrays([
        if std.type(objectMaps[key]) == 'array' then
          [expressionOrNull(item["rr:objectMap"]) for item in objectMaps[key]]
        else
          [expressionOrNull(objectMaps[key]["rr:objectMap"])]
        for key in std.objectFields(objectMaps)
      ]))
    }
  },
  "rr:subjectMap": subjectMapSource,
  "rr:predicateObjectMap": 
    [field("rr:IRI", null, classSource) + {"rr:predicate": { "@id": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" }}] +
    std.flattenArrays([
      if std.type(objectMaps[key]) == 'array' then
        [objectMapOrReference(key, item["rr:objectMap"]) for item in objectMaps[key]]
      else
        [objectMapOrReference(key, objectMaps[key]["rr:objectMap"])]
      for key in std.objectFields(objectMaps)
    ])
};

// SOURCES

local templateSource(template) = {
  "rr:template": if std.length(std.split(template, "{")) > 1 && std.length(std.split(template, "}")) > 1 then template else error "template should contain { and }",
};

local constantSource(literal) = {
  "rr:constant": literal
};

local columnSource(columnName) = {
  "rr:column": columnName
};

local jexlSource(expression) = {
  "tim:name": std.md5(expression),
  "tim:expression": expression
};

local jexlNullOrValue(variable, ifValue) = "(v." + variable + " != null ? " + ifValue + @' : ""';
local nameComponent(preComma, type, variableName, postComma) = '"' + (if preComma then "," else "") + @'{\"type\":\"' + type + @'\",\"value\":" + Json:stringify(v.' + variableName + ') + "}' + (if postComma then "," else "") + '"';
local personNameSource(preposition, given_name, intraposition, family_name, postposition) =
  jexlSource(@'"{\"components\":[" + ' + 
    jexlNullOrValue(given_name, nameComponent(false, "FORENAME", given_name, true)) + " + " + 
    nameComponent(false, "SURNAME", family_name, false) + " + " + 
    jexlNullOrValue(intraposition, nameComponent(true, "NAME_LINK", intraposition, false)) + " +" + 
    jexlNullOrValue(preposition, nameComponent(true, "ROLE_NAME", preposition, false)) + " +" + 
    jexlNullOrValue(postposition, nameComponent(true, "GEN_NAME", postposition, false)) + 
  '"]}"');


// FIELDS

local iriField(source) = field("rr:IRI", null, source);

local dataField(dataType, source) = field("rr:Literal", dataType, source);

local joinField(local_column, remote_table, remote_column) = {
  "rr:objectMap": {
    "rr:parentTriplesMap": {
      "@id": mappingName(remote_table)
    },
    "rr:joinCondition": {
      "rr:child": local_column,
      "rr:parent": remote_column
    }
  }
};

// PREDICATES
local customPredicate(suffix) = datasetUri + "predicate/" + suffix;
local personNamePredicate = "http://timbuctoo.huygens.knaw.nl/static/v5/predicate/names";

// TYPES
local personName = "http://timbuctoo.huygens.knaw.nl/static/v5/datatype/person-name";
local edtf = "https://www.loc.gov/standards/datetime/pre-submission.html";
local string = "http://www.w3.org/2001/XMLSchema#string";
local boolean = "http://www.w3.org/2001/XMLSchema#boolean";
local decimal = "http://www.w3.org/2001/XMLSchema#decimal";
local integer = "http://www.w3.org/2001/XMLSchema#integer";
local anyURI = "http://www.w3.org/2001/XMLSchema#anyURI";



{
  mappings:: mappings,
  mapping:: mapping,
  defaultPredicates:: {
    "tim_names": "http://timbuctoo.huygens.knaw.nl/static/v5/predicate/names"
  },
  datasetUri:: datasetUri,

  templateSource:: templateSource,
  constantSource:: constantSource,
  personNameSource:: personNameSource,
  columnSource:: columnSource,
  jexlSource:: jexlSource,

  iriField:: iriField,
  dataField:: dataField,
  joinField:: joinField,

  customPredicate:: customPredicate,
  personNamePredicate:: personNamePredicate,

  types:: {
    personName: personName,
    edtf: edtf,
    string: string,
    boolean: boolean,
    decimal: decimal,
    integer: integer,
    anyURI: anyURI,
  },
}
