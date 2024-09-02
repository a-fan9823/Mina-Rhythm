extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !FileAccess.file_exists("res://temp/generated_pak_file.ini"):
		$ColorRect2.visible = true
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUINT)
		tween.tween_property($ColorRect2,"position:x",1152,1).set_ease(Tween.EASE_IN_OUT)
	#else:
		#var config = Global.pak_reader.parse_config("res://temp", true, false)
		#for line in config:
			#for prefix in Global.pak_reader.prefixes:
				#if line.begins_with(prefix):
					#var value = line.trim_prefix(prefix).strip_edges()
					#if value != "" and FileAccess.file_exists(str("res://temp/",value)):
						#match prefix:
							#"icon=":
								#$TabContainer/PakInfo/Panel2/VBoxContainer/iconsel.text = $TabContainer/PakInfo/Panel2/VBoxContainer/iconsel.text.trim_suffix(" (unset)")
							## Add more cases here if needed
							#_:
								#pass
					#else: 
						#print("Invalid or unset path for prefix:", prefix)
