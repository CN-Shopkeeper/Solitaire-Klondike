extends Control
@onready var cards_control: Control = $Cards

@onready var tableau_0_cards: = GameData.get_tableau_stack(0)
@onready var tableau_1_cards: = GameData.get_tableau_stack(1)
@onready var tableau_2_cards: = GameData.get_tableau_stack(2)
@onready var difficulty: Button = $UI/Top/Difficulty
@onready var start: Button = $UI/Top/Start
@onready var tips: Button = $UI/Top/Tips
@onready var cancel: Button = $UI/Top/Cancel


@onready var tableau_0: Control = $HBoxContainer/Tableau_0
@onready var tableau_2: Control = $HBoxContainer/Tableau_2

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	cancel.disabled = GameSettings.undo_stack.size() == 0 or not GameSettings.playing
	tips.disabled = not GameSettings.playing

func _gen_test_tableau_0_cards():
	var suit_index = 0
	var tmp_cards_0 := ClassCardStack.new()
	for point in Poker.POINTS:
		var suit = Poker.SUITS[suit_index]
		suit_index += 1
		suit_index %= 2
		var new_card = ClassCard.new(suit, point)
		tmp_cards_0.push(new_card)

	tableau_0.reset(tmp_cards_0)

func _gen_test_tableau_2_cards():
	var suit_index = 0
	var points_copy = Poker.POINTS.duplicate()
	points_copy.reverse()
	var tmp_cards_2 := ClassCardStack.new()
	for point in points_copy:
		var suit = Poker.SUITS[suit_index + 2]
		suit_index += 1
		suit_index %= 2
		var new_card = ClassCard.new(suit, point)
		new_card.is_flipped = false
		tmp_cards_2.push(new_card)

	tableau_2.reset(tmp_cards_2)

func _on_cancel_pressed() -> void:
	GameSettings.undo()


func _on_start_pressed() -> void:
	GameSettings.clear(cards_control)

	# tableau_0的顶部是一张K
	_gen_test_tableau_0_cards()
	# tableau_1为空

	# tableau_2的顶部是一个排序的卡组
	_gen_test_tableau_2_cards()

	GameSettings.playing = true


func _on_difficulty_pressed() -> void:
	var is_game_mode_easy = GameSettings.change_difficulty()
	if is_game_mode_easy:
		difficulty.text = "游戏难度:简单"
	else:
		difficulty.text = "游戏难度:困难"
