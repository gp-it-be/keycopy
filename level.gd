extends Node
class_name Level

var amountOfAdders: int 
var amountOfStages: int 
var timeLimitSeconds: int
var moveLimit : int
var startLevelMessage:String
var adderTimings: Array[float]

func _init( amountOfAdders: int , amountOfStages: int , timeLimitSeconds: int, moveLimit : int,startLevelMessage: String, adderTimings: Array[float] ) -> void:
	self.amountOfAdders=amountOfAdders
	self.amountOfStages=amountOfStages
	self.timeLimitSeconds=timeLimitSeconds
	self.moveLimit=moveLimit
	self.startLevelMessage = startLevelMessage
	self.adderTimings = adderTimings
