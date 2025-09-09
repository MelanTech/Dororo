extends Node

@export var chat_client: OpenAIChatClient
@export var context_manager: ContextManager
@export var line_edit: LineEdit
@export var send_btn: Button
@export var stop_btn: Button
@export var chat_dialog: Window

@onready var _config: ConfigManager = get_node("/root/Config")

func _ready() -> void:
	chat_client.on_response.connect(_on_response)
	chat_client.on_finish.connect(_on_finish)

func _on_send_button_pressed():
	var text = line_edit.get_text()
	if chat_client.chat(text, context_manager.get_context()):
		context_manager.add_context(ContextManager.ROLE_USER, line_edit.text)
		line_edit.clear()
		chat_dialog.clear_text()
		send_btn.visible = false
		stop_btn.visible = true
	else:
		chat_dialog.clear_text()
		_on_response("错误：无法连接API")
	
func _on_stop_button_pressed():
	chat_client.cancel()
	
func _on_clear_button_pressed():
	context_manager.clear_context()
	
func _on_response(data: String):
	chat_dialog.show()
	chat_dialog.append_text(data)
	
func _on_finish():
	context_manager.add_context(ContextManager.ROLE_ASSISTANT, chat_dialog.get_text())
	send_btn.visible = true
	stop_btn.visible = false

func _on_line_edit_text_submitted(new_text: String):
	_on_send_button_pressed()
