## Global event bus singleton
extends Node


signal entity_spawned(node: Node)
signal entity_died(node: Node, attack: Attack)

signal water_collected(collector: Node)



#func _ready() -> void:
#	entity_spawned.connect(func(node: Node): print("entity_spawned(%s)" % node.get_path()))
#	entity_died.connect(func(node: Node): print("entity_died(%s)" % node.get_path()))
#
#	water_collected.connect(func(collector: Node): print("water_collected(%s) %d" % [ collector.get_meta("player_slot", collector), collector.get("water") ]))
