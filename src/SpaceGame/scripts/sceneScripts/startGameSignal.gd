extends Node

# start game
signal startGame()
signal syncSeed(randSeed)
signal finalPlanetDistance(distance)
signal shipValues(rent, fuel)

# continue cycle
signal continueCycle()
# end game
signal endGame()
# die
signal sendDie()

# VARAIBLES THAT WILL BE CHANGED BY STARTGAME
var randSeed = 0
var distance = 0
var firstValues = [0,0,0]
var previousValues = [5,120,0]

# health
var HP = 3
var immunity = false

func start():
	rpc("RPCsignal", randSeed, distance)

func die():
	if !immunity:
		HP -= 1
	immunity = true
	if HP < 1:
		rpc("dieFunc")
	await get_tree().create_timer(2.0).timeout
	immunity = false

func sendValues(rent, fuel, inputDistance):
	HP = 3
	if firstValues == [0,0,0]:
		firstValues = [rent, fuel, inputDistance]
	previousValues = [rent, fuel, inputDistance]
	rpc("RPCsendValues", rent, fuel)

func getValues():
	return [firstValues, previousValues]
	
func checkCycle(rent, balance):
	if balance - rent >= 0:
		rpc("continueCycleFunc")
	else:
		rpc("endGameFunc")

@rpc("any_peer", "call_local")
func RPCsignal(randSeedParam, distanceParam):
	emit_signal("syncSeed", randSeedParam)
	emit_signal("finalPlanetDistance", distanceParam)
	emit_signal("startGame")

@rpc("any_peer","call_local")
func continueCycleFunc():
	emit_signal("continueCycle")

@rpc("any_peer","call_local")
func endGameFunc():
	emit_signal("endGame")
	
@rpc("any_peer","call_local")
func dieFunc():
	emit_signal("sendDie")
	
@rpc("any_peer","call_local")
func RPCsendValues(rent, fuel):
	emit_signal("shipValues", rent, fuel)
