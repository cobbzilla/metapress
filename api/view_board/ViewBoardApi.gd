extends "res://api/ApiBase.gd"

func view_board (x1, x2, y1, y2):
	return api.get(self, "rooms/{room}/board?x1={x1}&x2={x2}&y1={y1}&y2={y2}".format({
		"x1": x1,
		"x2": x2,
		"y1": y1,
		"y2": y2
	}))
