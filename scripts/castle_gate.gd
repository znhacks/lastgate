extends Node2D
class_name CastleGate

const GATE_Y: float = 1080.0
const GAME_WIDTH: float = 720.0
const GAME_HEIGHT: float = 1280.0

var current_lane: int = 1
var player_x: float = 270.0
var target_player_x: float = 270.0
var player_y: float = 1040.0

var clash_timers: Array[float] = [0.0, 0.0, 0.0, 0.0]
const CLASH_DURATION: float = 0.22

var anim_time: float = 0.0
var prev_player_x: float = 270.0
var afterimages: Array[Dictionary] = []
var rage_waves: Array[Dictionary] = []

var felix_game_tex = preload("res://assets/felix_game.png")
var felix_ult_tex = preload("res://assets/felix_ult.png")
var mella_game_tex = preload("res://assets/mella_game.png")
var mella_ult_tex = preload("res://assets/mella_ult.png")

func _ready() -> void:
	player_x = CharacterData.LANE_X[1]
	target_player_x = player_x
	prev_player_x = player_x

func _process(delta: float) -> void:
	anim_time += delta * 10.0
	
	var dash_mult = 1.0
	if MainGame.instance and MainGame.instance.char_info.has("dash_speed_mult"):
		dash_mult = MainGame.instance.char_info["dash_speed_mult"]
	
	# If Mella Flashstep is active, increase dash speed even further to near-teleport
	if MainGame.instance and MainGame.instance.is_mella_flashstep_active:
		dash_mult = 4.5
		if abs(player_x - target_player_x) > 10.0:
			afterimages.append({
				"x": player_x,
				"y": player_y,
				"alpha": 0.85
			})
	
	# Smoothly glide player toward target lane X with character-specific speed
	player_x = lerp(player_x, target_player_x, clampf(delta * 22.0 * dash_mult, 0.0, 1.0))
	prev_player_x = player_x
	
	for i in range(4):
		if clash_timers[i] > 0.0:
			clash_timers[i] -= delta
			if clash_timers[i] < 0.0:
				clash_timers[i] = 0.0
				
	# Update active rage waves
	var active_waves: Array[Dictionary] = []
	for wave in rage_waves:
		wave["y"] -= wave["speed"] * delta
		wave["alpha"] -= delta * 0.75
		if wave["y"] > -120.0 and wave["alpha"] > 0.0:
			active_waves.append(wave)
	rage_waves = active_waves
	
	# Update flashstep afterimages
	var active_images: Array[Dictionary] = []
	for img in afterimages:
		img["alpha"] -= delta * 4.5
		if img["alpha"] > 0.0:
			active_images.append(img)
	afterimages = active_images
				
	queue_redraw()

func trigger_clash(lane: int) -> void:
	if lane >= 0 and lane < 4:
		current_lane = lane
		target_player_x = CharacterData.LANE_X[lane]
		clash_timers[lane] = CLASH_DURATION

func trigger_rage_wave(wave_num: int) -> void:
	rage_waves.append({
		"y": GATE_Y - 20.0,
		"speed": 1400.0,
		"alpha": 1.0,
		"wave_num": wave_num
	})

func _draw() -> void:
	# ── 1. Vertical 4-Lane Track Guidelines ────────────────────────
	for i in range(4):
		var lx = CharacterData.LANE_X[i]
		var lcol = CharacterData.LANE_COLORS[i]
		
		# Faint vertical track line
		draw_line(Vector2(lx, 0), Vector2(lx, GATE_Y), Color(lcol.r, lcol.g, lcol.b, 0.08), 2.0)
		
		# Lane indicator dot near gate
		var is_active = (i == current_lane)
		var dot_alpha = 0.85 if is_active else 0.35
		var dot_rad = 6.0 if is_active else 3.5
		draw_circle(Vector2(lx, GATE_Y - 8.0), dot_rad, Color(lcol.r, lcol.g, lcol.b, dot_alpha))

	# ── 2. Castle Wall (Bottom horizontal strip) ─────────────────
	var wall_rect = Rect2(0, GATE_Y, GAME_WIDTH, GAME_HEIGHT - GATE_Y)
	draw_rect(wall_rect, Color(0.08, 0.09, 0.13))

	# Wall border top line
	draw_line(Vector2(0, GATE_Y), Vector2(GAME_WIDTH, GATE_Y), Color(0.97, 0.72, 0.19, 0.85), 4.0)

	# Battlements / Crenellations along the top of the wall
	var cren_w = 56.0
	var cren_gap = 28.0
	var total = int(ceil(GAME_WIDTH / (cren_w + cren_gap)))
	for i in range(total):
		var cx = i * (cren_w + cren_gap) + 12.0
		draw_rect(Rect2(cx, GATE_Y - 14.0, cren_w, 14.0), Color(0.12, 0.14, 0.19))
		draw_line(Vector2(cx, GATE_Y - 14.0), Vector2(cx + cren_w, GATE_Y - 14.0), Color(0.25, 0.28, 0.38), 1.5)

	# Stone seam lines across the wall
	for rx in [120.0, 240.0, 360.0, 480.0, 600.0]:
		draw_line(Vector2(rx, GATE_Y + 2), Vector2(rx, GAME_HEIGHT), Color(0.12, 0.14, 0.2, 0.7), 1.5)

	# Wall torches
	for i in range(4):
		var tx = CharacterData.LANE_X[i]
		var ty = GATE_Y + 16.0
		draw_rect(Rect2(tx - 6, ty - 3, 12, 6), Color(0.28, 0.3, 0.38))
		var flicker = sin(anim_time + float(i) * 2.0) * 2.0
		draw_circle(Vector2(tx, ty + 8), 8.0 + flicker, Color(1.0, 0.5, 0.15, 0.75))
		draw_circle(Vector2(tx, ty + 8), 3.0, Color.WHITE)

	# ── 3. Simple Visualizer In Front of Character ───────────────
	var hit_zone_top = 800.0
	if MainGame.instance and MainGame.instance.char_info.has("hit_zone_top"):
		hit_zone_top = MainGame.instance.char_info["hit_zone_top"]
	
	var active_col = CharacterData.LANE_COLORS[current_lane]
	var zone_h = GATE_Y - hit_zone_top
	var zone_w = 140.0
	var zone_rect = Rect2(player_x - zone_w / 2.0, hit_zone_top, zone_w, zone_h)
	
	# Crisp, sleek guard box above player
	draw_rect(zone_rect, Color(active_col.r, active_col.g, active_col.b, 0.08))
	draw_rect(zone_rect, Color(active_col.r, active_col.g, active_col.b, 0.35), false, 1.5)
	# Timing line at the top edge of guard zone
	draw_line(Vector2(player_x - zone_w / 2.0, hit_zone_top), Vector2(player_x + zone_w / 2.0, hit_zone_top), Color(active_col.r, active_col.g, active_col.b, 0.75), 2.5)

	# ── 4. Clash Strike VFX at Specific Lane ─────────────────────
	for i in range(4):
		if clash_timers[i] > 0.0:
			var prog = 1.0 - (clash_timers[i] / CLASH_DURATION)
			var cx = CharacterData.LANE_X[i]
			var cy = GATE_Y - 45.0 - prog * 45.0
			var lcol = CharacterData.LANE_COLORS[i]
			var alpha = (1.0 - prog)
			
			var arc_left = Vector2(cx - 40.0 * (1.0 - prog * 0.3), cy + 15.0)
			var arc_mid = Vector2(cx, cy - 15.0)
			var arc_right = Vector2(cx + 40.0 * (1.0 - prog * 0.3), cy + 15.0)
			
			var pts = PackedVector2Array([arc_left, arc_mid, arc_right])
			draw_polyline(pts, Color(lcol.r, lcol.g, lcol.b, alpha * 0.5), 14.0)
			draw_polyline(pts, Color(1.0, 1.0, 1.0, alpha * 0.95), 4.0)
			
			draw_circle(Vector2(cx, GATE_Y - 24.0), (1.0 - prog) * 22.0, Color(1.0, 1.0, 1.0, alpha * 0.85))

	# ── 5. Flashstep Afterimages (Mella) ────────────────────────
	for img in afterimages:
		var ai_tex = mella_game_tex
		if ai_tex:
			var tw = float(ai_tex.get_width())
			var th = float(ai_tex.get_height())
			var target_h = 120.0
			var target_w = target_h * (tw / th)
			var asx = img["x"] - target_w / 2.0
			var asy = GATE_Y - target_h + 8.0
			var alpha = img["alpha"] * 0.45
			draw_texture_rect(ai_tex, Rect2(asx, asy, target_w, target_h), false, Color(0.3, 0.9, 1.0, alpha))

	# ── 6. Defender Character at current player_x ────────────────
	var char_type = MainGame.instance.selected_char if MainGame.instance else CharacterData.CharacterType.FELIX
	var is_felix_ult = MainGame.instance.is_felix_rage_active if MainGame.instance else false
	var is_mella_ult = MainGame.instance.is_mella_flashstep_active if MainGame.instance else false
	
	var bob = sin(anim_time) * 2.0
	var aura_color = Color(0.97, 0.72, 0.19, 0.25) if char_type == CharacterData.CharacterType.FELIX else Color(0.65, 0.37, 0.92, 0.25)
	if is_felix_ult:
		aura_color = Color(1.0, 0.25, 0.05, 0.6)
	elif is_mella_ult:
		aura_color = Color(0.2, 0.95, 1.0, 0.6)

	# Defender glow
	var aura_radius = 42.0 if (is_felix_ult or is_mella_ult) else 32.0
	draw_circle(Vector2(player_x, GATE_Y - 60.0), aura_radius, aura_color)

	var cur_tex: Texture2D = null
	if char_type == CharacterData.CharacterType.FELIX:
		cur_tex = felix_game_tex
	elif char_type == CharacterData.CharacterType.MELLA:
		cur_tex = mella_game_tex

	if cur_tex:
		var tw = float(cur_tex.get_width())
		var th = float(cur_tex.get_height())
		var target_h = 126.0 if (is_felix_ult or is_mella_ult) else 120.0
		var target_w = target_h * (tw / th)
		var sx = player_x - target_w / 2.0
		var sy = GATE_Y - target_h + 8.0 + bob
		draw_texture_rect(cur_tex, Rect2(sx, sy, target_w, target_h), false)

	# ── 7. Colossal 4-Lane Sweeping Rage Waves (Felix) ───────────
	for wave in rage_waves:
		var wy = wave["y"]
		var wa = wave["alpha"]
		if wa <= 0.0 or wy < -100.0: continue
		
		# Massive sweeping energy crescent across entire screen (all 4 lanes)
		var left_pt = Vector2(20.0, wy + 40.0)
		var mid_pt = Vector2(360.0, wy - 30.0)
		var right_pt = Vector2(700.0, wy + 40.0)
		var arc_pts = PackedVector2Array([left_pt, mid_pt, right_pt])
		
		# Outer fiery red/crimson shockwave
		draw_polyline(arc_pts, Color(1.0, 0.15, 0.05, wa * 0.7), 28.0)
		# Middle burning gold arc
		draw_polyline(arc_pts, Color(1.0, 0.75, 0.15, wa * 0.9), 12.0)
		# Inner piercing white energy blade core
		draw_polyline(arc_pts, Color(1.0, 1.0, 1.0, wa * 0.95), 4.0)
		
		# 4-lane fiery flash circles
		for lx in CharacterData.LANE_X:
			draw_circle(Vector2(lx, wy), 24.0 * wa, Color(1.0, 0.4, 0.1, wa * 0.5))
