extends Node2D
class_name Key
signal solved(keyId: float)
signal not_solved(amount: int)
signal lost(keyId: float)
var amountOfButtonPresses = 0
var id = randf_range(0, 9999)

var dispositionPerStage = 36

@onready var tooth_marker: Marker2D = $ToothMarker1

const STAGE_INDICATOR = preload("res://stage_indicator.tscn")

var teeth = []  as Array[Extension]

var amountOfToothPerStage : Array[int]
var markedStages: Array
var stageIndicators: Array[Node2D]
var timer: SceneTreeTimer

var target : Array[int]
var possibleTeethPerSpot: int
var amountOfAdders: int
var amountOfStages: int
var timeLimitSeconds: int
var moveLimit: int
var adderTimings : Array[float]
var adderIndexesThatAreSubtractors : Array[int]  = [0]

var moveSpotTimers : Array[Timer]
const KEY_EXTENSION = preload("res://key_extension.tscn")
func _ready() -> void:
	$LoopSprite.modulate = Color.WHITE

	assert(adderTimings.size() == amountOfAdders)
	for i in amountOfStages:
		var instance = KEY_EXTENSION.instantiate()
		instance.global_position = $ToothMarker1.position + Vector2(125 + i*37,94)
		instance.showParts(0)
		teeth.append(instance)
		print(str(instance.global_position))
		add_child(instance)
	markedStages  = range(0, amountOfAdders)
	for i in amountOfAdders:
		var instance = STAGE_INDICATOR.instantiate()
		if adderIndexesThatAreSubtractors.has(i):
			instance.markAsSubtractor()
		add_child(instance)
		stageIndicators.append(instance)
		createTimerForAdder(i)
	updateStageIndicators()
	redrawAllTeeth()
	if timeLimitSeconds > 0:
		timer = get_tree().create_timer(timeLimitSeconds)
		timer.timeout.connect(onLost)
	if moveLimit > 0:
		not_solved.connect(
			func(amountPresses):
				var pressesLeft = moveLimit - amountPresses
				$PressLimitLabel.text = str(pressesLeft)
				if pressesLeft == 0:
					onLost()
		)
	$TimerImage.visible = timeLimitSeconds > 0
	$PressLimitImage.visible = moveLimit > 0
	
func createTimerForAdder(adderIndex: int):
	var timer = Timer.new()
	timer.wait_time = adderTimings[adderIndex]
	timer.timeout.connect(func():_on_timer_timeout(adderIndex))
	moveSpotTimers.append(timer)
	add_child(timer)
	timer.start()
	
	
func _process(delta: float) -> void:
	if timer and timer.time_left > 0.0:
		$TimerLabel.text = str(timer.time_left).substr(0,3)

func incrementTeethAtMarkedStages():
	for i in amountOfAdders:
		var markedStage = markedStages[i]
		if adderIndexesThatAreSubtractors.has(i):
			substractTeethAt(markedStage)
		else:
			incrementTeethAt(markedStage)
	

func incrementTeethAt(stage:int) -> void:
	assert(stage <= amountOfStages)
	amountOfToothPerStage[stage] = (amountOfToothPerStage[stage] +1) % possibleTeethPerSpot
	
func substractTeethAt(stage:int) -> void:
	assert(stage <= amountOfStages)
	amountOfToothPerStage[stage] = (amountOfToothPerStage[stage] -1 + possibleTeethPerSpot) % possibleTeethPerSpot


func redrawAllTeeth() -> void:
	var counter = 0
	for amount in amountOfToothPerStage:
		teeth[counter].showParts(amount)
		if target and amount == target[counter]:
			teeth[counter].showCorrect()
		else:
			teeth[counter].showWrong()
		counter+=1

func setConfiguration(presets: Array[int]) -> void:
	amountOfToothPerStage = presets

func setTarget(target) -> void:
	self.target = target

	
func updateStageIndicators() -> void:
	for i in amountOfAdders:
		var stageIndicator = stageIndicators[i]
		var stageToIndicate = markedStages[i]
		
		var startingX = dispositionPerStage * stageToIndicate - (amountOfAdders-1) * 6
		stageIndicator.position = tooth_marker.position + Vector2(startingX + i * 11 + 30, 20)


func handleInput() -> void:
	amountOfButtonPresses += 1
	incrementTeethAtMarkedStages()
	redrawAllTeeth()
	evaluateResult()

func cheatSolved() -> void:
	onSolve()
		
		
func onSolve():	
	for sprite in find_children("*Sprite"):	
		sprite.modulate = Color.GOLDENROD
	for tooth in teeth:
		tooth.self_modulate = Color.GOLDENROD
	solved.emit(id)
	stopTimers()

func onLost():
	lost.emit(id)
	stopTimers()
	

func evaluateResult() -> void:
	if target == amountOfToothPerStage:
		onSolve()
		return
	not_solved.emit(amountOfButtonPresses)
	
func _on_timer_timeout(adderIndex: int) -> void:
	markedStages[adderIndex] = (markedStages[adderIndex]+1) % amountOfStages
	updateStageIndicators()

func stopTimers():
	for timer in moveSpotTimers:
		timer.stop()
