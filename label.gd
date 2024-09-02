extends Label

var min_font_size: int = 1
var max_font_size: int = 24
var font_step: int = 1  # Step to reduce font size
var max_text_length: int = 23

func _ready():
	adjust_font_size()

func adjust_font_size():
	var label_settings = self.label_settings
	if not label_settings:
		return

	if text.length() > max_text_length:
		text = text.substr(0, max_text_length - 3) + "..."

	var font_size = max_font_size
	
	while font_size >= min_font_size:
		label_settings.font_size = font_size
		
		# Get the minimum size required to fit the text
		var text_width = self.get_minimum_size().x
		
		# If text fits within the label's width, we're done
		if text_width <= size.x:
			break
		# Decrease the font size by the step value
		font_size -= font_step

	# Apply the best-fitting font size
	label_settings.font_size = font_size - 3
