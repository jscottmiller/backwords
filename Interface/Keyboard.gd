extends Control

signal keypress
signal backspace

const ROW1_KEYS = "qwertyuiop"
const ROW2_KEYS = "asdfghjkl"
const ROW3_KEYS = "zxcvbnm"


func _ready() -> void:
	layout_keys()


func layout_keys() -> void:
	layout_row($VBoxContainer/Row1, ROW1_KEYS)
	layout_row($VBoxContainer/Row2, ROW2_KEYS)
	layout_row($VBoxContainer/Row3/Letters, ROW3_KEYS)


func layout_row(container: HBoxContainer, keys: String) -> void:
	for letter in keys:
		var button := Button.new()
		button.rect_min_size = Vector2(33, 44)
		button.text = letter.capitalize()
		button.connect("pressed", self, "_on_keypress", [letter])
		container.add_child(button)


func enable() -> void:
	set_letters_disabled($VBoxContainer/Row1, false)
	set_letters_disabled($VBoxContainer/Row2, false)
	set_letters_disabled($VBoxContainer/Row3/Letters, false)
	$VBoxContainer/Row3/Backspace.disabled = false


func disable() -> void:
	set_letters_disabled($VBoxContainer/Row1, true)
	set_letters_disabled($VBoxContainer/Row2, true)
	set_letters_disabled($VBoxContainer/Row3/Letters, true)
	$VBoxContainer/Row3/Backspace.disabled = true


func set_letters_disabled(container: HBoxContainer, disabled: bool) -> void:
	for child in container.get_children():
		var button := child as Button
		if not button:
			continue
		button.disabled = disabled


func _on_keypress(key: String) -> void:
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.echo = false
	ev.scancode = OS.find_scancode_from_string(key)
	get_tree().input_event(ev)


func _on_Backspace_pressed():
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.echo = false
	ev.scancode = KEY_BACKSPACE
	get_tree().input_event(ev)
