extends MenuButton

func _ready():
	$ListRoomsApi.api_init(self)
	$ListRoomsApi.call_deferred("list_rooms")

func handle_api_response (rooms):
	print("found rooms: {rooms}".format({ "rooms": rooms }))
