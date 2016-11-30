import http from "http";
import mappingToJsonLdRml from "./mappingToJsonLdRml";

const archetypes = {
  concepts: [],
  locations: [],
  collectives: [],
  persons: []
};

/**
 * Mappings based on 2016_10_06_BIA_Master_WERFILE_JAUCO.xlsx
 * these core mappings include the sheets:
 * - Persons    (archetype: persons)
 * - Places     (archetype: locations)
 * - Institutes (archetype: collectives)
 *
 * and maps these one to many relations:
 * - Institute locatedAt Place
 * - Person hasBirthPlace Place
 * - Person hasDeathPlace Place
 */
const mappings = {
  collections: {
    Persons: {
      archetypeName: "persons",
      mappings: [
        {
          property: "sameAs",
          variable: [ { templateName: "Persons", variableName: "persistent_id" } ]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "surname",
          variable: [{ variableName: "family_name" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "forename",
          variable: [{ variableName: "given_name" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "roleName",
          variable: [ { variableName: "preposition" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "nameLink",
          variable: [ { variableName: "intraposition" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "genName",
          variable: [ { variableName: "postposition" }]
        },
        {
          property: "gender",
          variable: [ { variableName: "gender" }]
        },
        {
          property: "birthDate",
          variable: [ { variableName: "birth_date" }]
        },
        {
          property: "hasBirthPlace",
          variable: [{
            variableName: "birth_place_persistent_id",
            targetCollection: "Places",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "deathDate",
          variable: [ { variableName: "death_date" }]
        },
        {
          property: "hasDeathPlace",
          variable: [{
            variableName: "death_place_persistent_id",
            targetCollection: "Places",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "religion",
          variable: [ { variableName: "religion" }]
        },
        {
          property: "originDb",
          variable: [ { variableName: "origin_db" }]
        },
        {
          property: "important",
          variable: [ { variableName: "important" }]
        }
      ]
    },
    Person_name_variants: {
      archetypeName: "",
      mappings: [
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "surname",
          variable: [{ variableName: "family_name" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "forename",
          variable: [{ variableName: "given_name" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "roleName",
          variable: [ { variableName: "preposition" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "nameLink",
          variable: [ { variableName: "intraposition" }]
        },
        {
          predicateNamespace: "http://www.tei-c.org/ns/1.0/",
          property: "genName",
          variable: [ { variableName: "postposition" }]
        },
        {
          property: "isNameVariantOf",
          variable: [{
            variableName: "person_persistant_id",
            targetCollection: "Persons",
            targetVariableName: "persistent_id"
          }]
        },
      ]
    },
    Institutes: {
      archetypeName: "collectives",
      mappings: [
        {
          property: "sameAs",
          variable: [ { templateName: "Institutes", variableName: "persistent_id" } ]
        },
        {
          property: "name",
          variable: [{
            variableName: "name"
          }]
        }, {
          property: "hasLocation",
          variable: [{
            variableName: "place_persistant_id",
            targetCollection: "Places",
            targetVariableName: "persistent_id"
          }]
        }
      ]
    },
    Places: {
      archetypeName: "locations",
      mappings: [
        {
          property: "sameAs",
          variable: [ { templateName: "Places", variableName: "persistent_id" } ]
        },
        {
          property: "name",
          variable: [{ variableName: "name" }]
        },
        {
          property: "country",
          variable: [{ variableName: "country" }]
        },
        {
          property: "latitude",
          variable: [{ variableName: "latitude" }]
        },
        {
          property: "longitude",
          variable: [{ variableName: "longitude" }]
        },
        {
          property: "remarks",
          variable: [{ variableName: "remarks" }]
        },
      ]
    },
    Publications: {
      archetypeName: "documents",
      mappings: [
        {
          property: "sameAs",
          variable: [ { templateName: "Publications", variableName: "persistent_id" } ]
        },
        {
          property: "typeKey",
          variable: [{ variableName: "type_key" }]
        },
        {
          property: "title",
          variable: [{ variableName: "title" }]
        },
        {
          property: "date",
          variable: [{ variableName: "year" }]
        },
        {
          property: "pageNumbers",
          variable: [{ variableName: "page_numbers" }]
        },
        {
          property: "canonicalUrl",
          variable: [{ variableName: "canonical_url" }]
        },
        {
          property: "reference",
          variable: [{ variableName: "reference" }]
        },
        {
          property: "filename",
          variable: [{ variableName: "filename" }]
        }
      ]
    },
    Person_person_relations_type: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "label",
          variable: [{ variableName: "label" }]
        }
      ]
    },
    States_type: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "label",
          variable: [{ variableName: "label" }]
        }
      ]
    },
    Data_lines_type: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "label",
          variable: [{ variableName: "label" }]
        }
      ]
    },
    Fields_of_interest: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "label",
          variable: [{ variableName: "label" }]
        }
      ]
    },
    Person_person_relations: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "hasPersonToPersonRelationType",
          variable: [{
            variableName: "type",
            targetCollection: "Person_person_relations_type",
            targetVariableName: "ID"
          }]
        },
        {
          property: "hasFirstPerson",
          variable: [{
            variableName: "first_person_persistent_id",
            targetCollection: "Persons",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "hasSecondPerson",
          variable: [{
            variableName: "second_person_persistent_id",
            targetCollection: "Persons",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "from",
          variable: [{ variableName: "datable_from" }]
        },
        {
          property: "to",
          variable: [{ variableName: "datable_to" }]
        }
      ]
    },
    States: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "hasStateType",
          variable: [{
            variableName: "type",
            targetCollection: "States_type",
            targetVariableName: "ID"
          }]
        },
        {
          property: "isStateOfPerson",
          variable: [{
            variableName: "person_persistant_id",
            targetCollection: "Persons",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "label",
          variable: [{
            variableName: "description"
          }]
        },
        {
          property: "isStateLinkedToInstitute",
          variable: [{
            variableName: "institute_persistant_id",
            targetCollection: "Institutes",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "isStateLinkedToLocation",
          variable: [{
            variableName: "place_persistant_id",
            targetCollection: "Places",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "from",
          variable: [{ variableName: "datable_from" }]
        },
        {
          property: "to",
          variable: [{ variableName: "datable_to" }]
        }
      ]
    },
    Data_lines: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "hasDataLineType",
          variable: [{
            variableName: "type",
            targetCollection: "Data_lines_type",
            targetVariableName: "ID"
          }]
        },
        {
          property: "isDataLineForPerson",
          variable: [{
            variableName: "person_persistant_id",
            targetCollection: "Persons",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "label",
          variable: [{
            variableName: "data"
          }]
        }
      ]
    },
    Scientist_bios: {
      archetypeName: "concepts",
      mappings: [
        {
          property: "isScientistBioOf",
          variable: [{
            variableName: "person_persistant_id",
            targetCollection: "Persons",
            targetVariableName: "persistent_id"
          }]
        },
        {
          property: "label",
          variable: [{
            variableName: "claim_to_fame"
          }]
        },
        {
          property: "claim_to_fame",
          variable: [{
            variableName: "claim_to_fame"
          }]
        },
        {
          property: "biography",
          variable: [{
            variableName: "biography"
          }]
        },
        {
          property: "work_years",
          variable: [{
            variableName: "work_years"
          }]
        },
        {
          property: "highest_degree",
          variable: [{
            variableName: "highest_degree"
          }]
        },
        {
          property: "dissertation_title",
          variable: [{
            variableName: "dissertation_title"
          }]
        },
        {
          property: "sources",
          variable: [{
            variableName: "sources"
          }]
        },
        {
          property: "sources_reliability",
          variable: [{
            variableName: "sources_reliability"
          }]
        },
        {
          property: "remarks",
          variable: [{
            variableName: "remarks"
          }]
        },
        ...[1,2,3,4,5,6,7,8,9,10].map((num) => (
        {
          property: "hasFieldOfInterest",
          variable: [{
            variableName: `field_of_interest_id_${num}`,
            targetCollection: "Fields_of_interest",
            targetVariableName: "ID"
          }]
        }
        ))
      ]
    }
  }
};


const vre = process.env.VRE_ID;

const rml = mappingToJsonLdRml(mappings, vre, archetypes);
const mappingDocument = {
  ...rml,
  "@graph": [
    ...rml["@graph"],
    {
      "@id": `http://timbuctoo.huygens.knaw.nl/mapping/${vre}/Authorships`,
      "rml:logicalSource": {
        "rml:source": {
          "tim:rawCollection": "Authorships",
          "tim:vreName": vre
        }
      },
      "subjectMap": {
        "template": `http://timbuctoo.huygens.knaw.nl/${vre}/sheetLocal/Publications/{publications_persistant_id}`
      },
      "predicateObjectMap": [
        {
          "objectMap": {
            "template": `http://timbuctoo.huygens.knaw.nl/${vre}/sheetLocal/Persons/{person_persistant_id}`
          },
          "predicate": "http://timbuctoo.huygens.knaw.nl/isCreatedBy"
        }
      ]
    },
    {
      "@id": `http://timbuctoo.huygens.knaw.nl/mapping/${vre}/Place_name_variants`,
      "rml:logicalSource": {
        "rml:source": {
          "tim:rawCollection": "Place_name_variants",
          "tim:vreName": vre
        }
      },
      "subjectMap": {
        "template": `http://timbuctoo.huygens.knaw.nl/${vre}/sheetLocal/Places/{place_persistent_id}`
      },
      "predicateObjectMap": [
        {
          "objectMap": {
            "column": "name"
          },
          "predicate": "http://www.w3.org/2004/02/skos/core#altLabel"
        }
      ]
    },
    {
      "@id": `http://timbuctoo.huygens.knaw.nl/mapping/${vre}/Institute_name_variants`,
      "rml:logicalSource": {
        "rml:source": {
          "tim:rawCollection": "Institute_name_variants",
          "tim:vreName": vre
        }
      },
      "subjectMap": {
        "template": `http://timbuctoo.huygens.knaw.nl/${vre}/sheetLocal/Institutes/{institute_persistant_id}`
      },
      "predicateObjectMap": [
        {
          "objectMap": {
            "column": "name"
          },
          "predicate": "http://www.w3.org/2004/02/skos/core#altLabel"
        }
      ]
    },

  ]
};



console.log("JSON LD:\n===========");
console.log(JSON.stringify(mappingDocument, null, '  '));
console.log("===========");


if (process.env.HOST && process.env.AUTH_HEADER) {
  const jsonLd = JSON.stringify(mappingDocument);
  const auth = process.env.AUTH_HEADER;
  const host = process.env.HOST;
  const port = process.env.PORT || "80";
  const httpOpts = {
    host: host,
    port: port,
    path: `/v2.1/bulk-upload/${vre}/rml/execute`,
    method: "POST",
    headers: {
      'Authorization': auth,
      'Content-type': "application/ld+json",
      'Content-length': Buffer.byteLength(jsonLd)
    }
  };

  const req = http.request(httpOpts, (response) => {
    let str = '';
    response.on('data', (chunk) => str += chunk);
    response.on('end', () => console.log(str));
  });

  req.write(jsonLd);
  req.end();
}
