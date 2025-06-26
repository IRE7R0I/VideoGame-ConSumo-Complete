extends Area2D

signal touched_food(efecto: String)#Variable Local

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var efecto: String = "buena"  # Esto identifica el tipo de efecto
@export var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	var food_types = Array(anim_sprite.sprite_frames.get_animation_names())
	anim_sprite.animation = food_types.pick_random()
	
func _physics_process(delta: float) -> void:
	position += velocity * delta
	
func _on_area_entered(area: Area2D) -> void:
	if  area.name == "Player":
		touched_food.emit(efecto)
		queue_free()
		

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
