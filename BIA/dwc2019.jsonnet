local rml = import "../mapping-generator/rml.libsonnet";

local personNamesJexl = "\"{\\\"components\\\":[\" + (v.given_name != null ? \"{\\\"type\\\":\\\"FORENAME\\\",\\\"value\\\":\" + Json:stringify(v.given_name) + \"},\" : \"\") + \"{\\\"type\\\":\\\"SURNAME\\\",\\\"value\\\":\" + Json:stringify(v.family_name) + \"}\" + (v.intraposition != null ? \",{\\\"type\\\":\\\"NAME_LINK\\\", \\\"value\\\":\" + Json:stringify(v.intraposition) + \"}\" : \"\") + (v.preposition != null ? \",{\\\"type\\\":\\\"ROLE_NAME\\\", \\\"value\\\":\" + Json:stringify(v.preposition) + \"}\" : \"\") + (v.postposition != null ? \",{\\\"type\\\":\\\"GEN_NAME\\\", \\\"value\\\":\" + Json:stringify(v.postposition) + \"}\" : \"\") + \"]}\"";


rml.mappings([
  rml.mapping("bia_persons", "2019_11_26_DWC_timbuctoo_upload.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Persons/{persistent_id}"),
    rml.constantSource("http://schema.org/Person"),
    {
      "https://w3id.org/pnv/givenName": rml.dataField(rml.types.string, rml.columnSource("given_name")),
      "https://w3id.org/pnv/surnamePrefix": rml.dataField(rml.types.string, rml.columnSource("intraposition")),
      "https://w3id.org/pnv/infixTitle": rml.dataField(rml.types.string, rml.columnSource("pnv_infixTitle")),
      "https://w3id.org/pnv/surname": rml.dataField(rml.types.string, rml.columnSource("family_name")),
      "https://w3id.org/pnv/patronym": rml.dataField(rml.types.string, rml.columnSource("postposition")),
      "https://w3id.org/pnv/literalName": rml.dataField(rml.types.string, rml.columnSource("full_name")),
      "http://schema.org/gender": rml.dataField(rml.types.string, rml.columnSource("gender")),
      "http://schema.org/birthDate": rml.dataField(rml.types.edtf, rml.columnSource("birth_date")),
      [rml.customPredicate("birthDateRemark")]: rml.dataField(rml.types.string, rml.columnSource("birth_date_remark")),
      "http://schema.org/birthPlace": rml.joinField("birth_place_persistent_id", "bia_places", "persistent_id"),
      "http://schema.org/deathDate": rml.dataField(rml.types.edtf, rml.columnSource("death_date")),
      [rml.customPredicate("deathDateRemark")]: rml.dataField(rml.types.string, rml.columnSource("death_date_remark")),
      "http://schema.org/deathPlace": rml.joinField("death_place_persistent_id", "bia_places", "persistent_id"),
      "http://www.w3.org/2002/07/owl#sameAs": [rml.iriField(rml.jexlSource("v['VIAF_url'] == null || empty(v['VIAF_url']) ? \"http://timbuctoo.huygens.knaw.nl/fake_viaf/2017_06_19_BIA_Clusius/\" + v['tim_id'] : v['VIAF_url']")), 
      rml.iriField(rml.jexlSource("v['wikidata_id'] == null || empty(v['wikidata_id']) ? \"http://timbuctoo.huygens.knaw.nl/fake_wikidata/2017_06_19_BIA_Clusius/\" + v['tim_id']: \"https://www.wikidata.org/wiki/\" + v['wikidata_id']"))],
    }
  ),
  rml.mapping("bia_personNameVariants", "2019_11_26_DWC_timbuctoo_upload.xlsx", 2,
    rml.templateSource(rml.datasetUri + "collection/Persons/{person_persistant_id}"),
    rml.constantSource("http://schema.org/Person"),
    {
      "https://w3id.org/pnv/givenName": rml.dataField(rml.types.string, rml.columnSource("given_name")),
      "https://w3id.org/pnv/surnamePrefix": rml.dataField(rml.types.string, rml.columnSource("intraposition")),
      "https://w3id.org/pnv/infixTitle": rml.dataField(rml.types.string, rml.columnSource("pnv_infixTitle")),
      "https://w3id.org/pnv/surname": rml.dataField(rml.types.string, rml.columnSource("family_name")),
      "https://w3id.org/pnv/patronym": rml.dataField(rml.types.string, rml.columnSource("postposition")),
      "https://w3id.org/pnv/literalName": rml.dataField(rml.types.string, rml.columnSource("full_name")),
    }
  ),
  rml.mapping("bia_occupation", "2019_11_26_DWC_timbuctoo_upload.xlsx", 3,
    rml.templateSource(rml.datasetUri + "collection/Occupation/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Occupation"),
    {
      [rml.customPredicate("carriedOutBy")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      [rml.customPredicate("atInstitute")]: rml.joinField("institute_persistant_id", "bia_institutes", "persistent_id"),
      [rml.customPredicate("atPlace")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_from")),
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_to")),
    }
  ),
   rml.mapping("bia_residence", "2019_11_26_DWC_timbuctoo_upload.xlsx", 4,
    rml.templateSource(rml.datasetUri + "collection/Residence/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Residence"),
    {
      [rml.customPredicate("hasResident")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      [rml.customPredicate("hasLocation")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_from")),
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_to")),
    }
  ),
  rml.mapping("bia_education", "2019_11_26_DWC_timbuctoo_upload.xlsx", 5,
    rml.templateSource(rml.datasetUri + "collection/Education/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Education"),
    {
      [rml.customPredicate("hasStudent")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      [rml.customPredicate("atInstitute")]: rml.joinField("institute_persistant_id", "bia_institutes", "persistent_id"),
      [rml.customPredicate("atPlace")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_from")),
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_to")),
    }
  ),
  rml.mapping("bia_biography", "2019_11_26_DWC_timbuctoo_upload.xlsx", 6,
    rml.templateSource(rml.datasetUri + "collection/Biography/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Biography"),
    {
      [rml.customPredicate("isAbout")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      "http://schema.org/highestDegree": rml.dataField(rml.types.string, rml.columnSource("highest_degree")),
      "http://schema.org/dissertationTitle": rml.dataField(rml.types.string, rml.columnSource("dissertation_title")),
      [rml.customPredicate("hasFieldOfInterest")]: [
        rml.dataField(rml.types.string, rml.columnSource("field_of_interest_id_" + num)) for num in std.range(1, 10)
      ]
    }
  ),
  rml.mapping("bia_membership", "2019_11_26_DWC_timbuctoo_upload.xlsx", 7,
    rml.templateSource(rml.datasetUri + "collection/Membership/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Membership"),
    {
      [rml.customPredicate("hasMember")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      [rml.customPredicate("hasInstitute")]: rml.joinField("institute_persistant_id", "bia_institutes", "persistent_id"),
      [rml.customPredicate("hasLocation")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_from")),
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_to")),
    }
  ),
  rml.mapping("bia_provenance", "2019_11_26_DWC_timbuctoo_upload.xlsx", 8,
    rml.templateSource(rml.datasetUri + "collection/Provenance/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Provenance"),
    {
      [rml.customPredicate("aboutPerson")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description"))
    }
  ),
  rml.mapping("bia_places", "2019_11_26_DWC_timbuctoo_upload.xlsx", 9, 
    rml.templateSource(rml.datasetUri + "collection/Place/{persistent_id}"),
    rml.constantSource("https://schema.org/Place"),
    {
      "https://schema.org/name": rml.dataField(rml.types.string, rml.columnSource("name")),
      [rml.customPredicate("country")]: rml.dataField(rml.types.string, rml.columnSource("country")),
      [rml.customPredicate("countryCode")]: rml.dataField(rml.types.string, rml.columnSource("countryCode")),
      "https://schema.org/latitude": rml.dataField(rml.types.decimal, rml.columnSource("Latitude")),
      "https://schema.org/longitude": rml.dataField(rml.types.decimal, rml.columnSource("Longitude")),
      "http://www.w3.org/2002/07/owl#sameAs": [rml.iriField(rml.columnSource("GeoNames_uri")), rml.iriField(rml.columnSource("GeoNames_rdf"))],
      [rml.customPredicate("remarks")]: rml.dataField(rml.types.string, rml.columnSource("remarks")),
    },
  ),
  rml.mapping("bia_institutes", "2019_11_26_DWC_timbuctoo_upload.xlsx", 10,
    rml.templateSource(rml.datasetUri + "collection/Institutes/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Institutes"),
    {
      "https://schema.org/name": rml.dataField(rml.types.string, rml.columnSource("name")),
      [rml.customPredicate("hasLocation")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
    },
  ),
   rml.mapping("bia_institutes_name_variants", "2019_11_26_DWC_timbuctoo_upload.xlsx", 11,
    rml.templateSource(rml.datasetUri + "collection/Institutes/{institute_persistant_id}"),
    rml.constantSource(rml.datasetUri + "collection/Institutes"),
    {
      "https://schema.org/alternateName": rml.dataField(rml.types.string, rml.columnSource("name")),
    },
  )
])