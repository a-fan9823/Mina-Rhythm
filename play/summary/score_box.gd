extends PanelContainer

@export var _rank:Node
@export var _score:Node
@export var _possible_score:Node
@export var _beatmap_name:Node


var rank: String:
	set(value):
		match value:
			"SP":
				_rank.label_settings.font_color = Color8(255, 215, 0) # gold
			"SSS":
				_rank.label_settings.font_color = Color8(255, 105, 180) # pink
			"SS", "S":
				_rank.label_settings.font_color = Color8(0, 255, 255) # cyan
			"P":
				_rank.label_settings.font_color = Color8(186, 85, 211) # purple
			"A":
				_rank.label_settings.font_color = Color8(0, 200, 0) # green
			"B":
				_rank.label_settings.font_color = Color8(50, 150, 255) # blue
			"C":
				_rank.label_settings.font_color = Color8(255, 165, 0) # orange
			"D":
				_rank.label_settings.font_color = Color8(255, 140, 0) # darker orange
			"F":
				_rank.label_settings.font_color = Color8(255, 0, 0) # red
			"N/A":
				_rank.label_settings.font_color = Color8(100, 100, 100) # gray
			_:
				_rank.label_settings.font_color = Color.WHITE
		_rank.text = value

var score: String:
	set(value):
		_score.text = format_number(value)

var possible_score: String:
	set(value):
		_possible_score.text = format_number(value)

var beatmap_name:String:
	set(value):
		_beatmap_name.text = value

func format_number(value: String) -> String:
	var num = int(value)
	var string = str(num)
	var result = ""
	var count = 0
	for i in range(string.length() - 1, -1, -1):
		result = string[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result
