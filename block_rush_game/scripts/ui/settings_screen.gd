## BLOCK RUSH — Settings Screen Script
## Manages audio/accessibility preferences and displays Career Statistics.

extends Control

@onready var sound_toggle:   CheckButton = $VBox/SoundRow/SoundToggle
@onready var music_toggle:   CheckButton = $VBox/MusicRow/MusicToggle
@onready var haptics_toggle: CheckButton = $VBox/HapticsRow/HapticsToggle
@onready var reduced_toggle: CheckButton = $VBox/ReducedMotionRow/ReducedToggle
@onready var privacy_button: Button      = $VBox/PrivacyButton
@onready var back_button:    Button      = $VBox/BackButton

func _ready() -> void:
	# Load current settings
	GameState.load_settings()
	sound_toggle.button_pressed   = GameState.sound_enabled
	music_toggle.button_pressed   = GameState.music_enabled
	haptics_toggle.button_pressed = GameState.haptics_enabled
	reduced_toggle.button_pressed = GameState.reduced_motion

	sound_toggle.toggled.connect(_on_sound_toggled)
	music_toggle.toggled.connect(_on_music_toggled)
	haptics_toggle.toggled.connect(_on_haptics_toggled)
	reduced_toggle.toggled.connect(_on_reduced_toggled)
	privacy_button.pressed.connect(_on_privacy_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_setup_stats_section()

func _setup_stats_section() -> void:
	var stats_panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	var title := Label.new()
	title.text = "📊  CAREER STATISTICS"
	title.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0))
	title.add_theme_font_size_override("font_size", 15)
	vbox.add_child(title)

	var games := SaveManager.get_stat("games_played", 0)
	var lines := SaveManager.get_stat("lines_cleared", 0)
	var combo := SaveManager.get_stat("highest_combo", 0)
	var streak := SaveManager.get_daily_streak()
	var best_streak: int = int(SaveManager._config.get_value("daily", "best_streak", 0))

	var stat_lbl := Label.new()
	stat_lbl.text = "• Games Played: %d\n• Total Lines Cleared: %d\n• Highest Combo: x%d\n• Current Streak: %d Days\n• Best Streak: %d Days" % [games, lines, combo, streak, best_streak]
	stat_lbl.add_theme_font_size_override("font_size", 14)
	stat_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	vbox.add_child(stat_lbl)

	stats_panel.add_child(vbox)
	$VBox.add_child(stats_panel)
	$VBox.move_child(stats_panel, $VBox.get_child_count() - 3)

func _on_sound_toggled(value: bool) -> void:
	GameState.sound_enabled = value
	AudioManager.apply_settings()
	GameState.save_settings()
	if value:
		AudioManager.play_button_tap()

func _on_music_toggled(value: bool) -> void:
	GameState.music_enabled = value
	AudioManager.apply_settings()
	GameState.save_settings()

func _on_haptics_toggled(value: bool) -> void:
	GameState.haptics_enabled = value
	GameState.save_settings()

func _on_reduced_toggled(value: bool) -> void:
	GameState.reduced_motion = value
	GameState.save_settings()

func _on_privacy_pressed() -> void:
	AudioManager.play_button_tap()
	var d := AcceptDialog.new()
	d.title       = "Privacy Policy"
	d.dialog_text = "Block Rush is an offline, privacy-first game.\nNo personal data, telemetry, or device identifiers are collected.\nAll statistics and high scores stay 100% locally on your device."
	add_child(d)
	d.popup_centered()

func _on_back_pressed() -> void:
	AudioManager.play_button_tap()
	get_tree().change_scene_to_file("res://scenes/home/home_screen.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back_pressed()
