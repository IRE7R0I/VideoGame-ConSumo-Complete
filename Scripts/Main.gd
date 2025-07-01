extends Node

@export var enemy_scene: PackedScene
@export var good_food_scene: PackedScene
@export var bad_food_scene: PackedScene
@export var globe_fish_scene: PackedScene

var kilogram
var health  # o lo que quieras
var life
var objective_kilogram
var generated_meals #Cada 10 comidas genera un pez globo
var bad_probability
var timer_difficult #creo que esta mal escrito tan buen ingles no tengo jajaja
var level
var kilogram_count_life

func _ready() -> void:
	new_game()

func new_game():
	$PlayButtonSound.play()
	kilogram = 20
	health = 100  
	life = 3
	objective_kilogram = 60
	generated_meals = 0 
	bad_probability = 0.35
	timer_difficult = 0.0
	level = 1
	kilogram_count_life = 0
	$HUD.show_message("Preparate...")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_kilograms(kilogram)
	$HUD.update_health_bar(health)
	$HUD.update_lives(life)
	$HUD.update_level(level)
	
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("goodfoods", "queue_free")
	get_tree().call_group("badfoods", "queue_free")
	get_tree().call_group("globefishes", "queue_free")

func game_over():
	$MusicInGame.stop()
	$DeathSound.play()
	$EnemyTimer.stop()
	$FoodTimer.stop()
	$Player.hide()
	$Player.disabledColision()
	$HUD.update_health_bar(0)
	$HUD.update_lives(0)
	$HUD.show_game_over(kilogram)
	$GameOverSound.play()
	
func resume_game():
	print("El juego sigue")
	get_tree().paused = false

func pause_and_announce_level(new_level: int) -> void:
	get_tree().paused = true
	var texto = "¡Nivel " + str(new_level) + " alcanzado!\nPresioná CONTINUAR"
	$HUD.show_message_in_pause(texto)
	$HUD.show_continue_button()
	

func _on_start_timer_timeout() -> void:
	$EnemyTimer.start()
	$FoodTimer.start()
	$MusicInGame.play()

func _process(delta):
	var base_prob = 0.35 #probabilidad incial minima
	var extra_prob = float(kilogram) / 600.0  # cuanto mas kg, mayor dificultad
	var total_prob = clamp(base_prob + extra_prob, 0.35, 0.9) #Se mantiene entre 0,35 y 0,90 la probabilidad
	bad_probability = total_prob

func get_spawn_direction(pos: Vector2) -> Vector2:
	var screen = get_viewport().get_visible_rect().size
	if pos.y >= screen.y - 10:
		return Vector2(0, -1)  # de abajo hacia arriba
	elif pos.y <= 10:
		return Vector2(0, 1)   # de arriba hacia abajo
	elif pos.x <= 10:
		return Vector2(1, 0)   # de izquierda a derecha
	else:
		return Vector2(-1, 0)  # de derecha a izquierda

func _on_touched_food(efecto: String):
	if efecto == "buena":
		$GoodFoodSound.play()
		kilogram += 10
		kilogram_count_life += 10
		if kilogram_count_life >= 100:
			life += 1 
			kilogram_count_life = 0
		health += 10
		if health > 100:
			health = 100
	elif efecto == "mala":
		$BadFoodSound.play()
		kilogram -= 15
		if kilogram < 0:
			kilogram = 0  # Evitá mostrar valores negativos
		health -= 10
		if health <= 0:
			died()
	elif efecto == "instakill":
		died()
	

	if kilogram >= objective_kilogram: #Para cuando aumente el objetivo de 
		health = 25
		objective_kilogram *= 2
		
		level += 1
		pause_and_announce_level(level)
	

	$HUD.update_kilograms(kilogram)
	$HUD.update_health_bar(health)
	$HUD.update_lives(life)
	$HUD.update_level(level)

func died():
	$DeathSound.play()
	health = 50
	life -= 1
	$Player.respawn($StartPosition.position)
	if life <= 0:
		health = 0
		game_over()
		return

func _on_food_timer_timeout() -> void:
	generated_meals += 1
	var food
	if generated_meals % 5 == 0: #Cada 5 comidas malas se genera un pez globo
		food = globe_fish_scene.instantiate()
	elif randf() < bad_probability:
		food = bad_food_scene.instantiate()
	else :
		food = good_food_scene.instantiate()
		
	var food_spawn_location = $FoodPath/FoodSpawnLocation
	food_spawn_location.progress_ratio = randf()
	food.position = food_spawn_location.position
	
	#Esto es para asignar la direccion de las comidas
	var pos = food.position
	var direction = get_spawn_direction(pos)
	
	var velocity = Vector2(randf_range(150.0, 280.0),0.0)
	food.velocity = velocity.rotated(direction.angle())
	food.touched_food.connect(_on_touched_food)
	add_child(food)

func _on_enemy_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
	enemy_spawn_location.progress_ratio = randf()
	enemy.position = enemy_spawn_location.position
	
	var direction = enemy_spawn_location.rotation + deg_to_rad(90)
	var velocity = Vector2(randf_range(150.0,200.0),0.0)
	enemy.linear_velocity = velocity.rotated(direction)
	
	add_child(enemy)


func _on_player_pushed() -> void:
	$PushSound.play()
