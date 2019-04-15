#pragma once

#include <string>
#include <OPEN_GL/glew.h>

class Shader
{
	public:
		Shader(const std::string& fileName);

		void Bind();

		~Shader();
	private:
		std::string loadShader(const std::string& fileName);
		void CheckShaderError(GLuint shader, GLuint flag, bool isProgram, const std::string& errorMessage);
		GLuint createShader(const std::string& text, GLenum shaderType);

		static const unsigned int NUM_SHADERS = 2;

		GLuint m_program;
		GLuint m_shaders[NUM_SHADERS];
};

