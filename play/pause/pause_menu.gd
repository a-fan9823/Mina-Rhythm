extends CanvasLayer

@export var BUTTON_SCENE:PackedScene
const options:= ["Resume","Retry","Settings","Main Menu","Quit"]

func _ready() -> void:
	for option in options:
		var button = BUTTON_SCENE.instantiate()
		button.label.text = option
		button.id = options.find(option)
		button.connect("pressed", Callable(self, "_on_option_selected"))
		$Menu/VBoxContainer.add_child(button)

func confirm_dialog(dialog:String,option:int):
	$ConfirmationDialog.dialog_text = dialog
	%OverlayDim2.show()
	$ConfirmationDialog.set_meta("option",option)
	$ConfirmationDialog.show()

func _on_option_selected(id:int):
	match id:
		0:
			$ColorRect.hide()
			$Menu.hide()
			$OverlayDim.hide()
			$SettingsPanel.hide()
			$Label.show()
			$Timer.start(3)
		1:
			confirm_dialog("Are you sure you want to restart this song? You will lose all un-saved progress!",id)
		2:
			$SettingsPanel.show()
			%OverlayDim.show()
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_QUINT)
			tween.tween_property($SettingsPanel/Panel,"position:x",867,0.5).set_ease(Tween.EASE_OUT)
			await tween.finished
			$SettingsPanel/Panel/Exit.disabled = false
		3:
			confirm_dialog("Are you sure you want to quit to main menu? You will lose all un-saved progress!",id)
		4:
			confirm_dialog("Are you sure you want to quit to desktop? You will lose all un-saved progress!",id)
		_:
			pass

func _process(_delta: float) -> void:
	if !$Timer.is_stopped():
		$Label.text = str(int(round($Timer.time_left)))

func _on_timer_timeout() -> void:
	if get_tree().current_scene.has_method("unpause_song"):
		get_tree().current_scene.unpause_song()


func _on_confirmation_dialog_canceled() -> void:
	%OverlayDim2.hide()


func _on_confirmation_dialog_confirmed() -> void:
	var option = $ConfirmationDialog.get_meta("option")
	match option:
		1:
			var root = get_tree().current_scene
			if root.has_method("unpause_song"):
				var path = root.song_path
				var beatmap_index = root.beatmap_index
				await Global.clear_temp()
				Global.goto_scene("res://play/play.tscn",{"song_path":path,"beatmap_index":beatmap_index})
		3:
			await Global.clear_temp()
			Global.goto_scene("res://main_menu/menu.tscn")
		4:
			$Label.text = "Bye bye!"
			$Label.show()
			get_tree().quit()
		_:
			pass
