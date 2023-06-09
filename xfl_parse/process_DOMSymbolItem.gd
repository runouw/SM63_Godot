class_name Process_DOMSymbolItem
extends Object

const DEBUG_separate_polygons: bool = false
const max_bezier_subdivide_cuts: int = 5
const bezier_pixels_per_cut: float = 5.0

var root_node: Node2D

var animation: Animation

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
	
	root_node = Node2D.new()
	root_node.set_script(load("res://xfl_parse/symbol_item/symbol_item.gd"))
	root_node.source_xml = path
	
	# name = model.root.attributes.get("name", "")
	root_node.linkage_export = model.root.attributes.get("linkageExportForAS", "false") == "true"
	root_node.linkage = model.root.attributes.get("linkageIdentifier", "")
	
	var timeline_tag = model.root.first_child_with_tag("timeline")
	if timeline_tag:
		var DOMTimeline_tag = timeline_tag.first_child_with_tag("DOMTimeline")
		root_node.name = DOMTimeline_tag.attributes.get("name", "")
	
	var animation_lib = AnimationLibrary.new()
	animation = Animation.new()
	animation.length = 1.0 / 30.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	var animation_player = AnimationPlayer.new()
	animation_player.name = "Timeline"
	animation_player.add_animation_library("Timeline", animation_lib)
	
	root_node.add_child(animation_player)
	animation_player.owner = root_node
	
	# TODO: include proper output path replacement.
	model.root.path = path.get_basename().replace("sm63/LIBRARY", "sm63_godot")
	model.root.recurse_callback_with_tag("DOMLayer", _process_DOMLayer)
	
	animation_lib.add_animation("Default", animation)
	# animation_player.autoplay = "Timeline/Default"
	root_node.move_child(animation_player, 0)


func _process_DOMLayer(DOMLayer: XMLNode):
	var layer_node = Node2D.new()
	layer_node.name = DOMLayer.attributes.get("name", "untitled")
	
	if DOMLayer.attributes.get("layerType", "") == "mask":
		layer_node.visible = false
		layer_node.name += "(Mask)"
	
	root_node.add_child(layer_node)
	root_node.move_child(layer_node, 0)
	layer_node.owner = root_node
	
	DOMLayer.recurse_callback_with_tag("DOMFrame", func(DOMFrame: XMLNode):
		var frame_index = int(DOMFrame.attributes.get("index", "0"))
		var duration = int(DOMFrame.attributes.get("duration", "1"))
		
		var tweenType: String = DOMFrame.attributes.get("tweenType", "")
		
		var frame_node = Node2D.new()
		frame_node.name = "Frame %d" % frame_index
		layer_node.add_child(frame_node)
		frame_node.owner = root_node
		frame_node.visible = frame_index == 0
		
		var Actionscript_tag := DOMFrame.first_child_with_tag("Actionscript")
		if Actionscript_tag:
			_process_actionscript(Actionscript_tag, frame_node)
		
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
		animation.track_set_path(track_index, NodePath(str(root_node.get_path_to(frame_node)) + ":visible"))
		if frame_index > 0:
			animation.track_insert_key(track_index, 0.0, false)
		animation.track_insert_key(track_index, float(frame_index) / 30.0, true)
		animation.track_insert_key(track_index, float(frame_index + duration) / 30.0, false)
		
		animation.length = max(animation.length, float(frame_index + duration) / 30.0)
		
		var elements_tag = DOMFrame.first_child_with_tag("elements")
		
		if elements_tag:
			_process_elements(elements_tag.children, frame_node, DOMFrame.path)
	)

func _process_actionscript(Actionscript_tag: XMLNode, target: Node2D):
	var script_tag := Actionscript_tag.first_child_with_tag("script")
	if script_tag:
		var script_node := Node.new()
		script_node.name = "AS2"
		
		var script = GDScript.new()
		var text_arr = script_tag.c_data.split("\n")
		script.source_code = "extends Node\n# " + "\n# ".join(text_arr)
		# Does Godot have a better way to set file paths than hardcoding slashes into strings?
		# This seems like it might cause issues on different OSes.
		
		var base_path = Actionscript_tag.path
		assert(base_path != "")
		var script_path = "%s_%d.gd" % [base_path, target.get_instance_id()]
		ResourceSaver.save(script, script_path)
		# Load from file to ensure the script is referenced correctly.
		# This is probably slow.
		script_node.set_script(load(script_path))
		
		target.add_child(script_node)
		script_node.owner = root_node


func _process_elements(elements: Array[XMLNode], parent_node: Node2D, path: String):
	for element in elements:
		element.path = path
		match(element.name):
			"DOMGroup":
				_process_DOMGroup(element, parent_node)
			"DOMShape":
				_process_DOMShape(element, parent_node)
			"DOMBitmapInstance":
				_process_DOMBitmapInstance(element, parent_node)
			"DOMSymbolInstance":
				_process_DOMSymbolInstance(element, parent_node)
			_:
				print("Unhandled element ", element.name)


func _process_DOMGroup(DOMGroup: XMLNode, parent_node: Node2D):
	var group_node = Node2D.new()
	group_node.name = "Group"
	parent_node.add_child(group_node)
	group_node.owner = root_node
	
	for xml_child in DOMGroup.children:
		if xml_child.name == "matrix":
			group_node.transform = _matrix_to_Transform2D_Instances(xml_child)
		
		if xml_child.name == "members":
			_process_elements(xml_child.children, group_node, DOMGroup.path)


func _process_DOMSymbolInstance(DOMSymbolInstance: XMLNode, parent_node: Node2D):
	var symbol_node: Node2D = Node2D.new()
	symbol_node.set_script(load("res://xfl_parse/symbol/symbol_instance.gd"))
	symbol_node.path = XFLUtils.fix_symbol_path(DOMSymbolInstance.attributes.get("libraryItemName", ""))
	symbol_node.name = "DOMSymbolInstance"
	parent_node.add_child(symbol_node)
	symbol_node.owner = root_node
	
	for xml_child in DOMSymbolInstance.children:
		xml_child.path = DOMSymbolInstance.path
		if xml_child.name == "matrix":
			symbol_node.transform = _matrix_to_Transform2D_Instances(xml_child)
		if xml_child.name == "Actionscript":
			_process_actionscript(xml_child, symbol_node)
	
	var filters := DOMSymbolInstance.first_child_with_tag("filters")
	if filters:
		for filter in filters.children:
			print("TODO filter: ", filter.name)
	
	var color := DOMSymbolInstance.first_child_with_tag("color")
	if color:
		_handle_color(color.first_child_with_tag("Color"), symbol_node)


func _handle_color(color: XMLNode, node: Node2D):
	node.red_multiplier = float(color.attributes.get("redMultiplier", "1"))
	node.green_multiplier = float(color.attributes.get("greenMultiplier", "1"))
	node.blue_multiplier = float(color.attributes.get("blueMultiplier", "1"))
	node.alpha_multiplier = float(color.attributes.get("alphaMultiplier", "1"))
	
	node.red_offset = float(color.attributes.get("redOffset", "0"))
	node.green_offset = float(color.attributes.get("greenOffset", "0"))
	node.blue_offset = float(color.attributes.get("blueOffset", "0"))
	
	node.tint_multiplier = float(color.attributes.get("tintMultiplier", "0"))
	node.brightness = float(color.attributes.get("brightness", "0"))
	
	node.tint_color = Color.from_string(color.attributes.get("tintColor", "#000000"), Color.WHITE)


func _matrix_to_Transform2D_Fills(matrix_node: XMLNode) -> Transform2D:
	if matrix_node:
		var dat = matrix_node.first_child_with_tag("Matrix").attributes
		
		var mat := Transform2D(
				Vector2(float(dat.get("a", 1.0)), float(dat.get("b", 0.0))),
				Vector2(float(dat.get("c", 0.0)), float(dat.get("d", 1.0))),
				Vector2(float(dat.get("tx", 0.0)), float(dat.get("ty", 0.0)))
			)
		
		var sc = mat.get_scale() / 20.0
		
		var r = Transform2D()
		r = r.translated(-mat.get_origin() * sc)
		r = r.scaled(Vector2(1.0 / sc.x, 1.0 / sc.y))
		r = r.rotated(-mat.get_rotation())
		
		return r
	
	return Transform2D()


func _matrix_to_Transform2D_Instances(matrix_node: XMLNode) -> Transform2D:
	if matrix_node:
		var dat = matrix_node.first_child_with_tag("Matrix").attributes
		
		var r := Transform2D(
				Vector2(float(dat.get("a", 1.0)), float(dat.get("b", 0.0))),
				Vector2(float(dat.get("c", 0.0)), float(dat.get("d", 1.0))),
				Vector2(float(dat.get("tx", 0.0)), float(dat.get("ty", 0.0)))
			)
		
		return r
	
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
	sprite.owner = root_node


func _process_DOMShape(node_DOMShape: XMLNode, layer_node: Node2D):
	var matrix: XMLNode = node_DOMShape.first_child_with_tag("matrix")
	var fills: XMLNode = node_DOMShape.first_child_with_tag("fills")
	var strokes: XMLNode = node_DOMShape.first_child_with_tag("strokes")
	var edges: XMLNode = node_DOMShape.first_child_with_tag("edges")
	var fillStyles: Array[XMLNode] = []
	var strokeStyles: Array[XMLNode] = []
	
	var shape_node := Node2D.new()
	shape_node.name = "Shape"
	layer_node.add_child(shape_node)
	shape_node.owner = root_node
	
	if matrix:
		# interesting that this replaces the parent transform...?
		# is that because "group" isn't a real object in flash, but used for construction of the tree?
		# TODO: might have to do this trick to DOMBitmapInstance and DOMSymbolInstance too...
		shape_node.transform = layer_node.transform.affine_inverse() * _matrix_to_Transform2D_Instances(matrix)
	
	if fills:
		fillStyles = fills.all_children_with_tag("FillStyle")
	
	if strokes:
		strokeStyles = strokes.all_children_with_tag("StrokeStyle")
	
	var raw_edges: Array[DOMShape_Edge] = []

	if edges:
		for edge in edges.all_children_with_tag("Edge"):
			if not fillStyles.is_empty():
				raw_edges.append_array(_read_edge_commands(edge, shape_node))
	
	_create_polygon_from_edges(raw_edges, shape_node, fillStyles, strokeStyles)


class DOMShape_Edge:
	var a: Vector2
	var b: Vector2
	var fillStyle0: int
	var fillStyle1: int
	var strokeStyle: int
	
	func flip():
		var tmp = b
		b = a
		a = tmp
		
		tmp = fillStyle1
		fillStyle1 = fillStyle0
		fillStyle0 = tmp


func _apply_fillStyle(fills_node: XMLNode, target: Polygon2D):
	var bitmap_fill: XMLNode = fills_node.first_child_with_tag("BitmapFill")
	var solid_fill: XMLNode = fills_node.first_child_with_tag("SolidColor")
	var radial_gradient: XMLNode = fills_node.first_child_with_tag("RadialGradient")
	var linear_gradient: XMLNode = fills_node.first_child_with_tag("LinearGradient")
	
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
		target.color = Color.from_string(solid_fill.attributes.get("color", "#000000"), Color.WHITE)
		target.color.a = float(solid_fill.attributes.get("alpha", 1.0))
	
	if radial_gradient:
		target.set_script(load("res://xfl_parse/gradient/radial_gradient.gd"))
		target.matrix = _matrix_to_Transform2D_Instances(radial_gradient.first_child_with_tag("matrix"))
		
		target.focal_point_ratio = float(radial_gradient.attributes.get("focalPointRatio", "0.0"))
		
		var entries_color := PackedColorArray()
		var entries_ratio := PackedFloat32Array()
		
		var entries = radial_gradient.all_children_with_tag("GradientEntry")
		
		for entry in entries:
			var color := Color.from_string(entry.attributes.get("color", "#000000"), Color.WHITE)
			color.a = float(entry.attributes.get("alpha", "1.0"))
			
			entries_color.append(color)
			entries_ratio.append(float(entry.attributes.get("ratio", "0")))
		
		target.entries_color = entries_color
		target.entries_ratio = entries_ratio
	
	if linear_gradient:
		target.set_script(load("res://xfl_parse/gradient/linear_gradient.gd"))
		target.matrix = _matrix_to_Transform2D_Instances(linear_gradient.first_child_with_tag("matrix"))
		
		var entries_color := PackedColorArray()
		var entries_ratio := PackedFloat32Array()
		
		var entries = linear_gradient.all_children_with_tag("GradientEntry")
		
		for entry in entries:
			var color := Color.from_string(entry.attributes.get("color", "#000000"), Color.WHITE)
			color.a = float(entry.attributes.get("alpha", "1.0"))
			
			entries_color.append(color)
			entries_ratio.append(float(entry.attributes.get("ratio", "0")))
		
		target.entries_color = entries_color
		target.entries_ratio = entries_ratio
		target.spread_method_reflect = linear_gradient.attributes.get("spreadMethod", "") == "reflect"


func _apply_lineStyle(fills_node: XMLNode, target: Line2D):
	var solid_stroke: XMLNode = fills_node.first_child_with_tag("SolidStroke")
	
	target.joint_mode = Line2D.LINE_JOINT_ROUND
	target.begin_cap_mode = Line2D.LINE_CAP_ROUND
	target.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	if solid_stroke:
		var fill := solid_stroke.first_child_with_tag("fill")
		
		if fill:
			var SolidColor = fill.first_child_with_tag("SolidColor")
			if SolidColor:
				target.default_color = Color.from_string(SolidColor.attributes.get("color", "#000000"), Color.BLACK)


func _read_edge_commands(edge_node: XMLNode, layer_node: Node2D) -> Array[DOMShape_Edge]:
	var edge_list = edge_node.attributes.get("edges", "")
	if edge_list == "":
		return []
	
	var edges = XFL_Edges.new(edge_list)
	
	var fillStyle0_index = int(edge_node.attributes.get("fillStyle0", "0"))
	var fillStyle1_index = int(edge_node.attributes.get("fillStyle1", "0"))
	var strokeStyle_index = int(edge_node.attributes.get("strokeStyle", "0"))
	
	var styleCode: String = "1"
	
	var raw_edges: Array[DOMShape_Edge] = []
	
	var p: Vector2 = Vector2.ZERO

	for command in edges.commands:
		if command[0] == "move":
			p = Vector2(command[1], command[2])
		
		if command[0] == "line":
			var p2 = Vector2(command[1], command[2])
			
			var edge := DOMShape_Edge.new()
			edge.a = p
			edge.b = p2
			edge.fillStyle0 = fillStyle0_index
			edge.fillStyle1 = fillStyle1_index
			edge.strokeStyle = strokeStyle_index
			
			raw_edges.append(edge)
			
			p = p2
		
		if command[0] == "curve":
			var p2 = Vector2(command[1], command[2])
			var p3 = Vector2(command[3], command[4])
			
			var l: Vector2 = p
			
			var desired_cuts: int = 1
			
			if not (p2 - p).normalized().is_equal_approx((p3 - p2).normalized()):
				var length_estimate: float = (p2 - p).length() + (p3 - p2).length()
				
				desired_cuts = clamp(int(sqrt(length_estimate / bezier_pixels_per_cut)), 1, max_bezier_subdivide_cuts)
			
			for z in range(1, desired_cuts + 1):
				var t: float = float(z) / desired_cuts
				
				var s1: Vector2 = p.lerp(p2, t)
				var s2: Vector2 = p2.lerp(p3, t)
				var s: Vector2 = s1.lerp(s2, t)
				
				var edge := DOMShape_Edge.new()
				
				edge.a = l
				edge.b = s
				edge.fillStyle0 = fillStyle0_index
				edge.fillStyle1 = fillStyle1_index
				edge.strokeStyle = strokeStyle_index
				
				raw_edges.append(edge)
				
				l = s
			
			p = p3
		
		if command[0] == "style":
			# TODO
			styleCode = command[1]
	
#	var shape_container := Node2D.new()
#	shape_container.name = "Edge"
#	layer_node.add_child(shape_container)
#	shape_container.owner = root_node
#
#	# debug printout
#	for edge in raw_edges:
#		var debug_lines = Line2D.new()
#		debug_lines.width = 1
#		debug_lines.points = PackedVector2Array([edge.a, edge.b])
#		shape_container.add_child(debug_lines)
#		debug_lines.owner = root_node
	
	return raw_edges


func edge_sort_y(e1: DOMShape_Edge, e2: DOMShape_Edge) -> bool:
	return e1.a.y < e2.b.y


func edge_sort_intersection(e1: DOMShape_Edge, e2: DOMShape_Edge, y: float):
	return line_intersect_x(e1, y) < line_intersect_x(e2, y)


class GeneratedPolygon:
	var fillStyle := -1
	var points: PackedVector2Array
	
	# for merging a trapezoid at the bottom
	var tl_i: int = 3
	var tr_i: int = 2


func _create_polygon_from_edges(raw_edges: Array[DOMShape_Edge], shape_node: Node2D, fillStyles: Array[XMLNode], strokeStyles: Array[XMLNode]):
	# make every edge has `a` be the uppermost point
	for edge in raw_edges:
		if edge.b.y < edge.a.y:
			edge.flip()
	
	# sort edges so smallest Y is on top
	# raw_edges.sort_custom(edge_sort_y)
	
	var y_values := PackedFloat32Array()
	for edge in raw_edges:
		if not y_values.has(edge.a.y):
			y_values.append(edge.a.y)
		
		if not y_values.has(edge.b.y):
			y_values.append(edge.b.y)
	
	y_values.sort()
	
	var generated_polygons: Array[GeneratedPolygon] = []
	
	var last_row_size: int = 0
	
	for i in range(0, y_values.size() - 1):
		var y1 = y_values[i]
		var y2 = y_values[i + 1]
		
		var y_mid = y1 * 0.5 + y2 * 0.5
		
		# find all edges that intersect with the horizontal line at y_mid
		var hit_edges: Array[DOMShape_Edge] = []
		
		for edge in raw_edges:
			if y_mid > edge.a.y and y_mid < edge.b.y:
				hit_edges.append(edge)
		
		# sort hit_edges by the x value of the intersection point
		
		hit_edges.sort_custom(edge_sort_intersection.bind(y_mid))
		
		# produce trapezoids from this intersection data:
		for h in range(hit_edges.size() - 1):
			var edge1 = hit_edges[h]
			var edge2 = hit_edges[h + 1]
			
			# The Adobe Flash authoring tool supports two fill styles per edge, 
			# one for each side of the edge: FillStyle0 and FillStyle1.
			
			# For shapes that don’t self-intersect or overlap, FillStyle0 should
			# be used.
			
			# For overlapping shapes the situation is more complex. For example,
			# if a shape consists of two overlapping squares, and only
			# FillStyle0 is defined, Flash Player renders a ‘hole’ where the
			# paths overlap. This area can be filled using FillStyle1. In this
			# situation, the rule is that for any directed vector, FillStyle0 is
			# the color to the left of the vector, and FillStyle1 is the color
			# to the right of the vector
			
			var fillStyle: int = edge1.fillStyle0
			if edge1.b.y < edge1.a.y:
				fillStyle = edge1.fillStyle1
			
			if fillStyle != 0:
				var tl := Vector2(line_intersect_x(edge1, y1), y1)
				var tr := Vector2(line_intersect_x(edge2, y1), y1)
				var br := Vector2(line_intersect_x(edge2, y2), y2)
				var bl := Vector2(line_intersect_x(edge1, y2), y2)
				
				var trap := GeneratedPolygon.new()
				trap.points = PackedVector2Array([
					tl, tr,
					br, bl
				])
				
				trap.fillStyle = fillStyle
				
				# merge with previous row when possible!
				var matched := false
				
				for p in range(last_row_size):
					if generated_polygons.size() - 1 - p < 0:
						continue
					
					var prev_polygon := generated_polygons[generated_polygons.size() - 1 - p]
					
					if prev_polygon.points[prev_polygon.tl_i].is_equal_approx(tl) and prev_polygon.points[prev_polygon.tr_i].is_equal_approx(tr):
						if not tl.is_equal_approx(tr): # pinch points will break Godot triangulation
							matched = true
							
							prev_polygon.points.insert(prev_polygon.tl_i, br)
							prev_polygon.points.insert(prev_polygon.tl_i + 1, bl)
							
							prev_polygon.tl_i += 1
							prev_polygon.tr_i += 1
				
				if not matched:
					generated_polygons.append(trap)
		
		last_row_size = hit_edges.size()
	
	# simplify the geometry of the polygons
	for generated_polygon in generated_polygons:
		var i :int = 0
		while true:
			if i >= generated_polygon.points.size() - 2:
				break
			
			var a = generated_polygon.points[i]
			var b = generated_polygon.points[i + 1]
			var c = generated_polygon.points[i + 2]
			
			var ab = (b - a).normalized()
			var bc = (c - b).normalized()
			
			if ab.is_equal_approx(bc) or ab.is_equal_approx(-bc):
				generated_polygon.points.remove_at(i + 1)
			else:
				i += 1
	
	if DEBUG_separate_polygons:
		# each polygon is it's own node
		for generated_polygon in generated_polygons:
			var polygon_node = Polygon2D.new()
			
			var fillStyle = generated_polygon.fillStyle - 1
			_apply_fillStyle(fillStyles[fillStyle], polygon_node)
			polygon_node.polygon = generated_polygon.points
			
			shape_node.add_child(polygon_node)
			polygon_node.owner = root_node
	else:
		# group by fillStyle
		for fillStyle in range(fillStyles.size()):
			var polygon_node = Polygon2D.new()
			
			_apply_fillStyle(fillStyles[fillStyle], polygon_node)
			
			shape_node.add_child(polygon_node)
			polygon_node.owner = root_node
			
			var polygon_verts := PackedVector2Array()
			var polygon_indices: Array[PackedInt32Array] = []
			
			# create polygon2d nodes:
			for generated_polygon in generated_polygons:
				if fillStyle == generated_polygon.fillStyle - 1:
					var o = polygon_verts.size()
					polygon_verts.append_array(generated_polygon.points)
					
					var arr := PackedInt32Array()
					for i in range(generated_polygon.points.size()):
						arr.append(i + o)
					
					polygon_indices.append(arr)
			
			polygon_node.polygon = polygon_verts
			polygon_node.polygons = polygon_indices
	
	# draw strokes
	for strokeStyle_index in range(strokeStyles.size()):
		var line_node = Line2D.new()
		line_node.width = 1
		
		_apply_lineStyle(strokeStyles[strokeStyle_index], line_node)
		
		for edge in raw_edges:
			if edge.strokeStyle - 1 == strokeStyle_index:
				
				line_node.add_point(edge.a)
				line_node.add_point(edge.b)
				line_node.add_point(Vector2.ONE * NAN)
			
		shape_node.add_child(line_node)
		line_node.owner = root_node


func line_intersect_x(edge: DOMShape_Edge, y_mid: float) -> float:
	# y - y1 = m(x - x1)
	
	var p1: Vector2 = edge.a
	var p2: Vector2 = edge.b
	
	var run = p2.x - p1.x
	
	if abs(run) < 1e-6: # vertical line
		return p1.x
	
	var m = (p2.y - p1.y) / run
	
	# now get the x intersection for the mid_y value
	# x = (y - y1) / m + x1
	return (y_mid - p1.y) / m + p1.x
