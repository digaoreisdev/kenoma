@tool
extends RefCounted
## Turns a downloaded sheet PNG + atlas JSON into project resources:
## - res://autosprite_imported/<Character>/<anim>.png        (the sheet texture)
## - res://autosprite_imported/<Character>/<Character>_frames.tres  (one SpriteFrames per character; animations accumulate)
## - res://autosprite_imported/<Character>/<Character>.tscn  (AnimatedSprite2D wired to the SpriteFrames; created once, never overwritten)

const IMPORT_ROOT := "res://autosprite_imported"
const DEFAULT_FPS := 12.0


## Returns {"ok": true, "frames_path": String, "scene_path": String} or {"ok": false, "error": String}.
static func import_sheet(character_name: String, anim_name: String, png_bytes: PackedByteArray, atlas_json: String) -> Dictionary:
	var atlas: Variant = JSON.parse_string(atlas_json)
	if typeof(atlas) != TYPE_DICTIONARY or typeof(atlas.get("frames")) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Atlas JSON does not define any frames."}
	var frame_map: Dictionary = atlas.get("frames")
	if frame_map.is_empty():
		return {"ok": false, "error": "Atlas JSON does not define any frames."}
	if png_bytes.is_empty():
		return {"ok": false, "error": "Sheet PNG is empty."}

	var safe_char := _sanitize(character_name)
	var safe_anim := _sanitize(anim_name)
	var char_dir := IMPORT_ROOT + "/" + safe_char

	var mkdir_err := DirAccess.make_dir_recursive_absolute(char_dir)
	if mkdir_err != OK:
		return {"ok": false, "error": "Could not create folder %s (error %d)." % [char_dir, mkdir_err]}

	var png_path := char_dir + "/" + safe_anim + ".png"
	var write_err := _write_file(png_path, png_bytes)
	if write_err != "":
		return {"ok": false, "error": write_err}
	_write_file(char_dir + "/" + safe_anim + ".atlas.json", atlas_json.to_utf8_buffer())

	var fs := EditorInterface.get_resource_filesystem()
	var sheet_tex := await _import_texture(fs, png_path)
	if sheet_tex == null:
		return {"ok": false, "error": "Godot failed to import the sheet texture at %s." % png_path}

	var ordered_keys: Array = frame_map.keys()
	ordered_keys.sort_custom(func(a, b) -> bool:
		var ia := _frame_index(str(a))
		var ib := _frame_index(str(b))
		if ia != ib:
			return ia < ib
		return str(a) < str(b)
	)

	var frames_path := char_dir + "/" + safe_char + "_frames.tres"
	var frames_res: SpriteFrames = null
	if ResourceLoader.exists(frames_path):
		frames_res = ResourceLoader.load(frames_path, "SpriteFrames", ResourceLoader.CACHE_MODE_REPLACE) as SpriteFrames
	if frames_res == null:
		frames_res = SpriteFrames.new()
		if frames_res.has_animation("default"):
			frames_res.remove_animation("default")

	if frames_res.has_animation(anim_name):
		frames_res.remove_animation(anim_name)
	frames_res.add_animation(anim_name)
	frames_res.set_animation_loop(anim_name, true)
	frames_res.set_animation_speed(anim_name, DEFAULT_FPS)

	for key in ordered_keys:
		var fr: Variant = frame_map[key]
		if typeof(fr) != TYPE_DICTIONARY:
			continue
		var region := Rect2(
			float(fr.get("x", 0)), float(fr.get("y", 0)),
			float(fr.get("w", 0)), float(fr.get("h", 0)))
		if region.size.x <= 0 or region.size.y <= 0:
			continue
		var at := AtlasTexture.new()
		at.atlas = sheet_tex
		at.region = region
		at.filter_clip = true
		# Atlas "duration" is a relative unit (the generator emits 1 for every frame).
		frames_res.add_frame(anim_name, at, maxf(0.01, float(fr.get("duration", 1))))

	if frames_res.get_frame_count(anim_name) == 0:
		return {"ok": false, "error": "Atlas frames were empty or invalid."}

	frames_res.take_over_path(frames_path)
	var save_err := ResourceSaver.save(frames_res, frames_path)
	if save_err != OK:
		return {"ok": false, "error": "Could not save SpriteFrames to %s (error %d)." % [frames_path, save_err]}
	fs.update_file(frames_path)

	var scene_path := char_dir + "/" + safe_char + ".tscn"
	if not ResourceLoader.exists(scene_path):
		var scene_err := _create_scene(scene_path, safe_char, frames_res, anim_name)
		if scene_err != "":
			return {"ok": false, "error": scene_err}
		fs.update_file(scene_path)

	return {"ok": true, "frames_path": frames_path, "scene_path": scene_path}


static func _import_texture(fs: EditorFileSystem, png_path: String) -> Texture2D:
	await _wait_for_scan(fs)
	fs.update_file(png_path)
	if fs.get_file_type(png_path) != "":
		fs.reimport_files(PackedStringArray([png_path]))
		if ResourceLoader.exists(png_path):
			return load(png_path) as Texture2D

	# A brand-new folder isn't in the editor's file tree yet; a full rescan picks
	# up (and imports) the new file. The import keeps running briefly after the
	# scanning flag clears, so poll with a deadline instead of checking once.
	fs.scan()
	await _wait_for_scan(fs)
	var tree := Engine.get_main_loop() as SceneTree
	var deadline := Time.get_ticks_msec() + 15000
	while Time.get_ticks_msec() < deadline:
		if not fs.is_scanning() and ResourceLoader.exists(png_path):
			return load(png_path) as Texture2D
		if tree == null:
			break
		await tree.process_frame
	return null


static func _wait_for_scan(fs: EditorFileSystem) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	for i in 2:
		await tree.process_frame
	while fs.is_scanning():
		await tree.process_frame


static func _create_scene(scene_path: String, node_name: String, frames_res: SpriteFrames, anim_name: String) -> String:
	var node := AnimatedSprite2D.new()
	var valid_name := node_name.validate_node_name()
	node.name = valid_name if valid_name != "" else "AutoSprite"
	node.sprite_frames = frames_res
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.animation = anim_name
	node.autoplay = anim_name

	var packed := PackedScene.new()
	var pack_err := packed.pack(node)
	node.free()
	if pack_err != OK:
		return "Could not build the character scene (error %d)." % pack_err

	var save_err := ResourceSaver.save(packed, scene_path)
	if save_err != OK:
		return "Could not save the character scene to %s (error %d)." % [scene_path, save_err]
	return ""


static func _write_file(path: String, bytes: PackedByteArray) -> String:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return "Could not write %s (error %d)." % [path, FileAccess.get_open_error()]
	f.store_buffer(bytes)
	f.close()
	return ""


static func _frame_index(key: String) -> int:
	if key.is_valid_int():
		return key.to_int()
	var digits := ""
	for c in key:
		if c >= "0" and c <= "9":
			digits += c
	return digits.to_int() if digits != "" else 0


static func _sanitize(raw: String) -> String:
	var s := raw.strip_edges()
	if s == "":
		return "AutoSprite"
	for c in ["/", "\\", ":", "*", "?", "\"", "<", ">", "|", "%", "."]:
		s = s.replace(c, "_")
	return s.replace(" ", "_")
