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
          property: "familyName",
          variable: [{ variableName: "family_name" }]
        },
        {
          property: "givenName",
          variable: [{ variableName: "given_name" }]
        },
        {
          property: "preposition",
          variable: [ { variableName: "preposition" }]
        },
        {
          property: "intraposition",
          variable: [ { variableName: "intraposition" }]
        },
        {
          property: "postposition",
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
    Institutes: {
      archetypeName: "collectives",
      mappings: [
        {
          property: "name",
          variable: [{
            variableName: "name"
          }]
        }, {
          property: "locatedAt",
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
          property: "documentType",
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
      "@id": `http://timbuctoo.com/mapping/${vre}/Authorships`,
      "rml:logicalSource": {
        "rml:source": {
          "tim:rawCollection": "Authorships",
          "tim:vreName": vre
        }
      },
      "subjectMap": {
        "template": `http://timbuctoo.com/${vre}/sheetLocal/Publications/{publications_persistant_id}`
      },
      "predicateObjectMap": [
        {
          "objectMap": {
            "template": `http://timbuctoo.com/${vre}/sheetLocal/Persons/{person_persistant_id}`
          },
          "predicate": "http://timbuctoo.com/isCreatedBy"
        }
      ]
    }
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
