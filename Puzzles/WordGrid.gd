extends VBoxContainer
class_name WordGrid

signal solution_changed

var valid_lines := [false, false, false, false, false]
var words := ["", "", "", "", ""]
var scores := [0, 0, 0, 0, 0]


func _ready() -> void:
	wire_lines()


func _on_WordLine_next_line(index: int, next: WordLine):
	next.focus(index)


func _on_WordLine_previous_line(index: int, previous: WordLine):
	previous.focus(index)


func _on_WordLine_changed(valid: bool, word: String, score: int, index: int) -> void:
	valid_lines[index] = valid
	words[index] = word
	scores[index] = score
	check_solution()


func wire_lines() -> void:
	for i in range(5):
		var line := $Lines.get_child(i) as WordLine
		var next := $Lines.get_child((i + 1) % 5) as WordLine
		var previous := $Lines.get_child((i + 4) % 5) as WordLine
		line.connect("focus_next_line", self, "_on_WordLine_next_line", [next])
		line.connect("focus_previous_line", self, "_on_WordLine_previous_line", [previous])
		line.connect("word_changed", self, "_on_WordLine_changed", [i])


func set_puzzle(puzzle: PuzzleGeneratorSingleton.Puzzle) -> void:
	for i in range(5):
		var wordLine := $Lines.get_child(i) as WordLine
		var puzzleLine := puzzle.lines[i] as Array
		wordLine.set_puzzle_line(puzzleLine, puzzle.starting_word)
	$Lines/WordLine0.focus(0)
	$StartingLine.set_starting_line(puzzle.starting_word)


func check_solution() -> void:
	var valid := true
	var total_score := 0
	for i in range(5):
		if valid and not valid_lines[i]:
			valid = false
		total_score += scores[i]
	emit_signal("solution_changed", valid, total_score, words)
	
	
