class_name XFL_Edges
extends Node

var _edges: String
var at: int = 0
var end: int = 0

var commands = []

func _init(p_edges: String):
	_edges = p_edges
	# https://stackoverflow.com/questions/4077200/whats-the-meaning-of-the-non-numerical-values-in-the-xfls-edge-definition
	# !(x,y) moveTo
	# /(x,y)+ lineTo
	# |(x,y)+ lineTo
	# [(x1 y1 ex ey)+ curveTo (quadratic)
	# ](x1 y1 ex ey)+ curveTo (quadratic)
	# Sn selection (n=bitmask, 1:fillStyle0, 2:fillStyle1, 4:stroke)
	
	# https://github.com/SasQ/SavageFlask/blob/master/doc/FLA.txt
	# #aaaaaa.bb is a signed fixed point 32 bit number
	# For example, the correct result for '#BD9.4D' is 3033.30078125, because:
	# >> 'BD94D'.hex.to_f / 256 == 3033.30078125
	
	end = _edges.length()
	
	while at < end:
		var ch = _edges[at]
		at += 1
		
		match(ch):
			"!":
				_move_to()
			"|":
				_line_to()
			"[":
				_curve_to()
			_:
				pass


func _next_number():
	if _edges[at] == " ": # at most one space is used to separate params
		at += 1
	
	if _edges[at] == "#":
		at += 1
		return _parse_hex_number() / 20.0
	
	var allowed = "0123456789-."
	
	var buf = ""
	while _edges[at] in allowed:
		buf += _edges[at]
		at += 1
		if at >= end:
			break
	
	return float(buf) / 20.0


func _parse_hex_number():
	# Be careful that the number '#19F.2' is actually 00019F20 in hexadecimal.
	
	var allowed = "0123456789ABCDEF-."
	
	var buf = ""
	while _edges[at] in allowed:
		if _edges[at] == ".":
			buf.pad_zeros(6)
			at += 1
		
		buf += _edges[at]
		
		at += 1
		if at >= end:
			break
	
	while buf.length() < 8:
		buf += "0"
	
	return float(buf.hex_to_int()) / 256.0


func _move_to():
	var x = _next_number()
	var y = _next_number()
	
	commands.append(["move", x, y])


func _line_to():
	var x = _next_number()
	var y = _next_number()
	
	commands.append(["line", x, y])


func _curve_to():
	var x1 = _next_number()
	var y1 = _next_number()
	var ex = _next_number()
	var ey = _next_number()
	
	commands.append(["curve", x1, y1, ex, ey])
