class_name Process_DOMSymbolItem
extends Node2D

var linkage: String = ""
var linkage_export: bool = false

func _init(path: String):
	var parser = XMLParser.new()
	
	var error = parser.open(path)
	if error != 0:
		print("error ", error)
		return
	
	var model = XmlModel.new(parser)
	
	if model.root.name != "DOMSymbolItem":
		print("NOT DOMSymbolItem!")
		return
	
	name = model.root.attributes.get("name", "")
	linkage_export = model.root.attributes.get("linkageExportForAS", "false") == "true"
	linkage = model.root.attributes.get("linkageIdentifier", "")
	
#	var timeline_tag = model.root.first_child_with_tag("timeline")
#	if timeline_tag:
#		var DOMTimeline_tag = timeline_tag.first_child_with_tag("DOMTimeline")
#
#		var layers_tag = DOMTimeline_tag.first_child_with_tag("layers")
	
	model.root.recurse_callback_with_tag("DOMLayer", _process_DOMLayer)


func _process_DOMLayer(DOMLayer: XMLNode):
	var layer_node = Node2D.new()
	layer_node.name = DOMLayer.attributes.get("name", "untitled")
	add_child(layer_node)
	move_child(layer_node, 0)
	layer_node.owner = self
	
	DOMLayer.recurse_callback_with_tag("DOMFrame", func(DOMFrame: XMLNode):
		var frame_index = DOMFrame.attributes.get("index", "0")
		
		var frame_node = Node2D.new()
		frame_node.name = "Frame %s" % frame_index
		layer_node.add_child(frame_node)
		frame_node.owner = layer_node
		frame_node.visible = frame_index == "0"
		
		var elements_tag = DOMFrame.first_child_with_tag("elements")
		
		if elements_tag:
			_process_elements(elements_tag.children, frame_node)
	)


func _process_elements(elements: Array[XMLNode], parent_node: Node2D):
	for element in elements:
		match(element.name):
			"DOMGroup":
				_process_DOMGroup(element, parent_node)
			"DOMShape":
				_process_DOMShape(element, parent_node)
			"DOMBitmapInstance":
				_process_DOMBitmapInstance(element, parent_node)
			_:
				print("Unhandled element ", element.name)


func _process_DOMGroup(DOMGroup: XMLNode, parent_node: Node2D):
	var group_node = Node2D.new()
	group_node.name = "Group"
	parent_node.add_child(group_node)
	group_node.owner = parent_node
	
	for xml_child in DOMGroup.children:
		if xml_child.name == "matrix":
			group_node.transform = _matrix_to_Transform2D_Instances(xml_child)
		
		if xml_child.name == "members":
			_process_elements(xml_child.children, group_node)


func _matrix_to_Transform2D_Fills(matrix_node: XMLNode) -> Transform2D:
	if matrix_node:
		var dat = matrix_node.first_child_with_tag("Matrix").attributes
		
		var tr := Transform2D(
				Vector2(float(dat.get("a", 20.0)), float(dat.get("b", 0.0))),
				Vector2(float(dat.get("c", 0.0)), float(dat.get("d", 20.0))),
				Vector2(float(dat.get("tx", 0.0)), float(dat.get("ty", 0.0)))
			).inverse()
		
		return tr.scaled(Vector2(1.0, 1.0) / 20.0)
	
	return Transform2D()


func _matrix_to_Transform2D_Instances(matrix_node: XMLNode) -> Transform2D:
	if matrix_node:
		var dat = matrix_node.first_child_with_tag("Matrix").attributes
		
		var tr := Transform2D(
				Vector2(float(dat.get("a", 1.0)), float(dat.get("b", 0.0))),
				Vector2(float(dat.get("c", 0.0)), float(dat.get("d", 1.0))),
				Vector2(float(dat.get("tx", 0.0)), float(dat.get("ty", 0.0)))
			)
		
		tr.origin = tr.origin
		
		return tr
	
	return Transform2D()


func _process_DOMBitmapInstance(node_DOMBitmapInstance: XMLNode, layer_node: Node2D):
	var sprite = Sprite2D.new()
	
	var fixed_path = XFLUtils.fix_image_path(node_DOMBitmapInstance.attributes["libraryItemName"])
	var tex = load(fixed_path)
	
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.transform = _matrix_to_Transform2D_Instances(node_DOMBitmapInstance.first_child_with_tag("matrix"))
	sprite.centered = false
	
	layer_node.add_child(sprite)
	sprite.owner = layer_node


func _process_DOMShape(node_DOMShape: XMLNode, layer_node: Node2D):
	var fills: XMLNode = node_DOMShape.first_child_with_tag("fills")
	var edges: XMLNode = node_DOMShape.first_child_with_tag("edges")
	var fillStyles: Array[XMLNode] = []
	
	var shape_node := Node2D.new()
	shape_node.name = "Shape"
	layer_node.add_child(shape_node)
	shape_node.owner = layer_node
	
	if fills:
		fillStyles = fills.all_children_with_tag("FillStyle")
	
	if edges:
		for edge in edges.all_children_with_tag("Edge"):
			if not fillStyles.is_empty():
				_process_Edge(edge, fillStyles, shape_node)


func _process_Edge(edge_node: XMLNode, fills: Array[XMLNode], layer_node: Node2D):
	var edge_list = edge_node.attributes.get("edges", "")
	if edge_list == "":
		return
	
	var edges = XFL_Edges.new(edge_list)
	
	var raw_edges = []
	
	var p: Vector2 = Vector2.ZERO
	
	for command in edges.commands:
		if command[0] == "move":
			p = Vector2(command[1], command[2])
		
		if command[0] == "line":
			var p2 = Vector2(command[1], command[2])
			raw_edges.append([p, p2])
			p = p2
		
		if command[0] == "curve":
			var p2 = Vector2(command[1], command[2])
			var p3 = Vector2(command[3], command[4])
			raw_edges.append([p, p3])
			p = p3
	
	while true:
		var edge = raw_edges.pop_front()
		if edge == null:
			break
		
		while true:
			var end = edge[edge.size() - 1]
			var found = false
			
			for i in range(raw_edges.size()):
				var edge2 = raw_edges[i]
				var l = edge2.size() - 1
				
				if end == edge2[0]:
					edge2.remove_at(0)
					edge.append_array(edge2)
					raw_edges.remove_at(i)
					found = true
					break
				elif end == edge2[l]:
					edge2.remove_at(l)
					edge.append_array(edge2)
					raw_edges.remove_at(i)
					found = true
					break
			
			if not found:
				break
		
		var new_node := Polygon2D.new()
		new_node.polygon = PackedVector2Array(edge)
		
		if edge_node.attributes.has("fillStyle0"):
			var index = int(edge_node.attributes["fillStyle0"]) - 1
			
			_get_fillStyle(fills[index], new_node)
		
		if edge_node.attributes.has("fillStyle1"):
			var index = int(edge_node.attributes["fillStyle1"]) - 1
			
			_get_fillStyle(fills[index], new_node)
		
		layer_node.add_child(new_node)
		new_node.owner = layer_node

func _get_fillStyle(fills_node: XMLNode, target: Polygon2D):
	var bitmap_fill: XMLNode = fills_node.first_child_with_tag("BitmapFill")
	var solid_fill: XMLNode = fills_node.first_child_with_tag("SolidColor")
	
	if bitmap_fill:
		var tex = load(XFLUtils.fix_image_path(bitmap_fill.attributes["bitmapPath"]))
		
		target.texture = tex
		target.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		target.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		var transform := _matrix_to_Transform2D_Fills(bitmap_fill.first_child_with_tag("matrix"))
		
		target.texture_offset = transform.get_origin()
		target.texture_rotation = transform.get_rotation()
		target.texture_scale = transform.get_scale()
	
	if solid_fill:
		target.color = Color.from_string(solid_fill.attributes.get("color", "#FFFFFF"), Color.WHITE)
