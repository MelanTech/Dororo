extends PopupMenu

const ID_HIDE = 0
const ID_EXIT = 1

@onready var config: ConfigManager = get_node("/root/Config")
var _is_fullscreen_hide = false

func _on_status_indicator_pressed(mouse_button: int, mouse_position: Vector2i) -> void:
	# 左键点击托盘图标召回窗口
	if mouse_button == MOUSE_BUTTON_LEFT:
		var center_pos = _get_screen_center()
		var window_pos = get_tree().root.position
		if center_pos.distance_to(window_pos) > 10:
			get_node("/root/Node2D/GDCubismUserModel/Animation/EffectMove").move(center_pos, true, _on_recall_start, _on_recall_finish)

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

func _get_screen_center():
	var screen_pos = DisplayServer.screen_get_position()
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_tree().root.get_window().size
	return screen_pos + screen_size / 2 - window_size / 2

func _on_recall_start():
	get_node("/root/Node2D/GDCubismUserModel/Animation").run()
	get_node("/root/Node2D/GDCubismUserModel/Animation").set_expression("Amaze")
	
func _on_recall_finish():
	get_node("/root/Node2D/GDCubismUserModel/Animation").idle()
	get_node("/root/Node2D/GDCubismUserModel/Animation").set_expression("Idle")
