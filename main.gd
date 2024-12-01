extends Node2D

const KEY = preload("res://key.tscn")

var example_key: Key
var key: Key
@export var possibleTeethPerSpot: int
var progression : Progression = Progression.new()
var playing = false
var won = false

var toggleTimer : Timer


func _ready() -> void:
	progression.LevelChanged.connect($Gates.updateTo)
	assert(not toggleTimer)
	toggleTimer = Timer.new()
	toggleTimer.wait_time = 20
	toggleTimer.autostart = false
	add_child(toggleTimer)

	
func startAKeyRound() -> void:
	if example_key:
		example_key.queue_free()
	if key:
		key.queue_free()
	
	var solution = generateSolution()
	example_key = KEY.instantiate()
	example_key.global_position = $SolutionKeyMarker.global_position
	example_key.setConfiguration(solution)
	example_key.amountOfStages = progression.amountOfStages
	example_key.amountOfAdders = 0
	add_child(example_key)
	
	key = KEY.instantiate()
	key.global_position = $KeyMarker.global_position
	key.solved.connect(self._on_key_solved)
	key.setTarget(solution)
	key.possibleTeethPerSpot = possibleTeethPerSpot
	var emptyConfiguration : Array[int]
	emptyConfiguration.resize(progression.amountOfStages)
	emptyConfiguration.fill(0)
	key.setConfiguration(emptyConfiguration)	
	key.not_solved.connect(on_thousanded)
	key.lost.connect(on_lost)
	key.amountOfAdders = progression.amountOfAdders
	key.adderTimings = progression.adderTimings
	key.amountOfStages = progression.amountOfStages
	key.timeLimitSeconds = progression.timeLimitSeconds
	key.moveLimit = progression.moveLimit
	key. adderIndexesThatAreSubtractors = progression.adderIndexesThatAreSubtractors
	add_child(key)
	playing = true


func generateSolution() -> Array[int]:
	var solution = [] as Array[int]
	for i in progression.amountOfStages:
		solution.append(randi() % possibleTeethPerSpot)
	var teethInSolution = sum_array(solution)
	if teethInSolution < possibleTeethPerSpot:
		return generateSolution()
		#TODO also take into account aountOfSubtractors
	if (teethInSolution % progression.amountOfAdders) != 0:
		return generateSolution()
	return solution


func cheat():
	key.cheatSolved()



var playMusicToggles = [true, false, false, true]
var playSfxToggles = [true, true, false, false]

var playMusic: bool = playMusicToggles[0]
var playSfx: bool = playSfxToggles[0]


func displayResultOfReleaseAt(timePressed: float):
	if timePressed > 15:
		$Label.text = "You sneaky sneaky, you found a way to cheaty"
		return
	var indexOfThisTime = int(timePressed/2) %  playMusicToggles.size()
	var willPlayMusic = playMusicToggles[indexOfThisTime]
	var willPlaySFTX = playSfxToggles[indexOfThisTime]
	$Label.text = "Release for --- Music: " + suundStr(willPlayMusic) + "  Sfx: " + suundStr(willPlaySFTX)
	
func suundStr(value: bool)	:
	return "On" if value else "Off"
	
func triggerReleasedAt(timePressed: float):
	if timePressed > 15:
		cheat()
		return
	var indexOfThisTime = int(timePressed/2) % playMusicToggles.size()
	playMusic = playMusicToggles[indexOfThisTime]
	playSfx = playSfxToggles[indexOfThisTime]
	if playMusic:
		$Background.play()
	else:
		$Background.stop()	

var pressingTime = 0.0

func _process(delta: float) -> void:
	var pressing = Input.is_action_pressed("one_button")
	if not pressing:
		pressingTime = 0.0
	if pressing:
		pressingTime+= delta


	

func _input(event: InputEvent) -> void:
	if pressingTime > 1:
		displayResultOfReleaseAt(pressingTime)
		if(event.is_action_released("one_button")):
			triggerReleasedAt(pressingTime)
			$Label.text = ""

	if won: return
	if not playing  and event.is_action_pressed("one_button"):
		$HelpLabel.hide()	
		$Label.text = ""
		startAKeyRound()
		#TODO tell the key its a good time to start the timer
	if playing and event.is_action_pressed("one_button"):
		key.handleInput()
	if playing and event.is_action_pressed("cheat"):
		key.cheatSolved()
	

func _on_key_solved(keyId: float) -> void:
	if playSfx:
		$Solved.play()
	playing = false
	
	if progression.isFinalLevel():
		won = true
		$WonLabel.show()
		$WonRect.show()
	else:
		progression.advance()
		$Label.text = progression.startLevelMessage
		get_tree().create_timer(2.0).timeout.connect(func(): $Label.text = "")
		get_tree().create_timer(1).timeout.connect(func(): startAKeyRound())


func on_lost(keyId: float) -> void:
	if not playing or keyId != key.id:
		print("on lost of a key that has already been solved - ignoring")
		return
	progression.reset()
	playing = false
	$Label.text = "I suppose you lost."

func on_thousanded(amount_of_presses: int) -> void:
	if playSfx:
		$Click.play()
	if amount_of_presses == 100:
		$Label.text = "You are a persistent one, aren't you?"
		get_tree().create_timer(1.5).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 500:
		$Label.text = "Yes you are truly persistent. Will it be rewarded?"
		get_tree().create_timer(2).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 1000:
		$Label.text = "You are EXTREMELY persistent. Should that be rewarded?"
		get_tree().create_timer(2).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 2000:
		$Label.text = "Woaw, how did you not solve it in this much button presses?"
		get_tree().create_timer(2).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 2500:
		$Label.text = "Ok, you can stop now."
		get_tree().create_timer(1.5).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 2550:
		$Label.text = "Final message"
		get_tree().create_timer(1.5).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 2600:
		$Label.text = "OK I lied"
		get_tree().create_timer(1.5).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 2750:
		$Label.text = "This might just be insolvable"
		get_tree().create_timer(2).timeout.connect(func(): $Label.text = "")
	if amount_of_presses == 3000:
		$Label.text = "3000 times. you have pressed the button 3000 times. give up."
		get_tree().create_timer(4).timeout.connect(func(): $Label.text = "")

func sum_array(array):
	var sum = 0
	for element in array:
		sum += element
	return sum
