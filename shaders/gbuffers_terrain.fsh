#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform int frameCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

vec3 RGBtoHSV(float r, float g, float b) {
	float max = r > g ? r : g;
	max = max > b ? max : b;
	float min = r < g ? r : g;
	min = min < b ? min : b;
	float h = max - min;
	if (h > 0.0f) {
		if (max == r) {
			h = (g - b) / h;
			if (h < 0.0f) {
				h += 6.0f;
			}
		} else if (max == g) {
			h = 2.0f + (b - r) / h;
		} else {
			h = 4.0f + (r - g) / h;
		}
	}
	h /= 6.0f;
	float s = (max - min);
	if (max != 0.0f)
	s /= max;
	float v = max;
	return vec3(h , s , v);
}

vec3 HSVtoRGB(float h, float s, float v) {
	float r = v;
	float g = v;
	float b = v;
	if (s > 0.0f) {
		h *= 6.0f;
		int i = int(h);
		float f = h - i;
		switch (i) {
			default:
			case 0:
			g *= 1 - s * (1 - f);
			b *= 1 - s;
			break;
			case 1:
			r *= 1 - s * f;
			b *= 1 - s;
			break;
			case 2:
			r *= 1 - s;
			b *= 1 - s * (1 - f);
			break;
			case 3:
			r *= 1 - s;
			g *= 1 - s * f;
			break;
			case 4:
			r *= 1 - s * (1 - f);
			g *= 1 - s;
			break;
			case 5:
			g *= 1 - s;
			b *= 1 - s * f;
			break;
		}
	}
	return vec3(r , g , b);
}

void main() {
	vec4 diffuse = texture2D(texture, texcoord) * glcolor;
	diffuse *= texture2D(lightmap, lmcoord);
	vec3 def = diffuse.rgb;
	vec3 def_hsv = HSVtoRGB(def.x, def.y, def.z);
	float s = def_hsv.y;
	diffuse.rgb = HSVtoRGB(mod(frameCounter, 500) / 500, s, 1);
	gl_FragData[0] = diffuse;
}