extends "res://api/ApiBase.gd"

func view_board (x1, x2, y1, y2):
	return api.get(self, 'rooms/{room}/board?x1={x1}&x2={x2}&y1={y1}&y2={y2}'.format({
		"room": api.room.room,
		"x1": int(x1),
		"x2": int(x2),
		"y1": int(y1),
		"y2": int(y2)
	}))
