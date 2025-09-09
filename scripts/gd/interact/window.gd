extends Node2D

@export var enable_window_drag:bool = true
@export var enable_docking: bool = true
@export var model: GDCubismUserModel
@export var anim_controller: AnimationController
@export var dock_thresh:float = 0.3
@export var dock_pop_offset:int = 110
@export var dock_pop_expression_reset_time:float = 30
@export var dock_to_taskbar:bool = false

const STEP_SIZE = 0.05
const MIN_SCALE = 0.1

const DOCK_LEFT = 0
const DOCK_RIGHT = 1
const DOCK_TOP = 2
const DOCK_BOTTOM = 3
const DOCK_NONE = 4
const DOCK_POS_OFFSET = 380


@onready var BASE_WINDOW_WIDTH = get_tree().root.get_size().x
@onready var BASE_WINDOW_HEIGHT = get_tree().root.get_size().y
@onready var mouseTracker = get_node("/root/MouseTracker")
@onready var windowManager = get_node("/root/WindowManager")
@onready var mouseDetection = get_node("/root/MouseDetection")
@onready var config: ConfigManager = get_node("/root/Config")

var dragging: bool = false
var docking: bool = false
var docking_dir: int = DOCK_NONE
var docking_time_counter:TimeCounter = TimeCounter.new(dock_pop_expression_reset_time)

var window_scale: float = 1.0
var drag_start_mouse_pos: Vector2i
var drag_start_window_pos: Vector2i

var fullscreen_check_timer = Timer.new()
var is_other_app_fullscreen = false

signal window_scale_changed
signal window_pos_changed
signal other_app_fullscreen
signal window_middle_click
signal window_docking

func _ready() -> void:
	load_config()
	bind_signals()
	set_up_fullscreen_detector()
	update_window()
	
	add_child(docking_time_counter)
	mouseDetection.connect("MouseEntered", docking_time_counter.increase)
	
func _process(delta: float) -> void:
	dock_pop()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Window dragging
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if enable_window_drag and not $GDCubismUserModel/Animation/EffectMove.is_moving:
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
			new_position = dock_to_edge(new_position, dock_thresh)
		get_tree().root.position = new_position

func increase_window_size():
	window_scale += STEP_SIZE
	update_window()
	
func decrease_window_size():
	if window_scale < MIN_SCALE:
		return
	elif window_scale > MIN_SCALE:
		window_scale -= STEP_SIZE
		
	update_window()

func update_window():
	# 计算新的窗口尺寸
	var new_width = int(BASE_WINDOW_WIDTH * window_scale)
	var new_height = int(BASE_WINDOW_HEIGHT * window_scale)
	
	# 更新主视窗的大小
	get_tree().root.set_size(Vector2i(new_width, new_height))
	if enable_docking:
		var new_position = dock_to_edge(get_tree().root.position, dock_thresh)
		get_tree().root.position = new_position
	
func load_config():
	window_scale = config.get_window_config("window_scale", window_scale)
	get_tree().root.position = config.get_window_config("window_pos", get_tree().root.position)
	
func bind_signals():
	window_scale_changed.connect(config.on_window_config_change)
	window_pos_changed.connect(config.on_window_config_change)
	other_app_fullscreen.connect($StatusIndicator/PopupMenu._on_other_app_fullscreen)

func set_up_fullscreen_detector():
	fullscreen_check_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	fullscreen_check_timer.wait_time = 0.5
	fullscreen_check_timer.timeout.connect(_check_other_app_fullscreen)
	add_child(fullscreen_check_timer)
	fullscreen_check_timer.start()
	set_fullscreen_status(config.get_section(&"system").get_prop(&"auto_hide"))
	
func set_fullscreen_status(status: bool):
	fullscreen_check_timer.set_paused(!status)

func dock_to_edge(win_pos: Vector2i, thresh: float):
	var screen_size = Vector2i.ZERO
	
	if dock_to_taskbar:
		screen_size = DisplayServer.screen_get_usable_rect().size
	else:
		screen_size = DisplayServer.screen_get_size()
	
	var screen_pos = DisplayServer.screen_get_position()
	var win_size = DisplayServer.window_get_size()
	var win_cpos = win_pos - screen_pos + win_size / 2
	
	var thresh_pixel = int(win_size.x * thresh)
	var dis_mouse_win_cpos = DisplayServer.mouse_get_position().distance_to(get_tree().root.position + win_size / 2)
	
	if  dragging and (dis_mouse_win_cpos > win_size.x or dis_mouse_win_cpos > win_size.y):
		# 当拖动时，鼠标距离窗口超出窗口大小时不停靠，防止窗口移不出当前屏幕
		model.set_rotation_degrees(0)
		model.position = Vector2.ZERO
		model.Body_group = 1
		docking = true
		docking_dir = DOCK_NONE
		window_docking.emit(false, DOCK_NONE)
		anim_controller.set_expression("Idle")
		docking_time_counter.reset()
		return win_pos	
	elif win_cpos.x - thresh_pixel < 0:
		# 左侧停靠
		model.set_rotation_degrees(85)
		model.position.x = -DOCK_POS_OFFSET
		model.Body_group = 0
		docking = true
		docking_dir = DOCK_LEFT
		model.flip_h = false
		window_docking.emit(true, DOCK_LEFT)
		return Vector2i(screen_pos.x, win_pos.y)
	elif win_cpos.x + thresh_pixel > screen_size.x:
		# 右侧停靠
		model.set_rotation_degrees(-95)
		model.position.x = DOCK_POS_OFFSET
		model.Body_group = 0
		docking = true
		docking_dir = DOCK_RIGHT
		model.flip_h = false
		window_docking.emit(true, DOCK_RIGHT)
		return Vector2i(screen_size.x + screen_pos.x - win_size.x, win_pos.y)
	elif win_cpos.y - thresh_pixel < 0:
		# 顶部停靠
		model.set_rotation_degrees(175)
		model.position.y = -DOCK_POS_OFFSET
		model.Body_group = 0
		docking = true
		docking_dir = DOCK_TOP
		model.flip_h = false
		window_docking.emit(true, DOCK_TOP)
		return Vector2i(win_pos.x, screen_pos.y)
	elif win_cpos.y + thresh_pixel > screen_size.y:
		# 底部停靠
		model.set_rotation_degrees(-5)
		model.position.y = DOCK_POS_OFFSET
		model.Body_group = 0
		docking = true
		docking_dir = DOCK_BOTTOM
		model.flip_h = false
		window_docking.emit(true, DOCK_BOTTOM)
		return Vector2i(win_pos.x, screen_size.y + screen_pos.y - win_size.y)
	else:
		# 不停靠
		model.set_rotation_degrees(0)
		model.position = Vector2.ZERO
		model.Body_group = 1
		docking = false
		docking_dir = DOCK_NONE
		window_docking.emit(false, DOCK_NONE)
		anim_controller.set_expression("Idle")
		docking_time_counter.reset()
		return win_pos
		
	return win_pos
		
func dock_pop():
	if docking and not dragging:
		if mouseDetection.mouse_hovered:
			if docking_dir == DOCK_LEFT:
				model.position.x = -DOCK_POS_OFFSET + dock_pop_offset
			elif docking_dir == DOCK_RIGHT:
				model.position.x = DOCK_POS_OFFSET - dock_pop_offset
			elif docking_dir == DOCK_TOP:
				model.position.y = -DOCK_POS_OFFSET + dock_pop_offset
			elif docking_dir == DOCK_BOTTOM:
				model.position.y = DOCK_POS_OFFSET - dock_pop_offset
			
			var count = docking_time_counter.get_count()
			if count >= 6:
				anim_controller.set_expression("DockPopAngry")
			elif count >= 3:
				anim_controller.set_expression("Doubt")
		else:
			anim_controller.set_expression("Idle")
			if docking_dir == DOCK_LEFT:
				model.position.x = -DOCK_POS_OFFSET
			elif docking_dir == DOCK_RIGHT:
				model.position.x = DOCK_POS_OFFSET
			elif docking_dir == DOCK_TOP:
				model.position.y = -DOCK_POS_OFFSET
			elif docking_dir == DOCK_BOTTOM:
				model.position.y = DOCK_POS_OFFSET
	else:
		if docking_dir == DOCK_LEFT:
			model.position.x = -DOCK_POS_OFFSET
		elif docking_dir == DOCK_RIGHT:
			model.position.x = DOCK_POS_OFFSET
		elif docking_dir == DOCK_TOP:
			model.position.y = -DOCK_POS_OFFSET
		elif docking_dir == DOCK_BOTTOM:
			model.position.y = DOCK_POS_OFFSET
		
func _check_other_app_fullscreen():
	var state = windowManager.IsOtherAppFullscreen()
	if state != is_other_app_fullscreen:
		other_app_fullscreen.emit(state)
	is_other_app_fullscreen = state
