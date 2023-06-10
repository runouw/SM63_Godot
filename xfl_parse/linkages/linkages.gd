extends Node

@export var linkages: Dictionary



const LEVEL_COMPONENTS := [
	"FrontGFX",
	"BackGFX",
	"BPlatforms",
	"Platforms",
	"CamEdge",
	"Edge"
]

const BACKGROUND_SPEED := {
	"FarBackground": 0.0,
	"Background": 0.1,
	"MidBackground": 0.2,
	"CloseBackground": 0.5,
}

const SM63_BACKGROUNDS := {
	#
	"K-1FarBackground": "K-1FarBG",
	"K-1Background": "GrassandHillsBG",
	#"K-1CloseBackground": "8-E1-2-2CloseBG",

	"K-2FarBackground": "4-farBG",
	"K-3FarBackground": "4-farBG",
	#
	"C-1Background": "CastleColoredBGHigh",
	"C-1FarBackground": "CastleColoredFarBG",
	#CastleColoredFarBGHigh
	"C-2-2Background": "CastleColoredBG",
	"C-2-2FarBackground": "CastleColoredFarBG",
	"C-SBackground": "CastleColoredBG",
	"C-SFarBackground": "CastleColoredFarBG",
	"C-4Background": "CastleColoredBG",
	"C-4FarBackground": "CastleColoredFarBG",
	"C-4HBackground": "CastleColoredBG",
	"C-4HFarBackground": "CastleColoredFarBG",
	"C-4-SC1Background": "CastleColoredBG",
	"C-4-SC1FarBackground": "CastleColoredFarBG",
	"C-7Background": "CastleColoredBG",
	"C-7FarBackground": "CastleColoredFarBG",
	"C-10Background": "CastleColoredBG",
	"C-10FarBackground": "CastleColoredFarBG",
	"C-11Background": "CastleColoredBG",
	"C-11FarBackground": "CastleColoredFarBG",
	"C-13FarBackground": "C-13FarBG",
	"C-13Background": "C-13BG",
	#
	"C-OBackground": "CastleColoredBG",
	"C-OFarBackground": "CastleColoredFarBG",
	#
	"1-1Background": "GrassandHillsBG",
	"1-1FarBackground": "1-FarBG",
	"1-2Background": "GrassandHillsBG",
	"1-2FarBackground": "1-FarBG",
	"1-3Background": "GrassandHillsBG",
	"1-3FarBackground": "1-FarBG",
	"1-4Background": "GrassandHillsBG",
	"1-4FarBackground": "1-FarBG",
	#"1-4Maxzoomout": 40,
	"1-5FarBackground": "SecretLevelBG",
	#
	#"1-4Background": "GrassandHillsBG",
	"2-1FarBackground": "2-farBG",
	"2-1MidBackground": "2-1MidBG",
	"2-2FarBackground": "2-farBG",
	"2-2AFarBackground": "2-farBG",
	"2-2AMidBackground": "2-2AMidBG",
	"2-3FarBackground": "2-farBG",
	"2-3MidBackground": "2-1MidBG",
	"2-4FarBackground": "2-farBG",
	"2-5FarBackground": "SecretLevelBG",
	#
	"3-1Background": "3-BG",
	"3-1FarBackground": "3-farBG",
	"3-2Background": "3-BG",
	"3-2FarBackground": "3-farBG",
	"3-3Background": "3-BG",
	"3-3FarBackground": "3-farBG",
	"3-4Background": "3-BG",
	"3-4FarBackground": "3-farBG",
	#
	"3-5Background": "3-BG",
	"3-5FarBackground": "3-farBG",
	"3-6Background": "3-BG",
	"3-6FarBackground": "3-farBG",
	"3-7Background": "3-BG",
	"3-7FarBackground": "3-farBG",
	"3-8Background": "3-BG",
	"3-8FarBackground": "SecretLevelBG",
	"4-1FarBackground": "4-1BG",
	"4-2FarBackground": "4-1BG",
	"4-8FarBackground": "4-1BG",
	"4-9FarBackground": "4-1BG",
	"4-11FarBackground": "4-11BG",
	#
	"5-1FarBackground": "4-farBG",
	"5-1CloseBackground": "5-1CloseBG",
	"5-2FarBackground": "4-farBG",
	"5-2CloseBackground": "5-2CloseBG",
	"5-3FarBackground": "4-farBG",
	"5-3CloseBackground": "5-3CloseBG",
	"5-3MidBackground": "5-3MidBG",
	"5-4FarBackground": "4-farBG",
	"5-4CloseBackground": "5-4CloseBG",
	"5-7FarBackground": "4-farBG",
	"5-7CloseBackground": "5-1CloseBG",
	"5-8FarBackground": "4-farBG",
	"5-8CloseBackground": "5-8CloseBG",
	"5-8MidBackground": "5-1CloseBG",
	"5-9FarBackground": "SecretLevelBG",
	#
	"5-5CloseBackground": "5-5CloseBG",
	"5-5MidBackground": "5-5MidBG",
	"5-5Background": "5-5BG",
	#"5-5FarBackground": "Black-BG",
	"5-5FarBackground": "5-5FarBG",
	"5-6CloseBackground": "5-5CloseBG",
	"5-6MidBackground": "5-5MidBG",
	"5-6Background": "5-5BG",
	#"5-6FarBackground": "Black-BG",
	#5-5CloseBG
	#
	"6-1FarBackground": "CloudBackground",
	"6-1Background": "GrassandHillsBG",
	"6-1-2FarBackground": "CloudBackground",
	"6-1-2Background": "GrassandHillsBG",
	"6-2FarBackground": "CloudBackground",
	"6-2Background": "GrassandHillsBG",
	"6-3FarBackground": "CloudBackground",
	"6-3Background": "GrassandHillsBG2",
	"6-4FarBackground": "6-farBG",
	"6-4Background": "GrassandHillsBG2",
	"6-5FarBackground": "SecretLevelBG",
	"6-6FarBackground": "CloudBackground",
	"6-6Background": "GrassandHillsBG2",
	#
	"7-1FarBackground": "MovingCloudsBackground",
	"7-1Background": "7-MountainsBG",
	"7-2FarBackground": "MovingCloudsBackground",
	"7-2Background": "7-MountainsBG",
	"7-3FarBackground": "MovingCloudsBackground",
	"7-3Background": "7-MountainsBG2",
	"7-4FarBackground": "MovingCloudsBackground",
	"7-4Background": "7-MountainsBG2",
	"7-5FarBackground": "MovingCloudsBackground",
	"7-5Background": "7-MountainsBG",
	"7-6FarBackground": "SecretLevelBG",
	"7-6CloseBackground": "7-6CloseBG",
	#
	"8-1FarBackground": "4-farBG",
	"8-1CloseBackground": "8-1CloseBG",
	"8-2FarBackground": "4-farBG",
	"8-2MidBackground": "8-2MidBG",
	"8-2CloseBackground": "8-2CloseBG",
	#
	"8-3FarBackground": "4-farBG",
	"8-3CloseBackground": "8-InsideCloseBG",
	"8-3MidBackground": "8-InsideFarBG",
	"8-4FarBackground": "4-farBG",
	"8-4CloseBackground": "8-InsideCloseBG",
	"8-4MidBackground": "8-InsideFarBG",
	"8-5FarBackground": "4-farBG",
	"8-5CloseBackground": "8-1CloseBG",
	"8-6FarBackground": "4-farBG",
	"8-6CloseBackground": "8-InsideCloseBG",
	"8-6MidBackground": "8-InsideFarBG",
	"8-7FarBackground": "4-farBG",
	"8-7MidBackground": "8-7MidBG",
	"8-8FarBackground": "4-farBG",
	"8-8CloseBackground": "8-UpperInsideCloseBG",
	"8-8MidBackground": "8-UpperInsideMidBG",
	"8-9FarBackground": "4-farBG",
	"8-9CloseBackground": "8-UpperInsideCloseBG",
	"8-9MidBackground": "8-UpperInsideMidBG",
	"8-10FarBackground": "4-farBG",
	"8-10CloseBackground": "8-UpperInsideCloseBG",
	"8-10MidBackground": "8-UpperInsideMidBG",
	"8-10-bFarBackground": "4-farBG",
	"8-10-bCloseBackground": "8-UpperInsideCloseBG",
	"8-10-bMidBackground": "8-UpperInsideMidBG",
	#
	"8-11FarBackground": "4-farBG",
	"8-12FarBackground": "4-farBG",
	"8-12CloseBackground": "8-UpperInsideCloseBG",
	"8-12MidBackground": "8-UpperInsideMidBG",
	#
	"8-13FarBackground": "SpaceFarBG",
	"8-13CloseBackground": "8-13CloseBG",
	"8-13Background": "8-13BG",
	"8-14FarBackground": "SpaceFarBG",
	"8-14CloseBackground": "8-13CloseBG",
	"8-14Background": "8-14BG",
	#
	"8-15FarBackground": "SpaceFarBG",
	"8-15CloseBackground": "8-13CloseBG",
	"8-15MidBackground": "8-15MidBG",
	"8-15Background": "8-15BG",
	#
	"8-16FarBackground": "SpaceFarBG2",
	"8-16CloseBackground": "8-16CloseBG",
	"8-16MidBackground": "8-16MidBG",
	"8-16Background": "8-16BG",
	#
	"BC-1FarBackground": "4-farBG",
	"BC-1CloseBackground": "BC-1CloseBG",
	#"BC-1MidBackground": "8-16MidBG",
	"BC-1Background": "BC-1BG",
	#
	"BC-2FarBackground": "4-farBG",
	"BC-2CloseBackground": "BC-2CloseBG",
	#"BC-1MidBackground": "8-16MidBG",
	"BC-2Background": "BC-2BG",
	#
	"BC-3FarBackground": "4-farBG",
	"BC-3CloseBackground": "BC-3CloseBG",
	#"BC-1MidBackground": "8-16MidBG",
	"BC-3Background": "BC-3BG",
	#"8-10MidBackground": "8-UpperInsideMidBG",
	#8-InsideCloseBG
	#
	#
	"8-E1-1Background": "CastleColoredBG",
	"8-E1-1FarBackground": "CastleColoredFarBG",
	"8-E1-1CloseBackground": "8-E1-1CloseBG",
	"8-E1-1-2Background": "CastleColoredBG",
	"8-E1-1-2FarBackground": "CastleColoredFarBG",
	"8-E1-1-2CloseBackground": "8-E1-1CloseBG",
	"8-E1-2Background": "CastleColoredBG",
	"8-E1-2FarBackground": "CastleColoredFarBG",
	"8-E1-2CloseBackground": "8-E1-2CloseBG",
	"8-E1-2-2FarBackground": "CastleColoredFarBG",
	"8-E1-2-2CloseBackground": "8-E1-2-2CloseBG",
	#
	"8-E2-1FarBackground": "BowsersTrap1BG",
	"8-E2-2FarBackground": "BowsersTrap1BG",
	#
	"8-E3-1FarBackground": "CloudBackground",
	"8-E3-1Background": "GrassandHillsBG",
	"8-E3-2FarBackground": "CloudBackground",
	"8-E3-2Background": "GrassandHillsBG",
	"8-E3-2CloseBackground": "8-E1-2-2CloseBG",
	#
	"8-E5-1FarBackground": "4-farBG",
	"8-E5-2FarBackground": "4-farBG",
	"8-E5-3FarBackground": "4-farBG",
	"8-E5-4FarBackground": "4-farBG",
	"8-E5-4CloseBackground": "8-E5-4CloseBG",
	#8-E5-4CloseBG
	#
	"9-01FarBackground": "1UpBG",
	"9-02CloseBackground": "9-02CloseBG",
	"9-02FarBackground": "1-FarBG",
	"9-04FarBackground": "2-farBG",
	#
	"9-03Background": "3-BG",
	"9-03FarBackground": "3-farBG",
	"9-03-DBackground": "3-BG",
	"9-03-DFarBackground": "3-farBG",
	"9-03-2Background": "3-BG",
	"9-03-2FarBackground": "3-farBG",
	#
	"9-05Background": "GrassandHillsBG",
	"9-05FarBackground": "1-FarBG",
	"9-06FarBackground": "SecretLevelBG",
	#
	"9-07Background": "GrassandHillsBG",
	"9-07FarBackground": "1-FarBG",
	"9-08FarBackground": "4-farBG",
	"9-08CloseBackground": "8-1CloseBG",
	"9-10Background": "3-BG",
	"9-10FarBackground": "3-farBG",
	"9-10-2Background": "3-BG",
	"9-10-2FarBackground": "3-farBG",
	"9-11FarBackground": "SpaceFarBG",
	#
	"M1-1FarBackground": "M1-Background",
	"M1-1MidBackground": "M1-1MidBG",
	"M1-1CloseBackground": "M1-1CloseBG",
	"M1-2CloseBackground": "M1-2CloseBG",
	#
	"M2-1CloseBackground": "M2-1CloseBG",
	"M2-1FarBackground": "1-FarBG",
	"M2-2CloseBackground": "M2-1CloseBG",
	"M2-2FarBackground": "1-FarBG",
	"M2-3CloseBackground": "M2-3CloseBG",
	"M2-3MidBackground": "M2-3MidBG",
	#
	"M3-1CloseBackground": "M3-1CloseBG",
	"M3-2CloseBackground": "M3-2CloseBG",
	"M3-3CloseBackground": "M3-2CloseBG",
	#
	"level1FarBackground": "CloudBackground",
	"level1Background": "GrassandHillsBG"
	#
}


func _ready():
	var level_names := {}
	
	for linkage in linkages.keys():
		var level_name := ""
		
		for component in LEVEL_COMPONENTS:
			if linkage.ends_with(component):
				level_name = linkage.trim_suffix(component)
				break
		
		level_names[level_name] = true
	
	for level_name in level_names.keys():
		if not level_name.is_empty():
			_generate_level_scene(level_name)


func _generate_level_scene(level: String):
	var output_path = "res://sm63_courses/" + level + ".tscn"
	
	print(level)
	
	var root_node := Node2D.new()
	root_node.name = level
	
	var background_node := Node2D.new()
	background_node.name = "Background"
	root_node.add_child(background_node)
	background_node.owner = root_node
	
	for component in BACKGROUND_SPEED.keys():
		# SM63_BACKGROUNDS
		var component_linkage: String = level + component
		component_linkage = SM63_BACKGROUNDS.get(component_linkage, component_linkage)
		
		if linkages.has(component_linkage):
			var container_scene: Node2D = Node2D.new()
			container_scene.name = component
			container_scene.set_script(load("res://team63/parallax/r_parallax.gd"))
			container_scene.move_scale = BACKGROUND_SPEED[component]
			background_node.add_child(container_scene)
			container_scene.owner = root_node
			
			
			var tscn_path: String = XFLUtils.xml_to_tscn_path(linkages.get(component_linkage, ""))
			
			if tscn_path.is_empty():
				continue
			
			print("   ", level + component)
			var component_scene: Node2D = load(tscn_path).instantiate()
			
			container_scene.add_child(component_scene)
			component_scene.owner = root_node
	
	for component in ["BackGFX", "FrontGFX"]:
		var component_linkage: String = level + component
		
		if linkages.has(component_linkage):
			var tscn_path: String = XFLUtils.xml_to_tscn_path(linkages.get(component_linkage, ""))
			
			if tscn_path.is_empty():
				continue
			
			var component_scene: Node2D = load(tscn_path).instantiate()
			component_scene.name = component
			
			root_node.add_child(component_scene)
			component_scene.owner = root_node
	
	var collisions_node := Node2D.new()
	collisions_node.name = "Collisions"
	collisions_node.modulate = Color.WHITE
	collisions_node.modulate.a = 0.4
	collisions_node.visible = false
	root_node.add_child(collisions_node)
	collisions_node.owner = root_node
	
	for component in ["Platforms", "BPlatforms", "CamEdge", "Edge"]:
		var component_linkage:String = level + component
		
		if linkages.has(component_linkage):
			var tscn_path: String = XFLUtils.xml_to_tscn_path(linkages.get(component_linkage, ""))
			
			if tscn_path.is_empty():
				continue
			
			var component_scene: Node2D = load(tscn_path).instantiate()
			component_scene.name = component
			
			collisions_node.add_child(component_scene)
			component_scene.owner = root_node
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(root_node)
	var error := ResourceSaver.save(packed_scene, output_path)
	if error != OK:
		print("Error saving ", error)
