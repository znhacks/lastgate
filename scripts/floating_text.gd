extends Node2D
class_name FloatingText

@onready var label: Label = $Label

var text: String = "+10"
var color: Color = Color.WHITE
var velocity: Vector2 = Vector2(0, -60)
var lifetime: float = 0.85
var current_time: float = 0.0

func setup(p_text: String, p_color: Color, p_critical: bool = false) -> void:
	text = p_text
	color = p_color
	velocity = Vector2(randf_range(-30.0, 30.0), randf_range(-75.0, -45.0))
	if label:
		_apply_style(p_critical)

func _ready() -> void:
	_apply_style()

func _apply_style(p_critical: bool = false) -> void:
	if not label: return
	label.text = text
	label.modulate = color
	if p_critical:
		scale = Vector2(1.4, 1.4)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		scale = Vector2(1.15, 1.15)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func _process(delta: float) -> void:
	position += velocity * delta
	current_time += delta
	var alpha = 1.0 - (current_time / lifetime)
	modulate.a = clampf(alpha * 1.2, 0.0, 1.0)
	
	if current_time >= lifetime:
		queue_free()
