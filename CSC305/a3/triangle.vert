#version 450 core

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 colour;
layout(location = 2) in vec3 normal;

out vec3 fragVert;

out vec2 fragTexCoord;

out vec3 fragNormal;


void main()
{
    // Pass some variables to the fragment shader

    fragTexCoord = vertTexCoord;

    fragNormal = vertNormal;

    fragVert = vert;


}
