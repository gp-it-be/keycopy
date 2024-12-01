extends Node2D
class_name Extension


# Called when the node enters the scene tree for the first time.
func showParts(amount: int):
	$HidingRect.position = Vector2(-199, amount * 20 - 130)

func showWrong():
	self_modulate = Color.WHITE
	
func showCorrect():
	self_modulate = Color.GOLDENROD 
