extends Control
class_name Letter

signal changed
signal focus_backward
signal focus_forward
signal focus_next_line
signal focus_previous_line

const CORRECT_COLOR := Color("248a12")
const MISPLACED_COLOR := Color("fff125")
const INCORRECT_COLOR := Color("363636")

const NORMAL_MOD := Color("d1d1d1")
const HIGHLIGHT_MOD := Color("ffffff")

var operation: int
var starting_word: String
var starting_index: int
var has_focus = false
var readonly = false


func _ready() -> void:
	$ColorRect.modulate = NORMAL_MOD
	$ColorRect.color = INCORRECT_COLOR
	reset_letter()


func reset_letter(focus_only: bool = false) -> void:
	if focus_only and not has_focus:
		return
	
	$Letter.text = ""
	$Score.text = "0"
	$Score.hide()
	$Incorrect.hide()
	emit_signal("changed", "", false)


func set_letter(letter: String) -> void:
	if not has_focus:
		return
	
	var valid := check_valid(letter)
	$Letter.text = letter.to_upper()
	if valid:
		$Incorrect.hide()
		$Score.text = str(PuzzleGeneratorSingleton.LETTER_SCORES[letter])
		$Score.show()
	else:
		$Incorrect.show()
		$Score.hide()
	
	emit_signal("changed", letter, valid)


func clear_previous() -> void:
	if not has_focus:
		return
	emit_signal("focus_backward")
	get_tree().call_group("Letters", "reset_letter", true)


func set_operation_and_starting_word(operation: int, starting_word: String, starting_index: int) -> void:
	self.operation = operation
	self.starting_word = starting_word
	self.starting_index = starting_index
	if operation == PuzzleGeneratorSingleton.PuzzleOperation.LETTER_CORRECT:
		$ColorRect.color = CORRECT_COLOR
	elif operation == PuzzleGeneratorSingleton.PuzzleOperation.LETTER_MISPLACED:
		$ColorRect.color = MISPLACED_COLOR
	else:
		$ColorRect.color = INCORRECT_COLOR


func focus() -> void:
	has_focus = true
	$ColorRect.modulate = HIGHLIGHT_MOD
	get_tree().call_group("Letters", "remove_focus", self)


func remove_focus(caller: Letter) -> void:
	if caller == self or not has_focus:
		return
	has_focus = false
	$ColorRect.modulate = NORMAL_MOD


func disable() -> void:
	remove_focus(null)
	readonly = true


func enable() -> void:
	readonly = false


func check_valid(letter: String) -> bool:
	if operation == PuzzleGeneratorSingleton.PuzzleOperation.LETTER_CORRECT:
		return letter == starting_word[starting_index]
	elif operation == PuzzleGeneratorSingleton.PuzzleOperation.LETTER_MISPLACED:
		var index := starting_word.find(letter)
		return index != -1 and index != starting_index
	elif operation == PuzzleGeneratorSingleton.PuzzleOperation.LETTER_WRONG:
		return starting_word.find(letter) == -1
	return false


func set_starting_letter(letter: String) -> void:
	$Letter.text = letter.to_upper()
	$ColorRect.color = CORRECT_COLOR
	readonly = true


const KEY_SIGNAL_MAP := {
	KEY_SPACE: "focus_forward",
	KEY_RIGHT: "focus_forward",
	KEY_LEFT: "focus_backward",
	KEY_UP: "focus_previous_line",
	KEY_DOWN: "focus_next_line"
}


func _input(event: InputEvent):
	if not has_focus:
		return
	
	var key := event as InputEventKey
	if not key or key.echo or not key.pressed:
		return
	get_tree().set_input_as_handled()
	
	if key.scancode == KEY_DELETE:
		reset_letter()
		return
	
	if key.scancode == KEY_BACKSPACE:
		clear_previous()
		return
	
	if key.scancode == KEY_SPACE:
		reset_letter()
		
	var key_signal: String = KEY_SIGNAL_MAP.get(key.scancode, "")
	if key_signal:
		emit_signal(key_signal)
		return
	
	var keystring := OS.get_scancode_string(key.scancode).to_lower()
	if PuzzleGeneratorSingleton.LETTER_SCORES.has(keystring):
		set_letter(keystring)
		return


func _on_Letter_pressed() -> void:
	if readonly:
		return
	focus()



