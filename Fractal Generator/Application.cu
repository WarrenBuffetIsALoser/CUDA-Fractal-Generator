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

typedef struct {
	double r;       // a fraction between 0 and 1
	double g;       // a fraction between 0 and 1
	double b;       // a fraction between 0 and 1
} rgb;

typedef struct {
	double h;       // angle in degrees
	double s;       // a fraction between 0 and 1
	double v;       // a fraction between 0 and 1
} hsv;

static hsv   rgb2hsv(rgb in);
static rgb   hsv2rgb(hsv in);

hsv rgb2hsv(rgb in)
{
	hsv         out;
	double      min, max, delta;

	min = in.r < in.g ? in.r : in.g;
	min = min < in.b ? min : in.b;

	max = in.r > in.g ? in.r : in.g;
	max = max > in.b ? max : in.b;

	out.v = max;                                // v
	delta = max - min;
	if (delta < 0.00001)
	{
		out.s = 0;
		out.h = 0; // undefined, maybe nan?
		return out;
	}
	if (max > 0.0) { // NOTE: if Max is == 0, this divide would cause a crash
		out.s = (delta / max);                  // s
	}
	else {
		// if max is 0, then r = g = b = 0              
		// s = 0, h is undefined
		out.s = 0.0;
		out.h = NAN;                            // its now undefined
		return out;
	}
	if (in.r >= max)                           // > is bogus, just keeps compilor happy
		out.h = (in.g - in.b) / delta;        // between yellow & magenta
	else
		if (in.g >= max)
			out.h = 2.0 + (in.b - in.r) / delta;  // between cyan & yellow
		else
			out.h = 4.0 + (in.r - in.g) / delta;  // between magenta & cyan

	out.h *= 60.0;                              // degrees

	if (out.h < 0.0)
		out.h += 360.0;

	return out;
}

rgb hsv2rgb(hsv in)
{
	double      hh, p, q, t, ff;
	long        i;
	rgb         out;

	if (in.s <= 0.0) {       // < is bogus, just shuts up warnings
		out.r = in.v;
		out.g = in.v;
		out.b = in.v;
		return out;
	}
	hh = in.h;
	if (hh >= 360.0) hh = 0.0;
	hh /= 60.0;
	i = (long)hh;
	ff = hh - i;
	p = in.v * (1.0 - in.s);
	q = in.v * (1.0 - (in.s * ff));
	t = in.v * (1.0 - (in.s * (1.0 - ff)));

	switch (i) {
	case 0:
		out.r = in.v;
		out.g = t;
		out.b = p;
		break;
	case 1:
		out.r = q;
		out.g = in.v;
		out.b = p;
		break;
	case 2:
		out.r = p;
		out.g = in.v;
		out.b = t;
		break;

	case 3:
		out.r = p;
		out.g = q;
		out.b = in.v;
		break;
	case 4:
		out.r = t;
		out.g = p;
		out.b = in.v;
		break;
	case 5:
	default:
		out.r = in.v;
		out.g = p;
		out.b = q;
		break;
	}
	return out;
}

int WIDTH = 2000;
int HEIGHT = 2000;

double maxIterations = 100;

double min_valx = -2;
double max_valx = 2;

double min_valy = -2;
double max_valy = 2;

float *texData;

double map(double x, double in_min, double in_max, double out_min, double out_max)
{
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

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

	for (int x = 0; x < WIDTH; x++) {
		for (int y = 0; y < HEIGHT; y++) {
			double a = map(x, 0, WIDTH, min_valx, max_valx);
			double b = map(y, 0, HEIGHT, min_valy, max_valy);

			double ca = a;
			double cb = b;
			double n = 0;
			while (n < maxIterations) {
				double aa = a * a - b * b;
				double bb = 2 * a * b;

				a = aa + ca;
				b = bb + cb;
				if (a*a + b*b > 4) {
					break;
				}
				n++;
			}
			double col = map(n, 0, maxIterations, 0, 1);
			col = map(sqrt(col), 0, 1, 0, 360);
			hsv color1;
			color1.h = col;
			color1.s = 1;
			color1.v = n == maxIterations ? 0 : 1;

			rgb color2;
			color2 = hsv2rgb(color1);
			texData[(x + (y*WIDTH)) * 3 + 0] = (float)color2.r;
			texData[(x + (y*WIDTH)) * 3 + 1] = (float)color2.g;
			texData[(x + (y*WIDTH)) * 3 + 2] = (float)color2.b;
		}
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
		glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
		display.Update();
	}

	return 0;
}