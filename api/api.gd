extends Node

const SESSION_SCENE = 'ApiSession'

const HEADER_JSON = 'Content-Type: application/json'
const HEADER_NAME_WL_API = "x-wordland-api-key"

const DEFAULT_API_BASE = "http://127.0.0.1:9091/api/"
const USE_SSL = false

var session
var room

func board():
	return room.roomSettings.board.settings

func base_uri():
	return DEFAULT_API_BASE

func use_ssl():
	return USE_SSL

func api_request_headers():
	if has_api_token():
		return [HEADER_JSON, api_token_header()]
	else:
		return [HEADER_JSON]

func api_request_headers_get():
	if has_api_token():
		return [api_token_header()]
	else:
		return []

func api_token_header():
	return str(HEADER_NAME_WL_API, ": ", session.apiToken)

func has_api_token():
	return session != null and session.apiToken != null

func get (http, uri):
	return http.request(str(base_uri(), uri), api_request_headers_get(), use_ssl())

func post (http, uri, data):
	return http.request(str(base_uri(), uri), api_request_headers(), use_ssl(), HTTPClient.METHOD_POST, JSON.print(data))
	
func put (http, uri, data):
	return http.request(str(base_uri(), uri), api_request_headers(), use_ssl(), HTTPClient.METHOD_PUT, JSON.print(data))

func delete (http, uri):
	return http.request(str(base_uri(), uri), api_request_headers(), use_ssl(), HTTPClient.METHOD_DELETE)
