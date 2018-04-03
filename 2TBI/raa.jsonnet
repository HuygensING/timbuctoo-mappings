local rml = import "../mapping-generator/rml.libsonnet";

local personNamesJexl = "\"{\\\"components\\\":[\" + (v.Voornaam != null ? \"{\\\"type\\\":\\\"FORENAME\\\",\\\"value\\\":\" + Json:stringify(v.Voornaam) + \"},\" : \"\") + \"{\\\"type\\\":\\\"SURNAME\\\",\\\"value\\\":\" + Json:stringify(v.Geslachtsnaam) + \"}\" + (v.Tussenvoegsel != null ? \",{\\\"type\\\":\\\"NAME_LINK\\\", \\\"value\\\":\" + Json:stringify(v.Tussenvoegsel) + \"}\" : \"\") + \"]}\"";

rml.mappings([
  rml.mapping("raa_persons", "RAA_toogdag2018_update.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Ambtsdrager/{RAA-ID}"),
    rml.constantSource(rml.datasetUri + "collection/Ambtsdrager"), 
    {
      "http://schema.org/identifier": rml.dataField(rml.types.string, rml.columnSource("RAA-ID")),
      "http://timbuctoo.huygens.knaw.nl/static/v5/predicate/names": rml.dataField(
        rml.types.personName,
        rml.jexlSource(personNamesJexl)
      ),
      "http://schema.org/birthDate": rml.dataField(rml.types.edtf, rml.columnSource("dateOfBirth")),
      "http://schema.org/birthPlace": rml.joinField("placeOfBirthID", "raa_places", "placeID"),
      "http://schema.org/deathDate": rml.dataField(rml.types.edtf, rml.columnSource("dateOfDeath")),
      "http://schema.org/deathPlace": rml.joinField("placeOfDeathID", "raa_places", "placeID"),
      "http://www.w3.org/2002/07/owl#sameAs": rml.iriField(rml.columnSource("bprURL")),
      "http://schema.org/url": rml.dataField(rml.types.anyURI, rml.columnSource("viafURL"))
    },      
  ),
  rml.mapping("raa_publicOfficesHeld", "RAA_toogdag2018_update.xlsx", 2,
    rml.templateSource(rml.datasetUri + "collection/PublicOfficesHeld/{officeID}"),
    rml.constantSource(rml.datasetUri + "collection/PublicOfficesHeld"), 
    {
      "http://schema.org/identifier": rml.dataField(rml.types.string, rml.columnSource("officeID")),
      [rml.customPredicate("ambtsdrager")]: rml.joinField("RAA-ID", "raa_persons", "RAA-ID"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("dateStart")),      
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("dateEnd")),      
      [rml.customPredicate("function")]: rml.dataField(rml.types.string, rml.columnSource("function")),
      [rml.customPredicate("organization")]: rml.dataField(rml.types.string, rml.columnSource("Organization")),      
    },
  ),
  rml.mapping("raa_places", "RAA_toogdag2018_update.xlsx", 3,
    rml.templateSource(rml.datasetUri + "collection/Place/{placeID}"),
    rml.constantSource(rml.datasetUri + "collection/Place"),
    {
      "http://schema.org/name": rml.dataField(rml.types.string, rml.columnSource("place")),
      "http://schema.org/identifier": rml.dataField(rml.types.string, rml.columnSource("placeId")),
    },
  )
])