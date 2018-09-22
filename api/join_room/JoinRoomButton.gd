extends Area2D

var joined = false

func _ready():
	$JoinRoomApi.api_init(self)

func handle_api_response (room):
	print("joined room: room={room}".format({ "room": room.room }))
