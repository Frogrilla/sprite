local Manager = require("manager")
local manager = Manager.Create()

local gravityChaser = gravity.upRotation
local speed = 1000
local roll = 0

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

function onGui()
	manager:OnGui()
end

function tick(dt: number)
	manager:Tick()

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

	-- Mouse
	local mouse = Input.getMouseDelta()
	if mouse and mouse.x then
		-- Yaw
		if Input.getKey(Input.Key.RightMouseButton) then
			roll += mouse.x / 2.0
		else
			lookInputTargetDelta.z += mouse.x * 2
			-- Pitch
			lookInputTargetDelta.y += mouse.y * 2
		end
	end

	if Input.getKeyUp(Input.Key.RightMouseButton) then
		if math.abs(roll) < 10 then roll = 0 end
	end

	gravityChaser = Quat.slerp(gravityChaser, gravity.upRotation, math.exp(-2*dt))

	camera.rotation *= Quat.fromEuler(0, lookInputTargetDelta.y, lookInputTargetDelta.z)
	local rot = (gravityChaser:inverse() * camera.rotation):euler()
	if manager.updateRoll then
		roll = rot.x
		manager.updateRoll = false
	end
	rot.x = roll + (rot.x-roll) * math.exp(-16 * dt)
	camera.rotation = gravityChaser * Quat.fromEuler(rot.x, rot.y, rot.z)
	camera.position += camera.rotation:rotateVector(movement) * speed * dt * (if Input.getKey(Input.Key.LeftShift) then 1.5 else 1)
end