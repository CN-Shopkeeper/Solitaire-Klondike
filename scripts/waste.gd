extends Control


signal shuffle_finished
const STOCK_OFFSET:=Vector2(-112.0,0)

var stock_position:Vector2:
	get:
		return STOCK_OFFSET+global_position

func _ready() -> void:
	GameSettings.waste_cards.connect("item_changed",Callable(self,"_rearrange"))

func add_card(new_card:ClassCard)->void:
	# 生成最新的卡牌
	var new_card_node = GameSettings.add_waste_card_node(new_card)
	new_card_node.position=stock_position
	GameSettings.waste_cards.push(new_card)

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
		
	
func _rearrange():
	var cards_displayed= GameSettings.get_waste_card_nodes()
	#for i in range(cards_displayed.size()):
		#cards_displayed[i].z_index = i
	
	if cards_displayed.size()>=3:
		# 这里简化逻辑，只需要移动当前的倒数一二三张
		# 移动后面三张卡牌
		_move_card(cards_displayed[-3],0,cards_displayed[-3].position)
		_move_card(cards_displayed[-2],1,cards_displayed[-2].position)
		_move_card(cards_displayed[-1],2,cards_displayed[-1].position)
	elif cards_displayed.size()==2:
		_move_card(cards_displayed[-2],0,cards_displayed[-2].position)
		_move_card(cards_displayed[-1],1,cards_displayed[-1].position)
	elif cards_displayed.size()==1:
		_move_card(cards_displayed[0],0,cards_displayed[0].position)
	
	
	
func _move_card(card,to_index:int,from_pos):
	var final_pos =global_position+ Vector2(GameSettings.WAST_PILE_OFFSET_X*to_index,0.0)
	card.legal_position= final_pos
	return card.tween_position(final_pos,GameSettings.STOCK_TO_WASTE_DURATION,from_pos)
