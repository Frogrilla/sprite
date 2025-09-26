local Manager = require("manager")
local manager = Manager.Create()

if config.images then
	manager:LoadImages(config.images)
end

function onTransitionBegin(transitionInfo: Transition)
	camera.positionSmoothing = 0
	camera.rotationSmoothing = 0
	camera.fieldOfViewSmoothing = 0

	camera.position = transitionInfo.startPosition
	camera.rotation = transitionInfo.startRotation
	camera.fieldOfView = transitionInfo.startFieldOfView
end

function onGui()
	manager:OnGui()
end

function tick(dt: number)
	manager:Tick()
end