@tool
extends VBoxContainer
## The AutoSprite dock: API key settings, character browser, and one-click imports.

const Client := preload("res://addons/autosprite/client.gd")
const Importer := preload("res://addons/autosprite/importer.gd")

const SETTING_BASE_URL := "autosprite/base_url"
const SETTING_API_KEY := "autosprite/api_key"
const PAGE_SIZE := 20

var _client: Node
var _characters: Array = []
var _next_cursor: String = ""
var _search: String = ""
var _busy := false
var _expanded := {}

var _base_url := Client.DEFAULT_BASE_URL

var _api_key_edit: LineEdit
var _search_edit: LineEdit
var _refresh_btn: Button
var _list_box: VBoxContainer
var _load_more_btn: Button
var _status: Label


func _ready() -> void:
	custom_minimum_size = Vector2(320, 0)
	add_theme_constant_override("separation", 6)

	_client = Client.new()
	add_child(_client)

	_build_ui()
	_load_settings()

	if _client.api_key != "":
		call_deferred("_refresh")
	else:
		_set_status("Paste your API key to get started.", false)


func _build_ui() -> void:
	var intro := Label.new()
	intro.text = "Import your AutoSprite characters as SpriteFrames + AnimatedSprite2D scenes."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(intro)

	_api_key_edit = LineEdit.new()
	_api_key_edit.secret = true
	_api_key_edit.placeholder_text = "API key"
	_api_key_edit.text_changed.connect(func(_t: String) -> void: _save_settings())
	add_child(_api_key_edit)

	var key_link := LinkButton.new()
	key_link.text = "Get an API key at autosprite.io/apikey"
	key_link.uri = "https://www.autosprite.io/apikey"
	add_child(key_link)

	var search_row := HBoxContainer.new()
	add_child(search_row)

	_search_edit = LineEdit.new()
	_search_edit.placeholder_text = "Search characters…"
	_search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_edit.text_submitted.connect(func(_t: String) -> void: _refresh())
	search_row.add_child(_search_edit)

	_refresh_btn = Button.new()
	_refresh_btn.text = "Get Characters"
	_refresh_btn.pressed.connect(_refresh)
	search_row.add_child(_refresh_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_list_box = VBoxContainer.new()
	_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list_box)

	_load_more_btn = Button.new()
	_load_more_btn.text = "Load More"
	_load_more_btn.visible = false
	_load_more_btn.pressed.connect(_load_more)
	add_child(_load_more_btn)

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)


# --- Settings ---

func _load_settings() -> void:
	var es := EditorInterface.get_editor_settings()
	# Hidden dev override for testing against a non-production API host.
	if es.has_setting(SETTING_BASE_URL):
		var url := str(es.get_setting(SETTING_BASE_URL)).strip_edges()
		if url != "":
			_base_url = url
	if es.has_setting(SETTING_API_KEY):
		_api_key_edit.text = str(es.get_setting(SETTING_API_KEY))
	_apply_settings()


func _save_settings() -> void:
	var es := EditorInterface.get_editor_settings()
	es.set_setting(SETTING_API_KEY, _api_key_edit.text)
	_apply_settings()


func _apply_settings() -> void:
	_client.base_url = _base_url
	_client.api_key = _api_key_edit.text.strip_edges()


# --- Character listing ---

func _refresh() -> void:
	if _busy:
		return
	_busy = true
	_search = _search_edit.text.strip_edges()
	_set_status("Loading characters…", false)

	var res: Dictionary = await _client.list_characters(PAGE_SIZE, "", _search)
	_busy = false
	if not res.get("ok", false):
		_set_status(str(res.get("error", "Unknown error.")), true)
		return

	_characters = res.get("items", [])
	_next_cursor = str(res.get("next_cursor", ""))
	if _characters.is_empty():
		var msg := "No matches. Clear the search or create characters on autosprite.io."
		if _search == "":
			msg = "No characters yet. Create one on autosprite.io first."
		_set_status(msg, false)
	else:
		_set_status("%d character(s) loaded." % _characters.size(), false)
	_rebuild_list()


func _load_more() -> void:
	if _busy or _next_cursor == "":
		return
	_busy = true
	_set_status("Loading more…", false)

	var res: Dictionary = await _client.list_characters(PAGE_SIZE, _next_cursor, _search)
	_busy = false
	if not res.get("ok", false):
		_set_status(str(res.get("error", "Unknown error.")), true)
		return

	_characters.append_array(res.get("items", []))
	_next_cursor = str(res.get("next_cursor", ""))
	_set_status("%d character(s) loaded." % _characters.size(), false)
	_rebuild_list()


func _rebuild_list() -> void:
	for child in _list_box.get_children():
		child.queue_free()
	for character in _characters:
		if typeof(character) == TYPE_DICTIONARY:
			_list_box.add_child(_make_character_row(character))
	_load_more_btn.visible = _next_cursor != ""


func _make_character_row(character: Dictionary) -> Control:
	var char_id := _text(character.get("id"), "default")
	var display := _text(character.get("name"), char_id)
	var sheets: Array = character.get("spritesheets") if character.get("spritesheets") is Array else []

	var box := VBoxContainer.new()

	var header := HBoxContainer.new()
	box.add_child(header)

	var thumb := TextureRect.new()
	thumb.custom_minimum_size = Vector2(28, 28)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	header.add_child(thumb)
	var thumb_url := _text(character.get("thumbnail"), _text(character.get("baseImage")))
	if thumb_url != "":
		_load_thumbnail(thumb_url, thumb)

	var toggle := Button.new()
	toggle.flat = true
	toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
	toggle.clip_text = true
	toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(toggle)

	var import_all := Button.new()
	import_all.text = "Import All"
	import_all.disabled = sheets.is_empty()
	import_all.pressed.connect(func() -> void: _import_all(character))
	header.add_child(import_all)

	var inner := VBoxContainer.new()
	inner.visible = _expanded.get(char_id, false)
	box.add_child(inner)

	if sheets.is_empty():
		var empty := Label.new()
		empty.text = "    No spritesheets yet."
		inner.add_child(empty)
	for sheet in sheets:
		if typeof(sheet) != TYPE_DICTIONARY:
			continue
		var row := HBoxContainer.new()
		inner.add_child(row)

		var lbl := Label.new()
		lbl.text = "    " + _sheet_display_name(sheet)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		row.add_child(lbl)

		var btn := Button.new()
		btn.text = "Import"
		btn.pressed.connect(func() -> void: _import_one(character, sheet))
		row.add_child(btn)

	var update_toggle := func() -> void:
		var arrow := "▾" if inner.visible else "▸"
		toggle.text = "%s %s (%d)" % [arrow, display, sheets.size()]
	update_toggle.call()
	toggle.pressed.connect(func() -> void:
		inner.visible = not inner.visible
		_expanded[char_id] = inner.visible
		update_toggle.call()
	)

	box.add_child(HSeparator.new())
	return box


func _load_thumbnail(url: String, rect: TextureRect) -> void:
	var res: Dictionary = await _client.download(url)
	if not res.get("ok", false) or not is_instance_valid(rect):
		return
	var bytes: PackedByteArray = res.get("body", PackedByteArray())
	if bytes.size() < 4:
		return
	var img := Image.new()
	var err: Error = _carregar_imagem_por_magic_bytes(img, bytes)
	if err != OK:
		return
	rect.texture = ImageTexture.create_from_image(img)


static func _carregar_imagem_por_magic_bytes(img: Image, bytes: PackedByteArray) -> Error:
	if bytes.size() >= 8 and bytes[0] == 0x89 and bytes[1] == 0x50 and bytes[2] == 0x4E and bytes[3] == 0x47:
		return img.load_png_from_buffer(bytes)
	if bytes.size() >= 3 and bytes[0] == 0xFF and bytes[1] == 0xD8 and bytes[2] == 0xFF:
		return img.load_jpg_from_buffer(bytes)
	if bytes.size() >= 12 and bytes[0] == 0x52 and bytes[1] == 0x49 and bytes[2] == 0x46 and bytes[3] == 0x46:
		return img.load_webp_from_buffer(bytes)
	var err: Error = img.load_webp_from_buffer(bytes)
	if err != OK:
		err = img.load_jpg_from_buffer(bytes)
	if err != OK:
		err = img.load_png_from_buffer(bytes)
	return err


# --- Importing ---

func _import_one(character: Dictionary, sheet: Dictionary) -> void:
	if _busy:
		return
	_busy = true
	var display := _sheet_display_name(sheet)
	var char_name := _text(character.get("name"), "Character")
	_set_status("Importing %s for %s…" % [display, char_name], false)

	var res: Dictionary = await _do_import(character, sheet)
	_busy = false
	if not res.get("ok", false):
		_set_status("Import failed: " + str(res.get("error", "Unknown error.")), true)
		return

	_set_status("Imported %s for %s." % [display, char_name], false)
	EditorInterface.select_file(str(res.get("scene_path", "")))


func _import_all(character: Dictionary) -> void:
	if _busy:
		return
	var sheets: Array = character.get("spritesheets") if character.get("spritesheets") is Array else []
	if sheets.is_empty():
		return
	_busy = true
	var char_name := _text(character.get("name"), "Character")

	var last_scene := ""
	for i in sheets.size():
		var sheet: Variant = sheets[i]
		if typeof(sheet) != TYPE_DICTIONARY:
			continue
		_set_status("Importing %s (%d/%d) for %s…" % [_sheet_display_name(sheet), i + 1, sheets.size(), char_name], false)
		var res: Dictionary = await _do_import(character, sheet)
		if not res.get("ok", false):
			_busy = false
			_set_status("Import failed: " + str(res.get("error", "Unknown error.")), true)
			return
		last_scene = str(res.get("scene_path", ""))

	_busy = false
	_set_status("Imported %d animation(s) for %s." % [sheets.size(), char_name], false)
	if last_scene != "":
		EditorInterface.select_file(last_scene)


func _do_import(character: Dictionary, sheet: Dictionary) -> Dictionary:
	var png: Dictionary = await _client.download(_text(sheet.get("sheetUrl")))
	if not png.get("ok", false):
		return png
	var atlas: Dictionary = await _client.download(_text(sheet.get("atlasUrl")))
	if not atlas.get("ok", false):
		return atlas

	var atlas_bytes: PackedByteArray = atlas.get("body", PackedByteArray())
	return await Importer.import_sheet(
		_text(character.get("name"), "Character"),
		_sheet_anim_name(sheet),
		png.get("body", PackedByteArray()),
		atlas_bytes.get_string_from_utf8())


# --- Helpers ---

func _sheet_base_name(sheet: Dictionary) -> String:
	# Custom animations all share kind "custom"; label carries their real name.
	var label := _text(sheet.get("label"))
	if label != "":
		return label
	return _text(sheet.get("kind"), "animation")


func _sheet_display_name(sheet: Dictionary) -> String:
	var direction := _text(sheet.get("direction"))
	var suffix := (" (%s)" % direction) if direction != "" else ""
	return _sheet_base_name(sheet) + suffix


func _sheet_anim_name(sheet: Dictionary) -> String:
	var direction := _text(sheet.get("direction"))
	var suffix := ("_" + direction) if direction != "" else ""
	return _sheet_base_name(sheet) + suffix


func _set_status(text: String, is_error: bool) -> void:
	_status.text = text
	if is_error:
		_status.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	else:
		_status.remove_theme_color_override("font_color")


static func _text(value: Variant, fallback: String = "") -> String:
	if value is String:
		var s := String(value).strip_edges()
		if s != "":
			return s
	return fallback
