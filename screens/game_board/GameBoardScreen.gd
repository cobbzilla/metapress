extends Node

const TILE_PIXELS = 64
const PLAYER_BG_COLOR = 0xff0000
const PALETTE = [0x00ff00, 0x0000ff, 0x00ffff, 0xaa0000, 0x00aa00, 0x0000aa]

var viewportSize
var board
var tileWidth
var tileHeight

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
	var tileImageRequests = {}
	for row in view.tiles:
		if tileIndex.y > board.length:
			break
		for tile in row:
			if tileIndex.x > board.width:
				break
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
		tilePos.x = 0
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
