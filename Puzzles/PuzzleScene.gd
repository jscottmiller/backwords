extends Node
class_name PuzzleScene

const NUMBER_EMOJI := {
	0: "0️⃣",
	1: "1️⃣",
	2: "2️⃣",
	3: "3️⃣",
	4: "4️⃣",
	5: "5️⃣",
	6: "6️⃣",
	7: "7️⃣",
	8: "8️⃣",
	9: "9️⃣",
	10: "🔟"
}
const BETTER_EMOJI = "🟩"
const SAME_EMOJI = "⬛"
const WORSE_EMOJI = "🟥"
const FIRST_EMOJI = "🥇"
const SECOND_EMOJI = "🥈"
const THIRD_EMOJI = "🥉"

var puzzle: PuzzleGeneratorSingleton.Puzzle
var title: String
var puzzle_number: int
var score: int
var words: Array


func _ready() -> void:
	$"%SaveButton".hide()


func _on_SaveButton_pressed():
	save_and_update_statistics()
	show_summary_popup()


func _on_WordGrid_solution_changed(valid: bool, score: int, words: Array):
	self.score = score
	self.words = words
	
	$"%TotalScore".text = str(score)
	$"%SaveButton".visible = valid
	
	update_medal()


func set_puzzle(puzzle: PuzzleGeneratorSingleton.Puzzle, title: String, puzzle_number: int) -> void:
	self.puzzle = puzzle
	self.title = title
	self.puzzle_number = puzzle_number
	
	$"%WordGrid".set_puzzle(puzzle)
	
	update_medal()
	check_for_solution()


func check_for_solution() -> void:
	var solution := Statistics.load_solution(puzzle_number)
	if not solution:
		return
	
	for i in range(5):
		var line := $"%WordGrid/Lines".get_child(i) as WordLine
		var letters := line.find_node("Letters")
		for j in range(5):
			var letter := letters.get_child(j) as Letter
			letter.set_letter(solution[i][j])
	
	words = solution
	score = PuzzleGeneratorSingleton.score_solution(solution)
	
	show_summary_popup()


func show_summary_popup() -> void:
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "Inputs", "disable")
	
	$"%SaveButton".text = "Share and View Stats"
	
	var share_message := generate_share_message()
	$"%SummaryPopup".set_share_text(share_message)
	$"%SummaryPopup".popup()


func save_and_update_statistics() -> void:
	if Statistics.load_solution(puzzle_number):
		return
	
	Statistics.save_solution(words, puzzle_number)
	
	Statistics.statistics["completeCount"] += 1
	if score >= puzzle.score_quartiles[3]:
		Statistics.statistics["goldCount"] += 1
	elif score >= puzzle.score_quartiles[2]:
		Statistics.statistics["silverCount"] += 1
	elif score >= puzzle.score_quartiles[1]:
		Statistics.statistics["bronzeCount"] += 1
	
	if Statistics.statistics["lastFinish"] == puzzle_number - 1:
		Statistics.statistics["streakCount"] += 1
	else:
		Statistics.statistics["streakCount"] = 1
	
	Statistics.statistics["lastFinish"] = puzzle_number
	Statistics.save_stats()


func update_medal() -> void:
	var medal_text: String
	if score >= puzzle.score_quartiles[3]:
		medal_text = "You got gold!".format([puzzle.score_quartiles[4]])
	elif score >= puzzle.score_quartiles[2]:
		medal_text = "{0} points for Gold".format([puzzle.score_quartiles[3]])
	elif score >= puzzle.score_quartiles[1]:
		medal_text = "{0} points for Silver".format([puzzle.score_quartiles[2]])
	else:
		medal_text = "{0} points for Bronze".format([puzzle.score_quartiles[1]])
	$"%MedalLabel".text = medal_text


func generate_share_message() -> String:
	var medal := ""
	if score >= puzzle.score_quartiles[3]:
		medal = " " + FIRST_EMOJI
	elif score >= puzzle.score_quartiles[2]:
		medal = " " + SECOND_EMOJI
	elif score >= puzzle.score_quartiles[1]:
		medal = " " + THIRD_EMOJI
		
	var message := "{title}: {score}{medal}\n".format({
		"title": title,
		"score": score,
		"medal": medal
	})
	for i in range(5):
		var line := ""
		for j in range(5):
			var letter: String = words[i][j]
			var score: int = PuzzleGeneratorSingleton.LETTER_SCORES[letter]
			line += NUMBER_EMOJI[score]
		message += "\n" + line
	message += "\n\nhttps://cowboyscott.gg/backwords"
	
	return message
