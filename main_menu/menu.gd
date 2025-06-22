extends CanvasLayer

@export var EDITOR_SCENE:= preload("res://editor/editor.tscn")
@export var SONG_BUTTON_SCENE:= preload("res://main_menu/Buttons/song_button.tscn")
@export var SONG_INFO_SCENE:= preload("res://main_menu/info_panel.tscn")
@export var PLAY_SCENE:= preload("res://play/play.tscn")
@export var BEATMAP_BUTTON_SCENE:= preload("res://main_menu/Buttons/beatmap_button.tscn")
@export var scroll_container : ScrollContainer
signal import(songs:PackedStringArray)
var songs : Array = []
var selected_index : int = 0  # Index of selected song
var selected_beatmap_index : int = -1
var _seperation_factor = 100
var _x_factor = -50
var audioplayer:AudioStreamPlayer
var videoplayer:VideoPlayback
var backgroundimage:TextureRect
var curr_info_box:Node

var in_beatmap_menu:= false
var beatmap_selected_once:=false # Used to fix issue with beatmap being pre-selected causing bugs


const default_title := "Oh Noe!"
const default_dialog := "\"Dialogue Node\" -MinikoMew, Troubleshooting 2025"
func show_popup(title:=default_title,dialog:=default_dialog) -> void:
	%Popup.dialog_text = dialog
	%Popup.title = title
	%Popup.show()


func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	var import_dialog:=""
	print("Attempting to import songs: ",paths)
	var failed := []
	var success := []
	var exists := []
	for path in paths:
		var pass_code = await Global.pak_reader.import_minapak(path)
		var file_name = pass_code.substr(pass_code.find(": ") + 2, pass_code.length())  # Extract the name after ": "
		var err_code = pass_code.substr(0, pass_code.find(": "))  # Extract the error code before ": "
	
		match err_code:
			"failed":
				failed.append(file_name)
			"exists":
				exists.append(file_name)
			"success":
				success.append(file_name)
	if !failed.is_empty():
		import_dialog += "Failed: "
		for f in failed.size():
			import_dialog += failed[f] + str(", " if f != failed.size() - 1 else " ")
	if !exists.is_empty():
		import_dialog += "Already exists: "
		for e in exists.size():
			import_dialog += exists[e] + str(", " if e != exists.size() - 1 else " ")
	if !success.is_empty():
		import_dialog += "Success: "
		for s in success.size():
			import_dialog += success[s] + str(", " if s != success.size() - 1 else " ")

	show_popup("Import Status: ",import_dialog)
	emit_signal("import",success)
	for song in success:
		append_song(str("user://songs/",song))


func scene_transition() -> void:
	$TransitionOverlay.show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TransitionOverlay,"position:x",0,1).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	return


func _on_editor_pressed() -> void:
	scene_transition()
	await Global.clear_temp()
	get_tree().change_scene_to_packed(EDITOR_SCENE)


func _on_settings_pressed() -> void:
	$SettingsPanel.show()
	%OverlayDim.show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($SettingsPanel/Panel,"position:x",867,0.5).set_ease(Tween.EASE_OUT)
	await tween.finished
	$SettingsPanel/Panel/Exit.disabled = false


func _on_editor_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Editor/Control2/ColorRect,"position:x",1.5,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Editor/Control/Label,"position:x",3,0.4).set_ease(Tween.EASE_IN_OUT)


func _on_editor_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Editor/Control2/ColorRect,"position:x",-20,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Editor/Control/Label,"position:x",-325,0.4).set_ease(Tween.EASE_IN_OUT)


func _on_settings_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Settings/Control2/ColorRect,"position:x",0,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Settings/Control/Label,"position:x",1,0.4).set_ease(Tween.EASE_IN_OUT)


func _on_settings_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Settings/Control2/ColorRect,"position:x",30,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($TopNav/Settings/Control/Label,"position:x",70,0.4).set_ease(Tween.EASE_IN_OUT)


func _on_add_song_pressed():
	$FileDialog.show()


func _ready():
	populate_song_list()
	append_song("Add Song")
	_on_button_pressed(0)


func populate_song_list():
	var song_dir = DirAccess.open(ProjectSettings.globalize_path("user://songs"))
	if song_dir:
		for song in song_dir.get_directories():
			if Global.pak_reader.song_validator(str("user://songs/",song))[2]:
				songs.append(
					{"Name":Global.pak_reader.find_in_config(str("user://songs/",song),true,"pack_name"),
					"Path":str("user://songs/",song)
					})
		for i in songs.size():
			var song:Dictionary = songs[i]
			var song_name = song.get("Name","NULL")
			var button = SONG_BUTTON_SCENE.instantiate()
			button.label.text = song_name
			button.label.label_settings = button.label.label_settings.duplicate()
			button.label.label_settings.font_size = 21 * pow(24.0 / button.label.text.length(), 0.1)
			button.id = i
			button.audioplayer = audioplayer
			button.connect("pressed", Callable(self, "_on_button_pressed"))
			button.connect("focus_entered", Callable(self, "_on_focus_entered"))
			button.position = Vector2(_x_factor, i * _seperation_factor)
			button.set_meta("original_x",button.position.x)
			button.set_meta("original_y",button.position.y)
			button.set_meta("selected_once",false)
			%SongButtons.add_child(button)
			song.set("Button",button)
	else:
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path("user://songs"))
	#scroll_container.size.y = songs.size() * _seperation_factor + 50


func append_song(pak_path:String):
	var button = SONG_BUTTON_SCENE.instantiate()
	var song_name
	for b in %SongButtons.get_children():
		if b.label.text == "Add Song":
			b.free()
	if pak_path == "Add Song":
		song_name = pak_path
	else:
		song_name = Global.pak_reader.find_in_config(pak_path,true,"pack_name")
		if song_name:
			songs.append(
				{"Name":Global.pak_reader.find_in_config(pak_path,true,"pack_name"),
				"Path":str(pak_path)
				})
	if song_name:
		button.label.text = song_name
		var buttons = %SongButtons.get_children()
		if buttons.size() > 0:
			button.id = buttons.size()-1
		else:
			button.id = 0
		button.audioplayer = audioplayer
		button.connect("pressed", Callable(self, "_on_button_pressed"))
		button.connect("focus_entered", Callable(self, "_on_focus_entered"))
		button.position = Vector2(_x_factor, songs.size() * _seperation_factor)
		button.set_meta("original_x",button.position.x)
		button.set_meta("original_y",button.position.y)
		button.set_meta("selected_once",false)
		if pak_path == "Add Song":
			button.set_meta("add_song_button","")
		%SongButtons.add_child(button)
		if pak_path != "Add Song":
			append_song("Add Song")
		refresh_song_buttons()
		_on_button_pressed(buttons.size()+1)


func song_missing(index):
	var song = songs[index]
	pop_song(index)
	append_song("Add Song")
	await get_tree().process_frame
	await get_tree().process_frame
	refresh_song_buttons()
	_on_button_pressed(selected_index)
	show_popup("Oh Noe!",str("Song \"",song.get("Name","ERROR_NOT_FOUND"),"\" could not be found! please make sure its installed correctly! wan wan!"))


func pop_song(pop_index:= -1):
	if pop_index != -1:
		var buttons := %SongButtons.get_children()
		buttons[pop_index].marked_for_deletion = true
		buttons[pop_index].queue_free()
		songs.pop_at(pop_index)
		refresh_song_buttons()
		if selected_index >= songs.size():
			selected_index = max(0, songs.size() - 2)
		refresh_song_buttons()


func refresh_song_buttons():
	var buttons = %SongButtons.get_children()
	for i in buttons.size():
		var ibutton = buttons[i]
		if ibutton:
			ibutton.id = i
			ibutton.position = Vector2(_x_factor, i * _seperation_factor)
			ibutton.set_meta("original_x",ibutton.position.x)
			ibutton.set_meta("original_y",ibutton.position.y)


func _on_button_pressed(index: int):
	var button_node: Control = null

	for button in %SongButtons.get_children():
		if button is Control and button.has_method("get_id") and button.id == index:
			button_node = button
			break

	if button_node == null || !is_instance_valid(button_node) || button_node.is_queued_for_deletion() || button_node.marked_for_deletion:
		return
	if index > songs.size() || index < 0:
		return
	if !button_node.has_meta("add_song_button"):
		if !Global.pak_reader.song_validator(songs[index].get("Path",""),selected_beatmap_index)[0]:
			song_missing(index)

	if button_node == null || !is_instance_valid(button_node) || button_node.is_queued_for_deletion() || button_node.marked_for_deletion:
		return

	if button_node.get_meta("selected_once") == true:
		if button_node.has_meta("add_song_button"):
			_on_add_song_pressed()
			return
		apply_slide_back_effect(button_node)
	else:
		selected_beatmap_index = -1
		for child in %BeatmapButtons.get_children():
			child.free() #kill all the children! =3
		%SelectedBeatmap.hide()
		
		for button in %SongButtons.get_children():
			button.set_meta("selected_once", false)
		button_node.set_meta("selected_once", true)
		selected_index = index
		selected_beatmap_index = -1
		init_new_audioplayer()
		init_new_videoplayer()
		init_new_backgroundimage()
		scroll_to_selected(button_node)
		play_preview(index)
		await get_tree().process_frame
		await get_tree().process_frame
		for button in %SongButtons.get_children():
			apply_selected_effect(button,false)
		apply_selected_effect(button_node,true)


func apply_slide_back_effect(else_button: Control):
	if !Global.pak_reader.song_validator(songs[else_button.id].get("Path",""),selected_beatmap_index)[0]:
		song_missing(else_button.id)
	else:
		if selected_beatmap_index == -1:
			show_popup("Oopsies!","You need to select a beatmap to play this song!")
		else:
			for button in %SongButtons.get_children():
				var tween = create_tween()
				if button != else_button:
					tween.set_trans(Tween.TRANS_SINE)
					tween.tween_property(button, "position:x", button.get_meta("original_x") - button.size.x, 0.8).set_ease(Tween.EASE_IN)
				else: 
					tween.set_trans(Tween.TRANS_SINE)
					tween.tween_property(button, "position:x", button.get_meta("original_x") - button.size.x, 1.2).set_ease(Tween.EASE_IN)
					tween.connect("finished",Callable(self,"_trans_tween_finished"))

			$TransitionOverlay.show()
			var trantween = create_tween()
			trantween.set_trans(Tween.TRANS_QUINT)
			trantween.tween_property($TransitionOverlay,"position:x",0,1).set_ease(Tween.EASE_IN_OUT)
			await trantween.finished
			await Global.clear_temp()
			var play = PLAY_SCENE.instantiate()
			play.song_path = songs[else_button.id].get("Path","")
			play.beatmap_index = selected_beatmap_index
			get_tree().root.add_child(play)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = play


func apply_selected_effect(button,start_or_end:bool):
	if button:
		var tween = create_tween()
		if start_or_end:
			tween.tween_property(button, "position:x", button.get_meta("original_x") + 52, 0.1)
		else:
			tween.tween_property(button, "position:x", button.get_meta("original_x"), 0.1).set_ease(Tween.EASE_OUT)


func play_preview(index):
	if index < songs.size():
		var song_path = songs[index].get("Path","")
		var song_file = Global.pak_reader.find_in_config(song_path, true, "song")
		var music_path = song_path + "/" + song_file

		var loader := AudioLoader.new()
		var stream = loader.loadfile(music_path,true)
		if stream:
			audioplayer.stop()
			audioplayer.stream = stream
		else:
			push_error("Failed to load music from %s" % music_path)
			return

		var start_time = Global.pak_reader.find_in_config(song_path, true, "song_start")
		start_time = float(start_time) if start_time.is_valid_float() and float(start_time) >= 0 else 0.0

		videoplayer.hide()
		backgroundimage.hide()

		var video_path = Global.pak_reader.find_in_config(song_path, true, "background")
		var is_image = Global.pak_reader.is_song_background_image(song_path, true)

		if video_path:
			var full_path = "user://songs/%s/%s" % [songs[index].get("Name",""), video_path]
			if is_image:
				var img = Image.new()
				if img.load(full_path) == OK:
					backgroundimage.texture = ImageTexture.create_from_image(img)
			else:
				videoplayer.set_video_path(ProjectSettings.globalize_path(full_path))
		audioplayer.play(start_time)
		if is_image:
			backgroundimage.show()
		else:
			videoplayer.show()
			videoplayer.enable_auto_play = true


func init_new_audioplayer():
	if audioplayer:
		audioplayer.playing = false
		audioplayer.stop()
		audioplayer.free()
		audioplayer = null
	audioplayer = AudioStreamPlayer.new()
	audioplayer.name = "MusicPlayer"
	audioplayer.bus = "Music"
	audioplayer.volume_db = -12
	add_child(audioplayer,true)
	move_child(audioplayer,0)


func init_new_videoplayer():
	if videoplayer:
		videoplayer.is_playing = false
		videoplayer.close()
		videoplayer.free()
		videoplayer = null
	videoplayer = VideoPlayback.new()
	videoplayer.name = "VideoPlayback"
	videoplayer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	videoplayer.enable_audio = false
	videoplayer.loop = true
	videoplayer.visible = false
	videoplayer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(videoplayer,true)
	move_child(videoplayer,0)


func init_new_backgroundimage():
	if backgroundimage:
		backgroundimage.free()
		backgroundimage = null
	backgroundimage = TextureRect.new()
	backgroundimage.name = "BackgroundImage"
	backgroundimage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backgroundimage.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backgroundimage.visible = false
	backgroundimage.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backgroundimage,true)
	move_child(backgroundimage,0)


func scroll_to_selected(button:Control):
	var is_add_song_button = button.has_meta("add_song_button")
	var song_path = songs[button.id].get("Path") if !is_add_song_button else ""
	if is_add_song_button || Global.pak_reader.song_validator(song_path)[0]:
		beatmap_selected_once = false
		scroll_container.ensure_control_visible(button)
		var info_box = SONG_INFO_SCENE.instantiate()
		if is_add_song_button:
			info_box.title = "Import a song!"
			info_box.icon = load("res://resources/add.svg")
			info_box.desc = "Import a song from an .osz or .minapak!"
			info_box.song = ""
			info_box.pak = ""
		else:
			info_box.title = songs[button.id].get("Name","ERROR_NOT_FOUND")
			info_box.desc = Global.pak_reader.find_in_config(song_path,true,"desc")
			info_box.song = Global.pak_reader.find_in_config(song_path,true,"credits")
			info_box.pak = Global.pak_reader.find_in_config(song_path,true,"pak_creator")
			var icon_path = Global.pak_reader.find_in_config(song_path,true,"icon")
			if icon_path:
				info_box.icon = ImageTexture.create_from_image(Image.load_from_file(str(song_path,"/",icon_path)))
			else:
				info_box.icon = load("res://resources/minapak.svg")
		info_box.position.x = 1000
		info_box.position.y = 440
		if(curr_info_box):
			curr_info_box.free()
		curr_info_box = info_box
		add_child(info_box)
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(info_box, "position:x", 670, 0.3).set_ease(Tween.EASE_OUT)

		if !is_add_song_button:
			var song_dir = DirAccess.open(song_path)
			if song_dir:
				var minamaps:PackedStringArray = []
				for file in song_dir.get_files():
					if file.to_lower().ends_with(".minamap"):
						minamaps.append(file)
			
				for i in minamaps.size():
					var minamap_button = BEATMAP_BUTTON_SCENE.instantiate()
					minamap_button.label.text = minamaps[i].trim_suffix(".minamap")
					minamap_button.id = i
					minamap_button.connect("pressed", Callable(self, "_on_beatmap_selected"),i)
					%BeatmapButtons.add_child.call_deferred(minamap_button)
				if minamaps.size() > 1:
					%SelectedBeatmap.label.text = "Select beatmap"
					%SelectedBeatmap.show()
				elif minamaps.size() <= 1:
					%SelectedBeatmap.hide()
					selected_beatmap_index = 0
	else:
		song_missing(button.id)


func _on_selected_beatmap_pressed(_int) -> void:
	in_beatmap_menu = true
	%BeatmapSelectMenu.show()
	%OverlayDim.show()
	for beatmap in %BeatmapButtons.get_children():
		#beatmap._is_highlighted = true
		beatmap._on_button_focus_exited()


func _on_beatmap_selected(index: int):
	var button_node: Control = null

	for button in %BeatmapButtons.get_children():
		if button is Control and button.has_method("get_id") and button.id == index:
			button_node = button
			break

	if button_node == null:
		return

	if !beatmap_selected_once:
		beatmap_selected_once = true
		return
	else:
		selected_beatmap_index = button_node.get_id()
		in_beatmap_menu = false
		%BeatmapSelectMenu.hide()
		%SelectedBeatmap.label.text = button_node.label.text
		%OverlayDim.hide()


# This function is a hot mess but it works well enough for me to care
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.is_action_pressed("lane1",true):
				if in_beatmap_menu:
					if selected_beatmap_index-1 >= 0:
						var buttons = %BeatmapButtons.get_children()
						for button in buttons:
							button._on_button_focus_exited()
						buttons[selected_beatmap_index-1]._on_button_focus_entered()
				else:
					var buttons = %SongButtons.get_children()
					if selected_index-1 >= 0:
							buttons[selected_index-1]._on_button_pressed()
							buttons[selected_index]._on_button_mouse_entered()
			
			elif event.is_action_pressed("lane2",true):
				if in_beatmap_menu:
					var buttons = %BeatmapButtons.get_children()
					if selected_beatmap_index+1 < buttons.size():
						for button in buttons:
							button._on_button_focus_exited()
						buttons[selected_beatmap_index+1]._on_button_focus_entered()
				else:
					var buttons = %SongButtons.get_children()
					if selected_index+1 < buttons.size():
							buttons[selected_index+1]._on_button_pressed()
							buttons[selected_index]._on_button_mouse_entered()
