extends Area2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var target_ent := Enti2.get_enti2_or_null(area)
	if target_ent:
		var attack := Attack.new()
		attack.type = Attack.Type.CONTACT_DAMAGE
		attack.perpetrator_class = "toad"
		attack.set_explanation_text("nommed by Toad")
		attack.bind(get_parent(), target_ent)
		target_ent.attack(attack)
