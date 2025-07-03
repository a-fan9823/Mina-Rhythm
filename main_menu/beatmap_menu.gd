extends Control

func _on_exit_pressed() -> void:
	get_tree().current_scene.in_beatmap_menu = false
	self.hide()
	%OverlayDim.hide()

func _on_exit_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control2/ColorRect,"position:x",1.5,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control/Label,"position:x",-280,0.4).set_ease(Tween.EASE_IN_OUT)

func _on_exit_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control2/ColorRect,"position:x",-30,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Exit/Control/Label,"position:x",-380,0.4).set_ease(Tween.EASE_IN_OUT)
