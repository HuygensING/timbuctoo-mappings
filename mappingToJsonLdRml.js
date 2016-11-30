export default function mappingToJsonLdRml(mapping, vre, archetypes) {
  const relationsToExisting = Object.keys(mapping.collections)
    .map((key) => mapping.collections[key].mappings)
    .reduce((a, b) => a.concat(b))
    .filter((columnMapping) => typeof columnMapping.variable[0].targetExistingTimbuctooVre !== "undefined")
    .map((columnMapping) => columnMapping.property);

  const mappedArchetypes = Object.keys(mapping.collections)
    .map((key) => mapping.collections[key].archetypeName);
  
  const desiredArchetypes = Object.keys(archetypes)
    .map((key) => archetypes[key])
    .map((properties) => properties.filter((prop) => prop.type === "relation"))
    .reduce((a,b) => a.concat(b))
    .filter((relationType) => relationsToExisting.indexOf(relationType.name) > -1)
    .map((relationType) => relationType.relation.targetCollection);

  const missingArchetypes = desiredArchetypes
    .filter((da) => mappedArchetypes.indexOf(da) < 0);

  return {
  	"@context": {
  		"@vocab": "http://www.w3.org/ns/r2rml#",
  		"rml": "http://semweb.mmlab.be/ns/rml#",
  		"tim": "http://timbuctoo.huygens.knaw.nl/mapping#",
      "http://www.w3.org/2000/01/rdf-schema#subClassOf": {
        "@type": "@id"
      },
  		"predicate": {
  			"@type": "@id"
  		},
      "termType": {
        "@type": "@id"
      },
      "parentTriplesMap": {
        "@type": "@id"
      },
      "class": {
        "@type": "@id"
      },
      "object": {
        "@type": "@id"
      }
  	},
  	"@graph": Object.keys(mapping.collections)
      .map(key => mapSheet(key, mapping.collections[key], vre))
      .concat(missingArchetypes.map((archetypeName) => (
        {archetypeName: archetypeName, customProperties: [], mappings: [], ignoredColumns: []}
      )).map((mapping) => mapSheet(mapping.archetypeName, mapping, vre)))
  };
}

function makeMapName(vre, localName) {
  return `http://timbuctoo.huygens.knaw.nl/mapping/${vre}/${localName}`;
}

function mapSheet(key, sheet, vre) {
  //FIXME: move logicalSource and subjectMap under the control of the server
  return {
    "@id": makeMapName(vre, key),
    "http://www.w3.org/2000/01/rdf-schema#subClassOf": `http://timbuctoo.huygens.knaw.nl/${sheet.archetypeName.replace(/s$/, "")}`,
    "rml:logicalSource": {
			"rml:source": {
				"tim:rawCollection": key,
				"tim:vreName": vre
			}
		},
    "subjectMap": {
			"template": `${makeMapName(vre, key)}/{tim_id}`
		},
    "predicateObjectMap": [
      {"object": makeMapName(vre, key), "predicate": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"}
    ].concat(sheet.mappings.map(makePredicateObjectMap.bind(null, vre)))
  };
}

function makePredicateObjectMap(vre, mapping) {
  let property = mapping.property;
  let variable = mapping.variable[0];
  let predicateNamespace = mapping.predicateNamespace || "http://timbuctoo.huygens.knaw.nl/";

  if (variable.targetCollection) {
    return {
      "objectMap": {
        "joinCondition": {
          "child": variable.variableName,
          "parent": variable.targetVariableName
        },
        "parentTriplesMap": makeMapName(vre, variable.targetCollection)
      },
      "predicate": `${predicateNamespace}${property}`
    }
  } else if (variable.targetExistingTimbuctooVre) {
    return {
      "objectMap": {
        "column": variable.variableName,
        "termType": "http://www.w3.org/ns/r2rml#IRI"
      },
      "predicate": `http://timbuctoo.huygens.knaw.nl/${property}`,
      "http://timbuctoo.huygens.knaw.nl/mapping/existingTimbuctooVre": variable.targetExistingTimbuctooVre
    }
  } else if (variable.templateName) {
    return {
      "objectMap": {
        "template": `http://timbuctoo.huygens.knaw.nl/${vre}/sheetLocal/${variable.templateName}/{${variable.variableName}}`
      },
      "predicate": "http://www.w3.org/2002/07/owl#sameAs"
    }
  } else {
    return {
      "objectMap": {
        "column": variable.variableName
      },
      "predicate": `${predicateNamespace}${property}`
    }
  }
}
