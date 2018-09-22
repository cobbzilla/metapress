extends TextEdit

func _ready():
	pass

func _on_GuestName_focus_entered():
	if text == "" || text == "Name":
		text = ""

func _on_GuestName_focus_exited():
	if text == "":
		text = "Name"
