class_name InvertBoolBindingConverter
extends BindingConverter


func source_to_target(source_value: Variant) -> Variant:
	return not source_value


func target_to_source(target_value: Variant) -> Variant:
	return not target_value
