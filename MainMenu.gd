extends Control
class_name MainMenu


func _on_DailyButton_pressed():
	get_tree().change_scene("res://Scenes/DailyChallenge.tscn")


func _on_TutorialButton_pressed():
	get_tree().change_scene("res://Scenes/Tutorial.tscn")
