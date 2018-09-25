extends Area2D

var button = Button.new()
var tile
var game

func _ready():
	button.flat = true
	add_child(button)

	
func init(t, g):
	tile = t
	game = g
	position = tile.tilePos
	var imageTexture = ImageTexture.new()
	imageTexture.load(tile.texturePath)
	button.icon = imageTexture
	button.connect("pressed", self, "select_tile")

func select_tile():
	button.pressed = false
	game.select_tile(tile)