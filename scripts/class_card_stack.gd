class_name ClassCardStack
extends Node

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

func arrange_item()->void:
	for card in _stack:
		card.is_on_top=false
	peek().is_on_top=true
	peek().is_flipped=false

# 推入元素（push）
func push(value: ClassCard) -> void:
	if not is_empty():
		peek().is_on_top=false
	_stack.append(value)
	peek().is_on_top=true

# 弹出元素（pop）
func pop() -> ClassCard:
	if _stack.size() > 0:
		var top_card = _stack.pop_back()
		top_card.is_flipped=false
		if not is_empty():
			peek().is_on_top=true
		return top_card   # 返回并移除栈顶元素
	else:
		return null  # 如果栈空，返回 null

# 查看栈顶元素（peek）
func peek() -> ClassCard:
	if _stack.size() > 0:
		return _stack[_stack.size() - 1]  # 返回栈顶元素
	else:
		return null  # 如果栈空，返回 null

# 清空栈
func clear() -> void:
	_stack.clear()

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
