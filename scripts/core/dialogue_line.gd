class_name DialogueLine
extends RefCounted

## Estrutura de dados tipada para uma linha de diálogo em estilo JRPG.

var speaker: String = ""
var text: String = ""
var portrait: Texture2D = null
var expression: String = ""


func _init(
	p_speaker: String = "",
	p_text: String = "",
	p_portrait: Texture2D = null,
	p_expression: String = ""
) -> void:
	speaker = p_speaker
	text = p_text
	portrait = p_portrait
	expression = p_expression


static func from_dict(data: Dictionary) -> DialogueLine:
	var s: String = str(data.get("speaker", ""))
	var t: String = str(data.get("text", ""))
	var raw_p: Variant = data.get("portrait", null)
	var p: Texture2D = null
	var expr: String = str(data.get("expression", ""))
	if raw_p is Texture2D:
		p = raw_p as Texture2D
	elif raw_p is String:
		var p_str: String = (raw_p as String).strip_edges()
		if p_str.begins_with("res://") and ResourceLoader.exists(p_str):
			p = load(p_str) as Texture2D
		elif not p_str.is_empty() and expr.is_empty():
			expr = p_str
	return DialogueLine.new(s, t, p, expr)

