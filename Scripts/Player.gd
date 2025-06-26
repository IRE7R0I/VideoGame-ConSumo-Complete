extends Area2D

signal hit
signal pushed
@export var speed = 500
var screen_size
var invulnerability := false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	#start()
	#hide()

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO #Quiere decir Vector(0,0) como seria el vector origen
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		velocity.y += -1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed #El normalized es para que en diagonal no vaya mas rapido
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta #Para que no vaya mas rapido por los fps
	position = position.clamp(Vector2.ZERO, screen_size) #para mantenerlo en los limites de la pantalla
	
# Selección de animaciones
	if velocity.length() > 0:
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.flip_v = false
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "walk"
			
	if position.x < 15 or position.x > 835 \
	or position.y < 15 or position.y > 635: #ACORDARSE ESTO ES PARA QUE SI SE SALE DEL MAPA
		position = Vector2(425, 325)	#RESPAWNEE DEVUELTA EN EL CENTRO
		respawn(position)			#Y REUTILIZA LA FUNCION RESPAWN PARA CUANDO MUERE

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"): #Verifica si el objeto que tocó al jugador está en el grupo "enemies"
		var direction = (global_position - body.global_position).normalized() #Calcula la dirección de empuje desde el enemigo hacia el jugador.
		recibir_empujon(direction)
	else:
		hit.emit()

func disabledColision():
	$CollisionShape2D.set_deferred("disabled", true)#Desactivamos la colision
	
func recibir_empujon(dir: Vector2) -> void:
	emit_signal("pushed")
	var desplazamiento = dir * 160.0 # podés ajustar la fuerza del empujón, es 160 en este caso
	var destino = global_position + desplazamiento #se calcula desde donde esta mas el desplazamiento
	
	var tween = get_tree().create_tween()#crea una variable tween que es para desplazamientos mas "suaves"
	tween.tween_property(self, "position", destino, 0.45)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
	#La segunda linea anima la propiedad "position" desde donde estás hasta destino, en 0.5 segundos
	#TRANS_BACK da una sensación de rebote/retroceso
	#EASE_OUT hace que la animación arranque fuerte y se frene suavemente al final
	
func respawn(pos_reinicio: Vector2) -> void:
	if invulnerability:
		return  # ya está invulnerable, ignoramos
	invulnerability = true
	position = pos_reinicio  # reaparece en el centro
	
	var tween = get_tree().create_tween()
# Parpadea 3 veces en 0.25 segundos
	for i in 7:
		tween.tween_property($AnimatedSprite2D, "modulate", Color(1,1,1,0), 0.075)
		tween.tween_property($AnimatedSprite2D, "modulate", Color(1,1,1,1), 0.075)
	tween.tween_callback(func() -> void:
		invulnerability = false
	)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false#Se activa las comisiones por si estan apagadas
