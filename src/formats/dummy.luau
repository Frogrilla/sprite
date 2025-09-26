local types = require("types")
local Utils = require("utils")

export type Dummy = types.Image&{
	color : LinearColor
}

local Dummy = {} :: Dummy
Dummy.__index = Dummy

function Dummy.Load(data): Dummy
	local dummy = {} :: Dummy
	setmetatable(dummy, Dummy)

	dummy.id = data.id
	dummy.resolution = Vec2.new(data.width, data.height)
	dummy.color = LinearColor.new(
		data.color.R,
		data.color.G,
		data.color.B,
		data.color.A
	)

	return dummy
end

function Dummy.Blit(self: Dummy, transform: Transform)
	local p1 = Utils.ApplyTransformation(Vec3.new(0,-0.5,0.5), transform)
	local p2 = Utils.ApplyTransformation(Vec3.new(0,0.5,0.5), transform)
	local p3 = Utils.ApplyTransformation(Vec3.new(0,0.5,-0.5), transform)
	local p4 = Utils.ApplyTransformation(Vec3.new(0,-0.5,-0.5), transform)

	WorldDraw.drawTriangle(p1, p2, p3, self.color, 0)
	WorldDraw.drawTriangle(p3, p4, p1, self.color, 0)
end

return Dummy