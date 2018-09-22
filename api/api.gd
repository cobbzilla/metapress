extends Node

const SESSION_SCENE = 'ApiSession'

const HEADER_JSON = 'Content-Type: application/json'
const HEADER_NAME_WL_API = "x-wordland-api-key"

const DEFAULT_API_BASE = "http://127.0.0.1:9091/api/"
const USE_SSL = false

static func base_uri():
	return DEFAULT_API_BASE

static func use_ssl():
	return USE_SSL

static func api_request_headers(http):
	var apiSession = session(http)
	if has_api_token(apiSession):
		return [HEADER_JSON, api_token_header(apiSession)]
	else:
		return [HEADER_JSON]

static func api_request_headers_get(http):
	var apiSession = session(http)
	if has_api_token(apiSession):
		return [api_token_header(apiSession)]
	else:
		return null

static func api_token_header(apiSession):
	return str(HEADER_NAME_WL_API, ": ", apiSession.session.apiToken)

static func has_api_token(apiSession):
	return apiSession != null and apiSession.session != null and apiSession.session.apiToken != null

static func get (http, uri):
	return http.request(str(base_uri(), uri), api_request_headers_get(http), use_ssl())

static func post (http, uri, data):
	return http.request(str(base_uri(), uri), api_request_headers(http), use_ssl(), HTTPClient.METHOD_POST, JSON.print(data))
	
static func put (http, uri, data):
	return http.request(str(base_uri(), uri), api_request_headers(http), use_ssl(), HTTPClient.METHOD_PUT, JSON.print(data))

static func delete (http, uri):
	return http.request(str(base_uri(), uri), api_request_headers(http), use_ssl(), HTTPClient.METHOD_DELETE)

static func session (node):
	# find first parent that is a plain Node
	var parent = node.get_parent()
	while parent.get_class() != 'Node' and parent.get_class() != 'Node2D':
		parent = parent.get_parent()
		if parent == null:
			print("session: null parent!")
			return null
	return find_session(parent)

static func find_session(node):
	if node == null:
		return null

	for child in node.get_children():
		if child.name == SESSION_SCENE:
			return child

	for child in node.get_children():
		var found = find_session(child)
		if found != null:
			return found

	return null
