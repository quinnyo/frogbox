class_name Notifications
extends Control

const Card := preload("widgets/card.gd")

@export var expire_secs_default := 5.0

## Show a (card) popup notification.
## [br][code]expire_secs[/code] duration in seconds that card will be visible for. If expire_secs <= 0.0 the card won't expire.
func notify_send(heading: String, body: String, expire_secs: float = expire_secs_default) -> void:
	print("%s\n%s\n%s" % [ heading, "=".repeat(heading.length()), body ])
	var card := preload("widgets/card.tscn").instantiate() as Card
	card.setup(heading, body)
	if expire_secs > 0.0:
		get_tree().create_timer(expire_secs).timeout.connect(card.queue_free)

	add_child(card)
