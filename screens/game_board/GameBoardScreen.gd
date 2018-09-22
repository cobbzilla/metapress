extends Node

func _ready():
	$ViewBoardApi.api_init(self)
	$ViewBoardApi.view_board(0, api.board().width, 0, api.board().length)

func handle_api_response (board):
	for row in board.tiles:
		for tile in row:
			print("board tile: {tile}".format({ "tile": tile }))
