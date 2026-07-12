extends Node
class_name ART2Wiki
# The Abnormals Registry Tag to Wikitext Converter.

signal reported(text:String,log_level:int)

enum TagListItemTypes {
	INVALID = -1,
	STRING = 0,
	DICTIONARY = 1,
}

@export var mod_id: String
@export var middle_dir: String
@export var tag_folder_path: String = ""
@export var output_path: String = ""
@export var include_debug_logs: bool = false

var wiki_output: String = ""
var current_log: String = ""

@onready var logger = $FileLogger


func check_names() -> bool:
	# Make an expression for name checking
	var regex = RegEx.new()
	regex.compile("[^a-z0-9_\\-./:]")
	# Lowercase the names
	mod_id = mod_id.to_lower()
	middle_dir = middle_dir.to_lower()
	var result_mod = regex.search(mod_id)
	var result_middle_dir = regex.search(middle_dir)
	# Check if the mod id string has illegal characters.
	if result_mod:
		logger.log_error("Illegal character found in Mod ID: \"{err}\" ".format({"err":result_mod.get_string()}))
		_report(2)
		return false
	# If the string is empty, set it to "minecraft".
	elif mod_id.length() == 0:
		mod_id = "minecraft"
		logger.log_info("Mod id found empty. Defaulting to \"minecraft\"")
	
	else: 
		pass
	# Clear out "directory characters", as those are better
	# used for the middle directory string.
	mod_id = mod_id.remove_chars("./:")
	# Add the colon to the string, as it's part of the resource path. 
	mod_id += ":"
	
	# Check if middle directory string contains illegal characters.
	if result_middle_dir:
		logger.log_error("Illegal character found in middle directory: \"{err}\"".format({"err":result_middle_dir.get_string()}))
		_report(2)
		return false
	
	# Additional checks, as leaving the text empty is optional.
	elif middle_dir.length() != 0:
		if middle_dir.begins_with("/"):
			logger.log_error("Middle directory cannot begin with \"/\" ")
			_report(2)
			return false
		middle_dir = middle_dir.simplify_path()
		# Adding forward slash at the end, in the case 
		# it gets removed by simplify_path().
		middle_dir += "/"
	
	return true


func convert_tag_files(path:String):
	wiki_output = ""
	# Get all files within a directory, then filters the list to
	# only contain json files. 
	var all_files: PackedStringArray = DirAccess.get_files_at(path)
	var json_files := Array(all_files).filter(
		func(f:String): return f.get_extension() == "json"
	)
	
	for file in json_files:
		# Load the JSON from the file
		var file_path : String = (path + "\\" + file)
		var tag_name: String = file.trim_suffix(".json")
		var tag_heading := middle_dir+tag_name
		var tag_identifier := mod_id+middle_dir+tag_name
		var parsed_data = load_json_from_file(file_path)
		if parsed_data == null:
			logger.log_error("Failed to load or parse data")
			return
		# Check if the file has the values key.
		if parsed_data.has("values") == false:
			logger.log_error("{file_path} missing key \"values\". Skipping file.".format({"file_path":file_path}))
			continue
			
		var get_values : Array = parsed_data.get("values", [])
		var list_item_count :int = 0
		wiki_output += "==={tag_heading}===\n".format({"tag_heading":tag_heading})
		wiki_output += "REPLACE_DESCRIPTION_PLACEHOLDER<br>\n"
		wiki_output += "{{nbt|list|{tag_identifier}}}\n".format({"tag_identifier":tag_identifier})
		
		for list_item in get_values:
			list_item_count += 1
			match is_valid_item_type(list_item):
				TagListItemTypes.INVALID:
					logger.log_warn("{0} contains invalid entry {1}".format([file_path, str(list_item_count)]))
				TagListItemTypes.STRING:
					wiki_output += "* {{code|{:0:}}}\n".format({":0:":list_item})
				TagListItemTypes.DICTIONARY:
					if list_item.has("id") == false:
						logger.log_warn("{0} contains entry {1} with key \"id\" missing.".format([file_path, str(list_item_count)]))
						continue
					
					var entry_id = list_item.get("id",null)
					if is_valid_item_type(entry_id) != TagListItemTypes.STRING:
						logger.log_warn("{0} contains entry {1} with invalid ID.".format([file_path,str(list_item_count)]))
						continue
					wiki_output += "* {{code|{:0:}}}\n".format({":0:":entry_id})
		wiki_output += "\n"
		logger.log_info("{file_path} conversion complete".format({"file_path":file_path}))
	var output_dir = FileAccess.open(output_path,FileAccess.WRITE)
	if output_path:
		#wiki_output += debug_receipt
		output_dir.store_string(wiki_output)
		logger.log_info("Rgistry tag files successfully converted.")
		_report(0)

func is_valid_item_type(entry:Variant) -> TagListItemTypes:
	# Is the entry a string?
	if typeof(entry) ==4:
		return TagListItemTypes.STRING
	# If not a string, is it a dictionary?
	elif typeof(entry) == 27:
		return TagListItemTypes.DICTIONARY
	else:
		return TagListItemTypes.INVALID

func load_json_from_file(path) -> Dictionary:
	# Check if the file exists and can be opened.
	if not FileAccess.file_exists(path):
		logger.log_error("File not found at path: {path}".format({"path":path}))
		return{}
	
	# Open the file for reading.
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		logger.log_error("Error opening file: " + str(FileAccess.get_open_error()))
		return {}
	
	# Read the entire file's contents as a single string,
	var content = file.get_as_text()
	file.close()
	
	# Parse the string, check for errors, and return the data.
	var json_result = JSON.parse_string(content)
	if json_result is Dictionary:
		return json_result
	else:
		logger.log_error("JSON parsing failed.")
		return {}

func _on_debug_logger_log_entry(entry:String) -> void:
	current_log = entry
	print_rich(entry.strip_edges(false))

func _report(level:int):
	reported.emit(current_log,level)
