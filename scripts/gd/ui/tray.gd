extends PopupMenu

const ID_HIDE = 0
const ID_EXIT = 1

@onready var config: ConfigManager = get_node("/root/Config")

var _is_fullscreen_hide = false

func _on_item_pressed(id: int) -> void:
	if id == ID_HIDE:
		var checked = is_item_checked(ID_HIDE)
		$"../..".visible = checked
		get_tree().paused = !checked
		set_item_checked(ID_HIDE, !checked)
	elif id == ID_EXIT:
		get_tree().quit()

func _on_other_app_fullscreen(is_fullscreen):
	if is_fullscreen:
		if is_item_checked(ID_HIDE):
			return
		else:
			$"../..".visible = !is_fullscreen
			get_tree().paused = is_fullscreen
			set_item_checked(ID_HIDE, is_fullscreen)
			_is_fullscreen_hide = true
	else:
		if _is_fullscreen_hide:
			$"../..".visible = !is_fullscreen
			get_tree().paused = is_fullscreen
			set_item_checked(ID_HIDE, is_fullscreen)
			_is_fullscreen_hide = false
