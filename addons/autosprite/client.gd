@tool
extends Node
## Thin HTTP client for the AutoSprite external API.
## Every method returns a Dictionary with at least {"ok": bool} and, on failure, {"error": String}.

const DEFAULT_BASE_URL := "https://www.autosprite.io"

var base_url: String = DEFAULT_BASE_URL
var api_key: String = ""


## Lists characters with their selected spritesheets.
## Returns {"ok": true, "items": Array, "next_cursor": String} on success.
func list_characters(limit: int = 20, cursor: String = "", search: String = "") -> Dictionary:
	var url := "%s/api/external/characters?limit=%d" % [base_url.rstrip("/"), clampi(limit, 1, 50)]
	if cursor != "":
		url += "&cursor=" + cursor.uri_encode()
	if search != "":
		url += "&search=" + search.uri_encode()

	var res := await _request(url)
	if not res.get("ok", false):
		return res

	var body: PackedByteArray = res.get("body", PackedByteArray())
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Malformed response from the AutoSprite API."}

	var cursor_value: Variant = parsed.get("nextCursor")
	return {
		"ok": true,
		"items": parsed.get("items", []),
		"next_cursor": String(cursor_value) if cursor_value is String else "",
	}


## Downloads a URL (sheet PNG, atlas JSON, thumbnail) as raw bytes.
## Returns {"ok": true, "body": PackedByteArray} on success.
func download(url: String) -> Dictionary:
	if url.strip_edges() == "":
		return {"ok": false, "error": "Missing download URL."}
	return await _request(url)


func _request(url: String) -> Dictionary:
	var req := HTTPRequest.new()
	req.timeout = 60.0
	add_child(req)

	var headers := PackedStringArray(["Accept: application/json"])
	var key := api_key.strip_edges()
	if key != "":
		headers.append("Authorization: Bearer " + key)

	var err := req.request(url, headers)
	if err != OK:
		req.queue_free()
		return {"ok": false, "error": "Request failed to start (error %d)." % err}

	var sig: Array = await req.request_completed
	req.queue_free()

	var result: int = sig[0]
	var code: int = sig[1]
	var body: PackedByteArray = sig[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		return {"ok": false, "error": "Network error (result %d). Check the base URL and your connection." % result}
	if code == 401 or code == 403:
		return {"ok": false, "error": "HTTP %d — check your API key at autosprite.io/apikey." % code, "code": code}
	if code < 200 or code >= 300:
		return {"ok": false, "error": "HTTP %d from the AutoSprite API." % code, "code": code}

	return {"ok": true, "body": body}
