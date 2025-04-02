extends Control
@onready var tableau_0: Control = $HBoxContainer/Tableau_0
@onready var tableau_1: Control = $HBoxContainer/VBoxContainer/Tableau_1
@onready var tableau_2: Control = $HBoxContainer/VBoxContainer/Tableau_2

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout

	var tmp_cards := ClassCardStack.new()
	var card_CLUBS_A = ClassCard.new(Poker.CLUBS, "A")
	tmp_cards.push(card_CLUBS_A)
	tableau_1.reset(tmp_cards)

	var card_hearts_2 = ClassCard.new(Poker.HEARTS, "2")
	tmp_cards.clear()
	tmp_cards.push(card_hearts_2)
	tableau_2.reset(tmp_cards)

	_gen_test_tableau_0_cards()

func _gen_test_tableau_0_cards():
	var points_copy = Poker.POINTS.duplicate()
	points_copy.reverse()
	var tmp_cards := ClassCardStack.new()
	for point in points_copy:
		var suit = Poker.HEARTS
		var new_card = ClassCard.new(suit, point)
		tmp_cards.push(new_card)

	tableau_0.reset(tmp_cards)
