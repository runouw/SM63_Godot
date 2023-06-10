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
			"S":
				_select_style()
			_:
				pass


func _next_number():
	while _edges[at] in [" ", "\n", "\r", "\t"]: # at most one space is used to separate params
		at += 1
	
	if _edges[at] == "#":
		at += 1
		return _parse_hex_number() / 20.0
	
	var allowed = "0123456789-."
	
	var mark = at
	while _edges[at] in allowed:
		at += 1
		if at >= end:
			break
	
	return float(_edges.substr(mark, at - mark)) / 20.0


func _next_style() -> String:
	while _edges[at] in [" ", "\n", "\r", "\t"]: # at most one space is used to separate params
		at += 1
	
	if _edges[at] == "S":
		at += 1
	
	return _edges[at]


func _parse_hex_number():
	# Be careful that the number '#19F.2' is actually 00019F20 in hexadecimal.
	
	var allowed = "0123456789ABCDEF-."
	
	var buf = ""
	while _edges[at] in allowed:
		if _edges[at] == ".":
			while buf.length() < 6:
				buf = "0" + buf
			at += 1
		
		buf += _edges[at]
		
		at += 1
		if at >= end:
			break
	
	while buf.length() < 8:
		buf += "0"
	
	var bits: int = buf.hex_to_int() & 0xFFFF_FFFF
	
	# Looks like Godot int is 64 and not 32.
	# We have to be careful to handle 32-bit negative
	if (bits & 0x8000_0000) == 0x8000_0000: # highest bit in 32-bit
		# pad 1s
		bits = bits | (~0xFFFF_FFFF)
	
	return float(bits) / 256.0


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


func _select_style():
	var s = _next_style()
	
	commands.append(["style", s])
