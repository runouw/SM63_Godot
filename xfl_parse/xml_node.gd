class_name XMLNode

var name: String
var attributes: Dictionary
var children: Array[XMLNode]
var parent: XMLNode = null
var text: String = ""

func _init(
	p_name: String
):
	name = p_name

func first_child_with_tag(tag: String):
	for child in children:
		if child.name == tag:
			return child
	return null

func all_children_with_tag(tag: String):
	var ret: Array[XMLNode] = []
	for child in children:
		if child.name == tag:
			ret.append(child)
	return ret

func recurse_callback_with_tag(tag: String, callback: Callable):
	for child in children:
		if child.name == tag:
			callback.call(child)
		
		child.recurse_callback_with_tag(tag, callback)
