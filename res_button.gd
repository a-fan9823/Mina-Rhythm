extends Button

@export var dialog: FileDialog
@export var musicdialog: Node
@export var previewdialog: Node
@export var videodialog: Node
@export var icondialog: Node
@export var paknamedialog:Node
@export var pakinfodialog:Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog.connect("file_selected", Callable(self,"_file_selected"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _file_selected(path):
	var file_to_copy = FileAccess.open(path,FileAccess.READ)
	var tempfile = FileAccess.open(str("res://temp/",path.get_slice("\\",path.get_slice_count("\\") - 1),".",path.get_slice(".",path.get_slice_count(".") - 1)),FileAccess.WRITE)
	var generated_pak_config:String = str(
		"[PackInfo]\n",
		"pack_config=generated_pak_file.ini\n",
		"pack_name=", paknamedialog.text, "\n",
		"icon=", icondialog.current_file.replace("\\", "/").split("/")[icondialog.current_file.replace("\\", "/").split("/").size() - 1], "\n",
		"[Resources]\n",
		"song=", musicdialog.current_file.replace("\\", "/").split("/")[musicdialog.current_file.replace("\\", "/").split("/").size() - 1], "\n",
		"video=", videodialog.current_file.replace("\\", "/").split("/")[videodialog.current_file.replace("\\", "/").split("/").size() - 1], "\n",
		"preview_img=", previewdialog.current_file.replace("\\", "/").split("/")[previewdialog.current_file.replace("\\", "/").split("/").size() - 1], "\n",
		"beat_map=","\n",
		"info=generated_info_file.txt\n"
	)
	
	# Store the config in a temporary file
	var generated_pak_file = FileAccess.open("res://temp/generated_pak_file.ini", FileAccess.WRITE)
	generated_pak_file.store_string(generated_pak_config)
	generated_pak_file.close()
	tempfile.store_buffer(file_to_copy.get_buffer(file_to_copy.get_length()))
	tempfile.close()
	var generated_info_file = FileAccess.open("res://temp/generated_info_file.txt", FileAccess.WRITE)
	generated_info_file.store_string(pakinfodialog.text)
	generated_info_file.close()
	file_to_copy.close()
	#Global.restart_game("res://editor.tscn","")
func _on_pressed() -> void:
	dialog.visible = true
