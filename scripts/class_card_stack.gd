class_name ClassCardStack
extends Node

signal item_changed

var _stack: Array = []  # 使用 Array 来模拟栈


# 推入元素（push）
func push(value: ClassCard) -> void:
	_stack.append(value)
	_arrange_item()
	emit_signal("item_changed")

# 推入多个元素（push_n）
func push_n(values: Array[ClassCard]) -> void:
	for value in values:
		_stack.append(value)
	_arrange_item()
	emit_signal("item_changed")

# 弹出元素（pop）
func pop() -> ClassCard:
	if _stack.size() > 0:
		var top_card = _stack.pop_back()

		_arrange_item()
		emit_signal("item_changed")
		return top_card  # 返回并移除栈顶元素
	else:
		return null  # 如果栈空，返回 null

# 弹出多个元素（pop_n）
func pop_n(n: int) -> Array[ClassCard]:
	var popped_items: Array[ClassCard] = []
	for i in range(min(n, _stack.size())):
		popped_items.append(_stack.pop_back())
	_arrange_item()
	emit_signal("item_changed")
	popped_items.reverse()
	return popped_items

# 查看栈顶元素（peek）
func peek() -> ClassCard:
	if _stack.size() > 0:
		return _stack[_stack.size() - 1]  # 返回栈顶元素
	else:
		return null  # 如果栈空，返回 null

# 清空栈
func clear() -> void:
	_stack.clear()
	emit_signal("item_changed")

# 洗牌，应该只用于stock
func shuffle() -> void:
	_stack.shuffle()
	_arrange_item()

# 查找第一个匹配的card，并返回从该元素到栈底的数组拷贝
func find_first_and_get_sublist(card: ClassCard) -> Array:
	for i in range(_stack.size()):
		if _stack[i].equal(card):  # 使用card的equal函数进行比较
			return _stack.slice(i, _stack.size())  # 返回从i到末尾的子数组拷贝
	return []  # 如果没有找到匹配项，返回空数组

# 检查栈是否为空
func is_empty() -> bool:
	return _stack.size() == 0

# 获取栈的大小
func size() -> int:
	return _stack.size()

func assign(other: ClassCardStack) -> void:
	_stack = other._get_stack_copy()


# 获取栈的只读副本
func get_stack_array() -> Array:
	return _stack.duplicate(true)  # 返回栈的深拷贝，避免外部修改原始栈

# 获取栈的深拷贝（内部使用）
func _get_stack_copy() -> Array:
	return _stack.duplicate(true)

# 更新卡牌元素的属性，不对flipped属性修改
func _arrange_item() -> void:
	if is_empty():
		return
	var index: int = _stack.size()-1
	# 我们假设这里所有的index都是合法的
	var ordering := true
	var last_point_value = Poker.get_point_num_value(peek().point)
	while index >= 0:
		var card = _stack[index]
		if index == _stack.size()-1:
			card.is_on_top = true
			card.is_in_order = true
		else:
			card.is_on_top = false
			if ordering:
				var now_point_value = Poker.get_point_num_value(card.point)
				# 这里只判断了点数，没有判断花色
				if now_point_value == last_point_value + 1:
					card.is_in_order = true
				else:
					card.is_in_order = false
					ordering = false
				last_point_value = now_point_value
			else:
				card.is_in_order = false
		index -= 1
