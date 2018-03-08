local rml = import "../mapping-generator/rml.libsonnet";

local personNamesJexl = "\"{\\\"components\\\":[\" + (v.voornaam != null ? \"{\\\"type\\\":\\\"FORENAME\\\",\\\"value\\\":\" + Json:stringify(v.voornaam) + \"},\" : \"\") + \"{\\\"type\\\":\\\"SURNAME\\\",\\\"value\\\":\" + Json:stringify(v.geslachtsnaam) + \"}\" + (v.intrapositie != null ? \",{\\\"type\\\":\\\"NAME_LINK\\\", \\\"value\\\":\" + Json:stringify(v.intrapositie) + \"}\" : \"\") + (v.prepositie != null ? \",{\\\"type\\\":\\\"ROLE_NAME\\\", \\\"value\\\":\" + Json:stringify(v.prepositie) + \"}\" : \"\") + (v.postpositie != null ? \",{\\\"type\\\":\\\"GEN_NAME\\\", \\\"value\\\":\" + Json:stringify(v.postpositie) + \"}\" : \"\") + \"]}\"";

local viafJexl = "(v.VIAF_id != null ? \"http://viaf.org/viaf/\" + v.VIAF_id : null)";

local wikiDataJexl = "(v.Wikidata_id != null ? \"https://www.wikidata.org/wiki/\" + v.Wikidata_id : null)";

rml.mappings(std.flattenArrays([
    [rml.mapping("bioport_persons" + file, "BioPort_"+ file +"_13.xlsx", 1,
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
        "http://schema.org/birthPlace": rml.dataField(rml.types.string, rml.columnSource("event_birth_place")),
        "http://schema.org/deathDate": rml.dataField(rml.types.edtf, rml.columnSource("event_death_when")),
        [rml.customPredicate("deathDateRemark")]: rml.dataField(rml.types.string, rml.columnSource("event_death_text")),
        "http://schema.org/deathPlace": rml.dataField(rml.types.string, rml.columnSource("event_death_place")),
        [rml.customPredicate("funeralPlace")]: rml.dataField(rml.types.string, (if file == 12 then rml.columnSource("event_funeral_place") else rml.constantSource("") )),
        [rml.customPredicate("category")]: [
          rml.dataField(rml.types.string, rml.columnSource("category-" + num)) for num in std.range(1, 4)
        ],
        [rml.customPredicate("religion")]: rml.dataField(rml.types.string, rml.columnSource("religion")),
      }
    ),
    rml.mapping("bioport_namevariants" + file, "BioPort_" + file + "_13.xlsx", 2,
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
    )
  ] for file in std.range(1, 13)
]))

