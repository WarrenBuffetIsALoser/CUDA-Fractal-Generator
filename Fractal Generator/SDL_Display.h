#pragma once

#include <iostream>
#include <string>
#include "SDL2/SDL.h"

class Display
{
public:
	Display(int width, int height, const std::string& title);
	~Display();
	void Update();
	bool isClosed();
	void Clear(float r, float g, float b, float a);
	SDL_Window* m_window;
private:
	SDL_GLContext m_glContext;
	bool m_isClosed;
};