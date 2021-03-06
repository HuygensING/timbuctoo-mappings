local rml = import "../mapping-generator/rml.libsonnet";

local personNamesJexl = "\"{\\\"components\\\":[\" + (v.voornaam != null ? \"{\\\"type\\\":\\\"FORENAME\\\",\\\"value\\\":\" + Json:stringify(v.voornaam) + \"},\" : \"\") + \"{\\\"type\\\":\\\"SURNAME\\\",\\\"value\\\":\" + Json:stringify(v.geslachtsnaam) + \"}\" + (v.intrapositie != null ? \",{\\\"type\\\":\\\"NAME_LINK\\\", \\\"value\\\":\" + Json:stringify(v.intrapositie) + \"}\" : \"\") + (v.prepositie != null ? \",{\\\"type\\\":\\\"ROLE_NAME\\\", \\\"value\\\":\" + Json:stringify(v.prepositie) + \"}\" : \"\") + (v.postpositie != null ? \",{\\\"type\\\":\\\"GEN_NAME\\\", \\\"value\\\":\" + Json:stringify(v.postpositie) + \"}\" : \"\") + \"]}\"";

local viafJexl = "(v.VIAF_id != null ? \"http://viaf.org/viaf/\" + v.VIAF_id : null)";

local wikiDataJexl = "(v.Wikidata_id != null ? \\\"https://www.wikidata.org/wiki/\\\" + v.Wikidata_id : null)";

rml.mappings([
  rml.mapping("bioport_persons1", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Persons/{Person_id}"),
    rml.constantSource(rml.datasetUri + "collection/Persons"),
    {
      [rml.customPredicate("Bioport_id")]: rml.dataField(rml.types.string, rml.columnSource("Bioport_id")),
      [rml.customPredicate("Person_id")]: rml.dataField(rml.types.string, rml.columnSource("Person_id")),
      "http://timbuctoo.huygens.knaw.nl/static/v5/predicate/names": rml.dataField(
        rml.types.personName,
        rml.jexlSource(personNamesJexl)
      ),
      "http://schema.org/gender": rml.dataField(rml.types.string, rml.columnSource("person_sex")),
      [rml.customPredicate("viafUri")]: rml.dataField(
        rml.types.anyURI, 
        rml.jexlSource(viafJexl)
      ),
      [rml.customPredicate("wikiDataUri")]: rml.dataField(
        rml.types.anyURI, 
        rml.jexlSource(wikiDataJexl)
      ),
      "http://schema.org/birthDate": rml.dataField(rml.types.edtf, rml.columnSource("event_birth_when")),
      [rml.customPredicate("birthDateRemark")]: rml.dataField(rml.types.string, rml.columnSource("event_birth_text")),
      "http://schema.org/birthPlace": rml.joinField("event_birth_place", "bioport_birthplaces1", "event_birth_place"),
      "http://schema.org/deathDate": rml.dataField(rml.types.edtf, rml.columnSource("event_death_when")),
      [rml.customPredicate("deathDateRemark")]: rml.dataField(rml.types.string, rml.columnSource("event_death_text")),
      "http://schema.org/deathPlace": rml.joinField("event_death_place", "bioport_deathplaces1", "event_death_place"),
      [rml.customPredicate("category")]: [
        rml.joinField("category-" + num, "bioport_category1_"+num, "category-" + num) for num in std.range(1, 4)
      ],
      [rml.customPredicate("religion")]: rml.joinField("religion", "bioport_religion1", "religion"),
    }
  ),
  rml.mapping("bioport_namevariants1", "BioPort_1_13.xlsx", 2,
    rml.templateSource(rml.datasetUri + "collection/Persons/{Person_id}"),
    rml.constantSource(rml.datasetUri + "collection/Persons"),
    {
      [rml.customPredicate("Variant_id")]: rml.dataField(rml.types.string, rml.columnSource("Variant_id")),      
      [rml.customPredicate("Bioport_id")]: rml.dataField(rml.types.string, rml.columnSource("Bioport_id")),
      [rml.customPredicate("Person_id")]: rml.dataField(rml.types.string, rml.columnSource("Person_id")),
      "http://timbuctoo.huygens.knaw.nl/static/v5/predicate/names": rml.dataField(
        rml.types.personName,
        rml.jexlSource(personNamesJexl)
      ),
    }
  ),
  rml.mapping("bioport_birthplaces1", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Places/{event_birth_place}"),
    rml.constantSource(rml.datasetUri + "collection/Places"),
    {
      [rml.customPredicate("name")]: rml.dataField(rml.types.string, rml.columnSource("event_birth_place")),      
    },
  ),
  rml.mapping("bioport_deathplaces1", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Places/{event_death_place}"),
    rml.constantSource(rml.datasetUri + "collection/Places"),
    {
      [rml.customPredicate("name")]: rml.dataField(rml.types.string, rml.columnSource("event_death_place")),      
    },
  ),
  rml.mapping("bioport_category1_1", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Category/{category-1}"),
    rml.constantSource(rml.datasetUri + "collection/Category"),
    {
      [rml.customPredicate("label")]: rml.dataField(rml.types.string, rml.columnSource("category-1")),      
    },
  ),
  rml.mapping("bioport_category1_2", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Category/{category-2}"),
    rml.constantSource(rml.datasetUri + "collection/Category"),
    {
      [rml.customPredicate("label")]: rml.dataField(rml.types.string, rml.columnSource("category-2")),      
    },
  ),
  rml.mapping("bioport_category1_3", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Category/{category-3}"),
    rml.constantSource(rml.datasetUri + "collection/Category"),
    {
      [rml.customPredicate("label")]: rml.dataField(rml.types.string, rml.columnSource("category-3")),      
    },
  ),
  rml.mapping("bioport_category1_4", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Category/{category-4}"),
    rml.constantSource(rml.datasetUri + "collection/Category"),
    {
      [rml.customPredicate("label")]: rml.dataField(rml.types.string, rml.columnSource("category-4")),      
    },
  ),
  rml.mapping("bioport_religion1", "BioPort_1_13.xlsx", 1,
    rml.templateSource(rml.datasetUri + "collection/Religion/{religion}"),
    rml.constantSource(rml.datasetUri + "collection/Religion"),
    {
      [rml.customPredicate("name")]: rml.dataField(rml.types.string, rml.columnSource("religion")),      
    },
  ),
])

