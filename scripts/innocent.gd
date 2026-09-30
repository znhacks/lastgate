extends Node2D
class_name Innocent

signal saved(points: int, pos: Vector2)
signal hit_by_player(pos: Vector2)

const GATE_Y: float = 1080.0
const DEFAULT_HIT_ZONE_TOP: float = 800.0

@export var speed: float = 190.0
var lane: int = 0
var is_active: bool = true
var anim_time: float = 0.0

var innocent1_tex = preload("res://assets/innocent1.png")
var innocent2_tex = preload("res://assets/innocent2.png")

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if sprite:
		# Randomly pick innocent1 or innocent2
		if randf() < 0.5 and innocent2_tex:
			sprite.texture = innocent2_tex
		elif innocent1_tex:
			sprite.texture = innocent1_tex
			
		sprite.flip_h = false
		sprite.rotation = 0.0
		
		# Auto-scale to standard height (~75px)
		if sprite.texture:
			var s_size = sprite.texture.get_size()
			if s_size.y > 0:
				var s = 75.0 / s_size.y
				sprite.scale = Vector2(s, s)

func _process(delta: float) -> void:
	if not is_active:
		return
	if MainGame.instance and MainGame.instance.current_state != MainGame.GameState.PLAYING:
		return
		
	anim_time += delta * 10.0
	position.y += speed * delta
	if sprite:
		sprite.position.x = sin(anim_time) * 2.5
	queue_redraw()
		
	# Reached gate wall safely!
	if position.y > GATE_Y:
		is_active = false
		emit_signal("saved", 100, global_position)
		queue_free()

func _draw() -> void:
	if not is_active:
		return
	var pulse = sin(anim_time * 0.7) * 3.5
	var r = 38.0 + pulse
	# Friendly emerald/lime green glow aura
	draw_circle(Vector2(0, 0), r, Color(0.15, 1.0, 0.35, 0.26))
	draw_circle(Vector2(0, 0), r * 0.7, Color(0.3, 1.0, 0.5, 0.45))
	draw_circle(Vector2(0, 0), r * 0.42, Color(0.65, 1.0, 0.75, 0.65))
	# Subtle green friendly halo indicator above head
	draw_arc(Vector2(0, -44), 9.0 + pulse * 0.3, 0, TAU, 18, Color(0.4, 1.0, 0.6, 0.85), 2.0)

# Called when player clashes on this lane
func clash_hit(hit_zone_top: float = DEFAULT_HIT_ZONE_TOP) -> bool:
	if not is_active:
		return false
	if position.y <= GATE_Y + 25.0 and position.y >= hit_zone_top:
		is_active = false
		emit_signal("hit_by_player", global_position)
		queue_free()
		return true
	return false
