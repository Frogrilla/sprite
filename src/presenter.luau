local types = require("types")

export type Presenter = {
	manager : types.Manager,
	username : string,
	spriteIndex : number,
	cycleIndex : number,
	editIndex : number,
	imageCycle : {types.Image},
	justCycled : boolean,

	Create : () -> Presenter,
	OnGui : (self: Presenter) -> nil,
	UpdateSlide: (self: Presenter) -> nil,
	DoCycle : (self: Presenter, offset: number) -> nil,
	Tick : (self: Presenter) -> nil
}

local Presenter = {} :: Presenter
Presenter.__index = Presenter

function Presenter.Create(manager: types.Manager)
	local presenter = {}
	setmetatable(presenter, Presenter)
	presenter.manager = manager
	presenter.username = "No user " .. Icon.UserAltSlash
	presenter.spriteIndex = 0
	presenter.cycleIndex = 1
	presenter.editIndex = 0
	presenter.imageCycle = {}
	presenter.justCycled = false
	return presenter
end

function Presenter.OnGui(self: Presenter)

	if Gui.collapsingHeader("Presenter") then
		Gui.indent()

		if Gui.beginCombo("##select_presenter", self.username) then
			
			for i,player in ipairs(getGameData().players) do
				if Gui.selectable(player.playerName, self.username == player.playerName) then
					self.username = player.playerName
				end
			end

			Gui.endCombo()
		end

		if self.manager.editing then

			if self.spriteIndex == 0 then

				if Gui.beginCombo("##seletc_sprite_for_presentation", "Select Sprite") then
					
					for i,sprite in ipairs(self.manager.sprites) do
						if Gui.selectable(sprite.id, false) then
							self.spriteIndex = i
							self.cycleIndex = 1
							table.insert(self.imageCycle, sprite.image)
						end
					end

					Gui.endCombo()
				end

				Gui.unindent()
				return
			end

			local sprite = self.manager.sprites[self.spriteIndex]

			if not sprite then
				self.spriteIndex = 0
				table.clear(self.imageCycle)
				return
			end

			Gui.text(sprite.id)

			if Gui.button("Relinquish Control") then
				self.spriteIndex = 0
				table.clear(self.imageCycle)
				return
			end

			if Gui.beginCombo("##add_slide", "Add Slide") then

				for i,image in self.manager.images do
					if Gui.selectable(image.id, false) then
						table.insert(self.imageCycle, image)
					end
				end
				Gui.endCombo()
			end

			if Gui.beginListBox("##presentation_slides") then

				for i,image in self.imageCycle do
					if Gui.selectable(i .. ": " .. image.id, self.editIndex == i) then
						self.editIndex = if self.editIndex == i then 0 else i
					end
				end

				Gui.endListBox()
			end

			if self.editIndex > 0 then
				Gui.text("Selected Slide " .. self.editIndex .. ": " .. self.imageCycle[self.editIndex].id)

				if #self.imageCycle <= 1 then Gui.beginDisabled() end

				if Gui.button(Icon.Trash) then
					table.remove(self.imageCycle, self.editIndex)
					self.editIndex = 0
				end

				if #self.imageCycle <= 1 then Gui.endDisabled() end

				Gui.sameLine()
				if self.editIndex <= 1 then Gui.beginDisabled() end

				local justPressed = false

				if Gui.button(Icon.ArrowUp) then
					local reference = self.imageCycle[self.editIndex-1]
					self.imageCycle[self.editIndex-1] = self.imageCycle[self.editIndex]
					self.imageCycle[self.editIndex] = reference
					self.editIndex -= 1
					justPressed = true
				end

				if self.editIndex <= 1 and not justPressed then Gui.endDisabled() end
				Gui.sameLine()
				if self.editIndex >= #self.imageCycle then Gui.beginDisabled() end

				justPressed = false

				if Gui.button(Icon.ArrowDown) then
					local reference = self.imageCycle[self.editIndex+1]
					self.imageCycle[self.editIndex+1] = self.imageCycle[self.editIndex]
					self.imageCycle[self.editIndex] = reference
					self.editIndex += 1
					justPressed = true
				end

				if self.editIndex >= #self.imageCycle and not justPressed then Gui.endDisabled() end

			end

		else

			if self.spriteIndex > 0 then
				local sprite = self.manager.sprites[self.spriteIndex]
				if sprite then
					Gui.text(
						"Sprite: " .. sprite.id ..
						"\nSlide:  " .. self.cycleIndex
					)

					if Gui.beginListBox("##presentation_slides_selector") then

						for i,image in self.imageCycle do
							if Gui.selectable(i .. ": " .. image.id, self.cycleIndex == i) then
								self.cycleIndex = i
								self:UpdateSlide()
								self.manager:RenderAll()
							end
						end

						Gui.endListBox()
					end

				end
			end

		end

		Gui.unindent()
	end
end

function Presenter.UpdateSlide(self: Presenter)
	local sprite = self.manager.sprites[self.spriteIndex]
	local image = self.imageCycle[self.cycleIndex]

	sprite.transform.scale.y *= image.resolution.x / sprite.image.resolution.x
	sprite.transform.scale.z *= image.resolution.y / sprite.image.resolution.y
	sprite.image = image
end

function Presenter.DoCycle(self: Presenter, offset: number)
	self.cycleIndex += offset;
	if self.cycleIndex > #self.imageCycle then
		self.cycleIndex = 1;
	elseif self.cycleIndex == 0 then
		self.cycleIndex = #self.imageCycle
	end

	self:UpdateSlide()
	self.manager:RenderAll()
end

function Presenter.Tick(self: Presenter)

	if self.manager.editing then

		self.cycleIndex = 1

		local sprite = self.manager.sprites[self.spriteIndex]

		if sprite and sprite.image.id ~= self.imageCycle[1] then
			self:UpdateSlide()
		end

		return
	end

	local frame = getGameData()
	local user = frame:getPlayerByName(self.username)
	if not user then return end

	if user.rightThrusterActive then
		if not self.justCycled then
			self:DoCycle(1)
			self.justCycled = true
		end
	elseif user.leftThrusterActive then
		if not self.justCycled then
			self:DoCycle(-1)
			self.justCycled = true
		end
	else
		self.justCycled = false
	end
end

return Presenter