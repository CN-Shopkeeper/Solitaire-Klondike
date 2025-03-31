extends Control
const CARD = preload("res://scenes/card.tscn")
@export var group_index:int
@onready var card_pile: Control = $CardPile


var cards:ClassCardStack:
	get:
		return GameSettings.tableau_cards[group_index]


var pile_offset_y:float:
	get:
		if cards.size()<10:
			return 20
		else:
			return 20-cards.size()+10

func _ready() -> void:
	$Area2D.add_to_group("tableau_area")
	await get_tree().create_timer(1).timeout
	var stock_cards:=ClassCardStack.new()
	var suits=["hearts","clubs","diamonds","spades"]
	var index=0
	var points=['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
	points.reverse()
	var lpi=0
	for point in points:
		stock_cards.push(ClassCard.new(suits[index],point))
		if lpi>=group_index*2:
			break
		index+=1
		lpi+=1
		index%=4
	reset(stock_cards)
	
	cards.connect("item_changed",Callable(self,"_rearrange"))

func reset(new_stock_cards:ClassCardStack)->void:
	_clear_all_cards()
	cards.assign(new_stock_cards)
	var index=0
	for card in cards.get_stack_array():
		# 生成最新的卡牌
		var node = GameSettings.add_tableau_card_node(group_index,card)
		var position:=global_position+Vector2(0.0,index*pile_offset_y)
		node.position=position
		node.legal_position=position
		index+=1
	cards.peek().is_flipped=false

func _rearrange():
	var card_nodes = GameSettings.get_tableau_card_nodes(group_index)
	
	var index=0
	for node in card_nodes:
		var position:=global_position+Vector2(0.0,index*pile_offset_y)
		node.legal_position=position
		node.tween_to_legal_position()
		index+=1
	
	# 尝试将最上面一张翻开
	if card_nodes.size()>0:
		card_nodes[-1].card.is_flipped=false

func _clear_all_cards() -> void:
	for child in card_pile.get_children():
		child.queue_free()  # 从场景树中移除并销毁子节点
