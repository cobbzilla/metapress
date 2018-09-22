extends Node

func _ready():
	$SignInApi.api_init(self)

func handle_api_response (session):
	print("logged in: apiToken={apiToken}".format({ "apiToken": session.apiToken }))
	$ApiSession.session = session
	get_tree().change_scene("res://screens/GameBoardScreen.tscn")

func _on_BtnPlayNow_pressed():
	var name = $VBoxContainer/GuestName.text
	if name != 'Name' and name != '':
		$SignInApi.login_guest(name)
