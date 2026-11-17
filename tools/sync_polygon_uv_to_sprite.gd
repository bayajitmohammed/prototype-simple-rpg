@tool
class_name SyncPolygonUVToSprite
extends EditorScript

# Select textured Polygon2D nodes in the open scene and run this command.
# If several Sprite2D nodes share their texture, also select the source Sprite2D.
func _run() -> void:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null:
		push_warning("Open the scene containing the polygons first.")
		return

	var selected: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	var polygons: Array[Polygon2D] = []
	var selected_sprites: Array[Sprite2D] = []
	for node: Node in selected:
		if node != root and not root.is_ancestor_of(node):
			continue
		if node is Polygon2D and (node as Polygon2D).texture != null:
			polygons.append(node as Polygon2D)
		elif node is Sprite2D:
			selected_sprites.append(node as Sprite2D)

	if polygons.is_empty():
		push_warning("Select at least one textured Polygon2D.")
		return

	var scene_sprites: Array[Sprite2D] = []
	_collect_sprites(root, scene_sprites)
	var updates: Array[Dictionary] = []
	for polygon_node: Polygon2D in polygons:
		var matches: Array[Sprite2D] = []
		for sprite: Sprite2D in selected_sprites:
			if sprite.texture == polygon_node.texture:
				matches.append(sprite)
		if matches.is_empty():
			for sprite: Sprite2D in scene_sprites:
				if sprite.texture == polygon_node.texture:
					matches.append(sprite)
		if matches.size() != 1:
			push_warning("%s: found %d matching source sprites. Select exactly one source Sprite2D with this polygon." % [polygon_node.name, matches.size()])
			continue

		var source: Sprite2D = matches[0]
		if source.region_enabled or source.hframes != 1 or source.vframes != 1 or source.flip_h or source.flip_v:
			push_warning("%s: the source Sprite2D uses a region, frame, or flip; skipped." % polygon_node.name)
			continue
		if polygon_node.texture_offset != Vector2.ZERO or not is_zero_approx(polygon_node.texture_rotation) or polygon_node.texture_scale != Vector2.ONE:
			push_warning("%s: the polygon has a custom texture transform; skipped." % polygon_node.name)
			continue

		var new_uv := PackedVector2Array()
		for point: Vector2 in polygon_node.polygon:
			var image_point: Vector2 = source.to_local(polygon_node.to_global(point + polygon_node.offset))
			image_point -= source.offset
			if source.centered:
				image_point += Vector2(source.texture.get_size()) / 2.0
			new_uv.append(image_point)
		updates.append({"polygon": polygon_node, "uv": new_uv})

	if updates.is_empty():
		return

	var undo_redo: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Sync polygon UVs to source sprite", UndoRedo.MERGE_DISABLE, root)
	for update: Dictionary in updates:
		var polygon_node: Polygon2D = update["polygon"]
		undo_redo.add_do_property(polygon_node, "uv", update["uv"])
		undo_redo.add_undo_property(polygon_node, "uv", polygon_node.uv)
	undo_redo.commit_action()
	print("Synced UVs for %d polygon(s) in %s." % [updates.size(), root.scene_file_path])


func _collect_sprites(node: Node, output: Array[Sprite2D]) -> void:
	if node is Sprite2D and (node as Sprite2D).texture != null:
		output.append(node as Sprite2D)
	for child: Node in node.get_children():
		_collect_sprites(child, output)
