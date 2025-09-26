local Utils = {}

function Utils.ApplyTransformation(vector: Vec3, transformation: Transform): Vec3
	return transformation.position + 
		transformation.rotation:rotateVector(
			Vec3.new(vector.x * transformation.scale.x, vector.y * transformation.scale.y, vector.z * transformation.scale.z)
		) 
end

return Utils