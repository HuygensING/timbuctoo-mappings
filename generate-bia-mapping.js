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
    }
  }
};

function extendMappings() {
  if (process.env.EXTENDED_MAPPINGS !== "true") { return mappings; }
  else {
    return {
      collections: {
        ...mappings.collections,
        Persons: {
          ...mappings.collections.Persons,
          mappings: [
            ...mappings.collections.Persons.mappings,
            {
              property: "createdBy",
              variable: [{
                variableName: "creator_id",
                targetCollection: "Users",
                targetVariableName: "id"
              }]
            },
            {
              property: "modifiedBy",
              variable: [{
                variableName: "modifier_id",
                targetCollection: "Users",
                targetVariableName: "id"
              }]
            }
          ]
        },
        Users: {
          archetypeName: "concepts",
          mappings: [
            {
              property: "name",
              variable: [{ variableName: "name"}]
            },
            {
              property: "email",
              variable: [{variableName: "email"}]
            },
            {
              property: "role",
              variable: [{variableName: "rolestring"}]
            }
          ]
        }
      }
    }
  }
}

const vre = process.env.VRE_ID;

const jsonLd = JSON.stringify(mappingToJsonLdRml(extendMappings(), vre, archetypes));

console.log("JSON LD:\n===========");
console.log(JSON.stringify(JSON.parse(jsonLd), null, '  '));
console.log("===========");


if (process.env.HOST && process.env.AUTH_HEADER) {
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
