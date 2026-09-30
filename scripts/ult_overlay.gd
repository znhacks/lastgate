extends Control
class_name UltOverlay

var sugar_rush_time: float = 0.0

func _process(delta: float) -> void:
	if MainGame.instance:
		if MainGame.instance.is_felix_rage_active or MainGame.instance.rage_vignette_alpha > 0.01 or MainGame.instance.is_mella_flashstep_active:
			sugar_rush_time += delta * 8.0
			queue_redraw()
		else:
			queue_redraw()

func _draw() -> void:
	if not MainGame.instance:
		return
	
	var mg = MainGame.instance
	
	# 1. Felix Crimson Rage Vignette
	if mg.rage_vignette_alpha > 0.01:
		var va = clampf(mg.rage_vignette_alpha, 0.0, 1.0)
		var pulse = (sin(sugar_rush_time * 2.5) * 0.15 + 0.85) * va
		
		# Screen subtle red tint
		draw_rect(Rect2(0, 0, 720, 1280), Color(0.85, 0.05, 0.05, pulse * 0.18))
		
		# Edge vignette gradients (stepped for smooth rich border fade)
		var edge_depth = 150.0
		var steps = 8
		for s in range(steps):
			var frac = float(s) / float(steps)
			var cur_alpha = pow(1.0 - frac, 1.5) * pulse * 0.6
			var cur_d = edge_depth * (1.0 - frac)
			var col = Color(0.95, 0.02, 0.02, cur_alpha)
			
			# Top
			draw_rect(Rect2(0, 0, 720, cur_d), col)
			# Bottom
			draw_rect(Rect2(0, 1280 - cur_d, 720, cur_d), col)
			# Left
			draw_rect(Rect2(0, 0, cur_d, 1280), col)
			# Right
			draw_rect(Rect2(720 - cur_d, 0, cur_d, 1280), col)
			
		# Inner fiery border glow
		draw_rect(Rect2(12, 12, 696, 1256), Color(1.0, 0.3, 0.1, pulse * 0.7), false, 4.0)

	# 2. Mella Sugar Rush Hyperspeed Effect
	if mg.is_mella_flashstep_active:
		var st = sugar_rush_time
		var rainbow_hue = fmod(st * 0.25, 1.0)
		var neon_color = Color.from_hsv(rainbow_hue, 0.85, 1.0, 0.6)
		var neon_cyan = Color(0.2, 0.95, 1.0, 0.75)
		var neon_magenta = Color(0.95, 0.2, 0.9, 0.75)
		
		# Pulsing chromatic border
		draw_rect(Rect2(0, 0, 720, 1280), Color(neon_color.r, neon_color.g, neon_color.b, 0.09))
		draw_rect(Rect2(8, 8, 704, 1264), neon_cyan, false, 5.0)
		draw_rect(Rect2(16, 16, 688, 1248), neon_magenta, false, 3.0)
		
		# Hyperspeed vertical speed lines streaming down
		var rng = RandomNumberGenerator.new()
		rng.seed = int(st * 30.0)
		for i in range(16):
			var rx = rng.randf_range(20.0, 700.0)
			var ry = fmod(st * 900.0 + rng.randf_range(0.0, 1280.0), 1280.0)
			var rlen = rng.randf_range(70.0, 240.0)
			var line_col = neon_cyan if rng.randf() < 0.5 else neon_magenta
			line_col.a = rng.randf_range(0.4, 0.9)
			draw_line(Vector2(rx, ry), Vector2(rx, ry + rlen), line_col, rng.randf_range(1.5, 3.5))
