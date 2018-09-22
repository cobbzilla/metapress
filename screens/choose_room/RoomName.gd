extends OptionButton

func _ready():
	$ListRoomsApi.api_init(self)
	$ListRoomsApi.call_deferred("list_rooms")

func handle_api_response (rooms):
	for room in rooms:
		add_item(room.name)
		print("found room: {room}".format({ "room": room.name }))
