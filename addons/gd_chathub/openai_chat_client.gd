extends BaseChatClient
class_name OpenAIChatClient

var _chat_http: HTTPClient = HTTPClient.new()
var _response_parser: ResponseParser = ResponseParser.new()
var _last_http_status: int = 0

var _temperature_enable: bool = false
var _max_token_enable: bool = false

func _ready() -> void:
	_response_parser.on_thinking.connect(_emit_on_thinking)
	_response_parser.on_response.connect(_emit_on_response)
	_response_parser.on_error.connect(_emit_on_response)
	_response_parser.on_finish.connect(_on_process_response_finished)

func _connect():
	var err = _chat_http.connect_to_host(_url, _port)
	if err != OK:
		_connected = false
		_processing = false
		return false
	
	# 记录开始时间（秒）
	var start_time = Time.get_ticks_msec() / 1000.0
	
	# 循环检查直到超时或连接成功
	while true:
		# 计算已经过去的时间
		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
		
		# 检查是否超时
		if elapsed_time >= _connect_timeout:
			_connected = false
			_processing = false
			return false
		
		# 检查当前连接状态
		var status = _chat_http.get_status()
		
		# 如果已连接成功，退出循环
		if status == HTTPClient.STATUS_CONNECTED:
			break
		
		# 如果处于连接中或解析中状态，继续轮询
		if status == HTTPClient.STATUS_CONNECTING or status == HTTPClient.STATUS_RESOLVING:
			_chat_http.poll()
		else:
			# 其他错误状态
			_connected = false
			_processing = false
			return false
		
		# 短暂延迟避免CPU占用过高
		OS.delay_msec(10)
	
	# 连接成功
	_connected = true
	return true
	
func _disconnect():
	_chat_http.close()
	_connected = false

func chat(message: String, context: Array[Dictionary] = []):
	if not _connect():
		return false
	return _send(_route, message, context)
	
func cancel():
	_processing = false
	_response_parser.clear_cache()
	_disconnect()
	_on_process_response_finished()
	
func _send(api: String, message, context: Array[Dictionary] = []):
	if _processing:
		return false
		
	if !_connected:
		return false
		
	_processing = true
	_last_http_status = -1
	_response_parser.clear_cache()
		
	var data = {
		"model": _model_name,
		"messages": [
			{
			  "role": "system",
			  "content": _prompt,
			}
		],
		"stream": _stream,
		"thinking": {
			"type": "enabled" if _thinking else "disabled"
		}
	}
	
	if _temperature_enable:
		data["temperature"] = _temperature
	
	if _max_token_enable:
		data["max_tokens"] = _max_token
	
	data["messages"].append_array(context)
	data["messages"].append({"role": "user", "content": message})
	
	_chat_http.request(
		HTTPClient.METHOD_POST, 
		api, 
		[
			"Content-Type: application/json",
			"Authorization: Bearer {0}".format([_api_key]),
		], 
		JSON.stringify(data)
	)
	
	return true
	
func _process(delta: float) -> void:
	if _connected and _processing:
		_chat_http.poll()
		var http_status = _chat_http.get_status()
		if _chat_http.has_response() and http_status == HTTPClient.STATUS_BODY:
			var chunk = _chat_http.read_response_body_chunk()
			if chunk.size() > 0:
				var response = chunk.get_string_from_utf8()
				if _stream:
					_response_parser.process_stream(response)
				else:
					_response_parser.process(response)
		
		if http_status != HTTPClient.STATUS_BODY and _last_http_status == HTTPClient.STATUS_BODY:
			_on_process_response_finished()
			
		_last_http_status = http_status

func _on_process_response_finished():
	_processing = false
	_last_http_status = -1
	_response_parser.clear_cache()
	_disconnect()
	on_finish.emit()

func _emit_on_response(content: String):
	on_response.emit(content)
	
func _emit_on_thinking(content: String):
	on_thinking.emit(content)

func set_temperature_enable(enable: bool):
	_temperature_enable = enable
	
func get_temperature_enable():
	return _temperature_enable
	
func set_max_token_enable(enable: bool):
	_max_token_enable = enable
	
func get_max_token_enable(enable: bool):
	return _max_token_enable
