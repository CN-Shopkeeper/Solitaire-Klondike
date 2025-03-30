extends Control


signal shuffle_finished
const STOCK_OFFSET:=Vector2(-112.0,0)

var stock_position:Vector2:
	get:
		return STOCK_OFFSET+global_position


func add_card(new_card:ClassCard)->void:
	GameSettings.waste_cards.push(new_card)
	_push_displayed_cards()

func shuffle():
	var card_index=-1
	var card_displayed=GameSettings.get_waste_card_nodes()
	while not GameSettings.waste_cards.is_empty():
		GameSettings.waste_cards.pop()
		var card_now = card_displayed[card_index]
		await card_now.tween_position(stock_position,GameSettings.WASTE_TO_STOCK_DURATION,stock_position,GameSettings.WASTE_TO_STOCK_DELAY).finished
		# 在动画结束时释放
		card_now.queue_free()
		card_index-=1
	
	emit_signal("shuffle_finished")
		

func _push_displayed_cards():
	var cards_displayed= GameSettings.get_waste_card_nodes()
		
	if cards_displayed.size()>=3:
		# 这里简化逻辑，假设新增的卡牌只有一张，且只需要移动当前的倒数一二张
		# 移动后面两张卡牌
		_move_card(cards_displayed[-2],0,stock_position)
		_move_card(cards_displayed[-1],1,stock_position)

	# 生成最新的卡牌
	var new_card = GameSettings.add_waste_card_node(GameSettings.waste_cards.peek())
	
	# 修改最新卡牌位置		
	var new_card_index = min(3-1,cards_displayed.size())
	await _move_card(new_card,new_card_index,stock_position).finished

func _move_card(card,to_index:int,from_pos):
	var final_pos =global_position+ Vector2(GameSettings.WAST_PILE_OFFSET_X*to_index,0.0)
	return card.tween_position(final_pos,GameSettings.STOCK_TO_WASTE_DURATION,from_pos)
