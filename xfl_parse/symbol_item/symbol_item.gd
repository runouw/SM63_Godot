@tool
extends Node2D

@export_file var source_xml: String = ""
@export var linkage: String = ""
@export var linkage_export: bool = false

@export var regenerate: bool = false:
	set(to):
		if to:
			XFLUtils.convert_xfl_file(source_xml)
			print("Renerated!")
		regenerate = false
