extends Node

const TILE_PIXELS = 64
const PLAYER_BG_COLOR = 0xff0000
const PALETTE = [0x00ff00, 0x0000ff, 0x00ffff, 0xaa0000, 0x00aa00, 0x0000aa]

var viewportSize
var board
var viewStartIndex = Vector2()
var viewEndIndex = Vector2()
var tileWidth
var tileHeight
var boardStartX = 0
var boardStartY = 0
var symbolTileSprite = preload("res://screens/components/symbol_tile.gd")

var scrollable = {
	"up": false,
	"down": false,
	"left": false,
	"right": false
}

func _ready():
	viewportSize = get_viewport().size
	board = api.board()

	# determine how many tiles we can show horizontally, and the X coordinate where the board should start
	if board.has('width'):
		tileWidth = min(int(viewportSize.x / TILE_PIXELS), board.width)
	else:
		tileWidth = int(viewportSize.x / TILE_PIXELS)
	boardStartX = (viewportSize.x - (tileWidth * TILE_PIXELS))/2

	# determine how many tiles we can show vertically, and the Y coordinate where the board should start
	if board.has('length'):
		tileHeight = min(int((viewportSize.y) / TILE_PIXELS), board.length)
	else:
		tileHeight = int(viewportSize.y / TILE_PIXELS)
	boardStartY = (viewportSize.y - (tileHeight * TILE_PIXELS))/2

	set_scrollable(Vector2(0, tileHeight-1), Vector2(0, tileWidth-1))

	$ViewBoardApi.api_init(self)
	$ViewBoardApi.view_board(0, tileHeight-1, 0, tileWidth-1)

func set_scrollable(start, end):
	if board.has('width'):
		if start.x > 0:
			scrollable.left = true
		if end.x < board.width:
			scrollable.right = true
	else:
		scrollable.left = true
		scrollable.right = true
	if board.has('length'):
		if start.y > 0:
			scrollable.down = true
		if end.y < board.length:
			scrollable.up = true
	else:
		scrollable.down = true
		scrollable.up = true

func handle_api_response (view):
	viewStartIndex.x = view.x1
	viewStartIndex.y = view.y1
	viewEndIndex.x = view.x2
	viewEndIndex.y = view.y2
	set_scrollable(viewStartIndex, viewEndIndex)
	var tilePos = Vector2(boardStartX, boardStartY)
	var tileIndex = Vector2(0, 0)
	var tileImageRequests = {}
	for row in view.tiles:
		print(str("drawing row: ", row))
		for tile in row:
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
		var uiTile = symbolTileSprite.new()
		uiTile.init(tile, self)
		add_child(uiTile)

func select_tile(tile):
	print(str("selected tile ", tile))

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass