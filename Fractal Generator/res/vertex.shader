#version 330 core

in vec2 position;
in vec2 aTexCoord;

out vec2 TexCoord;

void main() {
	float y = position.y;
	float x = position.x;
	gl_Position = vec4(x, y, 1.0, 1.0);

	TexCoord = aTexCoord;
}	