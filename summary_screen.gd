extends CanvasLayer

@export var Song_path:String
@export var Beatmap_inx:int

@export var autoplay_used:bool

@export var Rank:String
@export var Score:int
@export var possible_score:int

@export var combo:int

var audioplayer:AudioStreamPlayer
var videoplayer:VideoPlayback
var backgroundimage:TextureRect

func _ready() -> void:
	init_new_audioplayer()
	init_new_backgroundimage()
	init_new_videoplayer()
	var song_file = Global.pak_reader.find_in_config(Song_path, true, "song")
	var music_path = Song_path + "/" + song_file

	var loader := AudioLoader.new()
	var stream = loader.loadfile(music_path,true)
	if stream:
		audioplayer.stop()
		audioplayer.stream = stream
	else:
		push_error("Failed to load music from %s" % music_path)
		return

	var start_time = Global.pak_reader.find_in_config(Song_path, true, "song_start")
	start_time = float(start_time) if start_time.is_valid_float() and float(start_time) >= 0 else 0.0

	videoplayer.hide()
	backgroundimage.hide()

	var video_path = Global.pak_reader.find_in_config(Song_path, true, "background")
	var is_image = Global.pak_reader.is_song_background_image(Song_path, true)
	
	var song_name = Global.pak_reader.find_in_config(Song_path,true,"pack_name")
	
	if video_path:
		var full_path = "user://songs/%s/%s" % [song_name, video_path]
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

	var info_box = $infobox
	info_box.title = song_name
	info_box.desc = Global.pak_reader.find_in_config(Song_path,true,"desc")
	info_box.song = Global.pak_reader.find_in_config(Song_path,true,"credits")
	info_box.pak = Global.pak_reader.find_in_config(Song_path,true,"pak_creator")
	var icon_path = Global.pak_reader.find_in_config(Song_path,true,"icon")
	if icon_path:
		info_box.icon = ImageTexture.create_from_image(Image.load_from_file(str(Song_path,"/",icon_path)))
	else:
		info_box.icon = load("res://resources/minapak.svg")
	info_box.position.x = 1000
	info_box.position.y = 440
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(info_box, "position:x", 670, 0.3).set_ease(Tween.EASE_OUT)
	
	
	var score_box = $ScoreBox
	score_box.rank = Rank
	score_box.score = str(Score)
	score_box.possible_score = str(possible_score)
	score_box.combo = str(combo)
	save_song_data()
	
	var song_dir = DirAccess.open(Song_path)
	var beatmap_name = "{ERR NOT FOUND!}"
	if song_dir:
		var minamaps:PackedStringArray = []
		for file in song_dir.get_files():
			if file.to_lower().ends_with(".minamap"):
				minamaps.append(file)
		if minamaps.size() == 1:
			beatmap_name = ""
		else:
			if Beatmap_inx > -1 && Beatmap_inx < minamaps.size():
				beatmap_name = minamaps[Beatmap_inx].trim_suffix(".minamap")
	score_box.beatmap_name = beatmap_name

	score_box.position.x = -500
	score_box.position.y = 496
	var score_tween = create_tween()
	score_tween.set_trans(Tween.TRANS_SINE)
	score_tween.tween_property(score_box, "position:x", 48, 0.3).set_ease(Tween.EASE_OUT)
	$auto_play_watermarks.visible = autoplay_used


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


func _on_exit_pressed() -> void:
	await Global.clear_temp()
	Global.goto_scene("res://main_menu/menu.tscn")

func _on_exit_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control2/ColorRect,"position:x",1.5,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control/Label,"position:x",-170,0.4).set_ease(Tween.EASE_IN_OUT)

func _on_exit_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control2/ColorRect,"position:x",-30,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control/Label,"position:x",-380,0.4).set_ease(Tween.EASE_IN_OUT)


func save_song_data() -> void:
	var save_data := Global.load_obscured_json(Global.save_file)
	var key := "%s|%d" % [Song_path, Beatmap_inx]

	var new_data := {
		"rank": Rank,
		"score": Score,
		"possible_score": possible_score,
		"combo": combo,
		"autoplay_used": autoplay_used
	}

	var existing_data = save_data.get(key, null)
	if existing_data:
		if not existing_data.get("autoplay_used", false) and autoplay_used:
			return

		var existing_score = existing_data.get("score", 0)
		var existing_rank = existing_data.get("rank", "F")

		if Score < existing_score and _compare_rank(Rank, existing_rank) <= 0:
			return

	save_data[key] = new_data
	Global.save_obscured_json(Global.save_file, save_data)


func _compare_rank(a: String, b: String) -> int:
	var rank_order = {
		"SP": 10,
		"SSS": 9,
		"SS": 8,
		"S": 7,
		"P": 6,
		"A": 5,
		"B": 4,
		"C": 3,
		"D": 2,
		"F": 1,
		"N/A": 0
	}
	return rank_order.get(a, 0) - rank_order.get(b, 0)
