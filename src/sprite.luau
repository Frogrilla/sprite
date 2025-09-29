local types = require("types")
local Utils = require("utils")

local Sprite = {} :: types.Sprite
Sprite.__index = Sprite

function Sprite.Create(image: types.Image): types.Sprite
	local sprite = {} :: types.Sprite
	setmetatable(sprite, Sprite)
	sprite.image = image
	sprite.transform = Transform.identity
	sprite.transform.scale = Vec3.new(0, image.resolution.x, image.resolution.y)
	sprite.id = image.id .. ".sprite"
	return sprite
end

function Sprite.DebugDraw(self: types.Sprite, col: Vec3)
	local p1 = Utils.ApplyTransformation(Vec3.new(0,-0.5,0.5), self.transform)
	local p2 = Utils.ApplyTransformation(Vec3.new(0,0.5,0.5), self.transform)
	local p3 = Utils.ApplyTransformation(Vec3.new(0,0.5,-0.5), self.transform)
	local p4 = Utils.ApplyTransformation(Vec3.new(0,-0.5,-0.5), self.transform)

	WorldDraw.drawLine(p1, p2, col.x, col.y, col.z, 0.5, 0)
	WorldDraw.drawLine(p2, p3, col.x, col.y, col.z, 0.5, 0)
	WorldDraw.drawLine(p3, p4, col.x, col.y, col.z, 0.5, 0)
	WorldDraw.drawLine(p4, p1, col.x, col.y, col.z, 0.5, 0)
	WorldDraw.drawLine(p1, p3, col.x, col.y, col.z, 0.5, 0)

	WorldDraw.drawLine(self.transform.position, self.transform.position + self.transform.rotation:getForwardVector()*20, 1, 0, 0, 0.5, 0)
	WorldDraw.drawLine(self.transform.position, self.transform.position + self.transform.rotation:getRightVector()*20, 0, 1, 0, 0.5, 0)
	WorldDraw.drawLine(self.transform.position, self.transform.position + self.transform.rotation:getUpVector()*20, 0, 0, 1, 0.5, 0)
end

function Sprite.Blit(self: types.Sprite)
	self.image:Blit(self.transform)
end

return Sprite