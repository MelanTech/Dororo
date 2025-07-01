class_name CaseBindingConverter
extends BindingConverter

var _case_value: Variant
var _last_source_value: Variant


func _init(case_value: Variant):
	_case_value = case_value


func source_to_target(source_value: Variant) -> Variant:
	_last_source_value = source_value
	return source_value == _case_value


func target_to_source(target_value: Variant) -> Variant:
	return _case_value if target_value else _last_source_value
