## Hitbox sensor/receiver
class_name Hitbox2D
extends Area2D

#signal hitbox_entered(hitbox: Hitbox2D)
#signal hitbox_exited(hitbox: Hitbox2D)

signal droplet_entered(node: KlWaterDrop)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
#	area_entered.connect(_on_area_entered)
#	area_exited.connect(_on_area_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is KlWaterDrop:
		droplet_entered.emit(body as KlWaterDrop)


#func _on_area_entered(area: Area2D) -> void:
#	if area is Hitbox2D:
#		hitbox_entered.emit(area)
#
#
#func _on_area_exited(area: Area2D) -> void:
#	if area is Hitbox2D:
#		hitbox_exited.emit(area)
