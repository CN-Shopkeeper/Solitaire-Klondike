extends Control
@onready var cards: Control = $Cards

var single_card_stack: ClassCardStack
var card_pile_stack: ClassCardStack
const CARD = preload("res://scenes/card.tscn")

const SINGLE_CARD_STACK_NAME = "test_cards_single"
const PILE_CARD_STACK_NAME = "test_cards_pile"

const SINGLE_CARD_ROOT_POSITION = Vector2(300, 100)
const PILE_CARD_ROOT_POSITION = Vector2(500, 100)

var pile_offset_y: float:
	get:
		if card_pile_stack.size() < 10:
			return 20
		else:
			return 20- card_pile_stack.size() + 10

func _ready() -> void:
	single_card_stack = ClassCardStack.new(SINGLE_CARD_STACK_NAME)
	card_pile_stack = ClassCardStack.new(PILE_CARD_STACK_NAME)

	GameData.set_test_cards(SINGLE_CARD_STACK_NAME, single_card_stack)
	GameData.set_test_cards(PILE_CARD_STACK_NAME, card_pile_stack)

	single_card_stack.connect("item_changed", _item_changed_single_card)
	card_pile_stack.connect("item_changed", _item_changed_piled_cards)

	var card_hearts_a = ClassCard.new(Poker.HEARTS, "A")
	CardNodeManager.create_card_node(card_hearts_a, cards)
	single_card_stack.push(card_hearts_a)

	var suit_index = 0
	var points_copy = Poker.POINTS.duplicate()
	points_copy.reverse()
	for point in points_copy:
		var suit = Poker.SUITS[suit_index]
		suit_index += 1
		suit_index %= 4
		var new_card = ClassCard.new(suit, point)
		new_card.is_flipped = false
		CardNodeManager.create_card_node(new_card, cards)
		card_pile_stack.push(new_card)

func _physics_process(delta: float) -> void:
	pass


func _item_changed_single_card():
	var card_nodes = CardNodeManager.get_test_card_nodes(SINGLE_CARD_STACK_NAME)
	for node in card_nodes:
		node.position = SINGLE_CARD_ROOT_POSITION
		node.legal_position = SINGLE_CARD_ROOT_POSITION
	if card_nodes.size() > 0:
		card_nodes[-1].card.is_flipped = false

func _item_changed_piled_cards():
	var card_nodes = CardNodeManager.get_test_card_nodes(PILE_CARD_STACK_NAME)
	var index = 0
	for node in card_nodes:
		var now_position := PILE_CARD_ROOT_POSITION + Vector2(0.0, index * pile_offset_y)
		node.legal_position = now_position
		node.tween_to_legal_position()
		index += 1

	# 尝试将最上面一张翻开
	if card_nodes.size() > 0:
		card_nodes[-1].card.is_flipped = false
