extends Node2D
class_name EnemyMelee

signal scored(points: int, label: String, pos: Vector2, color: Color)
signal damaged(amount: int, pos: Vector2)

const GATE_Y: float = 1080.0
const DEFAULT_HIT_ZONE_TOP: float = 800.0

@export var speed: float = 200.0
var lane: int = 0
var is_active: bool = true
var anim_time: float = 0.0

var archaxas_tex = preload("res://assets/archaxas.png")
var abraxas_tex = preload("res://assets/abraxas.png")

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if sprite:
		# Randomly pick Archaxas or Abraxas as walking soldier
		if randf() < 0.5 and abraxas_tex:
			sprite.texture = abraxas_tex
		elif archaxas_tex:
			sprite.texture = archaxas_tex
			
		sprite.flip_h = false  # upright facing player below
		sprite.rotation = 0.0  # stay upright
		
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
		sprite.position.x = sin(anim_time) * 3.0
	queue_redraw()
	
	# Reached gate wall at the bottom
	if position.y > GATE_Y:
		is_active = false
		emit_signal("damaged", 1, global_position)
		queue_free()

func _draw() -> void:
	if not is_active:
		return
	var pulse = sin(anim_time * 0.7) * 4.0
	var r = 40.0 + pulse
	# Layered luminous red glow behind hostile enemy
	draw_circle(Vector2(0, 0), r, Color(1.0, 0.08, 0.08, 0.24))
	draw_circle(Vector2(0, 0), r * 0.7, Color(1.0, 0.2, 0.15, 0.42))
	draw_circle(Vector2(0, 0), r * 0.42, Color(1.0, 0.45, 0.3, 0.65))
	# Subtle ground danger ring
	draw_arc(Vector2(0, 32), 22.0 + pulse * 0.5, 0, TAU, 24, Color(1.0, 0.2, 0.2, 0.7), 2.0)

# Called when player clashes on this lane
func clash_hit(hit_zone_top: float = DEFAULT_HIT_ZONE_TOP, base_pts: int = 25) -> bool:
	if not is_active:
		return false
	if position.y <= GATE_Y + 25.0 and position.y >= hit_zone_top:
		is_active = false
		if SoundManager.instance:
			SoundManager.instance.play_sweep()
		if MainGame.instance:
			MainGame.instance.apply_screen_shake(8.0)
			MainGame.instance.spawn_explosion(global_position, Color(0.97, 0.72, 0.19), 22)
		emit_signal("scored", base_pts, "CLASH!", global_position, Color(0.97, 0.72, 0.19))
		queue_free()
		return true
	return false

# Called when hit by a deflected projectile
func hit_by_deflect(base_pts: int = 80) -> void:
	if not is_active:
		return
	is_active = false
	if SoundManager.instance:
		SoundManager.instance.play_explosion()
	if MainGame.instance:
		MainGame.instance.apply_screen_shake(10.0)
		MainGame.instance.spawn_explosion(global_position, Color(0.3, 0.85, 1.0), 30)
	emit_signal("scored", base_pts, "BOUNCE KILL!", global_position, Color(0.35, 0.9, 1.0))
	queue_free()
