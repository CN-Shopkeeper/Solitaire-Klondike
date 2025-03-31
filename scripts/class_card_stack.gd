class_name ClassCardStack
extends Node

signal item_changed

var _stack: Array = []  # 使用 Array 来模拟栈

# 静态方法：打乱 ClassCardStack 的元素并返回一个新的 ClassCardStack
static func shuffle(input_stack: ClassCardStack) -> ClassCardStack:
	var shuffled_stack := ClassCardStack.new()
	var temp_array := input_stack._get_stack_copy()  # 通过私有方法获取副本

	temp_array.shuffle()  # 使用 Godot 的 shuffle 方法随机打乱数组

	# 逐个推入元素，保证 encapsulation
	for item in temp_array:
		shuffled_stack.push(item)

	return shuffled_stack


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
		return top_card   # 返回并移除栈顶元素
	else:
		return null  # 如果栈空，返回 null

# 弹出多个元素（pop_n）
func pop_n(n: int) -> Array[ClassCard]:
	var popped_items:Array[ClassCard] = []
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
func _arrange_item()->void:
	if is_empty():
		return
	var index:int = _stack.size()-1
	# 我们假设这里所有的index都是合法的
	var ordering:=true
	var last_point_index = GameSettings.POINTS.find(peek().point)
	while index>=0:
		var card = _stack[index]
		if index == _stack.size()-1:
			card.is_on_top=true
			card.is_in_order=true
		else:
			card.is_on_top=false
			if ordering:				
				var now_point_index = GameSettings.POINTS.find(card.point)
				# 这里只判断了点数，没有判断花色
				if now_point_index==last_point_index+1:
					card.is_in_order=true
				else:
					card.is_in_order=false
					ordering=false
				last_point_index=now_point_index
			else:
				card.is_in_order=false
		index-=1
