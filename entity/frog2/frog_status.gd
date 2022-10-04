#class_name FrogStatus
extends Node2D

signal flip_h_changed(flip: bool)
signal look_y_changed(look_y: int)

signal water_updated(water: int)


## Look target must be this far away from origin on the X axis to change flip_h...
const FLIP_H_THRESHOLD := 8.0

## Minimum absolute Y of `look_target` to set non-zero `look_y`
const LOOK_Y_THRESHOLD := 50.0

## Ratio of Y:X of `look_target` must be greater than this to cause a non-zero `look_y` (up or down).
const LOOK_Y_RATIO := 2.5


## How much water frog is carrying
@export var water: int = 0:
	set(value):
		water = value
		Events.water_collected.emit(self)
		water_updated.emit(water)

@export var flip_h: bool = false:
	set(value):
		if flip_h != value:
			flip_h = value
			flip_h_changed.emit(flip_h)
		($hitbox as Node2D).scale.x = -1 if flip_h else 1


var look_y: int = 0:
	set(y):
		if y != look_y:
			look_y = y
			look_y_changed.emit(look_y)

var look_target: Vector2:
	set(p):
		if !p.is_equal_approx(look_target):
			look_target = p
			if absf(look_target.x) > FLIP_H_THRESHOLD:
				flip_h = look_target.x < 0.0

			var look_y_threshold := maxf(LOOK_Y_THRESHOLD, absf(look_target.x * LOOK_Y_RATIO))
			if absf(look_target.y) > look_y_threshold:
				look_y = int(signf(look_target.y))
			else:
				look_y = 0


func _ready() -> void:
	if flip_h:
		flip_h_changed.emit(flip_h)


func add_water(delta: int) -> void:
	water += delta


func collect_droplet(node: KlWaterDrop) -> void:
	add_water(1)
	node.queue_free()


func set_look_target(p: Vector2) -> void:
	look_target = p


func _entered_zone(zone: Zone2D) -> void:
	if zone.type == Zone2D.ZONE_WORLD_BOUND:
		var ent := Enti2.get_enti2_or_null(self)
		if ent:
			print("%s: killed by world bound" % [ self ])
			ent.kill()
