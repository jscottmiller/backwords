extends HBoxContainer
class_name WordLine

signal focus_previous_line
signal focus_next_line
signal word_changed

var letters := PoolStringArray(["", "", "", "", ""])
var word: String


func _ready() -> void:
	wire_letters()
	check_line_solution()


func _on_Letter_focus_forward(next: Letter) -> void:
	next.focus()


func _on_Letter_focus_back(previous: Letter) -> void:
	previous.focus()


func _on_Letter_focus_next_line(index: int) -> void:
	emit_signal("focus_next_line", index)


func _on_Letter_focus_previous_line(index: int) -> void:
	emit_signal("focus_previous_line", index)


func _on_Letter_changed(letter: String, valid: bool, index: int) -> void:
	letters[index] = letter if valid else ""
	check_line_solution()
	if letter:
		var next := $Letters.get_child(index + 1)
		next.focus() if next else emit_signal("focus_next_line", 0)


func _on_DefineButton_pressed():
	get_tree().call_group("DefinitionPopups", "show_definition", word)


func wire_letters() -> void:
	for i in range(5):
		var letter := $Letters.get_child(i) as Letter
		letter.connect("changed", self, "_on_Letter_changed", [i])
		letter.connect("focus_next_line", self, "_on_Letter_focus_next_line", [i])
		letter.connect("focus_previous_line", self, "_on_Letter_focus_previous_line", [i])
		if i < 4:
			var next_letter := $Letters.get_child(i + 1) as Letter
			letter.connect("focus_forward", self, "_on_Letter_focus_forward", [next_letter])
		else:
			letter.connect("focus_forward", self, "_on_Letter_focus_next_line", [0])
		if i > 0:
			var previous_letter := $Letters.get_child(i - 1) as Letter
			letter.connect("focus_backward", self, "_on_Letter_focus_back", [previous_letter])
		else:
			letter.connect("focus_backward", self, "_on_Letter_focus_previous_line", [4])


func set_puzzle_line(puzzle_line: Array, starting_word: String) -> void:
	for i in puzzle_line.size():
		var letter := $Letters.get_child(i) as Letter
		var operation := puzzle_line[i] as int
		letter.set_operation_and_starting_word(operation, starting_word, i)


func set_starting_line(word: String) -> void:
	self.word = word
	$RowSummary/DefineButton.disabled = false
	$RowSummary/DefinitionLabel.show()
	
	$RowSummary/Score.hide()
	for i in word.length():
		var letter := $Letters.get_child(i) as Letter
		letter.set_starting_letter(word[i])


func check_line_solution() -> void:
	var score := 0
	for letter in letters:
		if not letter:
			set_invalid()
			return
		score += PuzzleGeneratorSingleton.LETTER_SCORES[letter]
	
	var word := letters.join("")
	if not PuzzleGeneratorSingleton.is_valid_word(word):
		set_invalid()
		return
	
	set_valid(word, score)


func set_invalid() -> void:
	self.word = ""
	$RowSummary/Score.text = "X"
	$RowSummary/DefinitionLabel.hide()
	$RowSummary/DefineButton.disabled = true
	emit_signal("word_changed", false, "", 0)


func set_valid(word: String, score: int) -> void:
	self.word = word
	$RowSummary/Score.text = str(score)
	$RowSummary/Score.show()
	$RowSummary/DefinitionLabel.show()
	$RowSummary/DefineButton.disabled = false
	emit_signal("word_changed", true, word, score)


func disable():
	$RowSummary/DefineButton.disabled = true
	$RowSummary/DefinitionLabel.hide()


func enable():
	$RowSummary/DefinitionLabel.show()
	$RowSummary/DefineButton.disabled = false


func focus(index: int):
	var letter := $Letters.get_child(index) as Letter
	letter.focus()
