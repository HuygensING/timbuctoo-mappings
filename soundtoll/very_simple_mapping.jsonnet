local rml = import "../mapping-generator/rml.libsonnet";

rml.mappings([
    rml.mapping(
	"PlacesMapping",
	"places_standard.csv",
	1,
	rml.templateSource(rml.datasetUri + "collection/Places/{persistent_id}"),
        rml.constantSource(rml.datasetUri + "collection/Places"),
	{ "http://schema.org/id": rml.dataField(rml.types.string, rml.columnSource("Kode")) ,
          "http://schema.org/name": rml.dataField(rml.types.string, rml.columnSource("Stednavn")) },
    )
])

