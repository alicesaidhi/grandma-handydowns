local vide = require(script.Parent.Parent.vide)
local stream = require(script.Parent.libraries.stream)

return {
	stream = vide.source(stream.get_string()),
	added = 0,
}