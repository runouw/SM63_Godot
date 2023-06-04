class_name XmlModel
extends Node

var root: XMLNode = null

func _init(parser: XMLParser):
	var current_node: XMLNode = null
	
	while parser.read() == 0:
		# print(parser.get_current_line())
		
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node_name = parser.get_node_name()
				
				# print(node_name, " ", parser.get_attribute_count(), " empty = ", parser.is_empty())
				
				var attributes = {}
				
				for attribute_id in range(parser.get_attribute_count()):
					var attribute_name = parser.get_attribute_name(attribute_id)
					var attribute_value = parser.get_attribute_value(attribute_id)
					
					attributes[attribute_name] = attribute_value
					
					# print("    ", attribute_name, " = ", attribute_value)
				
				var element = XMLNode.new(node_name)
				element.attributes = attributes
				
				if root == null:
					root = element
					current_node = element
				else:
					current_node.children.append(element)
					element.parent = current_node
					
					if not parser.is_empty(): # Node without children: e.g. '<node/>'
						current_node = element
				
			XMLParser.NODE_ELEMENT_END:
				# print("/", parser.get_node_name())
				current_node = current_node.parent
			XMLParser.NODE_TEXT:
				var text = parser.get_node_data().strip_edges()
				
				if not text.is_empty():
					current_node.text = text
					print("text: '", text, "'")
			_:
				print("unhandled node type: ", parser.get_node_type())


static func process_callback_objects(current_node: Dictionary, target):
	var method_name = "_node_%s" % [current_node.name]
	
	if target.has_method(method_name):
		target.call(method_name, current_node)
	
	for child in current_node.children:
		process_callback_objects(child, target)


static func process_match_callable(current_node: Dictionary, match_name: String, callable: Callable):
	if current_node.name == match_name:
		callable.call(current_node)
	
	for child in current_node.children:
		process_match_callable(child, match_name, callable)


static func match_first_tag(current_node: Dictionary, tag_name: String):
	if current_node.name == tag_name:
		return current_node
	
	for child in current_node.children:
		return match_first_tag(child, tag_name)
	
	return null


static func match_all_tags(current_node: Dictionary, tag_name: String):
	var ret = []
	_match_all_tags(current_node, tag_name, ret)
	
	return ret


static func _match_all_tags(current_node: Dictionary, tag_name: String, ret: Array):
	if current_node.name == tag_name:
		ret.append(current_node)
		return
	
	for child in current_node.children:
		return _match_all_tags(child, tag_name, ret)
	
	return
