## BLOCK RUSH — AudioManager (Autoload Singleton)
## High-polish procedural audio engine.
## Features voice-pooling, acoustic wooden placement taps,
## and ascending pentatonic scale chimes for addictive combo feedback.

extends Node

const BUS_SFX   := "SFX"
const BUS_MUSIC := "Music"

# Voice pool for zero sound clipping on rapid actions
const POOL_SIZE := 8
var _sfx_pool: Array[AudioStreamPlayer] = []
var _pool_idx: int = 0

# Pentatonic scale for combos (C5, D5, E5, G5, A5, C6, D6, E6, G6, A6)
const PENTATONIC: Array = [
	523.25, 587.33, 659.25, 783.99, 880.00,
	1046.50, 1174.66, 1318.51, 1567.98, 1760.00
]

func _ready() -> void:
	_setup_buses()
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = BUS_SFX
		add_child(p)
		_sfx_pool.append(p)
	_apply_settings()

## ---- Public API ----

## Tactile woody/marble placement tap with subtle pitch decay
func play_placement() -> void:
	if not GameState.sound_enabled:
		return
	var stream := _synth_pop(540.0, 220.0, 0.07)
	_play_voice(stream)

## Ascending pentatonic chime — each consecutive combo plays the next musical note!
func play_clear(combo_level: int = 0) -> void:
	if not GameState.sound_enabled:
		return
	var idx := clampi(combo_level, 0, PENTATONIC.size() - 1)
	var freq: float = PENTATONIC[idx]
	var stream := _synth_bell(freq, 0.28)
	_play_voice(stream)

## Resonant harmonic chord for high combos
func play_combo(chain: int) -> void:
	if not GameState.sound_enabled or chain < 2:
		return
	var idx := clampi(chain + 1, 0, PENTATONIC.size() - 2)
	var f1: float = PENTATONIC[idx]
	var f2: float = PENTATONIC[idx + 1]
	var stream := _synth_chord(f1, f2, 0.38)
	_play_voice(stream)

## Celebratory rising fanfare for new record or daily challenge complete
func play_celebration() -> void:
	if not GameState.sound_enabled:
		return
	var stream := _synth_fanfare()
	_play_voice(stream)

## Soft game-over chord
func play_game_over() -> void:
	if not GameState.sound_enabled:
		return
	var stream := _synth_tone_decay(330.0, 180.0, 0.55)
	_play_voice(stream)

## Crisp UI bubble tap
func play_button_tap() -> void:
	if not GameState.sound_enabled:
		return
	var stream := _synth_pop(780.0, 420.0, 0.045)
	_play_voice(stream)

func apply_settings() -> void:
	_apply_settings()

## ---- Private Synthesis Helpers ----

func _play_voice(stream: AudioStreamWAV) -> void:
	if _sfx_pool.is_empty():
		return
	var player := _sfx_pool[_pool_idx]
	_pool_idx = (_pool_idx + 1) % POOL_SIZE
	player.stream = stream
	player.play()

func _setup_buses() -> void:
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, BUS_SFX)
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, BUS_MUSIC)

func _apply_settings() -> void:
	var sfx_bus := AudioServer.get_bus_index(BUS_SFX)
	if sfx_bus >= 0:
		AudioServer.set_bus_mute(sfx_bus, not GameState.sound_enabled)

## Wood/plop sound with rapid pitch slide
func _synth_pop(start_freq: float, end_freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.format   = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo   = false

	var data := PackedByteArray()
	data.resize(num_samples)
	var phase: float = 0.0
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var progress := t / duration
		var freq := lerpf(start_freq, end_freq, progress)
		phase += TAU * freq * (1.0 / float(sample_rate))
		var envelope := (1.0 - progress) * (1.0 - progress)
		var sample := sin(phase) * envelope * 0.75
		data[i] = int(sample * 127.0) & 0xFF

	stream.data = data
	return stream

## Musical bell with overtone harmonic
func _synth_bell(freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.format   = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo   = false

	var data := PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var progress := t / duration
		var env := exp(-progress * 4.5)
		# Fundamental + 2nd harmonic + subtle 3rd
		var s := (sin(TAU * freq * t) * 0.7 + sin(TAU * (freq * 2.01) * t) * 0.22 + sin(TAU * (freq * 3.0) * t) * 0.08) * env * 0.75
		data[i] = int(s * 127.0) & 0xFF

	stream.data = data
	return stream

## Dual-tone chord for combo highlights
func _synth_chord(f1: float, f2: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.format   = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo   = false

	var data := PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var progress := t / duration
		var env := exp(-progress * 3.8)
		var s := (sin(TAU * f1 * t) * 0.5 + sin(TAU * f2 * t) * 0.5) * env * 0.7
		data[i] = int(s * 127.0) & 0xFF

	stream.data = data
	return stream

## Rising 4-tone celebration arpeggio
func _synth_fanfare() -> AudioStreamWAV:
	var sample_rate := 22050
	var note_dur := 0.1
	var notes := [523.25, 659.25, 783.99, 1046.50]
	var total_dur := note_dur * float(notes.size()) + 0.3
	var num_samples := int(sample_rate * total_dur)

	var stream := AudioStreamWAV.new()
	stream.format   = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo   = false

	var data := PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var sample: float = 0.0
		for n in range(notes.size()):
			var note_start := float(n) * note_dur
			if t >= note_start:
				var note_t := t - note_start
				var env := exp(-note_t * 5.0)
				sample += sin(TAU * notes[n] * note_t) * env * 0.28
		data[i] = int(clampf(sample, -1.0, 1.0) * 127.0) & 0xFF

	stream.data = data
	return stream

func _synth_tone_decay(f_start: float, f_end: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.format   = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo   = false

	var data := PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var progress := t / duration
		var freq := lerpf(f_start, f_end, progress)
		var env := exp(-progress * 2.5)
		var sample := sin(TAU * freq * t) * env * 0.6
		data[i] = int(sample * 127.0) & 0xFF

	stream.data = data
	return stream
