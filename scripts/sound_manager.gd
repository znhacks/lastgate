extends Node
class_name SoundManager

static var instance: SoundManager

var sfx_player: AudioStreamPlayer
var bgm_player_a: AudioStreamPlayer
var bgm_player_b: AudioStreamPlayer
var current_bgm_player: AudioStreamPlayer = null
var current_bgm_stream: AudioStream = null

var calma_music: AudioStream = preload("res://audio/calma.mp3")
var charge_music: AudioStream = preload("res://audio/charge.mp3")

const DEFAULT_BGM_VOLUME_DB: float = -6.0

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = &"Master"
	add_child(sfx_player)
	
	bgm_player_a = AudioStreamPlayer.new()
	bgm_player_a.bus = &"Master"
	add_child(bgm_player_a)
	
	bgm_player_b = AudioStreamPlayer.new()
	bgm_player_b.bus = &"Master"
	add_child(bgm_player_b)
	
	if calma_music is AudioStreamMP3:
		calma_music.loop = true
	if charge_music is AudioStreamMP3:
		charge_music.loop = true

func play_calma(fade_duration: float = 1.0, volume_db: float = DEFAULT_BGM_VOLUME_DB) -> void:
	play_bgm(calma_music, fade_duration, volume_db)

func play_charge(fade_duration: float = 2.0, volume_db: float = DEFAULT_BGM_VOLUME_DB) -> void:
	play_bgm(charge_music, fade_duration, volume_db)

func play_bgm(stream: AudioStream, fade_duration: float = 1.0, target_volume_db: float = DEFAULT_BGM_VOLUME_DB) -> void:
	if stream == null:
		stop_bgm(fade_duration)
		return
		
	if stream is AudioStreamMP3:
		stream.loop = true
		
	# If this stream is already active and playing
	if current_bgm_stream == stream and current_bgm_player != null and current_bgm_player.playing:
		if is_instance_valid(current_bgm_player):
			var tween = create_tween()
			tween.tween_property(current_bgm_player, "volume_db", target_volume_db, fade_duration)
		return
		
	var old_player = current_bgm_player
	var new_player = bgm_player_b if current_bgm_player == bgm_player_a else bgm_player_a
	
	current_bgm_player = new_player
	current_bgm_stream = stream
	
	new_player.stream = stream
	new_player.volume_db = -60.0
	new_player.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in new player
	tween.tween_property(new_player, "volume_db", target_volume_db, fade_duration)
	
	# Fade out old player
	if old_player != null and old_player.playing:
		var fade_out_tween = tween.tween_property(old_player, "volume_db", -60.0, fade_duration)
		tween.chain().tween_callback(func(): if old_player != current_bgm_player: old_player.stop())

func stop_bgm(fade_duration: float = 1.0) -> void:
	current_bgm_stream = null
	if current_bgm_player != null and current_bgm_player.playing:
		var player = current_bgm_player
		current_bgm_player = null
		var tween = create_tween()
		tween.tween_property(player, "volume_db", -60.0, fade_duration)
		tween.chain().tween_callback(func(): player.stop())

func _create_sine_wav(freq: float, duration: float, decay_rate: float = 12.0) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t = float(i) / sample_rate
		var envelope = exp(-t * decay_rate)
		var sample = sin(t * freq * TAU) * envelope * 0.6
		var val16 = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		var byte_idx = i * 2
		data[byte_idx] = val16 & 0xFF
		data[byte_idx + 1] = (val16 >> 8) & 0xFF
		
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav

func _create_noise_wav(duration: float, decay_rate: float = 15.0) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var rng = RandomNumberGenerator.new()
	for i in range(total_samples):
		var t = float(i) / sample_rate
		var envelope = exp(-t * decay_rate)
		var sample = (rng.randf() * 2.0 - 1.0) * envelope * 0.5
		var val16 = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		var byte_idx = i * 2
		data[byte_idx] = val16 & 0xFF
		data[byte_idx + 1] = (val16 >> 8) & 0xFF
		
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav

func play_block() -> void:
	_play_stream(_create_sine_wav(450.0, 0.15, 18.0), -4.0)

func play_sweep() -> void:
	_play_stream(_create_noise_wav(0.18, 14.0), -2.0)

func play_parry() -> void:
	_play_stream(_create_sine_wav(1200.0, 0.3, 10.0), 0.0)

func play_explosion() -> void:
	_play_stream(_create_noise_wav(0.4, 6.0), 2.0)

func play_damage() -> void:
	_play_stream(_create_sine_wav(110.0, 0.35, 8.0), 3.0)

func play_ult_activate() -> void:
	_play_stream(_create_sine_wav(880.0, 0.5, 4.0), 2.0)
	_play_stream(_create_sine_wav(1760.0, 0.4, 6.0), 0.0)

func play_rage_slash() -> void:
	_play_stream(_create_noise_wav(0.45, 4.5), 3.0)
	_play_stream(_create_sine_wav(180.0, 0.3, 8.0), 4.0)

func play_flashstep_zip() -> void:
	_play_stream(_create_sine_wav(1500.0, 0.12, 22.0), 1.0)
	_play_stream(_create_noise_wav(0.08, 25.0), -3.0)

func _play_stream(stream: AudioStream, volume_db: float = 0.0) -> void:
	var p = AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = volume_db
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
