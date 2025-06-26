extends RigidBody2D
signal push(direccion: Vector2)

func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())#Consigue un array de los movimientos
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()#Una vez que se salgan de pantalla desaparezcan de memoria
	



func _on_body_entered(body: Node) -> void:
	print("Choque contra el sumito azul")
	if body.name == "Player":
		var direction = (body.global_position - global_position).normalized()
		push.emit(direction) 
