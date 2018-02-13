local rml = import "../mapping-generator/rml.libsonnet";

rml.mappings([
    rml.mapping(
	"DoorvaartenMapping",
	"doorvaarten.csv",
	1,
	rml.templateSource(rml.datasetUri + "collection/soundtoll/{persistant_id}"),
        rml.constantSource(rml.datasetUri + "collection/soundtoll"),
	{
          "http://schema.org/id_doorvaart": rml.dataField(rml.types.string, rml.columnSource("id_doorvaart")) ,
          "http://schema.org/dag": rml.dataField(rml.types.string, rml.columnSource("dag")) ,
          "http://schema.org/maand": rml.dataField(rml.types.string, rml.columnSource("maand")) ,
          "http://schema.org/jaar": rml.dataField(rml.types.string, rml.columnSource("jaar")) ,
          "http://schema.org/volgnummer": rml.dataField(rml.types.string, rml.columnSource("volgnummer")) ,
          "http://schema.org/schipper_voornamen": rml.dataField(rml.types.string, rml.columnSource("schipper_voornamen")) ,
          "http://schema.org/schipper_patroniem": rml.dataField(rml.types.string, rml.columnSource("schipper_patroniem")) ,
          "http://schema.org/schipper_tussenvoegsel": rml.dataField(rml.types.string, rml.columnSource("schipper_tussenvoegsel")) ,
          "http://schema.org/schipper_achternaam": rml.dataField(rml.types.string, rml.columnSource("schipper_achternaam")) ,
          "http://schema.org/schipper_plaatsnaam": rml.dataField(rml.types.string, rml.columnSource("schipper_plaatsnaam")) ,
          "http://schema.org/soort_korting": rml.dataField(rml.types.string, rml.columnSource("soort_korting")) ,
          "http://schema.org/korting_muntsoort1": rml.dataField(rml.types.string, rml.columnSource("korting_muntsoort1")) ,
          "http://schema.org/korting_bedrag1": rml.dataField(rml.types.string, rml.columnSource("korting_bedrag1")) ,
          "http://schema.org/korting_muntsoort2": rml.dataField(rml.types.string, rml.columnSource("korting_muntsoort2")) ,
          "http://schema.org/korting_bedrag2": rml.dataField(rml.types.string, rml.columnSource("korting_bedrag2")) ,
          "http://schema.org/korting_muntsoort3": rml.dataField(rml.types.string, rml.columnSource("korting_muntsoort3")) ,
          "http://schema.org/korting_bedrag3": rml.dataField(rml.types.string, rml.columnSource("korting_bedrag3")) ,
          "http://schema.org/subtotaal1_muntsoort1": rml.dataField(rml.types.string, rml.columnSource("subtotaal1_muntsoort1")) ,
          "http://schema.org/subtotaal1_bedrag1": rml.dataField(rml.types.string, rml.columnSource("subtotaal1_bedrag1")) ,
          "http://schema.org/subtotaal1_muntsoort2": rml.dataField(rml.types.string, rml.columnSource("subtotaal1_muntsoort2")) ,
          "http://schema.org/subtotaal1_bedrag2": rml.dataField(rml.types.string, rml.columnSource("subtotaal1_bedrag2")) ,
          "http://schema.org/subtotaal1_muntsoort3": rml.dataField(rml.types.string, rml.columnSource("subtotaal1_muntsoort3")) ,
          "http://schema.org/subtotaal1_bedrag3": rml.dataField(rml.types.string, rml.columnSource("subtotaal1_bedrag3")) ,
          "http://schema.org/subtotaal2_muntsoort1": rml.dataField(rml.types.string, rml.columnSource("subtotaal2_muntsoort1")) ,
          "http://schema.org/subtotaal2_bedrag1": rml.dataField(rml.types.string, rml.columnSource("subtotaal2_bedrag1")) ,
          "http://schema.org/subtotaal2_muntsoort2": rml.dataField(rml.types.string, rml.columnSource("subtotaal2_muntsoort2")) ,
          "http://schema.org/subtotaal2_bedrag2": rml.dataField(rml.types.string, rml.columnSource("subtotaal2_bedrag2")) ,
          "http://schema.org/subtotaal2_muntsoort3": rml.dataField(rml.types.string, rml.columnSource("subtotaal2_muntsoort3")) ,
          "http://schema.org/subtotaal2_bedrag3": rml.dataField(rml.types.string, rml.columnSource("subtotaal2_bedrag3")) ,
          "http://schema.org/totaal_muntsoort1": rml.dataField(rml.types.string, rml.columnSource("totaal_muntsoort1")) ,
          "http://schema.org/totaal_bedrag1": rml.dataField(rml.types.string, rml.columnSource("totaal_bedrag1")) ,
          "http://schema.org/totaal_muntsoort2": rml.dataField(rml.types.string, rml.columnSource("totaal_muntsoort2")) ,
          "http://schema.org/totaal_bedrag2": rml.dataField(rml.types.string, rml.columnSource("totaal_bedrag2")) ,
          "http://schema.org/totaal_muntsoort3": rml.dataField(rml.types.string, rml.columnSource("totaal_muntsoort3")) ,
          "http://schema.org/totaal_bedrag3": rml.dataField(rml.types.string, rml.columnSource("totaal_bedrag3")) ,
          "http://schema.org/totaal_muntsoort4": rml.dataField(rml.types.string, rml.columnSource("totaal_muntsoort4")) ,
          "http://schema.org/totaal_bedrag4": rml.dataField(rml.types.string, rml.columnSource("totaal_bedrag4")) ,
          "http://schema.org/totaal_muntsoort5": rml.dataField(rml.types.string, rml.columnSource("totaal_muntsoort5")) ,
          "http://schema.org/totaal_bedrag5": rml.dataField(rml.types.string, rml.columnSource("totaal_bedrag5")) ,
          "http://schema.org/privilege": rml.dataField(rml.types.string, rml.columnSource("privilege")) ,
          "http://schema.org/opmerking_bron": rml.dataField(rml.types.string, rml.columnSource("opmerking_bron")) ,
          "http://schema.org/opmerking_invoerder": rml.dataField(rml.types.string, rml.columnSource("opmerking_invoerder")) ,
          "http://schema.org/naam_invoerder": rml.dataField(rml.types.string, rml.columnSource("naam_invoerder")) ,
          "http://schema.org/datum_opgevoerd": rml.dataField(rml.types.string, rml.columnSource("datum_opgevoerd")) ,
          "http://schema.org/dirnummer": rml.dataField(rml.types.string, rml.columnSource("dirnummer")) ,
          "http://schema.org/tonnage": rml.dataField(rml.types.string, rml.columnSource("tonnage")) ,
          "http://schema.org/belasting_korting": rml.dataField(rml.types.string, rml.columnSource("belasting_korting")) ,
          "http://schema.org/hulp": rml.dataField(rml.types.string, rml.columnSource("hulp")) ,
          "http://schema.org/hulp1": rml.dataField(rml.types.string, rml.columnSource("hulp1")) ,
          "http://schema.org/hulp2": rml.dataField(rml.types.string, rml.columnSource("hulp2")) ,
        }),
    rml.mapping(
	"BelastingenMapping",
	"belastingen.csv",
	1,
	rml.templateSource(rml.datasetUri + "collection/soundtoll/{persistant_id}"),
        rml.constantSource(rml.datasetUri + "collection/soundtoll"),
	{
          "http://schema.org/id_doorvaart": rml.dataField(rml.types.string, rml.columnSource("id_doorvaart")) ,
          "http://schema.org/regel": rml.dataField(rml.types.string, rml.columnSource("regel")) ,
          "http://schema.org/naam": rml.dataField(rml.types.string, rml.columnSource("naam")) ,
          "http://schema.org/muntsoort1": rml.dataField(rml.types.string, rml.columnSource("muntsoort1")) ,
          "http://schema.org/bedrag1": rml.dataField(rml.types.string, rml.columnSource("bedrag1")) ,
          "http://schema.org/muntsoort2": rml.dataField(rml.types.string, rml.columnSource("muntsoort2")) ,
          "http://schema.org/bedrag2": rml.dataField(rml.types.string, rml.columnSource("bedrag2")) ,
          "http://schema.org/muntsoort3": rml.dataField(rml.types.string, rml.columnSource("muntsoort3")) ,
          "http://schema.org/bedrag3": rml.dataField(rml.types.string, rml.columnSource("bedrag3")) ,
          "http://schema.org/korting": rml.dataField(rml.types.string, rml.columnSource("korting")) ,
          "http://schema.org/hulp": rml.dataField(rml.types.string, rml.columnSource("hulp")) ,
        }),
    rml.mapping(
	"LadingenMapping",
	"ladingen.csv",
	1,
	rml.templateSource(rml.datasetUri + "collection/soundtoll/{persistant_id}"),
        rml.constantSource(rml.datasetUri + "collection/soundtoll"),
	{
          "http://schema.org/id_doorvaart": rml.dataField(rml.types.string, rml.columnSource("id_doorvaart")) ,
          "http://schema.org/regel": rml.dataField(rml.types.string, rml.columnSource("regel")) ,
          "http://schema.org/van": rml.dataField(rml.types.string, rml.columnSource("van")) ,
          "http://schema.org/naar": rml.dataField(rml.types.string, rml.columnSource("naar")) ,
          "http://schema.org/maat": rml.dataField(rml.types.string, rml.columnSource("maat")) ,
          "http://schema.org/aantal": rml.dataField(rml.types.string, rml.columnSource("aantal")) ,
          "http://schema.org/soort": rml.dataField(rml.types.string, rml.columnSource("soort")) ,
          "http://schema.org/muntsoort1": rml.dataField(rml.types.string, rml.columnSource("muntsoort1")) ,
          "http://schema.org/bedrag1": rml.dataField(rml.types.string, rml.columnSource("bedrag1")) ,
          "http://schema.org/muntsoort2": rml.dataField(rml.types.string, rml.columnSource("muntsoort2")) ,
          "http://schema.org/bedrag2": rml.dataField(rml.types.string, rml.columnSource("bedrag2")) ,
          "http://schema.org/muntsoort3": rml.dataField(rml.types.string, rml.columnSource("muntsoort3")) ,
          "http://schema.org/bedrag3": rml.dataField(rml.types.string, rml.columnSource("bedrag3")) ,
          "http://schema.org/maat_alt": rml.dataField(rml.types.string, rml.columnSource("maat_alt")) ,
          "http://schema.org/aantal_alt": rml.dataField(rml.types.string, rml.columnSource("aantal_alt")) ,
          "http://schema.org/hulp": rml.dataField(rml.types.string, rml.columnSource("hulp")) ,
        }),
    rml.mapping(
	"PlacesSourceMapping",
	"places_source.csv",
	1,
	rml.templateSource(rml.datasetUri + "collection/soundtoll/{persistant_id}"),
        rml.constantSource(rml.datasetUri + "collection/soundtoll"),
	{
          "http://schema.org/vnr": rml.dataField(rml.types.string, rml.columnSource("vnr")) ,
          "http://schema.org/place": rml.dataField(rml.types.string, rml.columnSource("place")) ,
          "http://schema.org/soundcoding_(is_Kode_in_places_standard)": rml.dataField(rml.types.string, rml.columnSource("soundcoding_(is_Kode_in_places_standard)")) ,
          "http://schema.org/opm": rml.dataField(rml.types.string, rml.columnSource("opm")) ,
          "http://schema.org/HP": rml.dataField(rml.types.string, rml.columnSource("HP")) ,
          "http://schema.org/secundair": rml.dataField(rml.types.string, rml.columnSource("secundair")) ,
        }),
    rml.mapping(
	"ImagesMapping",
	"images.csv",
	1,
	rml.templateSource(rml.datasetUri + "collection/soundtoll/{persistant_id}"),
        rml.constantSource(rml.datasetUri + "collection/soundtoll"),
	{
          "http://schema.org/id_doorvaart": rml.dataField(rml.types.string, rml.columnSource("id_doorvaart")) ,
          "http://schema.org/bestandsnaam": rml.dataField(rml.types.string, rml.columnSource("bestandsnaam")) ,
          "http://schema.org/volgnummer": rml.dataField(rml.types.string, rml.columnSource("volgnummer")) ,
          "http://schema.org/hulp": rml.dataField(rml.types.string, rml.columnSource("hulp")) ,
          "http://schema.org/opmerkingen": rml.dataField(rml.types.string, rml.columnSource("opmerkingen")) ,
        }),
    rml.mapping(
	"PlacesStandardMapping",
	"places_standard.csv",
	1,
	rml.templateSource(rml.datasetUri + "collection/soundtoll/{persistant_id}"),
        rml.constantSource(rml.datasetUri + "collection/soundtoll"),
	{
          "http://schema.org/Kode": rml.dataField(rml.types.string, rml.columnSource("Kode")) ,
          "http://schema.org/Stednavn": rml.dataField(rml.types.string, rml.columnSource("Stednavn")) ,
          "http://schema.org/region": rml.dataField(rml.types.string, rml.columnSource("region")) ,
          "http://schema.org/big_category_code": rml.dataField(rml.types.string, rml.columnSource("big_category_code")) ,
          "http://schema.org/big_category": rml.dataField(rml.types.string, rml.columnSource("big_category")) ,
          "http://schema.org/small_category_code": rml.dataField(rml.types.string, rml.columnSource("small_category_code")) ,
          "http://schema.org/small_category": rml.dataField(rml.types.string, rml.columnSource("small_category")) ,
          "http://schema.org/west_of_Helsingør": rml.dataField(rml.types.string, rml.columnSource("west_of_Helsingør")) ,
          "http://schema.org/decLatitude": rml.dataField(rml.types.string, rml.columnSource("decLatitude")) ,
          "http://schema.org/decLongitude": rml.dataField(rml.types.string, rml.columnSource("decLongitude")) ,
          "http://schema.org/Modern_Country": rml.dataField(rml.types.string, rml.columnSource("Modern_Country")) ,
          "http://schema.org/Modern_name": rml.dataField(rml.types.string, rml.columnSource("Modern_name")) ,
          "http://schema.org/Province": rml.dataField(rml.types.string, rml.columnSource("Province")) ,
          "http://schema.org/Remark": rml.dataField(rml.types.string, rml.columnSource("Remark")) ,
          "http://schema.org/Zoom": rml.dataField(rml.types.string, rml.columnSource("Zoom")) ,
        }),
])