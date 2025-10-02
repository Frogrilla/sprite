local Utils = {}

function Utils.ApplyTransformation(vector: Vec3, transformation: Transform): Vec3
	return transformation.position + 
		transformation.rotation:rotateVector(
			Vec3.new(vector.x * transformation.scale.x, vector.y * transformation.scale.y, vector.z * transformation.scale.z)
		) 
end

function Utils.CorrectGamma(x: number): number
	if x <= 0.04045 then
		return x / 12.92
	else
		return math.pow(((x + 0.055)/1.055),2.4)
	end
end

function Utils.LinearColorFromSRGB(r: number, g: number, b: number, a: number): LinearColor
	return LinearColor.new(
		Utils.CorrectGamma(r/255),
		Utils.CorrectGamma(g/255),
		Utils.CorrectGamma(b/255),
		(a/255)
	)
end

return Utils