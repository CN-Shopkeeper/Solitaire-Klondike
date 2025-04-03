extends Control
@onready var stock_and_waste: HBoxContainer = $StockAndWaste
@onready var cards_control: Control = $Cards
@onready var difficulty: Button = $UI/Top/Difficulty
@onready var start: Button = $UI/Top/Start
@onready var cancel: Button = $UI/Top/Cancel

@onready var tips: Button = $UI/Top/Tips

var waste_cards = GameData.get_waste_stack()
var stock_cards = GameData.get_stock_stack()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	cancel.disabled = GameSettings.undo_stack.size() == 0 or not GameSettings.playing
	tips.disabled = not GameSettings.playing

func _on_difficulty_pressed() -> void:
	var is_game_mode_easy = GameSettings.change_difficulty()
	if is_game_mode_easy:
		difficulty.text = "游戏难度:简单"
	else:
		difficulty.text = "游戏难度:困难"


func _on_start_pressed() -> void:
	GameSettings.clear(cards_control)

	var new_stock_cards = ClassCardStack.new()
	var suit_index = 0
	var points_copy = Poker.POINTS.duplicate()
	points_copy.reverse()
	for point in points_copy:
		var suit = Poker.SUITS[suit_index]
		suit_index += 1
		suit_index %= 4
		var new_card = ClassCard.new(suit, point)
		new_stock_cards.push(new_card)

	stock_and_waste.reset_stock(new_stock_cards)
	GameSettings.playing = true


func _on_cancel_pressed() -> void:
	GameSettings.undo()

