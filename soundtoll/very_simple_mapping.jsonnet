local rml = import "./rml.libsonnet";

rml.mappings([
    rml.mapping("PlacesMapping", "places_standard.csv", 1,
      rml.templateSource(rml.datasetUri + "collection/Places/{id}"),
      {
        "http://schema.org/name": rml.columnSource("Kode")
      },
      rml.constantSource(rml.datasetUri + "collection/Places"),
      {
        "http://schema.org/name": rml.columnSource("Stednavn")
      },
    )
])

