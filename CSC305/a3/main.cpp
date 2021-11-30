#include "assignment.hpp"

// ===---------------TRIANGLE-----------------===

Triangle::Triangle()
{
    // allocate the memory to hold the program and shader data
    mProgramHandle = glCreateProgram();
    mVertHandle = glCreateShader(GL_VERTEX_SHADER);
    mFragHandle = glCreateShader(GL_FRAGMENT_SHADER);
}

void Triangle::loadShaders()
{
    std::string shaderRoot{ ShaderPath };
    vertexSource =
        glx::readShaderSource(shaderRoot + "triangle.vert", IncludeDir);
    fragmentSource =
        glx::readShaderSource(shaderRoot + "triangle.frag", IncludeDir);

    if (auto result{ glx::compileShader(vertexSource.sourceString, mVertHandle) };
        result)
    {
        throw OpenGLError(*result);
    }
    if (auto result =
        glx::compileShader(fragmentSource.sourceString, mFragHandle);
        result)
    {
        throw OpenGLError(*result);
    }

    // communicate to OpenGL the shaders used to render the Triangle
    glAttachShader(mProgramHandle, mVertHandle);
    glAttachShader(mProgramHandle, mFragHandle);

    if (auto result = glx::linkShaders(mProgramHandle); result)
    {
        throw OpenGLError(*result);
    }
    setupUniformVariables();
}

void Triangle::loadDataToGPU(std::array<float, 324> const& vertices)
{
    // create buffer to hold triangle vertex data
    glCreateBuffers(1, &mVbo);
    // allocate and initialize buffer to vertex data
    glNamedBufferStorage(
        mVbo, glx::size<float>(vertices.size()), vertices.data(), 0);

    // create holder for all buffers
    glCreateVertexArrays(1, &mVao);
    // bind vertex buffer to the vertex array
    glVertexArrayVertexBuffer(mVao, 0, mVbo, 0, glx::stride<float>(6));

    // enable attributes for the two components of a vertex
    glEnableVertexArrayAttrib(mVao, 0);
    glEnableVertexArrayAttrib(mVao, 1);

    // specify to OpenGL how the vertices and colors are laid out in the buffer
    glVertexArrayAttribFormat(
        mVao, 0, 3, GL_FLOAT, GL_FALSE, glx::relativeOffset<float>(0));
    glVertexArrayAttribFormat(
        mVao, 1, 3, GL_FLOAT, GL_FALSE, glx::relativeOffset<float>(3));

    // associate the vertex attributes (coordinates and color) to the vertex
    // attribute
    glVertexArrayAttribBinding(mVao, 0, 0);
    glVertexArrayAttribBinding(mVao, 1, 0);
}

void Triangle::reloadShaders()
{
    if (glx::shouldShaderBeReloaded(vertexSource))
    {
        glx::reloadShader(
            mProgramHandle, mVertHandle, vertexSource, IncludeDir);
    }

    if (glx::shouldShaderBeReloaded(fragmentSource))
    {
        glx::reloadShader(
            mProgramHandle, mFragHandle, fragmentSource, IncludeDir);
    }
}

void Triangle::render([[maybe_unused]] bool paused,
    [[maybe_unused]] int width,
    [[maybe_unused]] int height)
{

    if (!paused)
    {
        position = static_cast<float>(glfwGetTime()) * 64.0f;
    }

    auto modelMat{ glm::rotate(
        math::Matrix4{0.1f},
        glm::radians(position),
        math::Vector{0.0f,1.0f,0.0f}) };

    auto viewMat{ glm::lookAt(
        glm::vec3{1.0f,0.75f,5.0f},
        glm::vec3{1.0f,-1.0f,-1.0f},
        glm::vec3{0.0f,1.0f,-0.5f}) };

    auto projMat{ glm::perspective(
            glm::radians(90.0f),
            static_cast<float>(width) / height,
            nearVal,
            farVal) };

    reloadShaders();

    // tell OpenGL which program object to use to render the Triangle
    glUseProgram(mProgramHandle);

    glUniformMatrix4fv(mUniformModelLoc, 1, GL_FALSE, glm::value_ptr(modelMat));
    glUniformMatrix4fv(mUniformViewLoc, 1, GL_FALSE, glm::value_ptr(viewMat));
    glUniformMatrix4fv(mUniformProjectionLoc, 1, GL_FALSE, glm::value_ptr(projMat));

    // tell OpenGL which vertex array object to use to render the Triangle
    glBindVertexArray(mVao);
    // actually render the Triangle
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

void Triangle::freeGPUData()
{
    // unwind all the allocations made
    glDeleteVertexArrays(1, &mVao);
    glDeleteBuffers(1, &mVbo);
    glDeleteShader(mFragHandle);
    glDeleteShader(mVertHandle);
    glDeleteProgram(mProgramHandle);
}

void Triangle::setupUniformVariables()
{
    mUniformModelLoc = glGetUniformLocation(mProgramHandle, "model");
    mUniformViewLoc = glGetUniformLocation(mProgramHandle, "view");
    mUniformProjectionLoc = glGetUniformLocation(mProgramHandle, "projection");


}

struct PointLight {
	glm::vec3 position;
	glm::vec3 intensities; //a.k.a. the color of the light
};

// ===------------IMPLEMENTATIONS-------------===

Program::Program(int width, int height, std::string title) :
    settings{}, callbacks{}, paused{}, mWindow{ nullptr }
{
    settings.size.width = width;
    settings.size.height = height;
    settings.title = title;

    if (!glx::initializeGLFW(errorCallback))
    {
        throw OpenGLError("Failed to initialize GLFW with error callback");
    }

    mWindow = glx::createGLFWWindow(settings);
    if (mWindow == nullptr)
    {
        throw OpenGLError("Failed to create GLFW Window");
    }

    callbacks.keyPressCallback = [&](int key, int, int action, int)
    {
        if (key == GLFW_KEY_SPACE && action == GLFW_RELEASE)
        {
            paused = !paused;
        }

    };

    createGLContext();
}

void Program::run(Triangle& tri)
{
    glEnable(GL_DEPTH_TEST);

    while (!glfwWindowShouldClose(mWindow))
    {
        int width;
        int height;

        glfwGetFramebufferSize(mWindow, &width, &height);
        // setup the view to be the window's size
        glViewport(0, 0, width, height);
        // tell OpenGL the what color to clear the screen to
        glClearColor(0, 0, 0, 1);
        // actually clear the screen
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        tri.render(paused, width, height);

        glfwSwapBuffers(mWindow);
        glfwPollEvents();
    }
}

void Program::freeGPUData()
{
    glx::destroyGLFWWindow(mWindow);
    glx::terminateGLFW();
}

void Program::createGLContext()
{
    using namespace magic_enum::bitwise_operators;

    glx::bindWindowCallbacks(mWindow, callbacks);
    glfwMakeContextCurrent(mWindow);
    glfwSwapInterval(1);

    if (!glx::createGLContext(mWindow, settings.version))
    {
        throw OpenGLError("Failed to create OpenGL context");
    }

    glx::initializeGLCallback(glx::ErrorSource::All,
        glx::ErrorType::All,
        glx::ErrorSeverity::High |
        glx::ErrorSeverity::Medium);
}

// ===-----------------DRIVER-----------------===

int main()
{
	try
	{
		// clang-format off
		std::array<float, 324> vertices
		{
			//  X     Y     Z       U     V          Normal
					// bottom
					-1.0f,-1.0f,-1.0f,   1.0f,0.0f, 0.0f,   0.0f, -1.0f, 0.0f,
					 1.0f,-1.0f,-1.0f,  1.0f,0.0f, 0.0f,	0.0f, -1.0f, 0.0f,
					-1.0f,-1.0f, 1.0f,  1.0f,0.0f, 0.0f,   0.0f, -1.0f, 0.0f,
					 1.0f,-1.0f,-1.0f,   1.0f,0.0f, 0.0f,   0.0f, -1.0f, 0.0f,
					 1.0f,-1.0f, 1.0f,   1.0f,0.0f, 0.0f,   0.0f, -1.0f, 0.0f,
					-1.0f,-1.0f, 1.0f,  1.0f,0.0f, 0.0f,   0.0f, -1.0f, 0.0f,

					// top
					-1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   0.0f, 1.0f, 0.0f,
					-1.0f, 1.0f, 1.0f,   1.0f,0.0f, 0.0f,   0.0f, 1.0f, 0.0f,
					 1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   0.0f, 1.0f, 0.0f,
					 1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   0.0f, 1.0f, 0.0f,
					-1.0f, 1.0f, 1.0f,   1.0f,0.0f, 0.0f,  0.0f, 1.0f, 0.0f,
					 1.0f, 1.0f, 1.0f,   1.0f,0.0f, 0.0f,   0.0f, 1.0f, 0.0f,

					 // front
					 -1.0f,-1.0f, 1.0f,   1.0f,0.0f, 0.0f,   0.0f, 0.0f, 1.0f,
					  1.0f,-1.0f, 1.0f,  1.0f,0.0f, 0.0f,   0.0f, 0.0f, 1.0f,
					 -1.0f, 1.0f, 1.0f,  1.0f,0.0f, 0.0f,   0.0f, 0.0f, 1.0f,
					  1.0f,-1.0f, 1.0f,  1.0f,0.0f, 0.0f,  0.0f, 0.0f, 1.0f,
					  1.0f, 1.0f, 1.0f,   1.0f,0.0f, 0.0f,   0.0f, 0.0f, 1.0f,
					 -1.0f, 1.0f, 1.0f,  1.0f,0.0f, 0.0f,   0.0f, 0.0f, 1.0f,

					 // back
					 -1.0f,-1.0f,-1.0f,   1.0f,0.0f, 0.0f,   0.0f, 0.0f, -1.0f,
					 -1.0f, 1.0f,-1.0f,  1.0f,0.0f, 0.0f,   0.0f, 0.0f, -1.0f,
					  1.0f,-1.0f,-1.0f,  1.0f,0.0f, 0.0f,   0.0f, 0.0f, -1.0f,
					  1.0f,-1.0f,-1.0f,  1.0f,0.0f, 0.0f,   0.0f, 0.0f, -1.0f,
					 -1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   0.0f, 0.0f, -1.0f,
					  1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,  0.0f, 0.0f, -1.0f,

					  // left
					  -1.0f,-1.0f, 1.0f,   1.0f,0.0f, 0.0f,   -1.0f, 0.0f, 0.0f,
					  -1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   -1.0f, 0.0f, 0.0f,
					  -1.0f,-1.0f,-1.0f,  1.0f,0.0f, 0.0f,   -1.0f, 0.0f, 0.0f,
					  -1.0f,-1.0f, 1.0f,   1.0f,0.0f, 0.0f,   -1.0f, 0.0f, 0.0f,
					  -1.0f, 1.0f, 1.0f,   1.0f,0.0f, 0.0f,   -1.0f, 0.0f, 0.0f,
					  -1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   -1.0f, 0.0f, 0.0f,

					  // right
					   1.0f,-1.0f, 1.0f,   1.0f,0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
					   1.0f,-1.0f,-1.0f,   1.0f,0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
					   1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
					   1.0f,-1.0f, 1.0f,   1.0f,0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
					   1.0f, 1.0f,-1.0f,   1.0f,0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
					   1.0f, 1.0f, 1.0f,  1.0f,0.0f, 0.0f,   1.0f, 0.0f, 0.0f,
		};
		// clang-format on

		Program prog{ 1280, 720, "CSC305 Lab 6" };
		Triangle tri{};

		tri.loadShaders();
		tri.loadDataToGPU(vertices);

		prog.run(tri);

		prog.freeGPUData();
		tri.freeGPUData();
	}
    catch (OpenGLError & err)
    {
        fmt::print("OpenGL Error:\n\t{}\n", err.what());
    }

    return 0;
}
