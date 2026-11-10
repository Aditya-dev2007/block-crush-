## BLOCK RUSH — HomeScreen Script
## Featuring Daily Challenge streak integration and visual pulse.

extends Control

@onready var best_score_label: Label  = $VBox/BestScorePanel/BestScoreLabel
@onready var play_button:      Button = $VBox/PlayButton
@onready var daily_button:     Button = $VBox/DailyButton
@onready var settings_button:  Button = $VBox/SettingsButton
@onready var logo_label:       Label  = $VBox/LogoLabel

func _ready() -> void:
	GameState.load_settings()
	var best := SaveManager.load_best_score()
	var streak := SaveManager.get_daily_streak()
	var daily_done := SaveManager.is_daily_completed_today()

	if streak > 0:
		best_score_label.text = "🏆 BEST: %d   •   🔥 %d DAY STREAK" % [best, streak]
	else:
		best_score_label.text = "🏆 BEST SCORE: %d" % best

	if daily_done:
		daily_button.text = "⭐ DAILY: COMPLETE (🔥 %d)" % streak
	elif streak > 0:
		daily_button.text = "📅 DAILY CHALLENGE (🔥 %d)" % streak
	else:
		daily_button.text = "📅 DAILY CHALLENGE"

	play_button.pressed.connect(_on_play_pressed)
	daily_button.pressed.connect(_on_daily_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

	_start_pulse_animation()

func _start_pulse_animation() -> void:
	# Set pivot center for smooth pulse
	play_button.pivot_offset = play_button.size * 0.5
	var tw := create_tween().set_loops()
	tw.tween_property(play_button, "scale", Vector2(1.04, 1.04), 0.75).set_trans(Tween.TRANS_SINE)
	tw.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.75).set_trans(Tween.TRANS_SINE)

func _on_play_pressed() -> void:
	AudioManager.play_button_tap()
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/gameplay/gameplay_screen.tscn")

func _on_daily_pressed() -> void:
	AudioManager.play_button_tap()
	GameState.start_daily_run()
	get_tree().change_scene_to_file("res://scenes/gameplay/gameplay_screen.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_button_tap()
	get_tree().change_scene_to_file("res://scenes/settings/settings_screen.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
