extends Node

const STATS_FILE := "user://stats_v1.json"
const SOLUTION_FILE_TEMPLATE := "user://puzzle_{0}_solution_v1.json"

var statistics := {
	"completeCount": 0,
	"bronzeCount": 0,
	"silverCount": 0,
	"goldCount": 0,
	"streakCount": 0,
	"lastFinish": -1,
}


func _ready():
	load_stats()


func load_stats() -> void:
	var file := File.new()
	if not file.file_exists(STATS_FILE):
		return
	
	file.open(STATS_FILE, File.READ)
	var content := file.get_as_text()
	file.close()
	
	var parsed := JSON.parse(content)
	if parsed.error:
		return
	
	var read_stats := parsed.result as Dictionary
	if not parsed:
		return
	
	# Set defaults if missing
	for key in statistics.keys():
		if not read_stats.has(key):
			read_stats[key] = statistics[key]
	
	# Remove extra/old keys
	for key in read_stats.keys():
		if not statistics.has(key):
			read_stats.erase(key)
	
	statistics = read_stats


func save_stats() -> void:
	var file := File.new()
	file.open(STATS_FILE, File.WRITE)
	var contents := JSON.print(statistics)
	file.store_string(contents)
	file.close()


func load_solution(puzzle_number) -> Array:
	var filename := SOLUTION_FILE_TEMPLATE.format([puzzle_number])
	var file := File.new()
	
	if not file.file_exists(filename):
		return []
	
	file.open(filename, File.READ)
	var content := file.get_as_text()
	file.close()
	
	var parsed := JSON.parse(content)
	if parsed.error:
		return []
	
	return parsed.result as Array


func save_solution(solution: Array, puzzle_number: int):
	var filename := SOLUTION_FILE_TEMPLATE.format([puzzle_number])
	var file := File.new()
	file.open(filename, File.WRITE)
	var contents := JSON.print(solution)
	file.store_string(contents)
	file.close()
