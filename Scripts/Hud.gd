extends CanvasLayer

signal start_game

func _ready() -> void:
	$RestartButton.hide()
	$ExitButton.hide()

func update_kilograms(total: int):
	$KilogramCounter.text = "Kilos: " + str(total)

func update_lives(cantidad: int):
	$RemainingLives.text = "Vidas: " + str(cantidad)

func update_health_bar(value: int):
	$ProgressBar.value = value

func show_message(text: String):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
#
func show_game_over(total: int):
	show_message("JUEGO TERMINADO")
	await $MessageTimer.timeout
	$Message.text = "TOTAL: " + str(total) +" KILOS"
	show_message($Message.text)
	#await get_tree().create_timer(1.0).timeout
	await $MessageTimer.timeout
	$RestartButton.show()
	$ExitButton.show()
#
func _on_message_timer_timeout():
	$Message.hide()

func _on_restart_button_pressed() -> void:
	$RestartButton.hide()
	$ExitButton.hide()
	start_game.emit()

	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
