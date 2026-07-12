extends Control

const NOTIF_MODAL = preload("res://scenes/notif_modal.tscn")

@onready var art2wiki = $ART2Wiki
@onready var fd_tag = $FD_Tag
@onready var fd_output = $FD_Output
@onready var mod_id_panel: PanelContainer = %ModIDPanel
@onready var middle_dir_panel: PanelContainer = %MiddleDirPanel
@onready var tag_path_panel: PanelContainer = %TagPathPanel
@onready var wiki_path_panel: PanelContainer = %WikiPathPanel
@onready var btn_tag_dir = %BtnTagDir
@onready var btn_wiki_dir = %BtnWikiDir
@onready var btn_convert = %BtnConvert

#region : SettingPanel focus llogic
func _on_mod_id_input_focus_entered() -> void:
	mod_id_panel.theme_type_variation = "SettingPanel_Hovered"

func _on_mod_id_input_focus_exited() -> void:
	mod_id_panel.theme_type_variation = "SettingPanel"

func _on_mid_dir_input_focus_entered() -> void:
	middle_dir_panel.theme_type_variation = "SettingPanel_Hovered"

func _on_mid_dir_input_focus_exited() -> void:
	middle_dir_panel.theme_type_variation = "SettingPanel"

func _on_btn_tag_dir_focus_entered() -> void:
	tag_path_panel.theme_type_variation = "SettingPanel_Hovered"

func _on_btn_tag_dir_focus_exited() -> void:
	tag_path_panel.theme_type_variation = "SettingPanel"

func _on_btn_wiki_dir_focus_entered() -> void:
	wiki_path_panel.theme_type_variation = "SettingPanel_Hovered"

func _on_btn_wiki_dir_focus_exited() -> void:
	wiki_path_panel.theme_type_variation = "SettingPanel"

#endregion

func _on_fd_tag_dir_selected(dir: String) -> void:
	art2wiki.tag_folder_path = dir
	btn_tag_dir.text = dir


func _on_btn_tag_dir_pressed() -> void:
	fd_tag.popup_centered_clamped()


func _on_btn_wiki_dir_pressed() -> void:
	fd_output.popup_centered_clamped()


func _on_fd_output_file_selected(path: String) -> void:
	art2wiki.output_path = path
	btn_wiki_dir.text = path


func _on_art_2_wiki_reported(text: String, _log_level: int) -> void:
	var notif = NOTIF_MODAL.instantiate()
	call_deferred("add_child",notif)
	notif.global_position = Vector2(0,236.0)
	notif.appear(text)


func _on_btn_convert_pressed() -> void:
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


func _on_mod_id_input_text_submitted(new_text: String) -> void:
	art2wiki.mod_id = new_text


func _on_mid_dir_input_text_submitted(new_text: String) -> void:
	art2wiki.middle_dir = new_text


func _on_mod_id_input_text_changed(new_text: String) -> void:
	art2wiki.mod_id = new_text


func _on_mid_dir_input_text_changed(new_text: String) -> void:
	art2wiki.middle_dir = new_text


func _on_info_button_pressed() -> void:
	$InfoWindow.popup_centered_clamped()
