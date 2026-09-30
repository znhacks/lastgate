extends Node2D
class_name MainGame

static var instance: MainGame

const SAVE_PATH: String = "user://game_save.json"
const GAME_WIDTH: float = 720.0
const GAME_HEIGHT: float = 1280.0
const GATE_Y: float = 1080.0

# Preloaded Scenes
var projectile_scene = preload("res://scenes/enemy_projectile.tscn")
var melee_scene = preload("res://scenes/enemy_melee.tscn")
var innocent_scene = preload("res://scenes/innocent.tscn")
var text_scene = preload("res://scenes/floating_text.tscn")
var explosion_scene = preload("res://scenes/vfx_explosion.tscn")

# Preloaded SVG Textures
var heart_full_tex = preload("res://assets/heart.svg")
var heart_empty_tex = preload("res://assets/heart_empty.svg")

# Node References
@onready var castle_gate: CastleGate = $CastleGate
@onready var enemy_container: Node2D = $EnemyContainer
@onready var vfx_container: Node2D = $VFXContainer
@onready var camera: Camera2D = $Camera2D

# HUD References
@onready var hud_root: Control = $CanvasLayer/HUD
@onready var score_label: Label = $CanvasLayer/HUD/TopHUD/ScoreContainer/Margin/VBox/ScoreLabel
@onready var highscore_label: Label = $CanvasLayer/HUD/TopHUD/HighscoreContainer/Margin/VBox/HighscoreLabel
@onready var hp_hearts: HBoxContainer = $CanvasLayer/HUD/TopHUD/HPContainer/Margin/VBox/HeartsBox
@onready var char_badge: Label = $CanvasLayer/HUD/TopHUD/HPContainer/Margin/VBox/CharBadge
@onready var diff_badge: Label = $CanvasLayer/HUD/TopHUD/HighscoreContainer/Margin/VBox/DiffBadge
@onready var btn_hud_pause: Button = $CanvasLayer/HUD/TopHUD/BtnPause

const COMBO_PHRASES: Array[String] = [
	"GREAT COMBO!",
	"NICE STRIKE!",
	"FURY FLOW!",
	"UNSTOPPABLE!",
	"CRAZY REFLEX!",
	"HYPER GUARD!",
	"PERFECT RHYTHM!",
	"GODLIKE DEFENSE!",
	"BLAZING REFLEX!"
]

# 4-Lane Action Controls
@onready var controls_container: Control = $CanvasLayer/Controls
@onready var btn_lane_0: Button = $CanvasLayer/Controls/BtnRow/BtnLane0
@onready var btn_lane_1: Button = $CanvasLayer/Controls/BtnRow/BtnLane1
@onready var btn_lane_2: Button = $CanvasLayer/Controls/BtnRow/BtnLane2
@onready var btn_lane_3: Button = $CanvasLayer/Controls/BtnRow/BtnLane3
@onready var key_hint_label: Label = $CanvasLayer/Controls/KeyHint

# Start Screen Root
@onready var start_screen: Control = $CanvasLayer/StartScreen

# Menu Panels
@onready var menu_main: Control = $CanvasLayer/StartScreen/MenuMain
@onready var btn_menu_play: Button = $CanvasLayer/StartScreen/MenuMain/Margin/VBox/ButtonsBox/BtnPlay
@onready var btn_menu_tutorial: Button = $CanvasLayer/StartScreen/MenuMain/Margin/VBox/ButtonsBox/BtnTutorial
@onready var btn_menu_defender: Button = $CanvasLayer/StartScreen/MenuMain/Margin/VBox/ButtonsBox/BtnDefender
@onready var btn_menu_settings: Button = $CanvasLayer/StartScreen/MenuMain/Margin/VBox/ButtonsBox/BtnSettings

# Difficulty Selection Panel
@onready var panel_difficulty: Control = $CanvasLayer/StartScreen/PanelDifficulty
@onready var btn_diff_easy: Button = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnEasy
@onready var btn_diff_medium: Button = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnMedium
@onready var btn_diff_hard: Button = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnHard
@onready var btn_diff_extreme: Button = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnExtreme
@onready var lbl_hs_easy: Label = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnEasy/VBox/HS
@onready var lbl_hs_medium: Label = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnMedium/VBox/HS
@onready var lbl_hs_hard: Label = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnHard/VBox/HS
@onready var lbl_hs_extreme: Label = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/Grid/BtnExtreme/VBox/HS
@onready var btn_diff_back: Button = $CanvasLayer/StartScreen/PanelDifficulty/Margin/VBox/BtnBack

# Change Defender Panel
@onready var panel_defender: Control = $CanvasLayer/StartScreen/PanelDefender
@onready var card_felix: Button = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardFelix
@onready var card_mella: Button = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardMella
@onready var tag_felix_active: Label = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardFelix/ActiveTag
@onready var tag_mella_active: Label = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardMella/ActiveTag
@onready var btn_felix_perks: Button = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardFelix/BtnPerks
@onready var btn_mella_perks: Button = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardMella/BtnPerks
@onready var panel_felix_perks: Control = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardFelix/PerksBox
@onready var panel_mella_perks: Control = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/CardsBox/CardMella/PerksBox
@onready var btn_defender_back: Button = $CanvasLayer/StartScreen/PanelDefender/Margin/VBox/BtnBack

# Settings Panel
@onready var panel_settings: Control = $CanvasLayer/StartScreen/PanelSettings
@onready var btn_bind_0: Button = $CanvasLayer/StartScreen/PanelSettings/Margin/VBox/Grid/Row0/BtnBind
@onready var btn_bind_1: Button = $CanvasLayer/StartScreen/PanelSettings/Margin/VBox/Grid/Row1/BtnBind
@onready var btn_bind_2: Button = $CanvasLayer/StartScreen/PanelSettings/Margin/VBox/Grid/Row2/BtnBind
@onready var btn_bind_3: Button = $CanvasLayer/StartScreen/PanelSettings/Margin/VBox/Grid/Row3/BtnBind
@onready var btn_settings_reset: Button = $CanvasLayer/StartScreen/PanelSettings/Margin/VBox/BtnReset
@onready var btn_settings_back: Button = $CanvasLayer/StartScreen/PanelSettings/Margin/VBox/BtnBack

# Interactive Tutorial UI
@onready var tutorial_hud: Control = $CanvasLayer/TutorialHUD
@onready var tut_step_label: Label = $CanvasLayer/TutorialHUD/Panel/Margin/VBox/TextVBox/StepLabel
@onready var tut_instruction_label: Label = $CanvasLayer/TutorialHUD/Panel/Margin/VBox/TextVBox/InstructionLabel
@onready var tut_btn_exit: Button = $CanvasLayer/TutorialHUD/Panel/Margin/VBox/BtnExitTutorial

# Game Over References
@onready var gameover_screen: Control = $CanvasLayer/GameOverScreen
@onready var restart_button: Button = $CanvasLayer/GameOverScreen/CardPanel/Margin/Card/BtnRow/RestartButton
@onready var mainmenu_button: Button = $CanvasLayer/GameOverScreen/CardPanel/Margin/Card/BtnRow/MainMenuButton
@onready var final_score_label: Label = $CanvasLayer/GameOverScreen/CardPanel/Margin/Card/Grid/BoxScore/Margin/VBox/Value
@onready var final_combo_label: Label = $CanvasLayer/GameOverScreen/CardPanel/Margin/Card/Grid/BoxCombo/Margin/VBox/Value
@onready var final_highscore_label: Label = $CanvasLayer/GameOverScreen/CardPanel/Margin/Card/Grid/BoxHighScore/Margin/VBox/Value
@onready var gameover_diff_label: Label = $CanvasLayer/GameOverScreen/CardPanel/Margin/Card/DiffLabel
@onready var new_record_tag: Label = $CanvasLayer/GameOverScreen/CardPanel/Margin/Card/NewRecordTag

# Pause Screen References
@onready var pause_screen: Control = $CanvasLayer/PauseScreen
@onready var btn_pause_resume: Button = $CanvasLayer/PauseScreen/CardPanel/Margin/Card/ButtonsBox/BtnResume
@onready var btn_pause_settings: Button = $CanvasLayer/PauseScreen/CardPanel/Margin/Card/ButtonsBox/BtnPauseSettings
@onready var btn_pause_menu: Button = $CanvasLayer/PauseScreen/CardPanel/Margin/Card/ButtonsBox/BtnPauseMenu

var is_game_paused: bool = false
var opened_settings_from_pause: bool = false

# Sound Manager
var sound_mgr: SoundManager

# Game Settings State
var selected_char: CharacterData.CharacterType = CharacterData.CharacterType.FELIX
var selected_difficulty: CharacterData.Difficulty = CharacterData.Difficulty.MEDIUM
var char_info: Dictionary = {}

var high_scores: Dictionary = {
	"EASY": 0,
	"MEDIUM": 0,
	"HARD": 0,
	"EXTREME": 0
}

var keybind_codes: Dictionary = {
	"clash_0": KEY_Z,
	"clash_1": KEY_X,
	"clash_2": KEY_C,
	"clash_3": KEY_V
}

var rebinding_action: String = ""

# Gameplay Variables
enum GameState { MENU, PLAYING, GAMEOVER }
var current_state: GameState = GameState.MENU

var score: int = 0
var hp: int = 4
var max_hp: int = 4
var combo: int = 0
var max_combo: int = 0
var game_time: float = 0.0

var spawn_timer: float = 0.0
var spawn_interval: float = 1.8
var innocent_spawn_timer: float = 4.0
var lane_hostile_cooldown: Array[float] = [0.0, 0.0, 0.0, 0.0]
var screen_shake: float = 0.0

# Interactive Tutorial State
var is_tutorial_active: bool = false
var tutorial_step: int = 0
var tutorial_spawn_cooldown: float = 0.0

# BGM Transition State
var bgm_charge_pending: bool = false
var bgm_charge_timer: float = 0.0

# ── Ultimate System State ──────────────────────────────────────
const ULT_MAX_CHARGE: int = 20
var ult_charge: int = 0
var is_felix_rage_active: bool = false
var rage_vignette_alpha: float = 0.0
var is_mella_flashstep_active: bool = false
var flashstep_charges: int = 0

# Preloaded Ult Cut-In Textures
var felix_ult_tex = preload("res://assets/felix_ult.png")
var mella_ult_tex = preload("res://assets/mella_ult.png")

# Dynamic Ult UI References
var ult_overlay: UltOverlay
var ult_meter_panel: PanelContainer
var ult_meter_bar: ProgressBar
var ult_meter_label: Label
var ult_banner: PanelContainer
var ult_banner_label: Label
var ult_cutin_root: Control
var ult_cutin_shadow_glow: TextureRect
var ult_cutin_shadow: TextureRect
var ult_cutin_portrait: TextureRect
var ult_cutin_bubble: PanelContainer
var ult_cutin_bubble_label: Label
var ult_cutin_tween: Tween

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	sound_mgr = SoundManager.new()
	SoundManager.instance = sound_mgr
	add_child(sound_mgr)
	sound_mgr.play_calma(1.0)
	
	_setup_ult_ui()
	_load_game_data()
	_apply_all_keybinds_to_inputmap()
	_select_character(selected_char)
	_bind_ui_signals()
	_show_menu_panel(menu_main)
	_update_hud()
	_refresh_keybind_buttons()
	_refresh_difficulty_hs_labels()
	
	start_screen.visible = true
	gameover_screen.visible = false
	controls_container.visible = false
	if tutorial_hud: tutorial_hud.visible = false

func _bind_ui_signals() -> void:
	# Main Menu Buttons
	if btn_menu_play:
		btn_menu_play.pressed.connect(func(): _show_menu_panel(panel_difficulty))
	if btn_menu_tutorial:
		btn_menu_tutorial.pressed.connect(start_interactive_tutorial)
	if btn_menu_defender:
		btn_menu_defender.pressed.connect(func(): _show_menu_panel(panel_defender))
	if btn_menu_settings:
		btn_menu_settings.pressed.connect(func(): _show_menu_panel(panel_settings))
		
	# Back Buttons
	if btn_diff_back:
		btn_diff_back.pressed.connect(func(): _show_menu_panel(menu_main))
	if btn_defender_back:
		btn_defender_back.pressed.connect(func(): _show_menu_panel(menu_main))
	if btn_settings_back:
		btn_settings_back.pressed.connect(func():
			rebinding_action = ""
			if opened_settings_from_pause:
				opened_settings_from_pause = false
				start_screen.visible = false
				if pause_screen: pause_screen.visible = true
			else:
				_show_menu_panel(menu_main)
		)
	if tut_btn_exit:
		tut_btn_exit.pressed.connect(_return_to_main_menu)
		
	# Pause System Buttons
	if btn_hud_pause:
		btn_hud_pause.pressed.connect(toggle_pause)
	if btn_pause_resume:
		btn_pause_resume.pressed.connect(resume_game)
	if btn_pause_settings:
		btn_pause_settings.pressed.connect(func():
			opened_settings_from_pause = true
			if pause_screen: pause_screen.visible = false
			start_screen.visible = true
			_show_menu_panel(panel_settings)
		)
	if btn_pause_menu:
		btn_pause_menu.pressed.connect(func():
			resume_game()
			_return_to_main_menu()
		)
		
	# Difficulty Launch
	if btn_diff_easy:
		btn_diff_easy.pressed.connect(func(): _start_with_difficulty(CharacterData.Difficulty.EASY))
	if btn_diff_medium:
		btn_diff_medium.pressed.connect(func(): _start_with_difficulty(CharacterData.Difficulty.MEDIUM))
	if btn_diff_hard:
		btn_diff_hard.pressed.connect(func(): _start_with_difficulty(CharacterData.Difficulty.HARD))
	if btn_diff_extreme:
		btn_diff_extreme.pressed.connect(func(): _start_with_difficulty(CharacterData.Difficulty.EXTREME))
		
	# Defender Selection & Perks Toggle
	if card_felix:
		card_felix.pressed.connect(func(): _select_character(CharacterData.CharacterType.FELIX))
	if card_mella:
		card_mella.pressed.connect(func(): _select_character(CharacterData.CharacterType.MELLA))
	if btn_felix_perks:
		btn_felix_perks.pressed.connect(func():
			if panel_felix_perks:
				panel_felix_perks.visible = not panel_felix_perks.visible
				btn_felix_perks.text = "HIDE PERKS" if panel_felix_perks.visible else "VIEW PERKS"
		)
	if btn_mella_perks:
		btn_mella_perks.pressed.connect(func():
			if panel_mella_perks:
				panel_mella_perks.visible = not panel_mella_perks.visible
				btn_mella_perks.text = "HIDE PERKS" if panel_mella_perks.visible else "VIEW PERKS"
		)
		
	# Settings Rebinds
	if btn_bind_0:
		btn_bind_0.pressed.connect(func(): _start_rebinding("clash_0", btn_bind_0))
	if btn_bind_1:
		btn_bind_1.pressed.connect(func(): _start_rebinding("clash_1", btn_bind_1))
	if btn_bind_2:
		btn_bind_2.pressed.connect(func(): _start_rebinding("clash_2", btn_bind_2))
	if btn_bind_3:
		btn_bind_3.pressed.connect(func(): _start_rebinding("clash_3", btn_bind_3))
	if btn_settings_reset:
		btn_settings_reset.pressed.connect(_reset_default_keybinds)
		
	# In-game lane buttons
	if btn_lane_0:
		btn_lane_0.pressed.connect(func(): _on_clash_lane(0))
	if btn_lane_1:
		btn_lane_1.pressed.connect(func(): _on_clash_lane(1))
	if btn_lane_2:
		btn_lane_2.pressed.connect(func(): _on_clash_lane(2))
	if btn_lane_3:
		btn_lane_3.pressed.connect(func(): _on_clash_lane(3))
		
	# Game Over Buttons
	if restart_button:
		restart_button.pressed.connect(func(): _start_with_difficulty(selected_difficulty))
	if mainmenu_button:
		mainmenu_button.pressed.connect(_return_to_main_menu)

func _show_menu_panel(target: Control) -> void:
	if menu_main: menu_main.visible = (target == menu_main)
	if panel_difficulty: panel_difficulty.visible = (target == panel_difficulty)
	if panel_defender: panel_defender.visible = (target == panel_defender)
	if panel_settings: panel_settings.visible = (target == panel_settings)
	_refresh_difficulty_hs_labels()
	_refresh_keybind_buttons()

func _select_character(type: CharacterData.CharacterType) -> void:
	selected_char = type
	char_info = CharacterData.get_character_info(type)
	max_hp = char_info["hp"]
	hp = max_hp
		
	if char_badge:
		char_badge.text = "[" + char_info["name"].to_upper() + "]"
		char_badge.modulate = char_info["theme_color"]
		
	if tag_felix_active:
		tag_felix_active.visible = (type == CharacterData.CharacterType.FELIX)
	if tag_mella_active:
		tag_mella_active.visible = (type == CharacterData.CharacterType.MELLA)
		
	if card_felix:
		card_felix.modulate = Color(1.15, 1.15, 1.15) if type == CharacterData.CharacterType.FELIX else Color(0.6, 0.6, 0.7, 0.85)
	if card_mella:
		card_mella.modulate = Color(1.15, 1.15, 1.15) if type == CharacterData.CharacterType.MELLA else Color(0.6, 0.6, 0.7, 0.85)
		
	_save_game_data()
	_rebuild_hp_hearts()
	_update_hud()
	if castle_gate:
		castle_gate.queue_redraw()

func _rebuild_hp_hearts() -> void:
	if not hp_hearts: return
	for child in hp_hearts.get_children():
		child.queue_free()
	
	for i in range(max_hp):
		var rect = TextureRect.new()
		rect.custom_minimum_size = Vector2(26, 26)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.texture = heart_full_tex if i < hp else heart_empty_tex
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hp_hearts.add_child(rect)

func _update_hp_display() -> void:
	if not hp_hearts: return
	for i in range(hp_hearts.get_child_count()):
		var rect = hp_hearts.get_child(i) as TextureRect
		if rect:
			rect.texture = heart_full_tex if i < hp else heart_empty_tex

# ── Keybind Remapping ──────────────────────────────────────────
func _start_rebinding(action: String, btn: Button) -> void:
	rebinding_action = action
	btn.text = "[ PRESS KEY ]"

func _input(event: InputEvent) -> void:
	if rebinding_action != "":
		if event is InputEventKey and event.pressed and not event.echo:
			var code = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			if code != KEY_ESCAPE:
				keybind_codes[rebinding_action] = code
				_apply_keybind_to_inputmap(rebinding_action, code)
				_save_game_data()
			rebinding_action = ""
			_refresh_keybind_buttons()
			get_viewport().set_input_as_handled()
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if current_state == GameState.PLAYING and not is_game_paused:
				pause_game()
				get_viewport().set_input_as_handled()
			elif is_game_paused:
				if opened_settings_from_pause:
					opened_settings_from_pause = false
					start_screen.visible = false
					if pause_screen: pause_screen.visible = true
				else:
					resume_game()
				get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if is_game_paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	if current_state != GameState.PLAYING: return
	is_game_paused = true
	if pause_screen:
		pause_screen.visible = true

func resume_game() -> void:
	is_game_paused = false
	if opened_settings_from_pause:
		opened_settings_from_pause = false
		start_screen.visible = false
	if pause_screen:
		pause_screen.visible = false

func _apply_keybind_to_inputmap(action: String, code: int) -> void:
	InputMap.action_erase_events(action)
	var ev = InputEventKey.new()
	ev.physical_keycode = code as Key
	InputMap.action_add_event(action, ev)
	
	var default_digit = KEY_1
	match action:
		"clash_0": default_digit = KEY_1
		"clash_1": default_digit = KEY_2
		"clash_2": default_digit = KEY_3
		"clash_3": default_digit = KEY_4
	if code != default_digit:
		var ev_digit = InputEventKey.new()
		ev_digit.physical_keycode = default_digit
		InputMap.action_add_event(action, ev_digit)

func _apply_all_keybinds_to_inputmap() -> void:
	for action in keybind_codes.keys():
		_apply_keybind_to_inputmap(action, keybind_codes[action])

func _reset_default_keybinds() -> void:
	keybind_codes = {
		"clash_0": KEY_Z,
		"clash_1": KEY_X,
		"clash_2": KEY_C,
		"clash_3": KEY_V
	}
	_apply_all_keybinds_to_inputmap()
	_save_game_data()
	_refresh_keybind_buttons()

func _get_key_name(code: int) -> String:
	return OS.get_keycode_string(code as Key).to_upper()

func _refresh_keybind_buttons() -> void:
	var k0 = _get_key_name(keybind_codes.get("clash_0", KEY_Z))
	var k1 = _get_key_name(keybind_codes.get("clash_1", KEY_X))
	var k2 = _get_key_name(keybind_codes.get("clash_2", KEY_C))
	var k3 = _get_key_name(keybind_codes.get("clash_3", KEY_V))
	
	if btn_bind_0 and rebinding_action != "clash_0": btn_bind_0.text = "[" + k0 + "]"
	if btn_bind_1 and rebinding_action != "clash_1": btn_bind_1.text = "[" + k1 + "]"
	if btn_bind_2 and rebinding_action != "clash_2": btn_bind_2.text = "[" + k2 + "]"
	if btn_bind_3 and rebinding_action != "clash_3": btn_bind_3.text = "[" + k3 + "]"
	
	if btn_lane_0: btn_lane_0.text = "L1\n[" + k0 + "]"
	if btn_lane_1: btn_lane_1.text = "L2\n[" + k1 + "]"
	if btn_lane_2: btn_lane_2.text = "L3\n[" + k2 + "]"
	if btn_lane_3: btn_lane_3.text = "L4\n[" + k3 + "]"
	
	if key_hint_label:
		key_hint_label.text = "TAP LANES 1-4 TO CLASH · KEYS: " + k0 + ", " + k1 + ", " + k2 + ", " + k3 + " / 1, 2, 3, 4"

# ── Save / Load System ─────────────────────────────────────────
func _load_game_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_str = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_str) == OK and typeof(json.data) == TYPE_DICTIONARY:
				var data = json.data
				if data.has("high_scores") and typeof(data["high_scores"]) == TYPE_DICTIONARY:
					for k in data["high_scores"].keys():
						high_scores[k] = int(data["high_scores"][k])
				if data.has("selected_char"):
					selected_char = int(data["selected_char"]) as CharacterData.CharacterType
				if data.has("keybinds") and typeof(data["keybinds"]) == TYPE_DICTIONARY:
					for a in data["keybinds"].keys():
						keybind_codes[a] = int(data["keybinds"][a])

func _save_game_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"high_scores": high_scores,
			"selected_char": selected_char,
			"keybinds": keybind_codes
		}
		file.store_string(JSON.stringify(data))
		file.close()

func _refresh_difficulty_hs_labels() -> void:
	if lbl_hs_easy: lbl_hs_easy.text = "BEST: " + str(high_scores.get("EASY", 0))
	if lbl_hs_medium: lbl_hs_medium.text = "BEST: " + str(high_scores.get("MEDIUM", 0))
	if lbl_hs_hard: lbl_hs_hard.text = "BEST: " + str(high_scores.get("HARD", 0))
	if lbl_hs_extreme: lbl_hs_extreme.text = "BEST: " + str(high_scores.get("EXTREME", 0))

# ── Interactive Gameplay Tutorial ──────────────────────────────
func start_interactive_tutorial() -> void:
	is_tutorial_active = true
	tutorial_step = 1
	current_state = GameState.PLAYING
	bgm_charge_pending = false
	ult_charge = 0
	is_felix_rage_active = false
	rage_vignette_alpha = 0.0
	is_mella_flashstep_active = false
	flashstep_charges = 0
	if ult_banner: ult_banner.visible = false
	_hide_ult_cutin(true)
	if sound_mgr:
		sound_mgr.play_calma(1.0)
	
	hp = max_hp
	score = 0
	combo = 0
	
	for child in enemy_container.get_children():
		child.queue_free()
		
	start_screen.visible = false
	gameover_screen.visible = false
	controls_container.visible = true
	hud_root.visible = false
	if tutorial_hud: tutorial_hud.visible = true
	
	_run_tutorial_step(1)

func _run_tutorial_step(step: int) -> void:
	tutorial_step = step
	var k0 = _get_key_name(keybind_codes.get("clash_0", KEY_Z))
	var k1 = _get_key_name(keybind_codes.get("clash_1", KEY_X))
	var k2 = _get_key_name(keybind_codes.get("clash_2", KEY_C))
	var k3 = _get_key_name(keybind_codes.get("clash_3", KEY_V))
	
	match step:
		1:
			if tut_step_label: tut_step_label.text = "TRAINING 1 / 5: MELEE CLASH"
			if tut_instruction_label: tut_instruction_label.text = "Walking demon approaching on LANE 2. Press [" + k1 + "] or [2] when it reaches your guard zone!"
			var melee: EnemyMelee = melee_scene.instantiate()
			melee.lane = 1
			melee.position = Vector2(CharacterData.LANE_X[1], -30.0)
			melee.speed = 180.0
			melee.scored.connect(func(pts, lbl, pos, col):
				_on_scored(pts, lbl, pos, col)
				_schedule_next_tutorial_step(2)
			)
			melee.damaged.connect(func(amt, pos):
				# In tutorial, respawn if missed
				_schedule_next_tutorial_step(1)
			)
			enemy_container.add_child(melee)
		2:
			if tut_step_label: tut_step_label.text = "TRAINING 2 / 5: FIREBALL DEFLECT"
			if tut_instruction_label: tut_instruction_label.text = "Fireball incoming on LANE 1. Press [" + k0 + "] or [1] to deflect it back!"
			var proj: EnemyProjectile = projectile_scene.instantiate()
			proj.lane = 0
			proj.position = Vector2(CharacterData.LANE_X[0], -30.0)
			proj.speed = 280.0
			proj.scored.connect(func(pts, lbl, pos, col):
				_on_scored(pts, lbl, pos, col)
				_schedule_next_tutorial_step(3)
			)
			proj.damaged.connect(func(amt, pos):
				_schedule_next_tutorial_step(2)
			)
			enemy_container.add_child(proj)
		3:
			if tut_step_label: tut_step_label.text = "TRAINING 3 / 5: DEFLECT KILL"
			if tut_instruction_label: tut_instruction_label.text = "Deflect the fireball on LANE 3 to eliminate the advancing demon behind it! Press [" + k2 + "] or [3]."
			var proj: EnemyProjectile = projectile_scene.instantiate()
			proj.lane = 2
			proj.position = Vector2(CharacterData.LANE_X[2], 120.0)
			proj.speed = 250.0
			
			var melee: EnemyMelee = melee_scene.instantiate()
			melee.lane = 2
			melee.position = Vector2(CharacterData.LANE_X[2], -80.0)
			melee.speed = 160.0
			melee.scored.connect(func(pts, lbl, pos, col):
				_on_scored(pts, lbl, pos, col)
				_schedule_next_tutorial_step(4)
			)
			enemy_container.add_child(proj)
			enemy_container.add_child(melee)
		4:
			if tut_step_label: tut_step_label.text = "TRAINING 4 / 5: PROJECTILE AOE BLAST"
			if tut_instruction_label: tut_instruction_label.text = "Deflect the lead fireball on LANE 4. It will collide with the incoming fireball and trigger a massive AoE blast!"
			var lead_proj: EnemyProjectile = projectile_scene.instantiate()
			lead_proj.lane = 3
			lead_proj.position = Vector2(CharacterData.LANE_X[3], 150.0)
			lead_proj.speed = 230.0
			
			var trail_proj: EnemyProjectile = projectile_scene.instantiate()
			trail_proj.lane = 3
			trail_proj.position = Vector2(CharacterData.LANE_X[3], -90.0)
			trail_proj.speed = 190.0
			
			var side_demon: EnemyMelee = melee_scene.instantiate()
			side_demon.lane = 2  # Adjacent lane
			side_demon.position = Vector2(CharacterData.LANE_X[2], -50.0)
			side_demon.speed = 160.0
			
			enemy_container.add_child(lead_proj)
			enemy_container.add_child(trail_proj)
			enemy_container.add_child(side_demon)
			
			lead_proj.scored.connect(func(pts, lbl, pos, col):
				_on_scored(pts, lbl, pos, col)
				_schedule_next_tutorial_step(5)
			)
		5:
			if tut_step_label: tut_step_label.text = "TRAINING 5 / 5: PROTECT INNOCENTS"
			if tut_instruction_label: tut_instruction_label.text = "An innocent civilian with a GREEN aura is fleeing on LANE 2! DO NOT CLASH — IGNORE THEM and let them enter safely."
			var inno: Innocent = innocent_scene.instantiate()
			inno.lane = 1
			inno.position = Vector2(CharacterData.LANE_X[1], -30.0)
			inno.speed = 180.0
			inno.saved.connect(func(pts, pos):
				_on_innocent_saved(pts, pos)
				_schedule_next_tutorial_step(6)
			)
			inno.hit_by_player.connect(func(pos):
				spawn_floating_text("⚠️ DO NOT HIT INNOCENTS!", pos, Color(1.0, 0.3, 0.3), true)
				_schedule_next_tutorial_step(5)
			)
			enemy_container.add_child(inno)
		6:
			if tut_step_label: tut_step_label.text = "TRAINING COMPLETE!"
			if tut_instruction_label: tut_instruction_label.text = "Outstanding reflexes! You are ready to defend the Last Gate and protect innocent lives. Press EXIT to start playing."

func _schedule_next_tutorial_step(next_step: int) -> void:
	if not is_tutorial_active: return
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(func():
		if is_tutorial_active:
			_run_tutorial_step(next_step)
	)

# ── Game Flow ──────────────────────────────────────────────────
func _start_with_difficulty(diff: CharacterData.Difficulty) -> void:
	is_tutorial_active = false
	is_game_paused = false
	opened_settings_from_pause = false
	if pause_screen: pause_screen.visible = false
	selected_difficulty = diff
	var diff_name = CharacterData.DIFFICULTY_NAMES[diff]
	var dset = CharacterData.DIFFICULTY_SETTINGS[diff]
	
	current_state = GameState.PLAYING
	score = 0
	hp = max_hp
	combo = 0
	max_combo = 0
	game_time = 0.0
	spawn_timer = 0.6
	spawn_interval = dset["spawn_base"]
	screen_shake = 0.0
	
	# Reset Ultimate State
	ult_charge = 0
	is_felix_rage_active = false
	rage_vignette_alpha = 0.0
	is_mella_flashstep_active = false
	flashstep_charges = 0
	if ult_banner: ult_banner.visible = false
	_hide_ult_cutin(true)
	
	# BGM Logic:
	if diff == CharacterData.Difficulty.HARD or diff == CharacterData.Difficulty.EXTREME:
		bgm_charge_pending = true
		bgm_charge_timer = 0.0
		if sound_mgr:
			sound_mgr.play_calma(0.5)
	else:
		bgm_charge_pending = false
		if sound_mgr:
			sound_mgr.play_calma(1.0)
	
	lane_hostile_cooldown = [0.0, 0.0, 0.0, 0.0]
	innocent_spawn_timer = randf_range(4.5, 7.5)
	
	for child in enemy_container.get_children():
		child.queue_free()
		
	start_screen.visible = false
	gameover_screen.visible = false
	controls_container.visible = true
	hud_root.visible = true
	if tutorial_hud: tutorial_hud.visible = false
	
	if diff_badge:
		diff_badge.text = "[" + diff_name + "]"
		diff_badge.modulate = dset["color"]
		
	_rebuild_hp_hearts()
	_update_hud()
	
	var intro_quote = CharacterData.get_random_quote(selected_char)
	var q_col = Color(1.0, 0.75, 0.2) if selected_char == CharacterData.CharacterType.FELIX else Color(0.55, 0.9, 1.0)
	spawn_floating_text("💬 \"" + intro_quote + "\"", Vector2(castle_gate.player_x, GATE_Y - 90.0), q_col, true)

func _return_to_main_menu() -> void:
	is_tutorial_active = false
	is_game_paused = false
	opened_settings_from_pause = false
	if pause_screen: pause_screen.visible = false
	bgm_charge_pending = false
	ult_charge = 0
	is_felix_rage_active = false
	rage_vignette_alpha = 0.0
	is_mella_flashstep_active = false
	flashstep_charges = 0
	lane_hostile_cooldown = [0.0, 0.0, 0.0, 0.0]
	if ult_banner: ult_banner.visible = false
	_hide_ult_cutin(true)
	
	if sound_mgr:
		sound_mgr.play_calma(1.5)
		
	current_state = GameState.MENU

	for child in enemy_container.get_children():
		child.queue_free()
	gameover_screen.visible = false
	controls_container.visible = false
	hud_root.visible = true
	if tutorial_hud: tutorial_hud.visible = false
	start_screen.visible = true
	_show_menu_panel(menu_main)

func _process(delta: float) -> void:
	if screen_shake > 0.0 and not is_game_paused:
		screen_shake -= delta * 35.0
		if screen_shake < 0.0: screen_shake = 0.0
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * screen_shake
	elif not is_game_paused:
		camera.offset = Vector2.ZERO
		
	if current_state != GameState.PLAYING or is_game_paused:
		return
		
	game_time += delta
	_handle_pc_input()
	
	# Update lane cooldowns for hostile enemies behind innocents
	for i in range(4):
		if lane_hostile_cooldown[i] > 0.0:
			lane_hostile_cooldown[i] -= delta
	
	# Mella Flashstep Auto-Parry Loop
	if is_mella_flashstep_active and flashstep_charges > 0:
		_process_mella_flashstep_auto_parry()
	
	# 15s BGM fade out calma and fade in charge on Hard/Extreme
	if bgm_charge_pending:
		bgm_charge_timer += delta
		if bgm_charge_timer >= 15.0:
			bgm_charge_pending = false
			if sound_mgr:
				sound_mgr.play_charge(2.0)
				
	if not is_tutorial_active:
		# Spawn innocent civilians with plenty of safe space
		innocent_spawn_timer -= delta
		if innocent_spawn_timer <= 0.0:
			_spawn_innocent()
			innocent_spawn_timer = randf_range(6.5, 11.0)

		var dset = CharacterData.DIFFICULTY_SETTINGS[selected_difficulty]
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_enemy()
			var accel = 0.025 * dset["speed_mult"]
			spawn_interval = maxf(dset["spawn_min"], dset["spawn_base"] - (game_time * accel))
			spawn_timer = spawn_interval

func _handle_pc_input() -> void:
	if is_game_paused: return
	if Input.is_action_just_pressed(&"clash_0"):
		_on_clash_lane(0)
	elif Input.is_action_just_pressed(&"clash_1"):
		_on_clash_lane(1)
	elif Input.is_action_just_pressed(&"clash_2"):
		_on_clash_lane(2)
	elif Input.is_action_just_pressed(&"clash_3"):
		_on_clash_lane(3)

func _on_clash_lane(lane: int) -> void:
	if current_state != GameState.PLAYING or is_game_paused: return
	
	castle_gate.trigger_clash(lane)
	
	var hit_top = char_info["hit_zone_top"] if char_info.has("hit_zone_top") else 800.0
	var melee_score = char_info["score_clash_melee"] if char_info.has("score_clash_melee") else 25
	var proj_score = char_info["score_clash_proj"] if char_info.has("score_clash_proj") else 50
	
	var targets = []
	for enemy in enemy_container.get_children():
		if enemy.get("lane") == lane and enemy.get("is_active"):
			targets.append(enemy)
			
	# Nearest to bottom gate (highest Y) comes first
	targets.sort_custom(func(a, b): return a.position.y > b.position.y)
	
	for enemy in targets:
		if enemy is Innocent:
			if enemy.clash_hit(hit_top):
				break
		elif enemy is EnemyProjectile:
			if enemy.clash_hit(hit_top, proj_score):
				break
		elif enemy is EnemyMelee:
			if enemy.clash_hit(hit_top, melee_score):
				break

func _spawn_innocent() -> void:
	if current_state != GameState.PLAYING or is_tutorial_active:
		return
	
	# Find candidate lanes with no hostile enemy near the top (y < 450) and cooldown == 0
	var valid_lanes: Array[int] = []
	for l in range(4):
		if lane_hostile_cooldown[l] > 0.0:
			continue
		var has_close_hostile = false
		for ent in enemy_container.get_children():
			if ent.get("is_active") and ent.get("lane") == l and ent.position.y < 450.0:
				has_close_hostile = true
				break
		if not has_close_hostile:
			valid_lanes.append(l)
			
	if valid_lanes.is_empty():
		return
		
	var lane_idx = valid_lanes[randi() % valid_lanes.size()]
	var lx = CharacterData.LANE_X[lane_idx]
	
	var inno: Innocent = innocent_scene.instantiate()
	inno.lane = lane_idx
	inno.position = Vector2(lx, -40.0)
	inno.speed = 180.0
	inno.saved.connect(_on_innocent_saved)
	inno.hit_by_player.connect(_on_innocent_hit)
	
	# Prevent hostile enemies from spawning on this lane behind the innocent for 3.5 seconds
	lane_hostile_cooldown[lane_idx] = 3.5
	enemy_container.add_child(inno)

func _spawn_enemy() -> void:
	# Filter lanes that are not locked by innocent cooldown and don't have innocent near spawn
	var available_lanes: Array[int] = []
	for l in range(4):
		if lane_hostile_cooldown[l] <= 0.0:
			var inno_near = false
			for ent in enemy_container.get_children():
				if ent is Innocent and ent.is_active and ent.lane == l and ent.position.y < 520.0:
					inno_near = true
					break
			if not inno_near:
				available_lanes.append(l)
				
	var lane_idx = randi() % 4
	if not available_lanes.is_empty():
		lane_idx = available_lanes[randi() % available_lanes.size()]
		
	var lx = CharacterData.LANE_X[lane_idx]
	var dset = CharacterData.DIFFICULTY_SETTINGS[selected_difficulty]
	var speed_bonus = minf(260.0, game_time * 6.0 * dset["speed_mult"])
	
	if randf() < 0.5:
		var proj: EnemyProjectile = projectile_scene.instantiate()
		proj.lane = lane_idx
		proj.position = Vector2(lx, -40.0)
		proj.speed = (280.0 + speed_bonus + randf_range(-15.0, 25.0)) * dset["speed_mult"]
		proj.scored.connect(_on_scored)
		proj.damaged.connect(_on_damaged)
		enemy_container.add_child(proj)
	else:
		var melee: EnemyMelee = melee_scene.instantiate()
		melee.lane = lane_idx
		melee.position = Vector2(lx, -40.0)
		melee.speed = (190.0 + speed_bonus * 0.8 + randf_range(-15.0, 20.0)) * dset["speed_mult"]
		melee.scored.connect(_on_scored)
		melee.damaged.connect(_on_damaged)
		enemy_container.add_child(melee)

func _on_innocent_saved(points: int, pos: Vector2) -> void:
	if current_state != GameState.PLAYING: return
	combo += 1
	if combo > max_combo:
		max_combo = combo
	var mult = get_multiplier()
	var earned = int(round(points * mult))
	score += earned
	spawn_floating_text("+" + str(earned) + " INNOCENT SAVED!", pos, Color(0.35, 1.0, 0.55), true)
	spawn_explosion(pos, Color(0.35, 1.0, 0.55), 20)
	_update_hud()

func _on_innocent_hit(pos: Vector2) -> void:
	if current_state != GameState.PLAYING: return
	var lost = int(score / 2.0)
	score = maxi(0, score - lost)
	combo = 0
	apply_screen_shake(22.0)
	if SoundManager.instance:
		SoundManager.instance.play_damage()
	spawn_explosion(pos, Color(1.0, 0.2, 0.25), 36)
	spawn_floating_text("-" + str(lost) + " (50% PENALTY)\nINNOCENT CASUALTY!", pos + Vector2(0, -40), Color(1.0, 0.2, 0.25), true)
	_update_hud()

func _on_scored(base_points: int, label: String, pos: Vector2, color: Color) -> void:
	combo += 1
	if combo > max_combo:
		max_combo = combo
	var mult = get_multiplier()
	var dset = CharacterData.DIFFICULTY_SETTINGS[selected_difficulty] if not is_tutorial_active else {"score_mult": 1.0}
	var earned = int(round(base_points * mult * dset["score_mult"]))
	score += earned
	
	spawn_floating_text("+" + str(earned) + " " + label, pos, color, mult > 1.0)
	
	# Exciting dynamic randomized combo text popup on screen
	if combo >= 2 and not is_tutorial_active:
		_spawn_random_combo_popup(combo, mult)
	
	# Ultimate Charge Progression (Every 20 eliminations)
	if not is_tutorial_active and current_state == GameState.PLAYING:
		if not is_felix_rage_active and not is_mella_flashstep_active:
			ult_charge += 1
			if ult_charge >= ULT_MAX_CHARGE:
				ult_charge = 0
				_trigger_ultimate()
				
	_update_hud()

func _spawn_random_combo_popup(cur_combo: int, cur_mult: float) -> void:
	var phrase = COMBO_PHRASES[randi() % COMBO_PHRASES.size()]
	var combo_text = str(cur_combo) + "x " + phrase
	if cur_mult > 1.0:
		combo_text += " (x" + str(snappedf(cur_mult, 0.1)) + ")"
		
	# Pick dynamic randomized positions across mid-screen action area
	var rand_x = randf_range(130.0, 590.0)
	var rand_y = randf_range(460.0, 780.0)
	var popup_pos = Vector2(rand_x, rand_y)
	
	# Pick vibrant colors based on combo level
	var col = Color(1.0, 0.85, 0.25) # Gold
	if cur_combo >= 15:
		col = Color(0.95, 0.25, 0.85) # Neon Magenta
	elif cur_combo >= 10:
		col = Color(0.25, 0.95, 1.0) # Neon Cyan
	elif cur_combo >= 5:
		col = Color(1.0, 0.45, 0.15) # Fiery Orange
		
	var is_crit = (cur_combo % 5 == 0) or cur_combo >= 8
	spawn_floating_text(combo_text, popup_pos, col, is_crit)
	
	# Trigger character battle callout at combo milestones (5, 10, 15, 20...)
	if cur_combo % 5 == 0:
		var char_quote = CharacterData.get_random_quote(selected_char)
		var q_col = Color(1.0, 0.75, 0.2) if selected_char == CharacterData.CharacterType.FELIX else Color(0.55, 0.9, 1.0)
		spawn_floating_text("💬 \"" + char_quote + "\"", Vector2(castle_gate.player_x, GATE_Y - 90.0), q_col, true)

func _on_damaged(amount: int, pos: Vector2) -> void:
	if current_state != GameState.PLAYING:
		return
	if is_tutorial_active:
		# Protected in tutorial
		return
		
	hp = maxi(0, hp - amount)
	combo = 0
	apply_screen_shake(16.0)
	if SoundManager.instance:
		SoundManager.instance.play_damage()
	spawn_explosion(pos, Color(1.0, 0.28, 0.34), 28)
	spawn_floating_text("-1 HP", pos + Vector2(30, -35), Color(1.0, 0.28, 0.34), true)
	_update_hp_display()
	_update_hud()
	
	if hp <= 0:
		_trigger_game_over()

func _trigger_game_over() -> void:
	if current_state == GameState.GAMEOVER:
		return
	current_state = GameState.GAMEOVER
	bgm_charge_pending = false
	ult_charge = 0
	is_felix_rage_active = false
	rage_vignette_alpha = 0.0
	is_mella_flashstep_active = false
	flashstep_charges = 0
	if ult_banner: ult_banner.visible = false
	_hide_ult_cutin(true)
	
	for enemy in enemy_container.get_children():
		if "is_active" in enemy:
			enemy.is_active = false
			
	var diff_name = CharacterData.DIFFICULTY_NAMES[selected_difficulty]
	var current_best = high_scores.get(diff_name, 0)
	var is_new_record = false
	if score > current_best:
		high_scores[diff_name] = score
		_save_game_data()
		is_new_record = true
		current_best = score
		
	if final_score_label: final_score_label.text = str(score)
	if final_combo_label: final_combo_label.text = str(max_combo)
	if final_highscore_label: final_highscore_label.text = str(current_best)
	if gameover_diff_label: gameover_diff_label.text = "DIFFICULTY: " + diff_name
	if new_record_tag: new_record_tag.visible = is_new_record
	
	gameover_screen.visible = true
	gameover_screen.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(gameover_screen, "modulate:a", 1.0, 0.35)

func get_multiplier() -> float:
	return 1.0 + floor(combo / 4.0) * 0.5

func apply_screen_shake(amount: float) -> void:
	screen_shake = maxf(screen_shake, amount)

func spawn_floating_text(p_text: String, p_pos: Vector2, p_color: Color, p_critical: bool = false) -> void:
	var txt = text_scene.instantiate()
	txt.position = p_pos
	vfx_container.add_child(txt)
	txt.setup(p_text, p_color, p_critical)

func spawn_explosion(p_pos: Vector2, p_color: Color, p_count: int = 20) -> void:
	var exp_node: CPUParticles2D = explosion_scene.instantiate()
	exp_node.position = p_pos
	exp_node.color = p_color
	exp_node.amount = p_count
	vfx_container.add_child(exp_node)

# ── Dynamic Ultimate UI Setup & Trigger Methods ────────────────
func _setup_ult_ui() -> void:
	# Add custom UltOverlay to CanvasLayer behind HUD/StartScreen
	ult_overlay = UltOverlay.new()
	ult_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	$CanvasLayer.add_child(ult_overlay)
	$CanvasLayer.move_child(ult_overlay, 0)
	
	# Ult HUD Meter Panel
	ult_meter_panel = PanelContainer.new()
	ult_meter_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_meter_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	ult_meter_panel.offset_left = 180.0
	ult_meter_panel.offset_top = 100.0
	ult_meter_panel.offset_right = -180.0
	ult_meter_panel.offset_bottom = 128.0
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.14, 0.94)
	sb.border_width_bottom = 2
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_color = Color(0.97, 0.72, 0.19, 0.55)
	sb.set_corner_radius_all(8)
	ult_meter_panel.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_bottom", 3)
	ult_meter_panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 8)
	margin.add_child(hbox)
	
	ult_meter_label = Label.new()
	ult_meter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_meter_label.add_theme_font_size_override("font_size", 12)
	ult_meter_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	ult_meter_label.text = "🔥 RAGE: 0/20"
	hbox.add_child(ult_meter_label)
	
	ult_meter_bar = ProgressBar.new()
	ult_meter_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_meter_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ult_meter_bar.size_flags_vertical = Control.SIZE_FILL
	ult_meter_bar.min_value = 0
	ult_meter_bar.max_value = ULT_MAX_CHARGE
	ult_meter_bar.value = 0
	ult_meter_bar.show_percentage = false
	
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.12, 0.15, 0.22, 0.85)
	bar_bg.set_corner_radius_all(4)
	ult_meter_bar.add_theme_stylebox_override("background", bar_bg)
	
	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.97, 0.72, 0.19, 1.0)
	bar_fill.set_corner_radius_all(4)
	ult_meter_bar.add_theme_stylebox_override("fill", bar_fill)
	hbox.add_child(ult_meter_bar)
	
	if hud_root:
		hud_root.add_child(ult_meter_panel)
		
	# Ult Announcement Banner
	ult_banner = PanelContainer.new()
	ult_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	ult_banner.offset_left = -300.0
	ult_banner.offset_top = 210.0
	ult_banner.offset_right = 300.0
	ult_banner.offset_bottom = 295.0
	ult_banner.visible = false
	
	var b_sb = StyleBoxFlat.new()
	b_sb.bg_color = Color(0.04, 0.05, 0.1, 0.96)
	b_sb.border_width_bottom = 3
	b_sb.border_width_top = 3
	b_sb.border_width_left = 3
	b_sb.border_width_right = 3
	b_sb.border_color = Color(1.0, 0.85, 0.25, 1.0)
	b_sb.set_corner_radius_all(14)
	b_sb.shadow_size = 20
	b_sb.shadow_color = Color(0, 0, 0, 0.75)
	ult_banner.add_theme_stylebox_override("panel", b_sb)
	
	ult_banner_label = Label.new()
	ult_banner_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ult_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ult_banner_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ult_banner_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ult_banner_label.add_theme_font_override("font", preload("res://assets/fonts/Cinzel-Bold.ttf"))
	ult_banner_label.add_theme_font_size_override("font_size", 16)
	ult_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ult_banner.add_child(ult_banner_label)
	
	$CanvasLayer.add_child(ult_banner)

	# Dynamic Ultimate Cut-In Portrait (Bottom-Right Corner)
	ult_cutin_root = Control.new()
	ult_cutin_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_cutin_root.custom_minimum_size = Vector2(340, 680)
	ult_cutin_root.size = Vector2(340, 680)
	ult_cutin_root.position = Vector2(760.0, 600.0)
	ult_cutin_root.visible = false
	ult_cutin_root.modulate.a = 0.0

	# 1. Outer Red Silhouette Glow (slightly offset)
	ult_cutin_shadow_glow = TextureRect.new()
	ult_cutin_shadow_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_cutin_shadow_glow.offset_left = -10.0
	ult_cutin_shadow_glow.offset_top = -6.0
	ult_cutin_shadow_glow.offset_right = 340.0
	ult_cutin_shadow_glow.offset_bottom = 684.0
	ult_cutin_shadow_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ult_cutin_shadow_glow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ult_cutin_shadow_glow.modulate = Color(1.0, 0.1, 0.1, 0.45)
	ult_cutin_root.add_child(ult_cutin_shadow_glow)

	# 2. Main Red Drop Shadow (offset to the left-bottom)
	ult_cutin_shadow = TextureRect.new()
	ult_cutin_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_cutin_shadow.offset_left = -12.0
	ult_cutin_shadow.offset_top = 4.0
	ult_cutin_shadow.offset_right = 318.0
	ult_cutin_shadow.offset_bottom = 684.0
	ult_cutin_shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ult_cutin_shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ult_cutin_shadow.modulate = Color(1.0, 0.05, 0.05, 0.85)
	ult_cutin_root.add_child(ult_cutin_shadow)

	# 3. Portrait TextureRect
	ult_cutin_portrait = TextureRect.new()
	ult_cutin_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_cutin_portrait.offset_left = 0.0
	ult_cutin_portrait.offset_top = 0.0
	ult_cutin_portrait.offset_right = 330.0
	ult_cutin_portrait.offset_bottom = 680.0
	ult_cutin_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ult_cutin_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ult_cutin_root.add_child(ult_cutin_portrait)

	# Dialogue speech bubble beside character
	ult_cutin_bubble = PanelContainer.new()
	ult_cutin_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_cutin_bubble.offset_left = -230.0
	ult_cutin_bubble.offset_top = 100.0
	ult_cutin_bubble.offset_right = 30.0
	ult_cutin_bubble.offset_bottom = 175.0

	var bub_sb = StyleBoxFlat.new()
	bub_sb.bg_color = Color(0.05, 0.07, 0.14, 0.96)
	bub_sb.border_width_left = 2
	bub_sb.border_width_top = 2
	bub_sb.border_width_right = 2
	bub_sb.border_width_bottom = 3
	bub_sb.border_color = Color(1.0, 0.85, 0.3, 1.0)
	bub_sb.set_corner_radius_all(12)
	bub_sb.shadow_size = 18
	bub_sb.shadow_color = Color(0, 0, 0, 0.75)
	ult_cutin_bubble.add_theme_stylebox_override("panel", bub_sb)

	var bub_margin = MarginContainer.new()
	bub_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bub_margin.add_theme_constant_override("margin_left", 12)
	bub_margin.add_theme_constant_override("margin_right", 12)
	bub_margin.add_theme_constant_override("margin_top", 8)
	bub_margin.add_theme_constant_override("margin_bottom", 8)
	ult_cutin_bubble.add_child(bub_margin)

	ult_cutin_bubble_label = Label.new()
	ult_cutin_bubble_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ult_cutin_bubble_label.add_theme_font_override("font", preload("res://assets/fonts/Cinzel-Bold.ttf"))
	ult_cutin_bubble_label.add_theme_font_size_override("font_size", 14)
	ult_cutin_bubble_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	ult_cutin_bubble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ult_cutin_bubble_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ult_cutin_bubble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bub_margin.add_child(ult_cutin_bubble_label)

	ult_cutin_root.add_child(ult_cutin_bubble)

	$CanvasLayer.add_child(ult_cutin_root)

func _show_ult_cutin(type: CharacterData.CharacterType, quote_text: String) -> void:
	if not ult_cutin_root or not ult_cutin_portrait: return
	if ult_cutin_tween and ult_cutin_tween.is_valid():
		ult_cutin_tween.kill()
		
	var is_felix = (type == CharacterData.CharacterType.FELIX)
	var tex = felix_ult_tex if is_felix else mella_ult_tex
	ult_cutin_portrait.texture = tex
	if ult_cutin_shadow:
		ult_cutin_shadow.texture = tex
		ult_cutin_shadow.modulate = Color(1.0, 0.08, 0.08, 0.9) if is_felix else Color(1.0, 0.15, 0.35, 0.9)
	if ult_cutin_shadow_glow:
		ult_cutin_shadow_glow.texture = tex
		ult_cutin_shadow_glow.modulate = Color(1.0, 0.2, 0.1, 0.5) if is_felix else Color(1.0, 0.25, 0.45, 0.5)
		
	var border_col = Color(1.0, 0.8, 0.2, 1.0) if is_felix else Color(0.3, 0.95, 1.0, 1.0)
		
	if ult_cutin_bubble and ult_cutin_bubble_label:
		ult_cutin_bubble_label.text = "\"" + quote_text + "\""
		var bsb = StyleBoxFlat.new()
		bsb.bg_color = Color(0.05, 0.07, 0.14, 0.96)
		bsb.border_width_left = 2
		bsb.border_width_top = 2
		bsb.border_width_right = 2
		bsb.border_width_bottom = 3
		bsb.border_color = border_col
		bsb.set_corner_radius_all(12)
		bsb.shadow_size = 18
		bsb.shadow_color = Color(0, 0, 0, 0.75)
		ult_cutin_bubble.add_theme_stylebox_override("panel", bsb)
		
	ult_cutin_root.visible = true
	ult_cutin_root.position = Vector2(760.0, 600.0)
	ult_cutin_root.modulate.a = 0.0
	ult_cutin_root.scale = Vector2(0.85, 0.85)
	
	ult_cutin_tween = create_tween()
	ult_cutin_tween.set_parallel(true)
	ult_cutin_tween.tween_property(ult_cutin_root, "position", Vector2(380.0, 600.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	ult_cutin_tween.tween_property(ult_cutin_root, "modulate:a", 1.0, 0.2)
	ult_cutin_tween.tween_property(ult_cutin_root, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _hide_ult_cutin(immediate: bool = false) -> void:
	if not ult_cutin_root: return
	if ult_cutin_tween and ult_cutin_tween.is_valid():
		ult_cutin_tween.kill()
		
	if immediate:
		ult_cutin_root.visible = false
		ult_cutin_root.modulate.a = 0.0
		return
		
	ult_cutin_tween = create_tween()
	ult_cutin_tween.set_parallel(true)
	ult_cutin_tween.tween_property(ult_cutin_root, "position", Vector2(760.0, 600.0), 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	ult_cutin_tween.tween_property(ult_cutin_root, "modulate:a", 0.0, 0.25)
	ult_cutin_tween.chain().tween_callback(func(): ult_cutin_root.visible = false)

func _show_ult_banner(text: String, col: Color) -> void:
	if not ult_banner or not ult_banner_label: return
	ult_banner_label.text = text
	ult_banner_label.add_theme_color_override("font_color", col)
	ult_banner.visible = true
	ult_banner.scale = Vector2(0.6, 0.6)
	ult_banner.pivot_offset = Vector2(300.0, 42.0)
	ult_banner.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(ult_banner, "scale", Vector2(1.1, 1.1), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ult_banner, "modulate:a", 1.0, 0.18)
	tween.tween_property(ult_banner, "scale", Vector2(1.0, 1.0), 0.12)
	tween.tween_interval(1.5)
	tween.tween_property(ult_banner, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func(): ult_banner.visible = false)

func _trigger_ultimate() -> void:
	if SoundManager.instance:
		SoundManager.instance.play_ult_activate()
		
	if selected_char == CharacterData.CharacterType.FELIX:
		_start_felix_rage()
	elif selected_char == CharacterData.CharacterType.MELLA:
		_start_mella_flashstep()

# ── Felix: Paladin's Rage Cleave (3 Waves) ────────────────────
func _start_felix_rage() -> void:
	is_felix_rage_active = true
	rage_vignette_alpha = 0.95
	var quote = CharacterData.get_random_quote(CharacterData.CharacterType.FELIX)
	_show_ult_banner("🔥 PALADIN'S RAGE CLEAVE! 🔥\n\"" + quote + "!\"", Color(1.0, 0.4, 0.1))
	spawn_floating_text("📢 \"" + quote + "\"!", Vector2(castle_gate.player_x, GATE_Y - 90.0), Color(1.0, 0.35, 0.1), true)
	_show_ult_cutin(CharacterData.CharacterType.FELIX, quote)
	
	_perform_felix_rage_wave(1)
	
	var timer2 = get_tree().create_timer(0.4)
	timer2.timeout.connect(func():
		if is_felix_rage_active and current_state == GameState.PLAYING:
			_perform_felix_rage_wave(2)
	)
	
	var timer3 = get_tree().create_timer(0.8)
	timer3.timeout.connect(func():
		if is_felix_rage_active and current_state == GameState.PLAYING:
			_perform_felix_rage_wave(3)
	)
	
	var timer_end = get_tree().create_timer(1.35)
	timer_end.timeout.connect(func():
		_end_felix_rage()
	)

func _perform_felix_rage_wave(wave_num: int) -> void:
	if castle_gate:
		castle_gate.trigger_rage_wave(wave_num)
	apply_screen_shake(22.0)
	if SoundManager.instance:
		SoundManager.instance.play_rage_slash()
		
	# Annihilate all enemies in all 4 lanes (and rescue any innocents safely)
	for enemy in enemy_container.get_children():
		if enemy.get("is_active"):
			if enemy is Innocent:
				enemy.is_active = false
				_on_innocent_saved(100, enemy.global_position)
				enemy.queue_free()
			elif enemy is EnemyMelee or enemy is EnemyProjectile:
				enemy.is_active = false
				spawn_explosion(enemy.global_position, Color(1.0, 0.35, 0.1), 35)
				spawn_floating_text("+120 RAGE WAVE " + str(wave_num), enemy.global_position, Color(1.0, 0.45, 0.15), true)
				score += int(120 * get_multiplier())
				combo += 1
				if combo > max_combo: max_combo = combo
				enemy.queue_free()
			
	_update_hud()

func _end_felix_rage() -> void:
	is_felix_rage_active = false
	_hide_ult_cutin(false)
	var tween = create_tween()
	tween.tween_property(self, "rage_vignette_alpha", 0.0, 0.45)
	_update_hud()

# ── Mella: Sugar Rush Flashstep (15 Auto-Parries) ───────────────
func _start_mella_flashstep() -> void:
	is_mella_flashstep_active = true
	flashstep_charges = 15
	var quote = CharacterData.get_random_quote(CharacterData.CharacterType.MELLA)
	_show_ult_banner("⚡ SUGAR RUSH FLASHSTEP! ⚡\n\"" + quote + "\"", Color(0.3, 0.95, 1.0))
	spawn_floating_text("📢 \"" + quote + "\"!", Vector2(castle_gate.player_x, GATE_Y - 90.0), Color(0.35, 0.95, 1.0), true)
	_show_ult_cutin(CharacterData.CharacterType.MELLA, quote)
	_update_hud()

func _process_mella_flashstep_auto_parry() -> void:
	if not is_mella_flashstep_active or flashstep_charges <= 0:
		return
		
	var hit_top = char_info.get("hit_zone_top", 720.0)
	var candidates = []
	for enemy in enemy_container.get_children():
		if enemy.get("is_active") and (enemy is EnemyProjectile or enemy is EnemyMelee):
			if enemy.position.y >= hit_top - 60.0 and enemy.position.y <= GATE_Y + 20.0:
				if enemy is EnemyProjectile and enemy.deflected:
					continue
				candidates.append(enemy)
				
	# Nearest to gate (highest Y) first
	candidates.sort_custom(func(a, b): return a.position.y > b.position.y)
	
	for enemy in candidates:
		if flashstep_charges <= 0:
			break
		
		var elane = enemy.lane
		castle_gate.trigger_clash(elane)
		
		if SoundManager.instance:
			SoundManager.instance.play_flashstep_zip()
			SoundManager.instance.play_parry()
			
		apply_screen_shake(8.0)
		spawn_explosion(enemy.global_position, Color(0.3, 0.9, 1.0), 25)
		
		if enemy is EnemyProjectile:
			enemy.deflected = true
			enemy.velocity = Vector2.UP
			enemy.speed = 580.0
			if enemy.sprite:
				enemy.sprite.rotation = PI
				enemy.sprite.modulate = Color(0.3, 0.95, 1.0)
			_on_scored(char_info.get("score_clash_proj", 65), "⚡ AUTO-DEFLECT!", enemy.global_position, Color(0.3, 0.95, 1.0))
		elif enemy is EnemyMelee:
			enemy.is_active = false
			_on_scored(char_info.get("score_clash_melee", 25), "⚡ AUTO-CLASH!", enemy.global_position, Color(0.85, 0.35, 1.0))
			enemy.queue_free()
			
		flashstep_charges -= 1
		spawn_floating_text("⚡ FLASHSTEP (" + str(flashstep_charges) + ")", enemy.global_position + Vector2(0, -35), Color(0.35, 0.95, 1.0), true)
		
		if flashstep_charges <= 0:
			_end_mella_flashstep()
			break

func _end_mella_flashstep() -> void:
	is_mella_flashstep_active = false
	flashstep_charges = 0
	_hide_ult_cutin(false)
	_show_ult_banner("⚡ FLASHSTEP COMPLETE! ⚡", Color(0.4, 0.9, 1.0))
	_update_hud()

func _update_hud() -> void:
	if score_label:
		score_label.text = str(score)
	var diff_name = CharacterData.DIFFICULTY_NAMES[selected_difficulty]
	if highscore_label:
		highscore_label.text = str(high_scores.get(diff_name, 0))
			
	# Update Ultimate HUD Meter
	if ult_meter_bar and ult_meter_label:
		var theme_col = Color(1.0, 0.4, 0.1) if selected_char == CharacterData.CharacterType.FELIX else Color(0.3, 0.95, 1.0)
		var bar_fill = StyleBoxFlat.new()
		bar_fill.bg_color = theme_col
		bar_fill.set_corner_radius_all(4)
		ult_meter_bar.add_theme_stylebox_override("fill", bar_fill)
		
		if is_felix_rage_active:
			ult_meter_bar.max_value = 1
			ult_meter_bar.value = 1
			ult_meter_label.text = "🔥 RAGE CLEAVING!"
			ult_meter_label.modulate = Color(1.0, 0.35, 0.1)
		elif is_mella_flashstep_active:
			ult_meter_bar.max_value = 15
			ult_meter_bar.value = flashstep_charges
			ult_meter_label.text = "⚡ FLASHSTEP (" + str(flashstep_charges) + "/15)"
			ult_meter_label.modulate = Color(0.3, 0.95, 1.0)
		else:
			ult_meter_bar.max_value = ULT_MAX_CHARGE
			ult_meter_bar.value = ult_charge
			var u_name = "RAGE" if selected_char == CharacterData.CharacterType.FELIX else "FLASHSTEP"
			var icon = "🔥 " if selected_char == CharacterData.CharacterType.FELIX else "⚡ "
			ult_meter_label.text = icon + u_name + ": " + str(ult_charge) + "/" + str(ULT_MAX_CHARGE)
			ult_meter_label.modulate = char_info.get("theme_color", Color.WHITE)
