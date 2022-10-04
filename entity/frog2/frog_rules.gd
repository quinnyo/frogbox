class_name FrogRules
extends Resource

## maximum contact sliding speed
@export var grip_speed_threshold: float = 650.0
## contact angle lower than this is considered 'glancing'
@export var grip_glancing_degrees: float = 6.0
## grip_speed_threshold but for 'glancing' contacts
@export var grip_glancing_speed_threshold: float = 320.0

## can grip if contact velocity is lower than this
@export var grip_slow_speed_threshold: float = 250.0

@export var jump_speed_max: float = 650.0


func limit_jump(v: Vector2) -> Vector2:
	return v.limit_length(jump_speed_max)


## Evaluate grip for a contact (velocity & normal).
## Returns true if grip should be formed.
func grip_or_slip(vel: Vector2, normal: Vector2) -> bool:
	if vel.dot(normal) > 1.0:
		return false

	var speed := vel.length()
	if speed < grip_slow_speed_threshold:
		return true

	var angle := normal.angle_to(vel) - PI / 2.0
	var glancing := angle < grip_glancing_degrees
	var speed_threshold := grip_glancing_speed_threshold if glancing else grip_speed_threshold

	var tangent := normal.orthogonal()
	var sliding_speed := absf(vel.dot(tangent))
	if sliding_speed < speed_threshold:
		return true
	return false
#	var uvel := vel / speed
#	var vdn := uvel.dot(normal)
#	if speed < 250.0 || vdn < -0.7:
#		return true
