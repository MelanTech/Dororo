extends Window

@export var window: Node2D

@export var y_offset: int = 0
@export var x_offset: int = 0

@onready var text_label: Label = $"ChatDialog/MarginContainer/NinePatchRect/MarginContainer/ScrollContainer/Label"
@onready var scroll_container = $"ChatDialog/MarginContainer/NinePatchRect/MarginContainer/ScrollContainer"

var _buffer: String = ""
var _in_think_tag: bool = false
var _display_thinking: bool = false

const THINKING_TEXT := "思考中..."

func _ready() -> void:
	$"ChatDialog/CloseButton".pressed.connect(_on_close_button_pressed)

func _process(delta: float) -> void:
	if visible:
		var main_window_pos = DisplayServer.window_get_position()
		var main_window_size = DisplayServer.window_get_size()
		main_window_pos.x = main_window_pos.x - x_offset
		main_window_pos.y = main_window_pos.y - y_offset
		position = main_window_pos
		size.x = main_window_size.x + 2 * x_offset
		size.y = 100 * (window.window_scale + 0.5)
		content_scale_factor = window.window_scale + 0.5

func append_text(text: String):
	#_buffer += text
	#_process_buffer()
	text_label.text += text
	_scroll_to_bottom()
	
func set_text(text: String):
	text_label.text = text
	
func get_text():
	return text_label.text
	
func clear_text():
	text_label.text = ""

func _process_buffer():
	var output := ""
	
	while true:
		var idx: int
		if not _in_think_tag:
			# 当前不在 think 中：查找 <think> 开始
			idx = _buffer.find("<think>")
			if idx == -1:
				# 没找到开始标签，全部输出
				output += _buffer
				_buffer = ""
				break
			else:
				# 输出 think 前的内容
				output += _buffer.substr(0, idx)
				# 进入 think 状态
				_buffer = _buffer.substr(idx + 7, _buffer.length())  # 跳过 <think>
				_in_think_tag = true
				# 开始显示“思考中...”
				if not _display_thinking:
					# 保留原文本，后面加提示
					text_label.text += THINKING_TEXT
					_display_thinking = true
		else:
			# 当前在 think 中：查找 </think> 结束
			idx = _buffer.find("</think>\n\n")
			if idx == -1:
				# 还没收到结束标签，继续等待，不输出任何内容
				break
			else:
				# 结束 think 模式
				_buffer = _buffer.substr(idx + 10, _buffer.length())  # 跳过 </think>
				_in_think_tag = false
				# 停止显示“思考中...”
				if _display_thinking:
					# 移除“思考中...”（从末尾删掉）
					if text_label.text.ends_with(THINKING_TEXT):
						text_label.text = text_label.text.left(text_label.text.length() - THINKING_TEXT.length())
					_display_thinking = false
				
				# 继续解析剩余 buffer（可能包含正常文本）
				continue
	
	# 输出非 think 内容
	if output.length() > 0:
		text_label.text += output
	
	# 滚动到底部
	_scroll_to_bottom()

func _scroll_to_bottom():
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
		
func _on_close_button_pressed():
	hide()

func _on_window_docking(enable: bool, direction: int) -> void:
	if enable:
		hide()
