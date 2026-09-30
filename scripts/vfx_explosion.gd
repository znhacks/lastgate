extends CPUParticles2D
class_name VFXExplosion

func _ready() -> void:
	emitting = true
	one_shot = true
	# Auto remove when particles finish
	await get_tree().create_timer(lifetime + 0.1).timeout
	queue_free()
