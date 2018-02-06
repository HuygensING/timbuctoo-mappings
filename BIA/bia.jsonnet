local rml = import "../mapping-generator/rml.libsonnet";

local personNamesJexl = "\"{\\\"components\\\":[\" + (v.given_name != null ? \"{\\\"type\\\":\\\"FORENAME\\\",\\\"value\\\":\" + Json:stringify(v.given_name) + \"},\" : \"\") + \"{\\\"type\\\":\\\"SURNAME\\\",\\\"value\\\":\" + Json:stringify(v.family_name) + \"}\" + (v.intraposition != null ? \",{\\\"type\\\":\\\"NAME_LINK\\\", \\\"value\\\":\" + Json:stringify(v.intraposition) + \"}\" : \"\") + (v.preposition != null ? \",{\\\"type\\\":\\\"ROLE_NAME\\\", \\\"value\\\":\" + Json:stringify(v.preposition) + \"}\" : \"\") + (v.postposition != null ? \",{\\\"type\\\":\\\"GEN_NAME\\\", \\\"value\\\":\" + Json:stringify(v.postposition) + \"}\" : \"\") + \"]}\"";


rml.mappings([
  rml.mapping("bia_persons", 1,
    rml.templateSource(rml.datasetUri + "collection/Persons/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Persons"),
    {
      "http://timbuctoo.huygens.knaw.nl/static/v5/predicate/names": rml.dataField(
        rml.types.personName,
        rml.jexlSource(personNamesJexl)
      ),
      "http://schema.org/gender": rml.dataField(rml.types.string, rml.columnSource("gender")),
      "http://schema.org/birthDate": rml.dataField(rml.types.edtf, rml.columnSource("birth_date")),
      "http://schema.org/birthPlace": rml.joinField("birth_place_persistent_id", "bia_places", "persistent_id"),
      "http://schema.org/deathDate": rml.dataField(rml.types.edtf, rml.columnSource("death_date")),
      "http://schema.org/deathPlace": rml.joinField("death_place_persistent_id", "bia_places", "persistent_id"),
      [rml.customPredicate("dataSetName")]: rml.dataField(rml.types.string, rml.constantSource("BIA_Clusius")),
      "http://www.w3.org/2002/07/owl#sameAs": rml.iriField(rml.jexlSource("v['VIAF_url'] == null || empty(v['VIAF_url']) ? \"http://timbuctoo.huygens.knaw.nl/fake_viaf/2017_06_19_BIA_Clusius/\" + v['tim_id'] : v['VIAF_url']"))
    }
  ),
  rml.mapping("bia_personNameVariants", 2,
    rml.templateSource(rml.datasetUri + "collection/Persons/{person_persistant_id}"),
    rml.constantSource(rml.datasetUri + "collection/Persons"),
    {
      "http://timbuctoo.huygens.knaw.nl/static/v5/predicate/names": rml.dataField(
        rml.types.personName,
        rml.jexlSource(personNamesJexl)
      )
    }
  ),
  rml.mapping("bia_occupation", 3,
    rml.templateSource(rml.datasetUri + "collection/Occupation/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Occupation"),
    {
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      [rml.customPredicate("carriedOutBy")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      [rml.customPredicate("atInstitute")]: rml.joinField("institute_persistant_id", "bia_institutes", "persistent_id"),
      [rml.customPredicate("atPlace")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_from")),
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_to")),
    }
  ),
   rml.mapping("bia_residence", 4,
    rml.templateSource(rml.datasetUri + "collection/Residence/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Residence"),
    {
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      [rml.customPredicate("hasResident")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      [rml.customPredicate("hasLocation")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_from")),
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_to")),
    }
  ),
  rml.mapping("bia_education", 5,
    rml.templateSource(rml.datasetUri + "collection/Education/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Education"),
    {
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      [rml.customPredicate("hasStudent")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      [rml.customPredicate("atInstitute")]: rml.joinField("institute_persistant_id", "bia_institutes", "persistent_id"),
      [rml.customPredicate("atPlace")]: rml.joinField("place_persistant_id", "bia_places", "persistent_id"),
      "http://schema.org/startDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_from")),
      "http://schema.org/endDate": rml.dataField(rml.types.edtf, rml.columnSource("datable_to")),
    }
  ),
  rml.mapping("bia_biography", 6,
    rml.templateSource(rml.datasetUri + "collection/Biography/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Biography"),
    {
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      "http://schema.org/highestDegree": rml.dataField(rml.types.string, rml.columnSource("highest_degree")),
      "http://schema.org/dissertationTitle": rml.dataField(rml.types.string, rml.columnSource("dissertation_title")),
      [rml.customPredicate("isAbout")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      [rml.customPredicate("hasFieldOfInterest")]: [
        rml.joinField("field_of_interest_id_" + num, "bia_fieldOfInterest", "ID") for num in std.range(1, 10)
      ]
    }
  ),
  rml.mapping("bia_membership", 7,
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
  rml.mapping("bia_provenance", 8,
    rml.templateSource(rml.datasetUri + "collection/Provenance/{persistent_id}"),
    rml.constantSource(rml.datasetUri + "collection/Provenance"),
    {
      [rml.customPredicate("aboutPerson")]: rml.joinField("person_persistant_id", "bia_persons", "persistent_id"),
      "http://schema.org/description": rml.dataField(rml.types.string, rml.columnSource("description")),
      [rml.customPredicate("hasProvenanceType")]: rml.joinField("type", "bia_provenancetype", "ID"),
    }
  ),
  rml.mapping("bia_provenanceType", 9,
    rml.templateSource(rml.datasetUri + "collection/ProvenanceType/{ID}"),
    rml.constantSource(rml.datasetUri + "collection/ProvenanceType"),
    {
      "http://schema.org/label": rml.dataField(rml.types.string, rml.columnSource("label")),
    }
  ),
  rml.mapping("bia_fieldOfInterest", 9,
    rml.templateSource(rml.datasetUri + "collection/FieldOfInterest/{ID}"),
    rml.constantSource(rml.datasetUri + "collection/FieldOfInterest"),
    {
      "http://schema.org/label": rml.dataField(rml.types.string, rml.columnSource("label")),
    }
  ),
])