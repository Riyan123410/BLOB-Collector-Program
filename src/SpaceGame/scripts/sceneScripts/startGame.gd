extends Node


var sendStartSignal = Node

# START GAME SETTINGS:
#var distance = 0.1 # distance is the distance of the final planet from start position
var randSeed = randi()

# SHIP VALUES
var rent = 0
var fuel = 0

# NODE REFERNCES:
@export var rentLine : LineEdit
@export var fuelLine : LineEdit
@export var planetDistanceLine : LineEdit
@export var seedLine : LineEdit

# line variables
var oldRentText := ""
var oldFuelText := ""
var oldPlanetDistanceText := ""
var oldSeedText := ""

func _ready() -> void:
	sendStartSignal = $"/root/sceneSwitcher/startGameSignal"
	rentLine.text_changed.connect(rentNum)
	fuelLine.text_changed.connect(fuelNum)
	planetDistanceLine.text_changed.connect(planetNum)
	seedLine.text_changed.connect(seedNum)
	setTextValues()

func setTextValues():
	var firstValue = sendStartSignal.getValues()[0]
	var previousValue = sendStartSignal.getValues()[1]
	
	planetDistanceLine.text = str(previousValue[2] + 0.5)
	oldPlanetDistanceText = planetDistanceLine.text
	
	rentLine.text = str(previousValue[0] + (firstValue[0]/2))
	oldRentText = rentLine.text
	
	fuelLine.text = str(previousValue[1] + (firstValue[1]/3))
	oldFuelText = fuelLine.text
	
	seedLine.text = str(randi())
	oldSeedText = seedLine.text

func _onlyNumbers(text: String, oldText, object) -> String:
	if text.is_empty() or text.is_valid_int():
		return text
	else:
		object.text = oldText
		return oldText
		
func _on_button_pressed() -> void:
	
	# asign values
	sendStartSignal.randSeed = int(oldSeedText)
	sendStartSignal.distance = int(oldPlanetDistanceText)
	
	rent = int(oldRentText)
	fuel = int(oldFuelText)

	# send signal and die
	sendStartSignal.sendValues(rent, fuel, int(oldPlanetDistanceText))
	sendStartSignal.start()
	queue_free()

func rentNum(text: String):
	oldRentText = _onlyNumbers(text, oldRentText, rentLine)
func fuelNum(text: String):
	oldFuelText = _onlyNumbers(text, oldFuelText, fuelLine)
func planetNum(text: String):
	oldPlanetDistanceText = _onlyNumbers(text, oldPlanetDistanceText, planetDistanceLine)
func seedNum(text: String):
	oldSeedText = _onlyNumbers(text, oldSeedText, seedLine)
