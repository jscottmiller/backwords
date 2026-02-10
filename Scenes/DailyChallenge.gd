extends Control
class_name DailyChallenge

const STARTING_DATE = "2022-09-19"
const SECONDS_PER_DAY = 86400

var loading_thread = Thread.new()


func _ready() -> void:
	init_puzzle()


func init_puzzle() -> void:
	var starting_secs = Time.get_unix_time_from_datetime_string(STARTING_DATE)
	var system_now := Time.get_date_string_from_system()
	var unix_now := Time.get_unix_time_from_datetime_string(system_now)
	var puzzle_number: int = (unix_now - starting_secs) / SECONDS_PER_DAY
	
	var puzzle := PuzzleGeneratorSingleton.generate_puzzle(puzzle_number)
	
	var title := "Backwords {0}".format([puzzle_number])
	$PuzzleScene.set_puzzle(puzzle, title, puzzle_number)
