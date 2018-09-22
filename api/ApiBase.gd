extends HTTPRequest

onready var apiSession = api.session(self)

var handler

func api_init(handler):
	self.handler = handler
	return connect("request_completed", self, "api_callback")

func api_callback (result, status, headers, body):
	if status == 200:
		var json = body.get_string_from_utf8()
		var parsed = JSON.parse(json)
		if parsed.error == OK:
			handler.handle_api_response(parsed.result)
		else:
			print("API error: {err}: {description}".format({
				"err": parsed.error,
				"description": parsed.error_string
			}))
	else:
		print("error logging in: HTTP status {status}, response: {response}".format({
			"status": status,
			"response": body.get_string_from_utf8()
		}))
