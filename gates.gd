extends Node2D


func updateTo(level: int):
	print("Showing gate " + str(level))
	$Key.position = $Marker2D.position + Vector2(level * 75 + 75, 15)
	pass
