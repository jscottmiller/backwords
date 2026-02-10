extends Label


func _on_WordGrid_solution_changed(valid: bool, score: int):
	text = str(score)
