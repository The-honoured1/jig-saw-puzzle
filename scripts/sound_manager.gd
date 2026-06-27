extends Node

var sound_enabled: bool = true
var music_enabled: bool = true

func play_click() -> void:
	if not sound_enabled:
		return
	_play_synth_beep(880.0, 0.06)

func play_snap() -> void:
	if not sound_enabled:
		return
	# Play a double-chime snapping beep
	_play_synth_beep(660.0, 0.08)
	await get_tree().create_timer(0.04).timeout
	_play_synth_beep(990.0, 0.12)

func play_win() -> void:
	if not sound_enabled:
		return
	# Play a beautiful major arpeggio
	var notes = [523.25, 659.25, 783.99, 1046.50] # C5, E5, G5, C6
	for note in notes:
		_play_synth_beep(note, 0.16)
		await get_tree().create_timer(0.08).timeout

func _play_synth_beep(frequency: float, duration: float) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = duration
	player.stream = generator
	player.play()
	
	var playback = player.get_stream_playback()
	if playback == null:
		player.queue_free()
		return
		
	var sample_count = int(generator.mix_rate * duration)
	var phase = 0.0
	var increment = frequency * 2.0 * PI / generator.mix_rate
	
	var frames = PackedVector2Array()
	for i in range(sample_count):
		var value = sin(phase) * 0.20 # Volume limit to avoid clipping
		
		# Linear fade-out envelope to avoid clicks at the end of the sound
		var envelope = 1.0 - float(i) / sample_count
		value *= envelope
		
		frames.append(Vector2(value, value))
		phase += increment
		
	playback.push_buffer(frames)
	
	# Free player after duration is complete
	await get_tree().create_timer(duration + 0.1).timeout
	player.queue_free()
