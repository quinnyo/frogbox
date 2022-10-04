shader_type canvas_item;

uniform vec2 rest_axis = vec2(0.0, -1.0);
uniform float rest_length = 100.0;
//uniform vec2 tip_rest = vec2(0.0, -100.0);
uniform vec2 tip_position = vec2(0.0, -100.0);
uniform float flex_curve = 1.35;

/**
ease impl from Godot `Math::ease`
**/
float ease(float p_x, float p_c) {
	if (p_x < .0) {
		p_x = .0;
	} else if (p_x > 1.0) {
		p_x = 1.0;
	}
	if (p_c > .0) {
		if (p_c < 1.0) {
			return 1.0 - pow(1.0 - p_x, 1.0 / p_c);
		} else {
			return pow(p_x, p_c);
		}
	} else if (p_c < .0) {
		//inout ease
		if (p_x < 0.5) {
			return pow(p_x * 2.0, -p_c) * 0.5;
		} else {
			return (1.0 - pow(1.0 - (p_x - 0.5) * 2.0, -p_c)) * 0.5 + 0.5;
		}
	} else {
		return .0; // no ease (raw)
	}
}


vec2 bendy_line(const vec2 _a, const vec2 _b0, const vec2 _b1, const float _t, const float _flex_curve) {
	float flexion = ease(_t, _flex_curve);
	vec2 p = _a + mix(_b0 * _t, _b1 * _t, flexion);
	return p;
}

vec2 bendy_vert(vec2 _v, vec2 _rest, vec2 _target) {
	return _v;
}

float cross2(const vec2 _a, const vec2 _b) {
	return _a.x * _b.y - _a.y * _b.x;
}

float angle_to(const vec2 _a, vec2 _b) {
	return atan(cross2(_a, _b), dot(_a, _b));
}

vec2 rotated(const vec2 _v, const float _angle) {
	float s = sin(_angle);
	float c = cos(_angle);
	return vec2(_v.x * c - _v.y * s, _v.x * s + _v.y * c);
}

void vertex() {
	const vec2 tip_rest = rest_axis * rest_length;
	float full_stretch = length(tip_position) / rest_length;
	float full_angle = angle_to(tip_rest, tip_position);

	float t = dot(VERTEX, rest_axis) / rest_length;
	float flexion = ease(t, flex_curve);
	
	vec2 v1 = rotated(VERTEX, full_angle) * full_stretch;
	vec2 v = mix(VERTEX, v1, flexion);
	VERTEX = v;
}

void fragment() {
//	COLOR = texture(TEXTURE, UV);
}
