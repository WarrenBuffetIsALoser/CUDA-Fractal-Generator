#include <iostream>
#include "SDL_Display.h"
#include <OPEN_GL/glew.h>
#include <SDL2/SDL.h>

Display::Display(int width, int height, const std::string& title)
{
	SDL_Init(SDL_INIT_EVERYTHING);

	SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 32);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

	m_window = SDL_CreateWindow(title.c_str(), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_OPENGL);
	m_glContext = SDL_GL_CreateContext(m_window);

	SDL_SetWindowResizable(m_window, SDL_TRUE);
	GLenum status = glewInit();
	if (status != GLEW_OK) {
		std::cerr << "Failed to initialize glew" << std::endl;
	}
	m_isClosed = false;
	needToDraw = true;
}

Display::~Display()
{
	SDL_GL_DeleteContext(m_glContext);
	SDL_DestroyWindow(m_window);
	SDL_Quit();
}

void Display::Update() {
	SDL_GL_SwapWindow(m_window);

	SDL_Event e;
	while (SDL_PollEvent(&e)) {
		if (e.type == SDL_QUIT) {
			m_isClosed = true;
		}
		else if (e.type == SDL_WINDOWEVENT && e.window.event == SDL_WINDOWEVENT_RESIZED) {
			glViewport(0, 0, e.window.data1, e.window.data2);
		}
		
		if (e.type == SDL_MOUSEWHEEL) {
			setWheel(e.wheel.y);
			needToDraw = true;
		}
		else {
			setWheel(0);
		}
	}
}

bool Display::isClosed() {
	return m_isClosed;
}

void Display::setWheel(signed int val) {
	wheel = val;
}

signed int Display::getWheel() {
	return wheel;
}

void Display::Clear(float r, float g, float b, float a) {
	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT);
}