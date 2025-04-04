extends Node

signal win

func _ready() -> void:
	for suit in Poker.SUITS:
		GameData.get_foundation_stack(suit).connect("item_changed", Callable(self, "check_winning"))

# 直接送基础牌堆的操作
func get_tips_foundation():
	# 在tableau中的优先
	for tableau_index in range(7):
		var card_tableau_peek = GameData.get_tableau_stack(tableau_index).peek()
		if ! card_tableau_peek:
			continue
		for suit in Poker.SUITS:
			var is_legal = check_card_move_foundation_legal(card_tableau_peek, suit)
			if is_legal:
				return {"card": card_tableau_peek.get_copy(), "to": suit}
	# 其次是在wasted的
	var card = GameData.get_waste_stack().peek()
	if card:
		for suit in Poker.SUITS:
			var is_legal = check_card_move_foundation_legal(card, suit)
			if is_legal:
				return {"card": card.get_copy(), "to": suit}
	return null

# 翻开桌面上的隐藏牌，或创造空列
func get_tips_tableau_to_flip():
	for tableau_index in range(7):
		var from_tableau_cards = GameData.get_tableau_stack(tableau_index)
		var cards = from_tableau_cards.find_order_sublist()
		# cards.size()==from_tableau_cards.size()
		# 创造空列，否则翻开
		if 0 == cards.size():
			continue
		for ti in range(7):
			if ti == tableau_index or GameData.get_tableau_stack(ti).is_empty():
				continue
			var matched_card = GameData.get_tableau_stack(ti).peek()
			if check_card_move_tableau_card_legal(cards[0], matched_card):
				var cards_copy = []
				for card in cards:
					cards_copy.append(card.get_copy())
				return {"cards": cards_copy, "to": matched_card.get_copy(), "from_tableau_index": tableau_index, "to_tableau_index": ti}
	return null

# 利用空的tableau来翻开桌面上的隐藏牌
func get_tips_tableau_bottom():
	for tableau_index in range(7):
		if not GameData.get_tableau_stack(tableau_index).is_empty():
			continue
		for ti in range(7):
			var from_tableau_cards = GameData.get_tableau_stack(ti)
			if ti == tableau_index or from_tableau_cards.is_empty():
				continue
			var cards = from_tableau_cards.find_order_sublist()
			if cards[0].point != "K" or cards.size() == from_tableau_cards.size():
				continue
			var cards_copy = []
			for card in cards:
				cards_copy.append(card.get_copy())
			return {"cards": cards_copy, "to": tableau_index, "from_tableau_index": ti, "to_tableau_index": tableau_index}
	return null

# waste顶端是否可以移动到tableau
func get_tips_waste_to_tableau():
	var card = GameData.get_waste_stack().peek()
	if !card:
		return null
	for tableau_index in range(7):
		var card_top = GameData.get_tableau_stack(tableau_index).peek()
		if ! card_top:
			continue
		var is_legal = check_card_move_tableau_card_legal(card, card_top)
		if is_legal:
			return {"card": card.get_copy(), "to": card_top.get_copy(), "to_tableau_index": tableau_index}
	return null

# waste顶端是否可以移动到空tableau
func get_tips_waste_to_tableau_bottom():
	var card = GameData.get_waste_stack().peek()
	if !card or "K" != card.point:
		return null
	for tableau_index in range(7):
		if GameData.get_tableau_stack(tableau_index).is_empty():
			return {"card": card.get_copy(), "to": tableau_index, "to_tableau_index": tableau_index}
	return null

# 如果有可以移动到foundation、tableau的牌，则从废牌堆(Waste) 或库存（Stock）移动。
# 弃牌堆最上面一张已经在get_tips_foundation、get_tips_waste_to_tableau、get_tips_waste_to_tableau_bottom完成
func get_tips_stock_deal():
	var cards_to_check = []
	for card in GameData.get_stock_stack().get_stack_array():
		cards_to_check.append(card.get_copy())
	for card in GameData.get_waste_stack().get_stack_array():
		cards_to_check.append(card.get_copy())
	for suit in Poker.SUITS:
		for card in cards_to_check:
			var is_legal = check_card_move_foundation_legal(card, suit)
			if is_legal:
					return true
	for tableau_index in range(7):
		var card_top = GameData.get_tableau_stack(tableau_index).peek()
		if ! card_top:
			# 判断有没有k
			for card in cards_to_check:
				if card.point == "K":
					return true
		else:
			# 判断能不能移到牌下面
			for card in cards_to_check:
				var is_legal = check_card_move_tableau_card_legal(card, card_top)
				if is_legal:
					return true
	return false

# 移动多张牌
func get_tips_tableau():
	for tableau_index in range(7):
		var from_tableau_cards = GameData.get_tableau_stack(tableau_index)
		var cards = from_tableau_cards.find_order_sublist()
		if 0 == cards.size():
			continue
		for ti in range(7):
			if ti == tableau_index or GameData.get_tableau_stack(ti).is_empty():
				continue
			var matched_card = GameData.get_tableau_stack(ti).peek()
			if check_card_move_tableau_card_legal(cards[0], matched_card):
				var cards_copy = []
				for card in cards:
					cards_copy.append(card.get_copy())
				return {"cards": cards_copy, "to": matched_card.get_copy(), "from_tableau_index": tableau_index, "to_tableau_index": ti}
	return null

func check_winning():
	var completed_cnt = 0
	for suit in Poker.SUITS:
		completed_cnt += GameData.get_foundation_stack(suit).size()
	if completed_cnt == 52:
		emit_signal("win")

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
	var tableau_to_deal_count: Array[int] = [1, 2, 3, 4, 5, 6, 7]
	var stock_to_deal_count = 24

	var stock_tmp_array: Array[ClassCard] = []
	var dealt_tableau_cards: Array[ClassCardStack] = []
	for i in tableau_to_deal_count:
		dealt_tableau_cards.append(ClassCardStack.new())

	while deck_count > 0:
		# deck随机选择一个花色取出最顶上的牌
		var random_suit_index = randi() % 4  # 生成0-3的随机数
		while deck[random_suit_index].is_empty():
			random_suit_index += 1
			random_suit_index %= 4
		var card = deck[random_suit_index].pop()
		# 随机加入到一个dealt_cards
		if stock_to_deal_count == deck_count or (stock_to_deal_count > 0 and randi() % 2 == 0):
			# 50%的概率加入stock
			stock_to_deal_count -= 1
			stock_tmp_array.append(card)
		else:
			# 否则加入tableau
			var random_dealt_index = _weighted_random_select_tableau(tableau_to_deal_count)
			# 正常情况下，不会经过哪怕一次循环
			while tableau_to_deal_count[random_dealt_index] == 0:
				random_dealt_index += 1
				random_dealt_index %= 7
			tableau_to_deal_count[random_dealt_index] -= 1
			dealt_tableau_cards[random_dealt_index].push(card)
		deck_count -= 1
	stock_tmp_array.shuffle()
	var dealt_stock_cards = ClassCardStack.new()
	dealt_stock_cards.push_n(stock_tmp_array)
	var dealt_cards = dealt_tableau_cards
	dealt_cards.append(dealt_stock_cards)
	return dealt_cards

func _weighted_random_select_tableau(tableau_to_deal_count: Array[int]) -> int:
	var prefix_and = []
	var total_cnt = 0

	for i in range(tableau_to_deal_count.size()):
		var cnt = tableau_to_deal_count[i]
		total_cnt += cnt
		if 0 == i:
			prefix_and.append(cnt)
		else:
			prefix_and.append(prefix_and[i -1] + cnt)

		i += 1

	var pos = randi() % total_cnt

	var index = 0

	for i in range(prefix_and.size()):
		var prefix = prefix_and[i]
		if prefix >= pos:
			index = i
			break

	return index
