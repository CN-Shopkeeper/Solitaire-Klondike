extends Node

# todo: 重构这个类，分为：setting、game rules、node

const CARD_BACK_BLUE = preload("res://asserts/cards/card_back_blue.png")
const CARD_BACK_RED = preload("res://asserts/cards/card_back_red.png")
const CARD = preload("res://scenes/card.tscn")

const TIPS_CARD_DURATION = 1
const STOCK_TO_WASTE_DURATION = 0.1
const WASTE_TO_STOCK_DURATION = 0.05
const WASTE_TO_STOCK_DELAY = 0.02

const WAST_PILE_OFFSET_X = 20.0

var playing := false
var _is_game_mode_easy := true
var _tips_cnt_left := 5

var undo_stack = []

var stock_draw_number: int:
	get:
		return 1 if _is_game_mode_easy else 3

var max_undo: int:
	get:
		return 10 if _is_game_mode_easy else 5

func clear(cards_control: Control = null):
	_tips_cnt_left = 5
	playing = false
	undo_stack.clear()
	GameData.clear()
	CardNodeManager.delete_all_card_nodes(cards_control)
	# 等待card节点全部删除
	await get_tree().process_frame

func change_difficulty():
	_is_game_mode_easy = !_is_game_mode_easy
	return _is_game_mode_easy

func is_tips_cnt_left():
	return _is_game_mode_easy or _tips_cnt_left > 0

func spend_tips_cnt():
	_tips_cnt_left -= 1

func get_card_back():
	if _is_game_mode_easy:
		return CARD_BACK_BLUE
	else:
		return CARD_BACK_RED

func save_state():
	if undo_stack.size() >= max_undo:
		undo_stack.pop_front()
	undo_stack.append(GameData.get_game_data_copy())

func undo():
	if undo_stack.size() > 0:
		var prev_state = undo_stack.pop_back()
		GameData.set_game_data(prev_state)
