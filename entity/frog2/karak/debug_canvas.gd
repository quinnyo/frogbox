extends Node2D

@export var force_draw_contacts := false

#var _active_items := {}

var _tracked: RID
var _items: Array[RID] = []
var _idx := 0

func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO

	_tracked = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_tracked, get_canvas_item())
	_items.resize(3)
	for i in range(_items.size()):
		_items[i] = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(_items[i], get_canvas_item())


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			RenderingServer.free_rid(_tracked)
			for item in _items:
				RenderingServer.free_rid(item)


func _karak_contact_begin(contact: KarakTrackedContact) -> void:
	if force_draw_contacts || get_tree().debug_collisions_hint:
		RenderingServer.canvas_item_clear(_items[_idx])
		contact.draw(_items[_idx])
		_idx = (_idx + 1) % _items.size()


func _karak_contact_tracked(contact: KarakTrackedContact) -> void:
	if force_draw_contacts || get_tree().debug_collisions_hint:
		RenderingServer.canvas_item_clear(_tracked)
		contact.draw(_tracked)


#func _karak_contact_begin(contact: KarakTrackedContact) -> void:
#	var items: Array[RID] = []
#	_active_items[contact] = items


#func _karak_contact_end(contact: KarakTrackedContact) -> void:
#	var items: Array[RID] = _active_items[contact]
#	while !items.is_empty():
#		RenderingServer.free_rid(items.pop_back())
#
#
#func _karak_contact_tracked(contact: KarakTrackedContact) -> void:
#	var draw_contacts := force_draw_contacts || get_tree().debug_collisions_hint
#	if !draw_contacts:
#		return
#
#	var items: Array[RID] = _active_items[contact]
#	if items.size() < 2:
#		var item := RenderingServer.canvas_item_create()
#		items.push_back(item)
#	RenderingServer.canvas_item_clear(items.back())
#	RenderingServer.canvas_item_set_parent(items.back(), get_canvas_item())
#	contact.draw(items.back())
