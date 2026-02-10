extends Node

const LETTER_SCORES = {
	"a": 1,
	"b": 3,
	"c": 3,
	"d": 2,
	"e": 1,
	"f": 4,
	"g": 2,
	"h": 4,
	"i": 1,
	"j": 8,
	"k": 5,
	"l": 1,
	"m": 3,
	"n": 1,
	"o": 1,
	"p": 3,
	"q": 10,
	"r": 1,
	"s": 1,
	"t": 1,
	"u": 1,
	"v": 4,
	"w": 4,
	"x": 8,
	"y": 4,
	"z": 10 
}
const WORDS_FILENAME := "res://Puzzles/words.txt"
const DEFINITIONS_FILENAME := "res://Puzzles/definitions.txt"
const MINIMUM_SOLUTIONS = 10
const MISPLACED_LETTER_WEIGHT := 1
const WRONG_LETTER_WEIGHT := 1

var all_words: PoolStringArray
var word_set := {}
var definitions := {}


enum PuzzleOperation {
	LETTER_WRONG,
	LETTER_MISPLACED,
	LETTER_CORRECT
}


class Puzzle:
	var starting_word: String
	var score_quartiles := [0, 0, 0, 0, 0]
	var lines := []
	
	func to_dict() -> Dictionary:
		return {
			"version": 1,
			"starting_word": starting_word,
			"score_quartiles": score_quartiles,
			"lines": lines
		}
		
	func from_dict(source: Dictionary):
		if source.version > 1:
			return false
		starting_word = source.starting_word
		score_quartiles = source.score_quartiles
		lines = source.lines
		return true


func _ready():
	load_word_list()


func load_word_list():
	all_words = PoolStringArray()
	word_set = {}
	definitions = {}

	var file := File.new()
	file.open(WORDS_FILENAME, File.READ)
	while not file.eof_reached():
		var word := file.get_line().strip_edges()
		if word:
			all_words.append(word)
			word_set[word] = true
	file.close()

	# Load optional definitions file
	if file.file_exists(DEFINITIONS_FILENAME):
		file.open(DEFINITIONS_FILENAME, File.READ)
		while not file.eof_reached():
			var line := file.get_line()
			if not line:
				continue
			var parts := line.split("\t")
			if parts.size() == 2:
				definitions[parts[0]] = parts[1]
		file.close()


func is_valid_word(word: String) -> bool:
	return word_set.has(word)


func generate_puzzle(puzzle_seed: int) -> Puzzle:
	var f := File.new()
	var filename := "res://Puzzles/Generated/puzzle_{0}.json".format([puzzle_seed])
	if f.open(filename, File.READ) == OK:
		var contents := f.get_as_text()
		var puzzle := Puzzle.new()
		var parsed := JSON.parse(contents)
		if parsed.result and puzzle.from_dict(parsed.result):
			return puzzle
	
	seed(puzzle_seed)
	
	var puzzle_attempts := 0
	while puzzle_attempts < 1000:
		var puzzle := Puzzle.new()
		puzzle.starting_word = all_words[randi() % all_words.size()] as String
		
		var total_weight := float(
			MISPLACED_LETTER_WEIGHT +
			WRONG_LETTER_WEIGHT
		)
		var misplaced_weight := MISPLACED_LETTER_WEIGHT / total_weight
		var wrong_weight := WRONG_LETTER_WEIGHT / total_weight
		
		var previous_line := [
			PuzzleOperation.LETTER_CORRECT,
			PuzzleOperation.LETTER_CORRECT,
			PuzzleOperation.LETTER_CORRECT,
			PuzzleOperation.LETTER_CORRECT,
			PuzzleOperation.LETTER_CORRECT
		]
		
		var line_attempts := 0
		while puzzle.lines.size() < 5 and line_attempts < 20:
			var operation_rand := randf()
			var index := randi() % 5
			var operation: int
			if operation_rand < misplaced_weight:
				operation = PuzzleOperation.LETTER_MISPLACED
			else:
				operation = PuzzleOperation.LETTER_WRONG
			
			if previous_line[index] == operation:
				line_attempts += 1
				continue
			
			var candidate_line = previous_line.duplicate()
			candidate_line[index] = operation
			
			var solutions := find_solutions(candidate_line, puzzle.starting_word)
			if solutions.size() < MINIMUM_SOLUTIONS:
				line_attempts += 1
				continue
			
			solutions.sort_custom(SolutionSorter, "sort")
			var _25th := solutions.size() / 4
			var quartiles = PoolStringArray([
				solutions[0],
				solutions[_25th],
				solutions[_25th * 2],
				solutions[_25th * 3],
				solutions[-1]
			])
			
			puzzle.lines.append(candidate_line)
			for i in range(5):
				puzzle.score_quartiles[i] += score(quartiles[i])
			
			previous_line = candidate_line

		if puzzle.lines.size() < 5:
			puzzle_attempts += 1
			continue
		
		return puzzle

	return null


func find_solutions(candidate_line: Array, starting_word: String) -> Array:
	var candidates := []
	for candidate_word in all_words:
		var invalid := false
		for i in range(5):
			var letter := candidate_word[i] as String
			var operation := candidate_line[i] as int
			if operation == PuzzleOperation.LETTER_CORRECT and letter != starting_word[i]:
				invalid = true
				break
			elif operation == PuzzleOperation.LETTER_MISPLACED and (starting_word.find(letter) == -1 or letter == starting_word[i]):
				invalid = true
				break
			elif operation == PuzzleOperation.LETTER_WRONG and starting_word.find(letter) >= 0:
				invalid = true
				break
		if invalid:
			continue
		candidates.append(candidate_word)
	return candidates


func score_solution(solution: Array) -> int:
	var score := 0
	for word in solution:
		score += self.score(word)
	return score


func score(word: String) -> int:
	var score := 0
	for letter in word:
		score += LETTER_SCORES[letter]
	return score


class SolutionSorter:
	static func sort(a: String, b: String) -> bool:
		return score_word(a) < score_word(b)
	
	static func score_word(word: String) -> int:
		var score := 0
		for letter in word:
			score += LETTER_SCORES[letter]
		return score
