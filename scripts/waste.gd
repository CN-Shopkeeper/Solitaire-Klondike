extends Control

@export var cards_control: Control

const STOCK_OFFSET := Vector2(-112.0, 0)

var waste_cards = GameData.get_waste_stack()

var stock_position: Vector2:
	get:
		return STOCK_OFFSET + global_position

func _ready() -> void:
	waste_cards.connect("item_changed", Callable(self, "_rearrange"))

func _rearrange():
	var card_nodes = CardNodeManager.get_waste_card_nodes()

	for i in card_nodes.size():
		var node = card_nodes[i]
		var pile_offset = 0
		# 如果是顶端第一个元素
		if card_nodes.size()-1 == i:
			pile_offset = min(2, card_nodes.size()-1)
		# 如果是顶端顶第二个元素
		if card_nodes.size()-2 == i:
			pile_offset = min(1, card_nodes.size()-2)

		var legal_position := global_position + Vector2(GameSettings.WAST_PILE_OFFSET_X * pile_offset, 0.0)
		node.legal_position = legal_position
		if node.position != node.legal_position:
			node.tween_to_legal_position()


	for card in card_nodes:
		card.card.is_flipped = false
