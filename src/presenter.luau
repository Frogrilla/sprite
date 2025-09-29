local types = require("types")

export type Presenter = {
	manager : types.Manager,
	username : string,
	spriteIndex : number,
	cycleIndex : number,
	imageCycle : {types.Image},
	justCycled : boolean,

	Create : () -> Presenter,
	OnGui : (self: Presenter) -> nil,
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
		Gui.text(sprite.id)

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
				if Gui.selectable(image.id, self.cycleIndex == i) then
					table.remove(self.imageCycle, i)
					if i == self.cycleIndex then
						self.cycleIndex = 0
					end
					i -= 1
				end
			end

			Gui.endListBox()
		end

		if Gui.button("Step Backward") then
			self:DoCycle(-1)
		end

		if Gui.button("Step Forward") then
			self:DoCycle(1)
		end

		Gui.unindent()
	end
end

function Presenter.DoCycle(self: Presenter, offset: number)
	self.cycleIndex += offset;
	if self.cycleIndex > #self.imageCycle then
		self.cycleIndex = 1;
	elseif self.cycleIndex == 0 then
		self.cycleIndex = #self.imageCycle
	end

	local sprite = self.manager.sprites[self.spriteIndex]
	local image = self.imageCycle[self.cycleIndex]

	sprite.transform.scale.y *= image.resolution.x / sprite.image.resolution.x
	sprite.transform.scale.z *= image.resolution.y / sprite.image.resolution.y
	sprite.image = image

	self.manager:RenderAll()
end

function Presenter.Tick(self: Presenter)
	local frame = getGameData()
	local user = frame:getPlayerByName(self.username)
	if not user then return end

	if user.rightThrusterActive then
		if not self.justCycled then
			self:DoCycle(1)
		end
	elseif user.leftThrusterActive then
		if not self.justCycled then
			self:DoCycle(-1)
		end
	else
		self.justCycled = false
	end
end

return Presenter