extends Node
class_name FileLogger

signal log_entry

@export var info_color := Color("#C8C8C8")
@export var warn_color := Color("#FFEF91")
@export var error_color := Color("ff3d3dff")

enum Level {
	LOG_INFO = 0,
	LOG_WARNING = 1,
	LOG_ERROR = 2,
}

# Tint based on the supplied log level
func _level_to_color(log_level: Level) -> String:
	match log_level:
		Level.LOG_INFO:
			return info_color.to_html()
		Level.LOG_WARNING:
			return warn_color.to_html()
		Level.LOG_ERROR:
			return error_color.to_html()
	
	#This shouldn't be reached.
	return Color.MAGENTA.to_html()

# Format a log entry
func _format_log(log_level: Level, log_text: String) -> String:
	var log_color: String = _level_to_color(log_level)
	var out: String = "[color=#{log_color}]".format({"log_color":log_color})
	
	var timestamp = Time.get_datetime_string_from_system(false, true)
	out += "[{timestamp}] ".format({"timestamp":timestamp.right(8)})
	
	match log_level:
		Level.LOG_WARNING:
			out += "[WARN] "
		Level.LOG_ERROR:
			out += "[ERROR] "
	
	out += log_text + "[/color]\n"
	
	return out
	
func log_info(text:String) -> void:
	emit_signal("log_entry", _format_log(Level.LOG_INFO,text))

func log_warn(text:String) -> void:
	emit_signal("log_entry", _format_log(Level.LOG_WARNING,text))
	push_warning(text)

func log_error(text:String) -> void:
	emit_signal("log_entry", _format_log(Level.LOG_ERROR,text))
	push_error(text)
	
