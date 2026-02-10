extends Popup

var share_text := ""


func set_share_text(text: String) -> void:
	share_text = text


func _on_ShareButton_pressed():
	OS.set_clipboard(share_text)
	$"%ShareButton".text = "Copied!"
	$"%ShareButton/Timer".start()


func _on_Timer_timeout():
	$"%ShareButton".text = "Share Today's Score"


func _on_HideButton_pressed():
	hide()


func _on_SummaryPopup_about_to_show():
	var stats := Statistics.statistics
	
	$Panel/GridContainer/StreakCount.text = str(stats["streakCount"])
	$Panel/GridContainer/CompletedCount.text = str(stats["completeCount"])
	$Panel/GridContainer/BronzeCount.text = str(stats["bronzeCount"])
	$Panel/GridContainer/SilverCount.text = str(stats["silverCount"])
	$Panel/GridContainer/GoldCount.text = str(stats["goldCount"])
