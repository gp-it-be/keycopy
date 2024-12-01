extends Node
class_name Progression

signal LevelChanged(level:int)

var level : int
var amountOfAdders: int 
var amountOfStages: int 
var timeLimitSeconds: int
var moveLimit : int
var startLevelMessage: String
var adderTimings: Array[float]
var adderIndexesThatAreSubtractors: Array[int]

var levels: Array[Level] = [
	Level.new(1, 2, 0, 0, "Are you the one?" ,[2]),
	Level.new(1, 3, 0, 0, "Promising start ...",[1.7]),
	Level.new(1, 4, 60, 0,"Just how talented are you?",[1.3]),
	Level.new(1, 4, 0, 60,"You just might make it ...",[1.5]),
	Level.new(1, 5, 40, 0,"A true test lies before you",[0.7]),
	Level.new(1, 5, 0, 100,"You will be stopped",[0.4]),
	Level.new(1, 5, 0, 0,"An easy one before I stop you",[2]),
	Level.new(3, 5, 240, 200,"Are you the one? NOW we will know.",[1.7,2.5,4]),
]

func _init() -> void:	
	level = 0
	LevelChanged.emit(level) #This is sent before the connection is made, but that is okayish
	assignValuesForLevel()

func reset():
	_init()

func advance():
	assert(level < levels.size()  ) 
	level += 1
	LevelChanged.emit(level)
	assignValuesForLevel()
	
func assignValuesForLevel():
	amountOfAdders  = levels[level].amountOfAdders
	amountOfStages  = levels[level].amountOfStages
	timeLimitSeconds = levels[level].timeLimitSeconds
	moveLimit = levels[level].moveLimit
	startLevelMessage = levels[level].startLevelMessage
	adderTimings = levels[level].adderTimings
	if level == 6:
		adderIndexesThatAreSubtractors = [0]
	if level == 7:
		adderIndexesThatAreSubtractors = [randi_range(0,2)]
	
	
func isFinalLevel() -> bool:
	return level == levels.size() - 1
