extends Control

@export var internal_button:Button
@export var label:Label
signal pressed(int)
@export var id:int

var _is_highlighted = false

func get_id() -> int:
	return id

func _on_button_pressed() -> void:
	emit_signal("pressed",id)
	_on_button_focus_entered()

func _on_button_focus_entered() -> void:
	if !_is_highlighted:
		var style:StyleBoxFlat = $PanelContainer.get_theme_stylebox("panel").duplicate()
		style.bg_color.v += 0.15
		$PanelContainer.add_theme_stylebox_override("panel",style)
		_is_highlighted = true


func _on_button_mouse_entered() -> void:
	internal_button.grab_focus()

func _on_button_focus_exited() -> void:
	if _is_highlighted:
		var style:StyleBoxFlat = $PanelContainer.get_theme_stylebox("panel").duplicate()
		style.bg_color.v -= 0.15
		$PanelContainer.add_theme_stylebox_override("panel",style)
		_is_highlighted = false


func _on_button_mouse_exited() -> void:
	_on_button_focus_exited()
