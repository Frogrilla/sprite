local types = require("types")
local Utils = require("utils")

-- Default is 1.1 to make pixels spill slightly, tho if you want a cool holographic effect try out 0.5
local PIXEL_SIZE_FACTOR = 1.1

export type Indexed = types.Image&{
	pallete : {LinearColor},
	segments : {{color : number, length : number}}
}

local Indexed = {} :: Indexed
Indexed.__index = Indexed

function Indexed.Load(data): Indexed
	local indexed = {} :: Indexed
	setmetatable(indexed, Indexed)

	indexed.id = data.id
	indexed.resolution = Vec2.new(data.width, data.height)
	indexed.pallete = {}
	indexed.segments = {}

	for i,col in ipairs(data.pallete) do
		table.insert(indexed.pallete, LinearColor.new(
			col.r/255,
			col.g/255,
			col.b/255,
			col.a/255
		))
	end

	local numbers = data.data:split(";")
	for i = 1,#numbers,2 do
		local segement = {}
		segement.length = tonumber(numbers[i])
		segement.color = tonumber(numbers[i+1])
		if segement.length ~= nil and segement.color ~= nil then
			table.insert(indexed.segments, segement)
		end
	end

	return indexed
end

function Indexed.BlitLAGGY(self: Indexed, transform: Transform)
	local y = 0
	local z = 0
	for i,segment in ipairs(self.segments) do

		local p1 = Utils.ApplyTransformation(Vec3.new(0, y-0.5, z+0.5), transform)
		local p2 = Utils.ApplyTransformation(Vec3.new(0, y-0.5 + ((segment.length)/self.resolution.x), z+0.5), transform)
		local p3 = p1 - transform.rotation:getUpVector() * (transform.scale.z / self.resolution.y)
		local p4 = p2 - transform.rotation:getUpVector() * (transform.scale.z / self.resolution.y)


		local col = self.pallete[segment.color]

		WorldDraw.drawTriangle(p1, p2, p3, col, 0)
		WorldDraw.drawTriangle(p3, p2, p4, col, 0)

		y += segment.length / self.resolution.x
		if y >= 1 then
			z -= 1/self.resolution.y
			y = 0
		end
	end
end


function Indexed.Blit(self: Indexed, transform: Transform)
	local y = 0
	local z = 0
	local size = transform.scale.z / self.resolution.y * PIXEL_SIZE_FACTOR
	for i,segment in ipairs(self.segments) do

		local col = self.pallete[segment.color]
		
		-- col[3] is a hacky way to access LinearColor::A - At time of writing the member isnt accessible in the normal method
		if col[3] > 0 then
			local p1 = Utils.ApplyTransformation(Vec3.new(0, y-0.5, z+0.5), transform)
			local p2 = Utils.ApplyTransformation(Vec3.new(0, y-0.5 + ((segment.length)/self.resolution.x), z+0.5), transform)

			WorldDraw.drawLine(p1, p2, col.R, col.G, col.B, size, 0)
		end

		y += segment.length / self.resolution.x
		if y > (1 - (0.99/self.resolution.x)) then -- Was if y >= 1
			z -= 1/self.resolution.y
			y = 0
		end
	end
end

return Indexed