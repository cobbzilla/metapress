extends Node

func _ready():
	$JoinRoomApi.api_init(self)

func handle_api_response (room):
	print("joined room: {room}".format({ "room": room }))
	$ApiSession.room = room
	get_tree().change_scene("res://screens/game_board/GameBoardScreen.tscn")
