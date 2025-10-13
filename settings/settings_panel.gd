extends Control

@export var SettingsSlider:PackedScene
@export var SettingsToggle:PackedScene

@export var VolumeSection:Label
@export var GeneralSection:Label

func _ready() -> void:
	init_audio_settings()
	init_general_settings()

func init_audio_settings():
	var busses:Array[Dictionary] = []
	for i in min(AudioServer.bus_count,3):
		busses.append({"Name":AudioServer.get_bus_name(i),"Id":i})
	
	for bus in busses:
		var slider := SettingsSlider.instantiate()
		slider.label.text = str(bus.get("Name","Slider")).to_pascal_case()
		slider.set_meta("BusData",bus)
		slider.position.y += 50 * bus.get("Id",0)
		slider.connect("value_changed",Callable(self,"_on_VolumeSlider_value_changed").bind(bus.get("Id",0)))
		VolumeSection.add_child(slider)

		var db_val = Global.Settings.get(str(bus.get("Name","Slider")).to_lower()+"_volume", 0)

		var linear_val: float
		if db_val == -INF:
			linear_val = 0
		else:
			if typeof(db_val) == TYPE_FLOAT and (is_nan(db_val) or db_val == INF):
				db_val = 0
			linear_val = db_to_linear(db_val) * 100.0

		slider.value = linear_val
		_on_VolumeSlider_value_changed(linear_val,bus.get("Id"))

func init_general_settings():
	var lastVolume := VolumeSection.get_child(VolumeSection.get_child_count()-1)
	GeneralSection.position.y = lastVolume.position.y+lastVolume.size.y+50
	var toggle = SettingsToggle.instantiate()
	toggle.label.text = "Show FPS"
	toggle.position.y += 50
	toggle.set_meta("key","show_fps")
	toggle.connect("toggled",Callable(self,"_on_toggle_value_changed").bind("show_fps"))
	GeneralSection.add_child(toggle)
	
	var auto_toggle = SettingsToggle.instantiate()
	auto_toggle.label.text = "AutoPlay"
	auto_toggle.position.y += 50*2
	auto_toggle.set_meta("key","autoplay")
	auto_toggle.connect("toggled",Callable(self,"_on_toggle_value_changed").bind("autoplay"))
	GeneralSection.add_child(auto_toggle)
	
	var extra_toggle = SettingsToggle.instantiate()
	extra_toggle.label.text = "Extra Info"
	extra_toggle.position.y += 50*3
	extra_toggle.set_meta("key","extra_info")
	extra_toggle.connect("toggled",Callable(self,"_on_toggle_value_changed").bind("extra_info"))
	GeneralSection.add_child(extra_toggle)
	
	var quick_toggle = SettingsToggle.instantiate()
	quick_toggle.label.text = "Quick Play"
	quick_toggle.position.y += 50*4
	quick_toggle.set_meta("key","quick_play")
	quick_toggle.connect("toggled",Callable(self,"_on_toggle_value_changed").bind("quick_play"))
	GeneralSection.add_child(quick_toggle)
	
	var value = Global.Settings.get("show_fps",false)
	_on_toggle_value_changed(value,"show_fps")
	
	var autovalue = Global.Settings.get("autoplay",false)
	_on_toggle_value_changed(autovalue,"autoplay")
	
	var extravalue = Global.Settings.get("extra_info",false)
	_on_toggle_value_changed(extravalue,"extra_info")
	
	var quickvalue = Global.Settings.get("quick_play",false)
	_on_toggle_value_changed(quickvalue,"quick_play")

func _on_VolumeSlider_value_changed(value:float,index:int):
	var slider = VolumeSection.get_child(index)
	if slider == null:
		return
	
	var bus:= Dictionary(slider.get_meta("BusData"))
	if bus == null:
		return
	if !bus.get("Name"):
		return
	
	value /= 100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus.get("Name","")), linear_to_db(value))
	slider.valueLabel.text = "Volume: " + str(int(round(value*100))) + "%"
	Global.Settings[str(bus.get("Name")).to_lower()+"_volume"] = linear_to_db(value)
	Global.save_settings()

func _on_toggle_value_changed(value:bool,key:String):
	var toggle
	for option in GeneralSection.get_children():
		if option is CheckBox:
			if option.get_meta("key") == key:
				toggle = option
	toggle.button_pressed = value
	Global.Settings[key] = value
	Global.save_settings()

func _on_exit_pressed() -> void:
	$Panel/Exit.disabled = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Panel,"position:x",1152,0.5).set_ease(Tween.EASE_OUT)
	await tween.finished
	%OverlayDim.hide()
	self.hide()

func _input(event):
	if self.visible:
		if event is InputEventKey:
			if event.is_action_pressed("ui_cancel"):
				$Panel/Exit.disabled = true
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_QUINT)
				tween.tween_property($Panel,"position:x",1152,0.5).set_ease(Tween.EASE_OUT)
				await tween.finished
				%OverlayDim.hide()
				self.hide()

func _on_exit_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Panel/Exit/Control2/ColorRect,"position:x",1.5,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Panel/Exit/Control/Label,"position:x",-280,0.4).set_ease(Tween.EASE_IN_OUT)

func _on_exit_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Panel/Exit/Control2/ColorRect,"position:x",-30,0.4).set_ease(Tween.EASE_IN_OUT)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($Panel/Exit/Control/Label,"position:x",-380,0.4).set_ease(Tween.EASE_IN_OUT)
