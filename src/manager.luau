local types = require("types")
local Sprite = require("Sprite")
local Loader = require("loader")

local Manager = {} :: types.Manager
Manager.__index = Manager

function Manager.Create()
	local manager = {} :: types.Manager
	setmetatable(manager, Manager)
	manager.images = {}
	manager.sprites = {}
	manager.spriteIndex = 0
	manager.editing = true
	manager.log = ""
	manager.localEditing = true
	manager.scaleFactor = 1
	return manager
end

function Manager.LoadImages(self: types.Manager, data)
	for i,datum in ipairs(data) do
		local image = Loader.LoadImage(datum)
		if image then 
			table.insert(self.images, image)
			print("Loaded image: " .. image.id)
		end
	end

	table.sort(self.images, function(a: types.Image, b: types.Image) return a.id < b.id end)
end

function Manager.RenderAll(self: types.Manager)
	self.log = "Blitting Sprite Images:\n\n"
	self.editing = false
	WorldDraw.clear()

	for i,sprite in self.sprites do
		self.log ..= sprite.id .. " : " .. sprite.image.id .. "\n"

		-- Error catching by using pcall on the function
		local blit = function() sprite:Blit() end
		if pcall(blit) then
			self.log ..= "  -> Success\n\n"
		else
			self.log ..= "  -> Failure\n\n"
		end
	end

	print(self.log)
end

function Manager.OnGui(self: types.Manager)

	if Gui.collapsingHeader("Sprite Manager") then
		Gui.indent()

		if #self.images == 0 then
			Gui.text(
				"No images were found!\n\n"..
				"Sprite Config Generator must be used in order to import images:\n"..
				"https://github.com/frogrilla/sprite_config_generator"
			)
			Gui.unindent()
			return
		end

		if self.editing then
			if Gui.button("Render") then
				self:RenderAll()
			end

			if Gui.beginCombo("##add_sprite", "Add Sprite From Image") then
				for i,image in self.images do
					if Gui.selectable(image.id, false) then
						table.insert(self.sprites, Sprite.Create(image))
						self.spriteIndex = #self.sprites
					end
				end
				Gui.endCombo()
			end

			if Gui.beginListBox("##sprite_list") then
				for i,sprite in self.sprites do
					if Gui.selectable(tostring(i) .. ": " .. sprite.id, i == self.spriteIndex) then
						if self.spriteIndex == i then
							self.spriteIndex = 0
						else
							self.spriteIndex = i
						end
					end
				end
				Gui.endListBox()
			end

			local sprite = self.sprites[self.spriteIndex]

			if sprite then

				Gui.separatorText("Edit Sprite")

				if Gui.button("Delete " .. Icon.Trash) then
					table.remove(self.sprites, self.spriteIndex)
					self.spriteIndex = 0
					return
				end

				Gui.sameLine()

				if Gui.button("Duplicate " .. Icon.Copy) then
					table.insert(self.sprites, table.clone(sprite))
					self.spriteIndex = #self.sprites
				end

				Gui.text(
					"Sprite:     " .. sprite.id ..
					"\nImage:      " .. sprite.image.id ..
					"\nResolution: " .. sprite.image.resolution.x .. "x" .. sprite.image.resolution.y
				)

				sprite.id = Gui.inputText("Name", sprite.id)

				if Gui.beginCombo("##change_sprite_image", "Change Image") then
					for i,image in ipairs(self.images) do
						if Gui.selectable(image.id, image.id == sprite.image.id) then
							sprite.transform.scale.y *= image.resolution.x / sprite.image.resolution.x
							sprite.transform.scale.z *= image.resolution.y / sprite.image.resolution.y
							sprite.image = image
						end
					end
					Gui.endCombo()
				end

				if Gui.button("Bring to me") then
					sprite.transform.position = camera.position
				end

				Gui.setItemTooltip("Sets the sprite's position to the spectator's position")

				Gui.sameLine()

				if Gui.button("Look at me") then
					sprite.transform.rotation = camera.rotation
				end

				Gui.setItemTooltip("Aligns the sprite with the spectator's orientation")

				Gui.sameLine()

				if Gui.button("Locate") then
					camera.position = sprite.transform.position - sprite.transform.rotation:getForwardVector() * 500
					camera.rotation = sprite.transform.rotation
				end

				Gui.setItemTooltip("Brings the camera in front of the sprite and makes it look at it")


				if Gui.collapsingHeader("Transform") then
					
					Gui.indent()

					self.localEditing = Gui.checkbox("Use local space", self.localEditing)

					Gui.setItemTooltip("Makes \'Translate\' and \'Rotate\' use the sprite's local axis instead of the world's")

					sprite.transform.position = Gui.dragFloat3("Position", sprite.transform.position, 1, -100000, 100000)

					local translation = Gui.dragFloat3("Translate", Vec3.zeroVector, 1, -1000, 1000)
					if self.localEditing then
						translation = sprite.transform.rotation:rotateVector(translation)
					end
					sprite.transform.position += translation

					sprite.transform.scale = Gui.dragFloat3("Scale", sprite.transform.scale, 1, -100000, 100000)

					self.scaleFactor = Gui.dragFloat("Scale Factor", self.scaleFactor, 0.1, 0.1, 2)
					if Gui.button("Apply Scale") then
						sprite.transform.scale *= self.scaleFactor
					end

					Gui.sameLine()

					if Gui.button("Reset scale") then
						sprite.transform.scale = Vec3.new(0, sprite.image.resolution.x, sprite.image.resolution.y)
					end

					Gui.setItemTooltip("Resets the sprite's scale to match its image")

					--Gui.dragFloat4("Rotation", sprite.transform.rotation, 0, -1, 1)

					local rotation = Gui.dragFloat3("Rotate", Vec3.zeroVector, 1, -360, 360)
					if self.localEditing then
						sprite.transform.rotation *= Quat.fromEuler(rotation.x, rotation.y, rotation.z)
					else
						sprite.transform.rotation = Quat.fromEuler(rotation.x, rotation.y, rotation.z) * sprite.transform.rotation
					end

					Gui.unindent()

				end

			end
		else
			if Gui.button("Edit") then
				self.editing = true
			end
			Gui.text(self.log)
		end

		Gui.unindent()
	end
end

function Manager.Tick(self: types.Manager)
	if self.editing then
		WorldDraw.clear()
		for i,sprite in ipairs(self.sprites) do
			sprite:DebugDraw(if i == self.spriteIndex then Vec3.new(0.3,1,0.3) else Vec3.new(0,1,0))
		end
	end
end

return Manager