extends Control
@onready var tableau_0: Control = $HBoxContainer/Tableau_0
@onready var tableau_1: Control = $HBoxContainer/VBoxContainer/Tableau_1
@onready var tableau_2: Control = $HBoxContainer/VBoxContainer/Tableau_2
@onready var difficulty: Button = $UI/Top/Difficulty
@onready var cancel: Button = $UI/Top/Cancel
@onready var tips: Button = $UI/Top/Tips
@onready var cards_control: Control = $Cards
@onready var foundation: Control = $HBoxContainer/VBoxContainer/Foundation

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:  # 按下鼠标（松开时 event.pressed 为 false）
			CardNodeManager.remove_tips_card_node()

func _process(delta: float) -> void:
	cancel.disabled = GameSettings.undo_stack.size() == 0 or not GameSettings.playing
	tips.disabled = not GameSettings.playing

func _gen_test_tableau_0_cards():
	var points_copy = Poker.POINTS.duplicate()
	points_copy.reverse()
	var tmp_cards := ClassCardStack.new()
	for point in points_copy:
		var suit = Poker.HEARTS
		var new_card = ClassCard.new(suit, point)
		tmp_cards.push(new_card)

	tableau_0.reset(tmp_cards)


func _on_difficulty_pressed() -> void:
	var is_game_mode_easy = GameSettings.change_difficulty()
	if is_game_mode_easy:
		difficulty.text = "游戏难度:简单"
	else:
		difficulty.text = "游戏难度:困难"


func _on_start_pressed() -> void:
	GameSettings.clear(cards_control)

	var tmp_cards := ClassCardStack.new()
	var card_CLUBS_A = ClassCard.new(Poker.CLUBS, "A")
	tmp_cards.push(card_CLUBS_A)
	tableau_1.reset(tmp_cards)

	var card_hearts_2 = ClassCard.new(Poker.HEARTS, "2")
	tmp_cards.clear()
	tmp_cards.push(card_hearts_2)
	tableau_2.reset(tmp_cards)

	_gen_test_tableau_0_cards()

	GameSettings.playing = true



func _on_cancel_pressed() -> void:
	GameSettings.undo()


func _on_tips_pressed() -> void:
	var tips = GameRules.get_tips_foundation()
	if tips:
		print(tips)
		if tips["to"] == Poker.HEARTS:
			var from_pos = tips["card"].get_owning_node().global_position
			CardNodeManager.create_tips_cards_node_and_tween([tips["card"]], from_pos, foundation.global_position, Vector2.ZERO, cards_control)
