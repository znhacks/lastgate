extends Node2D
class_name EnemyProjectile

signal scored(points: int, label: String, pos: Vector2, color: Color)
signal damaged(amount: int, pos: Vector2)

const GATE_Y: float = 1080.0
const DEFAULT_HIT_ZONE_TOP: float = 800.0

@export var speed: float = 300.0
var lane: int = 0
var velocity: Vector2 = Vector2.DOWN
var deflected: bool = false
var is_active: bool = true

var anim_time: float = 0.0

var fire_tex = preload("res://assets/projectile_fire.png")

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if sprite:
		sprite.texture = fire_tex
		# Fireball head is at bottom of texture -> rotation 0 points DOWN toward player
		sprite.rotation = 0.0
		
		# Auto-scale fireball to standard size (~50px)
		if sprite.texture:
			var s_size = sprite.texture.get_size()
			if s_size.y > 0:
				var s = 50.0 / s_size.y
				sprite.scale = Vector2(s, s)

func _process(delta: float) -> void:
	if not is_active:
		return
	if MainGame.instance and MainGame.instance.current_state != MainGame.GameState.PLAYING and not MainGame.instance.is_tutorial_active:
		return
	
	anim_time += delta * 12.0
	position += velocity * speed * delta
	queue_redraw()

func _draw() -> void:
	if not is_active:
		return
	var pulse = sin(anim_time) * 3.0
	if not deflected:
		# Fiery red/orange luminous glow for incoming enemy projectile
		var r = 32.0 + pulse
		draw_circle(Vector2.ZERO, r, Color(1.0, 0.08, 0.05, 0.32))
		draw_circle(Vector2.ZERO, r * 0.68, Color(1.0, 0.28, 0.1, 0.55))
		draw_circle(Vector2.ZERO, r * 0.40, Color(1.0, 0.75, 0.3, 0.75))
	else:
		# Vibrant cyan/blue glow for player deflected projectile
		var r = 36.0 + pulse
		draw_circle(Vector2.ZERO, r, Color(0.15, 0.7, 1.0, 0.35))
		draw_circle(Vector2.ZERO, r * 0.68, Color(0.4, 0.9, 1.0, 0.60))
		draw_circle(Vector2.ZERO, r * 0.40, Color(0.85, 1.0, 1.0, 0.85))
	
	if deflected:
		var parent_node = get_parent()
		if parent_node:
			for sibling in parent_node.get_children():
				if sibling == self or not sibling.get("is_active"):
					continue
				
				# 1. Collision with another incoming projectile -> Trigger MEGA AOE BLAST on lane and adjacent lanes!
				if sibling is EnemyProjectile and not sibling.deflected and sibling.lane == lane:
					if abs(sibling.position.y - position.y) < 50.0:
						_trigger_aoe_blast(parent_node, global_position)
						sibling.is_active = false
						sibling.queue_free()
						is_active = false
						queue_free()
						return
				
				# 2. Collision with EnemyMelee (Archaxas or Abraxas) in the same lane
				elif sibling is EnemyMelee and sibling.lane == lane:
					if abs(sibling.position.y - position.y) < 45.0:
						var kill_pts = 80
						if MainGame.instance and MainGame.instance.char_info.has("score_deflect_kill"):
							kill_pts = MainGame.instance.char_info["score_deflect_kill"]
						sibling.hit_by_deflect(kill_pts)
						is_active = false
						if SoundManager.instance:
							SoundManager.instance.play_explosion()
						if MainGame.instance:
							MainGame.instance.apply_screen_shake(9.0)
							MainGame.instance.spawn_explosion(global_position, Color(0.4, 0.85, 1.0), 26)
						queue_free()
						return
		
		# Out of screen at the top
		if position.y < -80.0:
			is_active = false
			queue_free()
	else:
		# Hit castle gate wall at the bottom
		if position.y > GATE_Y:
			is_active = false
			emit_signal("damaged", 1, global_position)
			queue_free()

func _trigger_aoe_blast(parent_node: Node2D, blast_pos: Vector2) -> void:
	var aoe_mult = 1.0
	if MainGame.instance and MainGame.instance.char_info.has("aoe_radius_mult"):
		aoe_mult = MainGame.instance.char_info["aoe_radius_mult"]
	
	var aoe_y_range = 170.0 * aoe_mult
	
	if SoundManager.instance:
		SoundManager.instance.play_explosion()
	if MainGame.instance:
		MainGame.instance.apply_screen_shake(20.0)
		MainGame.instance.spawn_explosion(blast_pos, Color(1.0, 0.6, 0.1), 45)
		MainGame.instance.spawn_explosion(blast_pos, Color(0.3, 0.85, 1.0), 35)
		MainGame.instance.spawn_floating_text("+150 AOE BLAST", blast_pos, Color(1.0, 0.8, 0.2), true)
		if not MainGame.instance.is_tutorial_active:
			MainGame.instance.score += int(150 * MainGame.instance.get_multiplier())
			MainGame.instance._update_hud()
	
	# Blast enemies in the current lane and adjacent vertical lanes (lane-1, lane, lane+1)
	for sibling in parent_node.get_children():
		if sibling == self or not sibling.get("is_active"):
			continue
		var s_lane = sibling.get("lane")
		if s_lane != null and abs(s_lane - lane) <= 1:
			if abs(sibling.position.y - position.y) <= aoe_y_range:
				sibling.is_active = false
				if MainGame.instance:
					MainGame.instance.spawn_explosion(sibling.global_position, Color(1.0, 0.45, 0.2), 22)
				sibling.queue_free()

func clash_hit(hit_zone_top: float = DEFAULT_HIT_ZONE_TOP, base_pts: int = 50) -> bool:
	if not is_active or deflected:
		return false
	if position.y <= GATE_Y + 25.0 and position.y >= hit_zone_top:
		deflected = true
		velocity = Vector2.UP
		speed = 540.0  # fast deflect speed upwards
		if sprite:
			sprite.rotation = PI  # Point fireball head UPwards
			sprite.modulate = Color(0.4, 0.9, 1.0)
		if SoundManager.instance:
			SoundManager.instance.play_parry()
		if MainGame.instance:
			MainGame.instance.apply_screen_shake(10.0)
			MainGame.instance.spawn_explosion(global_position, Color(0.4, 0.9, 1.0), 24)
		emit_signal("scored", base_pts, "DEFLECT", global_position, Color(0.4, 0.9, 1.0))
		return true
	return false
