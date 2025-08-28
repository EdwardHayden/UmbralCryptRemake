extends Node

var players : Dictionary = {}

func add_player(id : int, name : String):
	var setup = PlayerInfo.new()
	setup.name = name
	setup.position = Vector3.ZERO
	players[id] = setup
