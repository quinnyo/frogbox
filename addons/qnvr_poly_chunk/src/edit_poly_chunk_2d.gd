extends Node


static func do_split_segment(unre: EditorUndoRedoManager, p_target: PolyChunk2D, p_segpos: float) -> int:
	var new_idx := int(ceil(p_segpos))
	unre.create_action("PolyChunk2D::split_segment")
	unre.add_do_method(p_target, "split_segment", p_segpos)
	unre.add_undo_method(p_target, "remove_point", new_idx)
	unre.commit_action()
	return new_idx


static func do_append_point(unre: EditorUndoRedoManager, p_target: PolyChunk2D, p_position: Vector2) -> void:
	unre.create_action("PolyChunk2D::append_point")
	unre.add_do_method(p_target, "append_point", p_position)
	unre.add_undo_method(p_target, "remove_point", p_target.get_points_count())
	unre.commit_action()


static func do_set_point(unre: EditorUndoRedoManager, p_target: PolyChunk2D, p_index: int, p_position: Vector2) -> void:
	unre.create_action("PolyChunk2D::set_point")
	unre.add_do_method(p_target, "set_point", p_index, p_position)
	unre.add_undo_method(p_target, "set_point", p_index, p_target.get_point(p_index))
	unre.commit_action()


static func do_remove_point(unre: EditorUndoRedoManager, p_target: PolyChunk2D, p_index: int) -> void:
	unre.create_action("PolyChunk2D::remove_point")
	unre.add_do_method(p_target, "remove_point", p_index)
	unre.add_undo_method(p_target, "insert_point", p_index, p_target.get_point(p_index))
	unre.commit_action()
