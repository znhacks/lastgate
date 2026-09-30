class_name CharacterData

enum CharacterType { FELIX, MELLA }
enum Difficulty { EASY, MEDIUM, HARD, EXTREME }

const DIFFICULTY_NAMES: Array[String] = ["EASY", "MEDIUM", "HARD", "EXTREME"]

const DIFFICULTY_SETTINGS: Dictionary = {
	Difficulty.EASY: {
		"name": "EASY",
		"desc": "Relaxed pace with forgiving reaction windows",
		"spawn_base": 2.2,
		"spawn_min": 0.85,
		"speed_mult": 0.85,
		"score_mult": 1.0,
		"color": Color(0.3, 0.88, 0.5)
	},
	Difficulty.MEDIUM: {
		"name": "MEDIUM",
		"desc": "Standard challenge with steady acceleration",
		"spawn_base": 1.7,
		"spawn_min": 0.55,
		"speed_mult": 1.0,
		"score_mult": 1.5,
		"color": Color(0.28, 0.72, 1.0)
	},
	Difficulty.HARD: {
		"name": "HARD",
		"desc": "Rapid onslaught for trained defenders",
		"spawn_base": 1.25,
		"spawn_min": 0.40,
		"speed_mult": 1.25,
		"score_mult": 2.0,
		"color": Color(1.0, 0.75, 0.2)
	},
	Difficulty.EXTREME: {
		"name": "EXTREME",
		"desc": "Relentless fury testing maximum reflexes",
		"spawn_base": 0.90,
		"spawn_min": 0.28,
		"speed_mult": 1.5,
		"score_mult": 3.0,
		"color": Color(0.95, 0.28, 0.38)
	}
}

# 4 fixed vertical lane X-positions for portrait top-to-bottom gameplay (720px width)
const LANE_X: Array[float] = [90.0, 270.0, 450.0, 630.0]

# Lane accent colors (used by lane indicators, buttons, effects)
const LANE_COLORS: Array[Color] = [
	Color(0.28, 0.72, 1.0),   # Lane 0: Sky Blue
	Color(0.25, 0.92, 0.55),  # Lane 1: Emerald Green
	Color(1.0, 0.82, 0.22),   # Lane 2: Amber Gold
	Color(0.95, 0.35, 0.45),  # Lane 3: Rose Red
]

static func get_character_info(type: CharacterType) -> Dictionary:
	match type:
		CharacterType.FELIX:
			return {
				"name": "Felix",
				"title": "The Steadfast Paladin",
				"hp": 4,
				"hit_zone_top": 800.0,
				"score_clash_melee": 35,
				"score_clash_proj": 50,
				"score_deflect_kill": 80,
				"dash_speed_mult": 0.42,
				"aoe_radius_mult": 1.45,
				"avatar_path": "res://assets/felix.png",
				"theme_color": Color(0.97, 0.72, 0.19),
				"ult_name": "PALADIN'S RAGE",
				"perks": [
					{"title": "Heavy Iron Armor", "desc": "4 Base HP & heavy weighty movement, packing devastating power"},
					{"title": "Blast Wave Amplifier", "desc": "+45% Larger AoE blast when fireballs collide across lanes"},
					{"title": "Ultimate: Paladin's Rage", "desc": "Every 20 eliminations, unleashes 3 colossal cleaves across all 4 lanes with crimson vignette"}
				]
			}
		CharacterType.MELLA:
			return {
				"name": "Mella",
				"title": "The Agile Duelist",
				"hp": 3,
				"hit_zone_top": 720.0,
				"score_clash_melee": 25,
				"score_clash_proj": 65,
				"score_deflect_kill": 120,
				"dash_speed_mult": 1.6,
				"aoe_radius_mult": 1.0,
				"avatar_path": "res://assets/mella.png",
				"theme_color": Color(0.65, 0.37, 0.92),
				"ult_name": "SUGAR RUSH FLASHSTEP",
				"perks": [
					{"title": "Extended Guard Reach", "desc": "720px Guard line (+80px reach) for earlier reflex strikes"},
					{"title": "Acrobatic Reposition", "desc": "Ultra-agile lane transition speed to effortlessly spam all lanes"},
					{"title": "Ultimate: Flashstep Auto-Parry", "desc": "Every 20 eliminations, automatically parries next 15 attacks with sugar rush hyperspeed"}
				]
			}
	return {}

const FELIX_QUOTES: Array[String] = [
	"RAHHH",
	"GET LOST",
	"NOBODY TOUCH THE CASTLE",
	"SUFFER"
]

const MELLA_QUOTES: Array[String] = [
	"Relax, ill handle this",
	"Look at those bad boys",
	"Watch your back",
	"Nice one",
	"Aww, lets CRUSH them"
]

static func get_random_quote(type: CharacterType) -> String:
	if type == CharacterType.FELIX:
		return FELIX_QUOTES[randi() % FELIX_QUOTES.size()]
	elif type == CharacterType.MELLA:
		return MELLA_QUOTES[randi() % MELLA_QUOTES.size()]
	return ""
