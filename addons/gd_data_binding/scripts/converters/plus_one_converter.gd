class_name PlusOneConverter
extends BindingConverter


func source_to_target(source_value: Variant) -> Variant:
	return source_value + 1


func target_to_source(target_value: Variant) -> Variant:
	return target_value - 1
