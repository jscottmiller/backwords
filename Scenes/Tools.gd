extends Control
class_name Tools

var generating_thread := Thread.new()
var halt_signal := false


func _on_StartButton_pressed():
	halt_signal = false
	generating_thread.start(self, "generate_puzzles")
	$PuzzleGenerator/StartButton.disabled = true
	$PuzzleGenerator/StopButton.disabled = false


func _on_StopButton_pressed():
	halt_signal = true
	generating_thread.wait_to_finish()
	$PuzzleGenerator/StartButton.disabled = false
	$PuzzleGenerator/StopButton.disabled = true


func generate_puzzles():
	var puzzle_number := 0
	while not halt_signal:
		$PuzzleGenerator/Progress.text = "Generating {0}".format([puzzle_number])
		
		var filename := "./Puzzles/Generated/puzzle_{0}.json".format([puzzle_number])
		var f := File.new()
		if f.file_exists(filename):
			puzzle_number += 1
			continue
		
		var puzzle = PuzzleGeneratorSingleton.generate_puzzle(puzzle_number)
		if not puzzle:
			print("could not generate puzzle {0}".format([puzzle_number]))
			return

		f.open(filename, File.WRITE)
		f.store_string(JSON.print(puzzle.to_dict()))
		f.close()

		puzzle_number += 1

