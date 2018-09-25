extends Node

const TILE_PIXELS = 64
const PLAYER_BG_COLOR = 0xff0000
const PALETTE = [0x00ff00, 0x0000ff, 0x00ffff, 0xaa0000, 0x00aa00, 0x0000aa]

var viewportSize
var board
var tileWidth
var tileHeight
var boardStartX = 0
var boardStartY = 0

func _ready():
	viewportSize = get_viewport().size
	board = api.board()

	# determine how many tiles we can show horizontally, and the X coordinate where the board should start
	if board.has('width'):
		tileWidth = min(int(viewportSize.x / TILE_PIXELS), board.width)
		if tileWidth == board.width:
			boardStartX = (viewportSize.x - (tileWidth * TILE_PIXELS))/2
	else:
		tileWidth = int(viewportSize.x / TILE_PIXELS)

	# determine how many tiles we can show vertically, and the Y coordinate where the board should start
	if board.has('length'):
		tileHeight = min(int((viewportSize.y) / TILE_PIXELS), board.length)
		if tileHeight == board.length:
			boardStartY = (viewportSize.y - (tileHeight * TILE_PIXELS))/2
		if boardStartY < 0:
			# should never happen, but just in case
			boardStartY = 0
	else:
		tileHeight = int(viewportSize.y / TILE_PIXELS)
	print("tileHeight={tileHeight}, viewportSize.y={y}, boardStartY={boardStartY}".format({
		"tileHeight": tileHeight,
		"y": viewportSize.y,
		"boardStartY": boardStartY
	}))
	print("tileWidth={tileWidth}, viewportSize.x={x}, boardStartX={boardStartX}".format({
		"tileWidth": tileWidth,
		"x": viewportSize.x,
		"boardStartX": boardStartX
	}))
	$ViewBoardApi.api_init(self)
	$ViewBoardApi.view_board(0, tileHeight-1, 0, tileWidth-1)

func handle_api_response (view):
	var tilePos = Vector2(boardStartX, boardStartY)
	var tileIndex = Vector2(0, 0)
	var tileImageRequests = {}
	for row in view.tiles:
		print(str("drawing row: ", row))
#		if tileIndex.y >= tileHeight:
#			break
		for tile in row:
#			if tileIndex.x >= tileWidth:
#				break
			# place a sprite in the scene for each tile
			tile = prep_tile(tile)
			if !tileImageRequests.has(tile.texturePath):
				tileImageRequests[tile.texturePath] = []
			tile.tilePos = tilePos
			tileImageRequests[tile.texturePath].append(tile)
			tilePos.x += TILE_PIXELS
			tileIndex.x += 1
		tilePos.y += TILE_PIXELS
		tileIndex.y += 1
		tilePos.x = boardStartX
		tileIndex.x = 0
	for texturePath in tileImageRequests:
		download_and_draw_tiles(texturePath, tileImageRequests[texturePath])

func prep_tile(tile):
	var suffix
	tile.fgColor = 0x000000
	if !tile.has('owner'):
		suffix = "_unclaimed"
		tile.bgColor = 0xffffff
	elif tile.owner == api.session.id:
		suffix = "_p0"
		tile.bgColor = PLAYER_BG_COLOR
	else:
		suffix = str("_p", api.getOpponentNumber(tile.owner))
		tile.bgColor = PALETTE[(api.getOpponentNumber(tile.owner)-1) % PALETTE.size()]

	tile.texturePath = "user://images_tiles_{symbol}{suffix}.png".format({
		"symbol": tile.symbol,
		"suffix": suffix
	})
	return tile

func download_and_draw_tiles(texturePath, tiles):
	var tile = tiles[0]
	var textureFile = File.new()
	if !textureFile.file_exists(texturePath):
		# Texture file does not exist. Download it
		var dl = HTTPRequest.new()
		dl.connect("request_completed", self, "handle_download_then_draw_tiles", [texturePath, tiles, dl])
		add_child(dl)
		api.post(dl, "alphabets/{symbolSet}/tile.png".format({
			"symbolSet": api.room.roomSettings.symbolSet.name
		}), {
			"symbol": tile.symbol,
			"fgColor": tile.fgColor,
			"bgColor": tile.bgColor
		})
	else:
		# Texture file exists. Draw tiles
		draw_tiles(tiles)

func handle_download_then_draw_tiles(result, status, headers, body, texturePath, tiles, dl):
	if status != 200:
		print("handle_download_then_draw_tile: error, HTTP status was {status}".format({"status": status}))
		return
	var textureFile = File.new()
	if !textureFile.file_exists(texturePath):
		textureFile.open(texturePath, File.WRITE)
		textureFile.store_buffer(PoolByteArray(body))
		textureFile.close()
	remove_child(dl)
	draw_tiles(tiles)

func draw_tiles(tiles):
	for tile in tiles:
		draw_tile(tile)

func draw_tile (tile):
	var textureFile = File.new()
	if !textureFile.file_exists(tile.texturePath):
		print(str("draw_tile: texturePath not found: ", tile.texturePath))
	else:
		# Texture file exists, draw tile
		var uiTile = Sprite.new()
		uiTile.centered = false
		uiTile.position = tile.tilePos
		var imageTexture = ImageTexture.new()
		imageTexture.load(tile.texturePath)
		uiTile.texture = imageTexture
		uiTile.set("symbol", tile.symbol)
		add_child(uiTile)
