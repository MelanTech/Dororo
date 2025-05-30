extends Node2D

@export var enable_window_drag:bool = true

const STEP_SIZE = 0.05
const MIN_SCALE = 0.1

@onready var BASE_WINDOW_WIDTH = get_tree().root.get_size().x
@onready var BASE_WINDOW_HEIGHT = get_tree().root.get_size().y
@onready var mouseTracker = get_node("/root/MouseTracker")
@onready var windowManager = get_node("/root/WindowManager")
@onready var config = get_node("/root/Config")

var window_scale: float = 1.0
var dragging: bool = false
var drag_start_mouse_pos: Vector2i
var drag_start_window_pos: Vector2i

signal window_scale_changed
signal window_pos_changed
signal other_app_fullscreen
signal window_middle_click

func _ready() -> void:
	load_config()
	bind_signals()
	set_up_fullscreen_detector()
	update_window_size()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Window dragging
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if enable_window_drag and not $GDCubismUserModel/Animation/EffectRandMove.is_moving:
					dragging = true
					drag_start_mouse_pos = mouseTracker.GetMousePosition()
					drag_start_window_pos = get_tree().root.position
			else:
				dragging = false
				window_pos_changed.emit("window_pos", get_tree().root.position)
				
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				window_middle_click.emit()
		
		# Window rescaling
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			increase_window_size()
			window_scale_changed.emit("window_scale", window_scale)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			decrease_window_size()
			window_scale_changed.emit("window_scale", window_scale)
	
	if event is InputEventMouseMotion and dragging:
		var cur_mouse_pos = mouseTracker.GetMousePosition()
		var delta_pos = cur_mouse_pos - drag_start_mouse_pos
		get_tree().root.position = drag_start_window_pos + delta_pos

func increase_window_size():
	window_scale += STEP_SIZE
	update_window_size()
	
func decrease_window_size():
	if window_scale < MIN_SCALE:
		return
	elif window_scale > MIN_SCALE:
		window_scale -= STEP_SIZE
		
	update_window_size()

func update_window_size():
	# 计算新的窗口尺寸
	var new_width = int(BASE_WINDOW_WIDTH * window_scale)
	var new_height = int(BASE_WINDOW_HEIGHT * window_scale)
	
	# 更新主视窗的大小
	get_tree().root.set_size(Vector2i(new_width, new_height))
	
func load_config():
	window_scale = config.get_window_config("window_scale", window_scale)
	get_tree().root.position = config.get_window_config("window_pos", get_tree().root.position)
	
func bind_signals():
	window_scale_changed.connect(config.on_window_config_change)
	window_pos_changed.connect(config.on_window_config_change)
	other_app_fullscreen.connect($StatusIndicator/PopupMenu._on_other_app_fullscreen)

func set_up_fullscreen_detector():
	var timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.wait_time = 0.5
	timer.timeout.connect(_on_other_app_fullscreen)
	add_child(timer)
	timer.start()
	
func _on_other_app_fullscreen():
	other_app_fullscreen.emit(windowManager.IsOtherAppFullscreen())
