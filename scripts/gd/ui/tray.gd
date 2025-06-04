extends PopupMenu

const ID_HIDE = 0
const ID_AUTO_START = 1
const ID_EXIT = 2

@onready var config: ConfigManager = get_node("/root/Config")
@onready var auto_starter = get_node("/root/AutoStarter")

var app_name = ProjectSettings.get_setting("application/config/name")
var _is_fullscreen_hide = false

func _ready() -> void:
	set_item_checked(ID_AUTO_START, auto_starter.IsAutoStartEnabled(app_name))

func _on_status_indicator_pressed(mouse_button: int, mouse_position: Vector2i) -> void:
	# 左键点击托盘图标召回窗口
	if mouse_button == MOUSE_BUTTON_LEFT:
		get_tree().root.position = Vector2i.ZERO

func _on_item_pressed(id: int) -> void:
	if id == ID_HIDE:
		var checked = is_item_checked(ID_HIDE)
		$"../..".visible = checked
		get_tree().paused = !checked
		set_item_checked(ID_HIDE, !checked)
	elif id == ID_AUTO_START:
		var checked = is_item_checked(ID_AUTO_START)
		set_item_checked(ID_AUTO_START, !checked)
		if !checked:
			auto_starter.EnableAutoStart(app_name)
		else:
			auto_starter.DisableAutoStart(app_name)
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
