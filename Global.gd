extends Node

# Singleton reference to PakFileReader
var pak_reader = preload("res://pak_reader.gd").new()
var import_dialog: String
var show_import_dialog: bool
var Settings = {"music_volume":-12}
signal imported(String)

func _ready():
	if FileAccess.file_exists("res://reload_file"):
		var import_file = FileAccess.open("res://reload_file",FileAccess.READ)
		if import_file.get_length() > 4:
			var scene = import_file.get_as_text().get_slice("\n",0)
			var data = import_file.get_as_text().erase(0,import_file.get_as_text().get_slice("\n",0).length())
			await ready 
			
			get_tree().change_scene_to_file(scene)
			if scene == "res://menu.tscn":
				import_dialog = data
				show_import_dialog = true
			if scene == "res://editor.tscn":
				emit_signal("imported",data)
			import_file = FileAccess.open("res://reload_file",FileAccess.WRITE)
			import_file.store_string("")
		import_file.close()
	DisplayServer.window_set_title(str(get_window().title.trim_suffix("(DEBUG)")," ",ProjectSettings.get_setting("application/config/version")))
func restart_game(return_scene_path:String,data_to_store:String):
	var file = FileAccess.open("res://reload_file",FileAccess.WRITE)
	file.store_string(str(return_scene_path,"\n"))
	file.store_string(data_to_store)
	file.close()
	var exec_path = OS.get_executable_path()  # Get the current executable path
	OS.shell_open(exec_path)  # Open the executable again
	get_tree().quit()  # Quit the current instance of the game
