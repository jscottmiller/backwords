extends Popup
class_name DefinitionPopup


func show_definition(word: String) -> void:
	var definition: String
	if PuzzleGeneratorSingleton.definitions.has(word):
		definition = PuzzleGeneratorSingleton.definitions[word]
	else:
		definition = "(no definition available)"

	$Panel/Definition.text = "{0}: {1}".format([word.to_upper(), definition])

	show()


func _on_CloseButton_pressed():
	hide()
