class_name BindingSource
extends BaseBindingSource

enum LineEditTrigger { ON_SUBMITTED, ON_FOCUS_EXITED, ON_CHANGED }
enum TextEditTrigger { ON_FOCUS_EXITED, ON_CHANGED }

var _wrapper_dict = {}


func bind(source_property: StringName) -> Binder:
	return Binder.new(self, source_property)


func unbind(source_property: StringName) -> Unbinder:
	return Unbinder.new(self, source_property)


func _add_wrapper(source_property: StringName, wrapper: Wrapper):
	var wrappers = _wrapper_dict.get_or_add(source_property, []) as Array[Wrapper]
	wrappers.append(wrapper)


func _remove_wrapper(source_property: StringName, wrapped_object: Object):
	var wrappers = _wrapper_dict.get(source_property, []) as Array[Wrapper]
	_wrapper_dict[source_property] = wrappers.filter(
		func(wrapper): return not wrapper.wraps(wrapped_object)
	)


# gdlint:ignore = max-public-methods
class Binder:
	var _source: BindingSource
	var _source_property: StringName
	var _converter_pipeline: BindingConverterPipeline
	var _with_pipeline: BindingWithPipeline

	func _init(
		source: BindingSource,
		source_property: StringName,
		converter_pipeline: BindingConverterPipeline = null,
		with_pipeline: BindingWithPipeline = null
	):
		_source = source
		_source_property = source_property

		if converter_pipeline == null:
			_converter_pipeline = BindingConverterPipeline.new()
		else:
			_converter_pipeline = converter_pipeline
			
		if with_pipeline == null:
			_with_pipeline = BindingWithPipeline.new()
		else:
			_with_pipeline = with_pipeline
			

	func using(converter) -> Binder:
		var converter_pipeline = _converter_pipeline.copy()
		converter_pipeline.append(converter)
		return Binder.new(_source, _source_property, converter_pipeline)
		
	func with(with_func: Callable):
		var with_pipeline = _with_pipeline.copy()
		with_pipeline.append(with_func)
		return Binder.new(_source, _source_property, _converter_pipeline, with_pipeline)

	func to(target_object, target_property: StringName, target_value_change_signal = null):
		_source.bind_to(
			_source_property,
			target_object,
			target_property,
			_converter_pipeline,
			target_value_change_signal,
			_with_pipeline
		)

	func to_toggle_button(toggle_button: BaseButton):
		assert(_convert_to(TYPE_BOOL), "A value bound to Button must be a bool.")
		assert(toggle_button.toggle_mode, "The button must be toggle mode.")
		to(toggle_button, &"button_pressed", toggle_button.toggled)

	func to_check_box(check_box: CheckBox):
		assert(_convert_to(TYPE_BOOL), "A value bound to CheckBox must be a bool.")
		to_toggle_button(check_box)

	func to_check_button(check_button: CheckButton):
		assert(_convert_to(TYPE_BOOL), "A value bound to CheckButton must be a bool.")
		to_toggle_button(check_button)

	func to_color_picker_button(color_picker_button: ColorPickerButton):
		assert(_convert_to(TYPE_COLOR), "A value bound to ColorPickerButton must be a color.")
		to(color_picker_button, &"color", color_picker_button.color_changed)

	func to_option_button(option_button: OptionButton):
		assert(_convert_to(TYPE_INT), "A value bound to OptionButton must be an int.")
		to(option_button, &"selected", option_button.item_selected)

	func to_texture_button(texture_button: TextureButton):
		assert(_convert_to(TYPE_BOOL), "A value bound to TextureButton must be a bool.")
		to_toggle_button(texture_button)

	func to_color_rect(color_rect: ColorRect):
		assert(_convert_to(TYPE_COLOR), "A value bound to ColorRect must be a color.")
		to(color_rect, &"color", null)

	func to_color_picker(color_picker: ColorPicker):
		assert(_convert_to(TYPE_COLOR), "A value bound to ColorPicker must be a color.")
		to(color_picker, &"color", color_picker.color_changed)

	func to_split_container(split_container: SplitContainer):
		assert(_convert_to(TYPE_INT), "A value bound to SplitContainer must be an int.")
		to(split_container, &"split_offset", split_container.dragged)

	func to_tab_container(tab_container: TabContainer):
		assert(_convert_to(TYPE_INT), "A value bound to TabContainer must be an int.")
		to(tab_container, &"current_tab", tab_container.tab_selected)

	func to_label(label: Label):
		assert(_convert_to(TYPE_STRING), "A value bound to Label must be a string.")
		to(label, &"text", null)

	func to_line_edit(
		line_edit: LineEdit, trigger: LineEditTrigger = LineEditTrigger.ON_FOCUS_EXITED
	):
		assert(_convert_to(TYPE_STRING), "A value bound to LineEdit must be a string.")
		var target_value_change_signal: Signal

		match trigger:
			LineEditTrigger.ON_SUBMITTED:
				target_value_change_signal = line_edit.text_submitted
			LineEditTrigger.ON_FOCUS_EXITED:
				var edit_wrapper = EditWrapper.new(line_edit)
				target_value_change_signal = edit_wrapper.focus_exited_without_ui_cancel
				# gdlint:ignore = private-method-call
				_source._add_wrapper(_source_property, edit_wrapper)
			LineEditTrigger.ON_CHANGED:
				target_value_change_signal = line_edit.text_changed

		to(line_edit, &"text", target_value_change_signal)

	func to_range(range: Range, target_value_change_signal = range.value_changed):
		assert(_convert_to(TYPE_FLOAT), "A value bound to Range must be a float.")
		to(range, &"value", target_value_change_signal)

	func to_progress_bar(progress_bar: ProgressBar):
		assert(_convert_to(TYPE_FLOAT), "A value bound to ProgressBar must be a float.")
		to_range(progress_bar, null)

	func to_slider(slider: Slider):
		assert(_convert_to(TYPE_FLOAT), "A value bound to Slider must be a float.")
		to_range(slider)

	func to_spin_box(spin_box: SpinBox):
		assert(_convert_to(TYPE_FLOAT), "A value bound to SpinBox must be a float.")
		to_range(spin_box)

	func to_texture_progress_bar(texture_progress_bar: TextureProgressBar):
		assert(_convert_to(TYPE_FLOAT), "A value bound to TextureProgressBar must be a float.")
		to_range(texture_progress_bar, null)

	func to_tab_bar(tab_bar: TabBar):
		assert(_convert_to(TYPE_INT), "A value bound to TabBar must be an int.")
		to(tab_bar, &"current_tab", tab_bar.tab_selected)

	func to_text_edit(
		text_edit: TextEdit, trigger: TextEditTrigger = TextEditTrigger.ON_FOCUS_EXITED
	):
		assert(_convert_to(TYPE_STRING), "A value bound to TextEdit must be a string.")

		var target_value_change_signal: Signal

		match trigger:
			TextEditTrigger.ON_FOCUS_EXITED:
				var edit_wrapper = EditWrapper.new(text_edit)
				target_value_change_signal = edit_wrapper.focus_exited_without_ui_cancel
				# gdlint:ignore = private-method-call
				_source._add_wrapper(_source_property, edit_wrapper)
			TextEditTrigger.ON_CHANGED:
				var text_edit_wrapper = TextEditWrapper.new(text_edit)
				target_value_change_signal = text_edit_wrapper.text_changed
				# gdlint:ignore = private-method-call
				_source._add_wrapper(_source_property, text_edit_wrapper)

		to(text_edit, &"text", target_value_change_signal)

	func to_code_edit(
		code_edit: CodeEdit, trigger: TextEditTrigger = TextEditTrigger.ON_FOCUS_EXITED
	):
		assert(_convert_to(TYPE_STRING), "A value bound to CodeEdit must be a string.")
		to_text_edit(code_edit, trigger)

	func _convert_to(target_type: Variant.Type):
		assert(
			_source_property in _source,
			"The source property %s was not in the source object." % _source_property
		)
		var source_value = _source[_source_property]
		var target_value = _converter_pipeline.source_to_target(source_value)
		return typeof(target_value) == target_type


# gdlint:ignore = max-public-methods
class Unbinder:
	var _source: BindingSource
	var _source_property: StringName

	func _init(source: BindingSource, source_property: StringName):
		_source = source
		_source_property = source_property

	func from(target_object, target_property: StringName):
		_source.unbind_from(_source_property, target_object, target_property)

	func from_toggle_button(button: BaseButton):
		from(button, &"button_pressed")

	func from_check_box(check_box: CheckBox):
		from_toggle_button(check_box)

	func from_check_button(check_button: CheckButton):
		from_toggle_button(check_button)

	func from_color_picker_button(color_picker_button: ColorPickerButton):
		from(color_picker_button, &"color")

	func from_option_button(option_button: OptionButton):
		from(option_button, &"selected")

	func from_texture_button(texture_button: TextureButton):
		from_toggle_button(texture_button)

	func from_color_rect(color_rect: ColorRect):
		from(color_rect, &"color")

	func from_color_picker(color_picker: ColorPicker):
		from(color_picker, &"color")

	func from_split_container(split_container: SplitContainer):
		from(split_container, &"split_offset")

	func from_tab_container(tab_container: TabContainer):
		from(tab_container, &"current_tab")

	func from_label(label: Label):
		from(label, &"text")

	func from_line_edit(line_edit: LineEdit):
		# gdlint:ignore = private-method-call
		_source._remove_wrapper(_source_property, line_edit)
		from(line_edit, &"text")

	func from_range(range: Range):
		from(range, &"value")

	func from_progress_bar(progress_bar: ProgressBar):
		from_range(progress_bar)

	func from_slider(slider: Slider):
		from_range(slider)

	func from_spin_box(spin_box: SpinBox):
		from_range(spin_box)

	func from_texture_progress_bar(texture_progress_bar: TextureProgressBar):
		from_range(texture_progress_bar)

	func from_tab_bar(tab_bar: TabBar):
		from(tab_bar, &"current_tab")

	func from_text_edit(text_edit: TextEdit):
		# gdlint:ignore = private-method-call
		_source._remove_wrapper(_source_property, text_edit)
		from(text_edit, &"text")

	func from_code_edit(code_edit: CodeEdit):
		from_text_edit(code_edit)


class Wrapper:
	var _object: Object

	func _init(object: Object):
		_object = object

	func wraps(object: Object):
		return _object == object


class EditWrapper:
	extends Wrapper

	signal focus_exited_without_ui_cancel(new_text: String)

	var _is_canceled: bool = false

	func _init(edit):
		super(edit)

		assert(edit is LineEdit or edit is TextEdit)

		edit.focus_exited.connect(_on_focus_exited)

	func _on_focus_exited():
		if Input.is_action_pressed("ui_cancel"):
			return

		focus_exited_without_ui_cancel.emit(_object.text)


class TextEditWrapper:
	extends Wrapper

	signal text_changed(new_text: String)

	func _init(text_edit: TextEdit):
		super(text_edit)

		text_edit.text_changed.connect(_on_text_changed)

	func _on_text_changed():
		text_changed.emit(_object.text)
