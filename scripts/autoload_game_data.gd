extends Node

var _stock_cards: ClassCardStack = ClassCardStack.new("stock")
var _waste_cards: ClassCardStack = ClassCardStack.new("waste")
var _tableau_cards: Array[ClassCardStack] = []
var _foundation_cards: Array[ClassCardStack] = []

var _test_cards := {}

func _ready() -> void:
	for i in range(7):
		_tableau_cards.append(ClassCardStack.new("tableau_%s"%str(i)))
	for i in range(4):
		_foundation_cards.append(ClassCardStack.new("foundation_%s"%Poker.SUITS[i]))

func clear():
	_stock_cards.clear()
	_waste_cards.clear()
	for tableau in _tableau_cards:
		tableau.clear()
	for foundation in _foundation_cards:
		foundation.clear()

func set_game_data(new_game_data):
	var new_stock_cards = new_game_data["stock"]
	_stock_cards.assign(new_stock_cards)
	var new_waste_cards = new_game_data["waste"]
	_waste_cards.assign(new_waste_cards)
	# 这里假设下标不越界
	for i in _tableau_cards.size():
		var new_tableau_cards = new_game_data["tableau"][i]
		_tableau_cards[i].assign(new_tableau_cards)
	for i in _foundation_cards.size():
		var new_foundation_cards = new_game_data["foundation"][i]
		_foundation_cards[i].assign(new_foundation_cards)

func get_game_data_copy():
	var foundation_state = []
	for foundation in _foundation_cards:
		foundation_state.append(foundation.get_copy())
	var tableau_state = []
	for tableau in _tableau_cards:
		tableau_state.append(tableau.get_copy())
	return {
		"stock": _stock_cards.get_copy(),
		"waste": _waste_cards.get_copy(),
		"foundation": foundation_state,
		"tableau": tableau_state
	}

func set_test_cards(key: String, value: ClassCardStack):
	_test_cards[key] = value

func get_test_cards(key: String):
	return _test_cards.get(key, null)

func get_stock_stack() -> ClassCardStack:
	return _stock_cards

func get_waste_stack() -> ClassCardStack:
	return _waste_cards

func get_tableau_stack(index: int) -> ClassCardStack:
	# 假设这里的下标不越界
	return _tableau_cards[index]


func get_foundation_stack(suit: String) -> ClassCardStack:
	# 假设这里的下标不越界
	return _foundation_cards[Poker.SUITS.find(suit)]

func get_card_stack(card: ClassCard) -> ClassCardStack:
	var stack_name = card.owning_stack
	if _stock_cards.stack_name == stack_name:
		return _stock_cards
	if _waste_cards.stack_name == stack_name:
		return _waste_cards
	for tableau_cards in _tableau_cards:
		if tableau_cards.stack_name == stack_name:
			return tableau_cards
	for foundation_cards in _foundation_cards:
		if foundation_cards.stack_name == stack_name:
			return foundation_cards

	# 可能是测试场景下的卡组
	for value in _test_cards.values():
		if value.stack_name == stack_name:
			return value
	return null
