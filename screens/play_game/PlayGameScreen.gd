extends Node2D

onready var boardScreen = $GameBoardScreen
var viewportSize

var navButtons = {
	"up": null,
	"down": null,
	"left": null,
	"right": null
}

func _ready():
	viewportSize = get_viewport().size
	navButtons.up = Button.new()
	navButtons.up.rect_position = Vector2(0, 0)
	navButtons.up.rect_size = Vector2(viewportSize.x, 30)
	navButtons.up.text = "/\\\nUP"

	navButtons.down = Button.new()
	navButtons.down.rect_position = Vector2(0, viewportSize.y-30)
	navButtons.down.rect_size = Vector2(viewportSize.x, 30)
	navButtons.down.text = "DOWN\n\\/"

	navButtons.left = Button.new()
	navButtons.left.rect_position = Vector2(0, 0)
	navButtons.left.rect_size = Vector2(30, viewportSize.y)
	navButtons.left.text = "/\nLEFT\n\\"
	
	navButtons.right = Button.new()
	navButtons.right.rect_position = Vector2(0, 0)
	navButtons.right.rect_size = Vector2(30, viewportSize.y)
	navButtons.right.text = "\\\nRIGHT\n/"


var lastScrollable = null
func _process():
	if lastScrollable != null and lastScrollable != boardScreen.scrollable:
		for direction in boardScreen.scrollable.keys():
			if boardScreen.scrollable[direction] != lastScrollable[direction]:
				if boardScreen.scrollable[direction]:
					print(str("showing nav: ", direction))
					add_child(navButtons[direction])
				else:
					print(str("hiding nav: ", direction))
					remove_child(navButtons[direction])
	lastScrollable = boardScreen.scrollable
