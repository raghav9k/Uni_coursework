#include <atlas/glx/Buffer.hpp>
#include <atlas/glx/Context.hpp>
#include <atlas/glx/ErrorCallback.hpp>
#include <atlas/glx/GLSL.hpp>
#include <atlas/gui/GUI.hpp>

#include <fmt/printf.h>
#include <magic_enum.hpp>

#include <array>

using namespace atlas;

// For the sake of simplicity, define the shader code here.
constexpr auto vertexSource =
    R"(#version 450 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 colour;

out vec3 vertexColour;

void main()
{
    gl_Position = vec4(position, 1.0);
    vertexColour = colour;
}
)";

constexpr auto fragmentSource =
    R"(#version 450 core

in vec3 vertexColour;

out vec4 fragColour;

void main()
{
    fragColour = vec4(vertexColour, 1.0);
}
)";

// We need to define an error callback function for GLFW, so we do that
// here.
void errorCallback(int code, char const* message)
{
    fmt::print("error ({}):{}\n", code, message);
}

int main()
{
    // First, lets create all of the structs that we're going to need.
    glx::WindowSettings settings;
    glx::WindowCallbacks callbacks;

    gui::GuiRenderData guiRenderData;
    gui::GuiWindowData guiWindowData;

    // Set our window settings first.
    {
        settings.size.width  = 1280;
        settings.size.height = 720;
        settings.title       = "Hello Triangle";
    }

    // Now, let's make the window callbacks.
    {
        auto mousePressCallback =
            [&guiWindowData](int button, int action, int mode, double, double) {
                gui::mousePressedCallback(guiWindowData, button, action, mode);
            };

        auto mouseScrollCallback = [](double xOffset, double yOffset) {
            gui::mouseScrollCallback(xOffset, yOffset);
        };

        auto keyPressCallback =
            [](int key, int scancode, int action, int mods) {
                gui::keyPressCallback(key, scancode, action, mods);
            };

        auto charCallback = [](unsigned int codepoint) {
            gui::charCallback(codepoint);
        };

        callbacks.mousePressCallback  = mousePressCallback;
        callbacks.mouseScrollCallback = mouseScrollCallback;
        callbacks.keyPressCallback    = keyPressCallback;
        callbacks.charCallback        = charCallback;
    }

    // We're ready to start initializing things. So start with GLFW and OpenGL.
    GLFWwindow* window;
    {
        glx::initializeGLFW(errorCallback);

        // Next comes the window.
        window = createGLFWWindow(settings);

        // Bind the callbacks.
        glx::bindWindowCallbacks(window, callbacks);

        // Now bind the context.
        glfwMakeContextCurrent(window);
        glfwSwapInterval(1);

        // Create the OpenGL context.
        glx::createGLContext(window, settings.version);

        // Set the error callback.
        using namespace magic_enum::bitwise_operators;
        glx::initializeGLCallback(glx::ErrorSource::All,
                                  glx::ErrorType::All,
                                  glx::ErrorSeverity::High |
                                      glx::ErrorSeverity::Medium);
    }

    // We have a window and a GL context, so now initialize the GUI.
    {
        ImGui::CreateContext();
        ImGui::StyleColorsDark();

        // Initialize the GUI structs. Remember to set the window!
        gui::initializeGuiWindowData(guiWindowData);
        gui::initializeGuiRenderData(guiRenderData);
        setGuiWindow(guiWindowData, window);
    }

    // We want to draw a triangle on the screen, so let's setup all of the
    // OpenGL variables next. Start with the shaders.
    GLuint vertexShader{0};
    GLuint fragmentShader{0};
    GLuint shaderProgram{0};
    {
        // Let's setup our shaders first. Create the program and the shaders.
        shaderProgram  = glCreateProgram();
        vertexShader   = glCreateShader(GL_VERTEX_SHADER);
        fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);

        // Now compile both the shaders.
        if (auto res = glx::compileShader(vertexSource, vertexShader); res)
        {
            fmt::print("error: {}\n", res.value());
            return 0;
        }

        if (auto res = glx::compileShader(fragmentSource, fragmentShader); res)
        {
            fmt::print("error: {}\n", res.value());
            return 0;
        }

        // Attach the shaders.
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);

        // Now link the shaders.
        if (auto res = glx::linkShaders(shaderProgram); res)
        {
            fmt::print("error: {}\n", res.value());
            return 0;
        }
    }

    // Now let's setup the data and buffers for our triangle.
    GLuint vbo;
    GLuint vao;
    {
        // clang-format off
        std::array<float, 18> vertices = 
        {
            0.5f, -0.5f, 0.0f,   1.0f, 0.0f, 0.0f,
           -0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,
            0.0f,  0.5f, 0.0f,   0.0f, 0.0f, 1.0f
        };
        // clang-format on

        glCreateVertexArrays(1, &vao);
        glCreateBuffers(1, &vbo);
        glNamedBufferStorage(
            vbo, glx::size<float>(vertices.size()), vertices.data(), 0);

        glBindVertexArray(vao);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glVertexAttribPointer(0,
                              3,
                              GL_FLOAT,
                              FALSE,
                              glx::stride<float>(6),
                              glx::bufferOffset<float>(0));
        glVertexAttribPointer(1,
                              3,
                              GL_FLOAT,
                              FALSE,
                              glx::stride<float>(6),
                              glx::bufferOffset<float>(3));
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
    }

    // Now we are ready for our main loop.
    while (!glfwWindowShouldClose(window))
    {
        int width, height;
        glfwGetFramebufferSize(window, &width, &height);
        glViewport(0, 0, width, height);
        glClearColor(0, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUseProgram(shaderProgram);
        glBindVertexArray(vao);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        // Now draw the GUI elements.
        gui::newFrame(guiWindowData);
        ImGui::Begin("HUD");
        ImGui::Text("Application average %.3f ms/frame (%.1f FPS)",
                    1000.0f / ImGui::GetIO().Framerate,
                    ImGui::GetIO().Framerate);
        ImGui::End();

        // Render the GUI.
        ImGui::Render();
        gui::endFrame(guiWindowData, guiRenderData);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // Clean up our resources.
    gui::destroyGuiRenderData(guiRenderData);
    gui::destroyGuiWindow(guiWindowData);
    ImGui::DestroyContext();

    glx::destroyGLFWWindow(window);
    glx::terminateGLFW();

    return 0;
}
