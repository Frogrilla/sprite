local Manager = require("manager")
local Presenter = require("Presenter")

local manager = Manager.Create()
local presenter = Presenter.Create(manager)

local speed = 1000
local gravityChaser = gravity.upRotation

if config.images then
	manager:LoadImages(config.images)
end

function onTransitionBegin(transitionInfo: Transition)
	camera.positionSmoothing = 0
	camera.rotationSmoothing = 0
	camera.fieldOfViewSmoothing = 0

	camera.position = transitionInfo.startPosition
	camera.fieldOfView = transitionInfo.startFieldOfView

	camera.rotation = transitionInfo.startRotation
	gravityChaser = gravity.upRotation
end

function onTransitionEnd(transitionInfo: Transition)
	camera.positionSmoothing = 0.1
	camera.rotationSmoothing = 0.1
end

function onGui()
	manager:OnGui()
	presenter:OnGui()
end

function tick(dt: number)

	local movement = Vec3.zeroVector
	if Input.getKey(Input.Key.W) then
		movement += Vec3.forwardVector
	end
	if Input.getKey(Input.Key.S) then
		movement -= Vec3.forwardVector
	end	
	if Input.getKey(Input.Key.D) then
		movement += Vec3.rightVector
	end	
	if Input.getKey(Input.Key.A) then
		movement -= Vec3.rightVector
	end
	if Input.getKey(Input.Key.E) then
		movement += Vec3.upVector
	end	
	if Input.getKey(Input.Key.Q) then
		movement -= Vec3.upVector
	end

	movement = movement:normalize()

	local lookInputTargetDelta = Vec3.zeroVector

	local rotEuler = (gravityChaser:inverse() * camera.rotation):euler()

	-- get rid of roll
	rotEuler.x *= math.exp(-16 * dt)

	-- Mouse
	local mouse = Input.getMouseDelta()
	if mouse and mouse.x then
		-- Yaw
		lookInputTargetDelta.z += mouse.x * 2
		-- Pitch
		lookInputTargetDelta.y += mouse.y * 2
	end

	if gravityChaser ~= gravity.upRotation and gravity.strength ~= 0 then
		local inputTotal = lookInputTargetDelta:length()
		local nextGravityChaser = Quat.slerp(gravityChaser, gravity.upRotation, inputTotal * 10 * dt)

		local nextRotation = nextGravityChaser:inverse()
			* Quat.fromXZ(camera.rotation:getForwardVector(), nextGravityChaser:rotateVector(Vec3.new(0, 0, 1)))
		rotEuler = nextRotation:euler() + Vec3.new(rotEuler.x, 0, 0) -- preserve existing roll
		gravityChaser = nextGravityChaser
	end

	rotEuler += lookInputTargetDelta
	camera.rotation = gravityChaser * Quat.fromEuler(rotEuler.x, rotEuler.y, rotEuler.z)

	camera.position += camera.rotation:rotateVector(movement) * speed * dt * (if Input.getKey(Input.Key.LeftShift) then 3 else 1)

	manager:Tick()
	presenter:Tick()
end