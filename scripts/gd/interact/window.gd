extends Node2D

@export var enable_window_drag:bool = true
@export var enable_docking: bool = true
@export var model: GDCubismUserModel
@export var anim_controller: AnimationController
@export var dock_thresh:float = 0.3
@export var dock_offset:float = -0.1
@export var dock_pop_offset:int = 380

const STEP_SIZE = 0.05
const MIN_SCALE = 0.1
const DOCK_LEFT = 0
const DOCK_RIGHT = 1
const DOCK_NONE = 2

@onready var BASE_WINDOW_WIDTH = get_tree().root.get_size().x
@onready var BASE_WINDOW_HEIGHT = get_tree().root.get_size().y
@onready var mouseTracker = get_node("/root/MouseTracker")
@onready var windowManager = get_node("/root/WindowManager")
@onready var mouseDetection = get_node("/root/MouseDetection")
@onready var config = get_node("/root/Config")

var dragging: bool = false
var docking: bool = false
var docking_dir: int = DOCK_NONE 

var window_scale: float = 1.0
var drag_start_mouse_pos: Vector2i
var drag_start_window_pos: Vector2i

signal window_scale_changed
signal window_pos_changed
signal other_app_fullscreen
signal window_middle_click
signal window_docking

func _ready() -> void:
	load_config()
	bind_signals()
	set_up_fullscreen_detector()
	update_window_size()
	
func _physics_process(delta: float) -> void:
	dock_pop()

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
			if event.pressed and not docking:
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
		var new_position = drag_start_window_pos + delta_pos
		if enable_docking:
			new_position = dock_to_edge(Rect2i(new_position, DisplayServer.window_get_size()), dock_thresh, dock_offset)
		get_tree().root.position = new_position

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
	if enable_docking:
		var new_position = dock_to_edge(Rect2i(get_tree().root.position, DisplayServer.window_get_size()), dock_thresh, dock_offset)
		get_tree().root.position = new_position
	
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
	
func dock_to_edge(window_rect: Rect2i, thresh: float, offset: float):
	var center_pos = window_rect.position.x + window_rect.size.x / 2
	
	var screen_width = windowManager.GetSystemMetrics(78)
	var thresh_pixel = window_rect.size.x * thresh
	var offset_pixel = window_rect.size.x * offset
	
	if center_pos - thresh_pixel < 0:
		model.set_rotation_degrees(85)
		model.Body_group = 0
		docking = true
		docking_dir = DOCK_LEFT
		model.flip_h = false
		window_docking.emit(true, DOCK_LEFT)
		return Vector2i(-window_rect.size.x / 2 + offset_pixel, window_rect.position.y)
	elif center_pos + thresh_pixel > screen_width:
		model.set_rotation_degrees(-95)
		model.Body_group = 0
		docking = true
		docking_dir = DOCK_RIGHT
		model.flip_h = false
		window_docking.emit(true, DOCK_RIGHT)
		return Vector2i(screen_width - window_rect.size.x / 2 - offset_pixel, window_rect.position.y)
	else:
		model.set_rotation_degrees(0)
		model.Body_group = 1
		docking = false
		docking_dir = DOCK_NONE
		window_docking.emit(false, DOCK_NONE)
		anim_controller.set_expression("Idle")
		return window_rect.position

func dock_pop():
	if docking:
		if mouseDetection.mouse_hovered:
			if docking_dir == DOCK_LEFT:
				model.position.x = dock_pop_offset
			elif docking_dir == DOCK_RIGHT:
				model.position.x = -dock_pop_offset
				
			anim_controller.set_expression("Doubt")
		else:
			anim_controller.set_expression("Idle")
			model.position.x = 0
	else:
		model.position.x = 0

func _on_other_app_fullscreen():
	other_app_fullscreen.emit(windowManager.IsOtherAppFullscreen())
