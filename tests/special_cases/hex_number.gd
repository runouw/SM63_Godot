extends Node2D


func _ready():
	# "!#FFFFFF.FF #FFFFFF.FF"
	
	var commands = XFL_Edges.new("!#FFFF00.00 #FFFF00.00|#100.00 #100.00").commands
	
	for command in commands:
		print(command)
	
	assert(commands[0][1] == -12.8)
	assert(commands[0][2] == -12.8)
	assert(commands[1][1] == 12.8)
	assert(commands[1][2] == 12.8)
