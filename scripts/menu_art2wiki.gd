extends Control

const NOTIF_MODAL = preload("res://scenes/notif_modal.tscn")

@onready var fd_tag = $FD_Tag
@onready var tag_button: Button = $VBoxContainer/TagPath/Button
@onready var output_button: Button = $VBoxContainer/OutputPath/Button
@onready var info_popup = $Window
@onready var fd_output = $FD_Output
@onready var art2wiki = $ART2Wiki


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_tag_path_button_pressed() -> void:
	fd_tag.popup_centered_clamped()


func _on_fd_tag_dir_selected(dir: String) -> void:
	tag_button.text = dir
	art2wiki.tag_folder_path = dir


func _on_info_button_pressed() -> void:
	info_popup.popup_centered_clamped()


func _on_window_close_requested() -> void:
	info_popup.hide()


func _on_wiki_output_button_pressed() -> void:
	fd_output.popup_centered_clamped()


func _on_fd_output_file_selected(path: String) -> void:
	output_button.text = path
	art2wiki.output_path = path


func _on_convert_button_pressed() -> void:
	var passes_check = art2wiki.check_names()
	if passes_check:
		if art2wiki.tag_folder_path.length() == 0:
			art2wiki.logger.log_error("Please provide a tag path.")
			art2wiki._report(2)
			return
		if art2wiki.output_path.length() == 0:
			art2wiki.logger.log_error("Please provide an output path.")
			art2wiki._report(2)
			return
		art2wiki.logger.log_info("Starting conversion...")
		art2wiki.convert_tag_files(art2wiki.tag_folder_path)


func _on_line_edit_text_submitted(new_text: String) -> void:
	art2wiki.mod_id = new_text


func _on_middle_dir_text_submitted(new_text: String) -> void:
	art2wiki.middle_dir = new_text


func _on_mod_id_text_changed(new_text: String) -> void:
	art2wiki.mod_id = new_text


func _on_art_2_wiki_reported(text: String, _log_level: int) -> void:
	var notif = NOTIF_MODAL.instantiate()
	#var screen_center_x = (DisplayServer.screen_get_size(-4).x)/2
	notif.global_position = Vector2(0,244.0)
	notif.appear(text)
	add_child(notif)


func _on_middle_dir_text_changed(new_text: String) -> void:
	art2wiki.middle_dir = new_text
