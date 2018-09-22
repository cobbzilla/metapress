extends "res://api/ApiBase.gd"

func list_rooms ():
	return api.get(self, "rooms")
