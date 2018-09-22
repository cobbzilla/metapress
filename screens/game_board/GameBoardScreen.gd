extends Node

const TILE_PIXELS = 64

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
	for row in view.tiles:
		print("board row size: {size}".format({ "size": row.size() }))
		if tileIndex.y > board.length:
			break
		for tile in row:
			if tileIndex.x > board.width:
				break
			# place a sprite in the scene for each tile
			var uiTile = Sprite.new()
			uiTile.centered = false
			uiTile.position = tilePos
			uiTile.texture = load("res://images/symbols/A.png")
			add_child(uiTile)
			print("board tile: {tile}".format({ "tile": tile }))
			tilePos.x += TILE_PIXELS
			tileIndex.x += 1
		tilePos.y += TILE_PIXELS
		tileIndex.y += 1
		tilePos.x = 0
		tileIndex.x = 0
