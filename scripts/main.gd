extends Control
@onready var tableau_group: HBoxContainer = $CardTable/MarginContainer/Tableau_group
@onready var stock_and_waste: HBoxContainer = $CardTable/HBoxContainer/HBoxContainer/StockAndWaste
@onready var difficulty: Button = $UI/Top/Difficulty
@onready var start: Button = $UI/Top/Start
@onready var tips: Button = $UI/Top/Tips
@onready var cancel: Button = $UI/Top/Cancel
@onready var foundation: HBoxContainer = $CardTable/HBoxContainer/HBoxContainer/Foundation
@onready var cards_control: Control = $Cards

func _ready() -> void:
	GameRules.connect("win", Callable(self, "_win"))
	tips.disabled = true
	cancel.disabled = true

func _process(_delta: float) -> void:
	cancel.disabled = GameSettings.undo_stack.size() == 0 or not GameSettings.playing
	tips.disabled = not GameSettings.playing

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:  # 按下鼠标（松开时 event.pressed 为 false）
			CardNodeManager.remove_tips_card_node()

func _win():
	GameSettings.playing = false


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


func _on_tips_pressed() -> void:
	var tips = GameRules.get_tips_foundation()
	if tips:
		print(tips)
		var suit_index = Poker.SUITS.find(tips["to"])
		var to_pos = foundation.get_child(suit_index).global_position
		var from_pos = tips["card"].get_owning_node().global_position
		CardNodeManager.create_tips_cards_node_and_tween([tips["card"]], from_pos, to_pos, Vector2.ZERO, cards_control)
		return

	tips = GameRules.get_tips_tableau_to_flip()
	if tips:
		print(tips)
		var from_tableau_index = tips["from_tableau_index"]
		var to_tableau_index = tips["to_tableau_index"]
		var from_y_offset = tableau_group.get_child(from_tableau_index).pile_offset_y
		var to_y_offset = tableau_group.get_child(to_tableau_index).pile_offset_y
		var from_pos = tips["cards"][0].get_owning_node().global_position
		var to_pos = tips["to"].get_owning_node().global_position + Vector2(0, to_y_offset)

		CardNodeManager.create_tips_cards_node_and_tween(tips["cards"], from_pos, to_pos, Vector2(0, from_y_offset), cards_control)
		return

	tips = GameRules.get_tips_tableau_bottom()
	if tips:
		print(tips)
		var from_tableau_index = tips["from_tableau_index"]
		var to_tableau_index = tips["to_tableau_index"]
		var from_y_offset = tableau_group.get_child(from_tableau_index).pile_offset_y
		var to_y_offset = tableau_group.get_child(to_tableau_index).pile_offset_y
		var from_pos = tips["cards"][0].get_owning_node().global_position
		var to_pos = tableau_group.get_child(to_tableau_index).global_position
		CardNodeManager.create_tips_cards_node_and_tween(tips["cards"], from_pos, to_pos, Vector2(0, from_y_offset), cards_control)
		return

	tips = GameRules.get_tips_waste_to_tableau()
	if tips:
		print(tips)
		var to_tableau_index = tips["to_tableau_index"]
		var to_y_offset = tableau_group.get_child(to_tableau_index).pile_offset_y
		var from_pos = tips["card"].get_owning_node().global_position
		var to_pos = tips["to"].get_owning_node().global_position + Vector2(0, to_y_offset)

		CardNodeManager.create_tips_cards_node_and_tween([tips["card"]], from_pos, to_pos, Vector2(0, 0), cards_control)
		return

	tips = GameRules.get_tips_waste_to_tableau_bottom()
	if tips:
		var to_tableau_index = tips["to_tableau_index"]
		var to_y_offset = tableau_group.get_child(to_tableau_index).pile_offset_y
		var from_pos = tips["card"].get_owning_node().global_position
		var to_pos = tableau_group.get_child(to_tableau_index).global_position
		CardNodeManager.create_tips_cards_node_and_tween([tips["card"]], from_pos, to_pos, Vector2(0, 0), cards_control)
		return

	tips = GameRules.get_tips_stock_deal()
	if tips:
		CardNodeManager.create_tips_card_back_node_and_tween_scale(stock_and_waste.global_position, cards_control)
		return

	tips = GameRules.get_tips_tableau()
	if tips:
		print(tips)
		var from_tableau_index = tips["from_tableau_index"]
		var to_tableau_index = tips["to_tableau_index"]
		var from_y_offset = tableau_group.get_child(from_tableau_index).pile_offset_y
		var to_y_offset = tableau_group.get_child(to_tableau_index).pile_offset_y
		var from_pos = tips["cards"][0].get_owning_node().global_position
		var to_pos = tips["to"].get_owning_node().global_position + Vector2(0, to_y_offset)

		CardNodeManager.create_tips_cards_node_and_tween(tips["cards"], from_pos, to_pos, Vector2(0, from_y_offset), cards_control)
		return
