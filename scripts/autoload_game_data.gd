extends Node

var _stock_cards:ClassCardStack=ClassCardStack.new()
var _waste_cards:ClassCardStack=ClassCardStack.new()
var _tableau_cards: Array[ClassCardStack] = []
var _foundation_cards: Array[ClassCardStack] = []

func _ready() -> void:
	for i in range(7):
		_tableau_cards.append(ClassCardStack.new())
	for i in range(4):
		_foundation_cards.append(ClassCardStack.new())


func get_stock_stack()->ClassCardStack:
	return _stock_cards

func get_waste_stack()->ClassCardStack:
	return _waste_cards

func get_tableau_stack(index:int)->ClassCardStack:
	# 假设这里的下标不越界
	return _tableau_cards[index]


func get_foundation_stack(suit:String)->ClassCardStack:
	# 假设这里的下标不越界
	return _foundation_cards[Poker.SUITS.find(suit)]

func get_stack_from_group(group:String)->ClassCardStack:
	if group.begins_with("stock"):
		return get_stock_stack()
	if group.begins_with("waste"):
		return get_waste_stack()
	if group.begins_with("foundation"):
		var foundation_suit= _get_foundation_suit_from_group(group)
		if !foundation_suit:
			return null
		return get_foundation_stack(foundation_suit)
	if group.begins_with("tableau_"):
		var tableau_index=_get_tableau_index_from_group(group)
		if -1==tableau_index:
			return null
		return get_tableau_stack(tableau_index)
		
	return null

func _get_tableau_index_from_group(group:String)->int:
	if group.begins_with("tableau_"):
		var digit = group.replace("tableau_", "").replace("_cards", "")
		return int(digit)
	return -1

func _get_foundation_suit_from_group(group:String)->String:
	if group.begins_with("foundation_"):
		var suit = group.replace("foundation_", "").replace("_cards", "")
		return suit
	return ""
