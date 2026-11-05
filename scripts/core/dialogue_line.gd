class_name DialogueLine
extends RefCounted

## Estrutura de dados tipada para uma linha de diálogo em estilo JRPG.

var speaker: String = ""
var text: String = ""
var portrait: Texture2D = null


func _init(p_speaker: String = "", p_text: String = "", p_portrait: Texture2D = null) -> void:
	speaker = p_speaker
	text = p_text
	portrait = p_portrait


static func from_dict(data: Dictionary) -> DialogueLine:
	var s: String = str(data.get("speaker", ""))
	var t: String = str(data.get("text", ""))
	var p: Texture2D = data.get("portrait", null) as Texture2D
	return DialogueLine.new(s, t, p)

