if [ -z "$1" ]; then
  echo "Please specify the timbuctoo uri as the first argument"
fi

if [ -z "$2" ]; then
  echo "Please specify the datasetname as the second argument"
fi

#FIXME: use graphql to get the dataset uri
jsonnet --ext-str dataseturi="http://example.org/dataset/$2" ./BIA/bia.jsonnet 

