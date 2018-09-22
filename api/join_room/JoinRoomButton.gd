extends Area2D

var joined = false

func _ready():
	$JoinRoomApi.api_init(self)

func handle_api_response (room):
	print("joined room: room={room}".format({ "room": room.room }))

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.TYPE == "PLAYER" and not joined:
				$JoinApi.join("tictac")
				joined = true
				get_tree().change_scene("res://screens/GameBoardScreen.tscn")
