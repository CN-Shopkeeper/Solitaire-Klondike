extends Control
@onready var stock: Control = $HBoxContainer/Stock
@onready var waste: Control = $HBoxContainer/Waste
var waste_cards = GameData.get_waste_stack()
var stock_cards = GameData.get_stock_stack()
@onready var cards_control: Control = $Cards

func _ready() -> void:

	var suit_index = 0
	var points_copy = Poker.POINTS.duplicate()
	points_copy.reverse()
	for point in points_copy:
		var suit = Poker.SUITS[suit_index]
		suit_index += 1
		suit_index %= 4
		var new_card = ClassCard.new(suit, point)
		CardNodeManager.create_stock_card_node(new_card, cards_control)
		stock_cards.push(new_card)
