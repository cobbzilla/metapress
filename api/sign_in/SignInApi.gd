extends "res://api/ApiBase.gd"

func login (name = null, password = null):
	return api.post(self, "auth/login", { "name": name, "password": password })

func login_guest (name = null):
	return api.post(self, "auth/login", { "name": name })
