
def header
    output =<<EOT
local rml = import "../mapping-generator/rml.libsonnet";

rml.mappings([
EOT
    output
end

def footer
    "])"
end

def table_header mapping_name,file_name,collection,table_names,number
    table_name = table_names.first
    output =<<EOT
    rml.mapping(
	"#{mapping_name}",
	"#{file_name}",
	#{number},
	rml.templateSource(rml.datasetUri + "collection/#{collection}/{persistant_id}"),
        rml.constantSource(rml.datasetUri + "collection/#{collection}"),
	{
EOT
    output
end

def table_content column_names
    column_name = column_names.first
    output =<<EOT
          "http://schema.org/#{column_name}": rml.dataField(rml.types.string, rml.columnSource("#{column_name}")) ,
EOT
    output
end

def table_footer
    "        }),"
end

def handle_columns table_names,columns,tim_id,collection
    table_name = table_names.first
    
    res = ""
    table_name.split('_').each do |match|
	res += match.capitalize
    end
    mapping_name = "#{res}Mapping"
    STDERR.puts res

    file_name = "#{table_name}.csv"

    puts table_header(mapping_name,file_name,collection,table_names,tim_id)

    columns.each_with_index do |column_names,index|
	puts table_content(column_names)
    end

    puts table_footer
end

if __FILE__ == $0

    collection = "soundtoll"
    file_in = "tabellen.txt"

    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    # voeg start en stop tags toe
	    when '-i' then file_in = ARGV[i+1]
	    when '-c' then collection = ARGV[i+1]
	    when '-h' then
		begin
		    STDERR.puts "use: ruby conver_table -i inputfile -c collection"
		    exit(0)
		end
	    end
    end

    puts header

    table = Array.new
    columns = Array.new

    tim_id = 1

    File.open(file_in) do |file|
	begin
	while line = file.gets
	    line.strip!
	    if !line.empty?
		if line.match(/^-/)
		    columns << line[2..-1].split
		else
		    if !columns.empty?
			handle_columns table,columns,tim_id,collection
			tim_id += 1
		    end
		    table = line.split(' ')
		    columns = Array.new
		end
	    end
	end
	rescue => all 
	    STDERR.puts all
	end
    end
    handle_columns table,columns,tim_id,collection if !columns.empty?
    puts footer
end

