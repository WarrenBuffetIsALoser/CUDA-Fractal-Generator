// CUDA
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

// OPEN_GL
#include <OPEN_GL/glew.h>

// SDL2
#include <SDL2/SDL.h>

#include "SDL_Display.h"
#include "shader.h"
#include <stdio.h>

int WIDTH = 500;
int HEIGHT = 500;

float *texData;
int main() {
	Display display(WIDTH, HEIGHT, "Fractal Generator");

	Shader shader("./res/");
	shader.Bind();

	float verticies[] = {
		-1.0f, -1.0f,	0.0f, 1.0f,
		 1.0f, -1.0f,	1.0f, 1.0f,
		 1.0f,  1.0f,	1.0f, 0.0f,
		-1.0f,  1.0f,   0.0f, 0.0f
	};

	unsigned int indicies[] {
		0, 1, 2,
		2, 3, 0
	};

	texData = (float*)malloc(sizeof(float)*(WIDTH*HEIGHT * 3));

	for (int i = 0; i < WIDTH*HEIGHT; i++) {
		texData[i * 3] = 0.0f;
		texData[i * 3 + 1] = 1.0f;
		texData[i * 3 + 2] = 0.7f;
	}

	for (int i = 0; i < 1000; i++) {
		texData[i * 3] = 1.0f;
		texData[i * 3 + 1] = 0.0f;
		texData[i * 3 + 2] = 0.0f;
	}

	unsigned int buffer;
	glGenBuffers(1, &buffer);
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(verticies), verticies, GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 4, (void*)0);

	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 4, (void*)8);

	unsigned int i_buffer;
	glGenBuffers(1, &i_buffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, i_buffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indicies), indicies, GL_STATIC_DRAW);

	unsigned int texture;
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, WIDTH, HEIGHT, 0, GL_RGB, GL_FLOAT, texData);

	
	while (!display.isClosed()) {
		//glDrawArrays(GL_TRIANGLES, 0, 3);
		glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
		display.Update();
	}

	return 0;
}