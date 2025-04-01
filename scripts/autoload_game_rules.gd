extends Node

# 检查是否能移动到目标牌
func check_card_move_tableau_card_legal(card_source: ClassCard, card_target: ClassCard) -> bool:
	var point_value_s = Poker.get_point_num_value(card_source.point)
	var point_value_t = Poker.get_point_num_value(card_target.point)
	if point_value_s == -1 or point_value_t == -1:
		return false
	var legal = ((point_value_s == point_value_t -1)
			and Poker.is_opposite_suits(card_source.suit, card_target.suit)
		)
	return legal

# todo: 胜利条件判定，放在signal中做
func check_card_move_foundation_legal(card_source: ClassCard, target_foundation_suit: String) -> bool:
	# 花色判断
	if card_source.suit != target_foundation_suit:
		return false
	var target_stack = GameData.get_foundation_stack(target_foundation_suit)
	# 如果当前foundation已完成，则直接判错
	if target_stack.size() > 13:
		return false
	var source_point_value = Poker.get_point_num_value(card_source.point)
	# 如果当前foundation为空，则点数必须为A
	if target_stack.size() == 0:
		return source_point_value == 1
	# 否则，foundation的peek的点数必须等于source点数-1
	return Poker.get_point_num_value(target_stack.peek().point) == source_point_value -1

func check_card_move_tableau_bottom_legal(card_source: ClassCard, target_tableau_index: int) -> bool:
	# 如果tableau不为空则不允许
	if GameData.get_tableau_stack(target_tableau_index).size() != 0:
		return false
	# 是否为k
	if card_source.point != "K":
		return false

	return true


func deal() -> Array[ClassCardStack]:
	var deck = Poker.generate_deck()
	var deck_count = 52
	# 7个牌桌堆和一个牌库
	var table_to_deal_count = [1, 2, 3, 4, 5, 6, 7, 24]
	var dealt_cards: Array[ClassCardStack] = []
	for i in table_to_deal_count:
		dealt_cards.append(ClassCardStack.new())

	var stock_tmp_array: Array[ClassCard] = []
	while deck_count > 0:
		# deck随机选择一个花色取出最顶上的牌
		var random_suit_index = randi() % 4  # 生成0-3的随机数
		while deck[random_suit_index].is_empty():
			random_suit_index += 1
			random_suit_index %= 4
		var card = deck[random_suit_index].pop()
		# 随机加入到一个dealt_cards
		if table_to_deal_count[7] == deck_count or (table_to_deal_count[7] > 0 and randi() % 2 == 0):
			# 50%的概率加入stock
			table_to_deal_count[7] -= 1
			stock_tmp_array.append(card)
		else:
			# 否则加入tableau
			var random_dealt_index = randi() % 7  # 生成0-7的随机数
			while table_to_deal_count[random_dealt_index] == 0:
				random_dealt_index += 1
				random_dealt_index %= 7
			table_to_deal_count[random_dealt_index] -= 1
			dealt_cards[random_dealt_index].push(card)
		deck_count -= 1
	stock_tmp_array.shuffle()
	dealt_cards[7].push_n(stock_tmp_array)
	return dealt_cards
