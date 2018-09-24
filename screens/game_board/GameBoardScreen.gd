extends Node

const TILE_PIXELS = 64
const PLAYER_BG_COLOR = 0xff0000
const PALETTE = [0x00ff00, 0x0000ff, 0x00ffff, 0xaa0000, 0x00aa00, 0x0000aa]

var viewportSize
var board
var tileWidth
var tileHeight

var tileImageRequests = {}

func _ready():
	viewportSize = get_viewport().size
	board = api.board()

	tileWidth = min(int(viewportSize.x / TILE_PIXELS) + 10, board.width)
	tileHeight = min(int(viewportSize.y / TILE_PIXELS) + 10, board.length)

	$ViewBoardApi.api_init(self)
	$ViewBoardApi.view_board(0, tileWidth, 0, tileHeight)

func handle_api_response (view):
	var tilePos = Vector2(0, 0)
	var tileIndex = Vector2(0, 0)
	for row in view.tiles:
		print("board row size: {size}".format({ "size": row.size() }))
		if tileIndex.y > board.length:
			break
		for tile in row:
			if tileIndex.x > board.width:
				break
			# place a sprite in the scene for each tile
			draw_tile(tile, tilePos)
			print("board tile: {tile}".format({ "tile": tile }))
			tilePos.x += TILE_PIXELS
			tileIndex.x += 1
		tilePos.y += TILE_PIXELS
		tileIndex.y += 1
		tilePos.x = 0
		tileIndex.x = 0

func draw_tile (tile, tilePos):
	var suffix
	var fgColor = 0x000000
	var bgColor
	if !tile.has('owner'):
		suffix = "_unclaimed"
		bgColor = 0xffffff
	elif tile.owner == api.session.id:
		suffix = "_p0"
		bgColor = PLAYER_BG_COLOR
	else:
		suffix = str("_p", api.getOpponentNumber(tile.owner))
		bgColor = PALETTE[(api.getOpponentNumber(tile.owner)-1) % PALETTE.size()]

	var texturePath = "user://images_tiles_{symbol}{suffix}.png".format({
		"symbol": tile.symbol,
		"suffix": suffix
	})
	var textureFile = File.new()
	if !textureFile.file_exists(texturePath):
		# Texture file does not exist. Should we download it?
		var request = {
			"symbol": tile.symbol,
			"fgColor": fgColor,
			"bgColor": bgColor
		}
		var requestJson = JSON.print(request)
		if tileImageRequests.has(requestJson):
			# Someone else already is already downloading, just wait for them
			# call_deferred("wait_for_download_then_draw_tile", tile, tilePos, texturePath)
			pass
		else:
			# We are first, download the tile image
			tileImageRequests[requestJson] = requestJson
			var dl = HTTPRequest.new()
			dl.connect("request_completed", self, "handle_download_then_draw_tile", [tile, tilePos, texturePath, requestJson, dl])
			add_child(dl)
			api.post(dl, "alphabets/{symbolSet}/tile.png".format({
				"symbolSet": api.room.roomSettings.symbolSet.name
			}), request)
	else:
		# Texture file exists, draw tile
		var uiTile = Sprite.new()
		uiTile.centered = false
		uiTile.position = tilePos
		var imageTexture = ImageTexture.new()
		imageTexture.load(texturePath)
		uiTile.texture = imageTexture
		uiTile.set("symbol", tile.symbol)
		add_child(uiTile)

func handle_download_then_draw_tile(result, status, headers, body, tile, tilePos, texturePath, requestJson, dl):
	if status != 200:
		print("handle_download_then_draw_tile: error, HTTP status was {status}".format({"status": status}))
		return
	var textureFile = File.new()
	if !textureFile.file_exists(texturePath):
		textureFile.open(texturePath, File.WRITE)
		textureFile.store_buffer(PoolByteArray(body))
		textureFile.close()
	tileImageRequests.erase(requestJson)
	remove_child(dl)
	draw_tile(tile, tilePos)

func wait_for_download_then_draw_tile (tile, tilePos, texturePath):
	var textureFile = File.new()
	if !textureFile.file_exists(texturePath):
		call_deferred("wait_for_download_then_draw_tile", tile, tilePos, texturePath)
	else:
		draw_tile(tile, tilePos)