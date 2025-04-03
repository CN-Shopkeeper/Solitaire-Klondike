extends Control
@onready var tableau_group: HBoxContainer = $CardTable/MarginContainer/Tableau_group
@onready var stock_and_waste: HBoxContainer = $CardTable/HBoxContainer/HBoxContainer/StockAndWaste
@onready var difficulty: Button = $UI/Top/Difficulty
@onready var start: Button = $UI/Top/Start
@onready var tips: Button = $UI/Top/Tips
@onready var cancel: Button = $UI/Top/Cancel

func _ready() -> void:
	GameRules.connect("win", Callable(self, "_win"))
	tips.disabled = true
	cancel.disabled = true

func _win():
	$Label.text = "you win"
	GameSettings.playing = false

func _process(_delta: float) -> void:
	cancel.disabled = GameSettings.undo_stack.size() == 0 or not GameSettings.playing
	tips.disabled = not GameSettings.playing

func _on_difficulty_pressed() -> void:
	var is_game_mode_easy = GameSettings.change_difficulty()
	if is_game_mode_easy:
		difficulty.text = "游戏难度:简单"
	else:
		difficulty.text = "游戏难度:困难"


func _on_start_pressed() -> void:
	GameSettings.clear()

	var dealt_cards = GameRules.deal()
	for i in range(7):
		tableau_group.get_child(i).reset(dealt_cards[i])
	stock_and_waste.reset_stock(dealt_cards[7])
	GameSettings.playing = true
	start.text = "重开一局"


func _on_cancel_pressed() -> void:
	GameSettings.undo()
