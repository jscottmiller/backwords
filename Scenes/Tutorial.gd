extends Control

const MESSAGES := [
	"Welcome to Backwords!",
	"Backwords is like other daily word puzzle games but... backwards. Let me explain.",
	"You start with the solution...",
	"...and work your way back (get it?) to the starting point.",
	"Along the way, make sure that green spaces have the same letter as the column in the first row...",
	"...and yellow spaces contain a letter from one of the other columns in the first row.",
	"Words are scored by the letters they contain. Less common letters get more points!",
	"That's it! Good luck out there!"
]

var current_message := 0


func _ready() -> void:
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "Inputs", "disable")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "HelpInputs", "disable")
	
	var puzzle := PuzzleGeneratorSingleton.generate_puzzle(2000000)
	$Puzzle.set_puzzle(puzzle, "Backwords Tutorial", 0)
	
	$TutorialPopup.popup()
	
	show_message()


func show_message() -> void:
	$TutorialPopup/Message.text = MESSAGES[current_message]
	
	var animation := $TutorialPopup/Animations.get_child(current_message) as AnimationPlayer
	animation.play("tutorial")


func _on_NextButton_pressed():
	current_message += 1
	
	if current_message == MESSAGES.size():
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
		return
	
	show_message()
