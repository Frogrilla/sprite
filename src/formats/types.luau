export type Image = {
	id : string,
	resolution : Vec2,

	Blit : (self: Image, transform: Transform) -> nil
}

export type Sprite = {
	id : string,
	image : Image,
	transform : Transform,

	Create : (image: Image) -> Sprite,
	DebugDraw : (self: Sprite, col: Vec3) -> nil,
	Blit : (self: Sprite) -> nil
}

export type Manager = {
	images : {Image},
	sprites : {Sprite},
	editing : boolean,
	log : string,
	spriteIndex : number,
	localEditing : boolean,
	scaleFactor : number,

	Create : () -> Manager,
	RenderAll : (self: Manager) -> nil,
	OnGui : (self: Manager) -> nil,
	Tick : (self: Manager) -> nil
}

return nil