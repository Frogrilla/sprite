local types = require("types")

local Loader = {}

Loader.formats = {
	dummy = require("formats/dummy"),
	indexed = require("formats/indexed")
}

function Loader.LoadImage(data): types.Image?
	local format = Loader.formats[data.format]
	if format then
		return format.Load(data)
	end
	return nil
end

return Loader