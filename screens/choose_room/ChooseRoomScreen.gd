extends Node

func _ready():
	$JoinRoomApi.api_init(self)

func handle_api_response (room):
	print("joined room: {room}".format({ "room": room }))
	api.room = room
	get_tree().change_scene("res://screens/game_board/GameBoardScreen.tscn")

func _on_JoinRoomButton_pressed():
	var roomName = $VBoxContainer/RoomName
	$JoinRoomApi.join(roomName.get_item_text(roomName.selected))
