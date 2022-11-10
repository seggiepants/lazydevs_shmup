#include <iostream>
#include <raylib.h>
#include <rlgl.h>

#include "common.h"
#include "draw.h"
#include "game.h"
#include "Starfield.h" // remove later

const char* fragRecolor = R""""(
const int colors = 16;

// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;
varying vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Custom Variables
uniform vec4 Pal[colors]; // size of color palette (16 colors)
uniform vec4 Target[colors];

void main()
{
    vec4 pixel = texture2D(texture0, fragTexCoord);
    for (int i = 0; i < colors; i++)
    {
        if (pixel == Pal[i])
        {
            gl_FragColor = Target[i] * colDiffuse;
            return;
        }
    }
    gl_FragColor = pixel * colDiffuse;
    return;
}
)"""";

// Stolen / modified from https ://love2d.org/forums/viewtopic.php?t=84137
const char* fragAlpha = R""""(
// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;
varying vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Custom Variables
uniform float alpha;
void main() 
{
    vec4 c = texture2D(texture0, fragTexCoord);
    gl_FragColor =  vec4(c.r, c.g, c.b, c.a * alpha);
}
)"""";

const float pal[] = {
        0.0f, 0.0f, 0.0f, 1.0f
        , 29.0f / 255.0f, 43.0f / 255.0f, 83.0f / 255.0f, 1.0f
        , 126.0f / 255.0f, 37.0f / 255.0f, 83.0f / 255.0f, 1.0f
        , 0.0f, 135.0f / 255.0f, 81.0f / 255.0f, 1.0f
        , 171.0f / 255.0f, 82.0f / 255.0f, 54.0f / 255.0f, 1.0f
        , 95.0f / 255.0f, 87.0f / 255.0f, 79.0f / 255.0f, 1.0f
        , 194.0f / 255.0f, 195.0f / 255.0f, 199.0f / 255.0f, 1.0f
        , 1.0f, 241.0f / 255.0f, 232.0f / 255.0f, 1.0f
        , 1.0f, 0.0f, 77.0f / 255.0f, 1.0f
        , 1.0f, 163.0f / 255.0f, 0.0f, 1.0f
        , 1.0f, 236.0f / 255.0f, 39.0f / 255.0f, 1.0f
        , 0.0f, 228.0f / 255.0f, 54.0f / 255.0f, 1.0f
        , 41.0f / 255.0f, 173.0f / 255.0f, 1.0f, 1.0f
        , 131.0f / 255.0f, 118.0f / 255.0f, 156.0f / 255.0f, 1.0f
        , 1.0f, 119.0f / 255.0f, 168.0f / 255.0f, 1.0f
        , 1.0f, 204.0f / 255.0f, 170.0f / 255.0f, 1.0f
};

const float palRedAlien[] = {
        0.0f, 0.0f, 0.0f, 1.0f
        , 29.0f / 255.0f, 43.0f / 255.0f, 83.0f / 255.0f, 1.0f
        , 126.0f / 255.0f, 37.0f / 255.0f, 83.0f / 255.0f, 1.0f
        , 126.0f / 255.0f, 37.0f / 255.0f, 83.0f / 255.0f, 1.0f
        , 171.0f / 255.0f, 82.0f / 255.0f, 54.0f / 255.0f, 1.0f
        , 95.0f / 255.0f, 87.0f / 255.0f, 79.0f / 255.0f, 1.0f
        , 194.0f / 255.0f, 195.0f / 255.0f, 199.0f / 255.0f, 1.0f
        , 1.0f, 241.0f / 255.0f, 232.0f / 255.0f, 1.0f
        , 1.0f, 0.0f / 255.0f, 77.0f / 255.0f, 1.0f
        , 1.0f, 163.0f / 255.0f, 0.0f, 1.0f
        , 1.0f, 236.0f / 255.0f, 39.0f / 255.0f, 1.0f
        , 1.0f, 0.0f, 77.0f / 255.0f, 1.0f
        , 41.0f / 255.0f, 173.0f / 255.0f, 1.0f, 1.0f
        , 131.0f / 255.0f, 118.0f / 255.0f, 156.0f / 255.0f, 1.0f
        , 1.0f, 119.0f / 255.0f, 168.0f / 255.0f, 1.0f
        , 1.0f, 204.0f / 255.0f, 170.0f / 255.0f, 1.0f
};


int main(int argc, char** argv)
{
    const char* Title = "My Awesome Shmup";

    srand(time(NULL));

    InitWindow(static_cast<int>(SCREEN_W * SCREEN_SCALE), static_cast<int>(SCREEN_H * SCREEN_SCALE), Title);
    InitAudioDevice();    

    Shader shaderRecolor = LoadShaderFromMemory(NULL, fragRecolor);
    int indexPal = GetShaderLocation(shaderRecolor, "Pal");
    if (indexPal == -1)
    {
        std::cout << "Failure accessing Pal in Recolor Shader." << std::endl;
        return EXIT_FAILURE;
    }

    int indexTarget = GetShaderLocation(shaderRecolor, "Target");
    if (indexTarget == -1)
    {
        std::cout << "Failure accessing Target in Recolor Shader." << std::endl;
        return EXIT_FAILURE;
    }
    SetShaderValueV(shaderRecolor, indexPal, (const void*)pal, SHADER_UNIFORM_VEC4, COLORS_PER_PALETTE);
    SetShaderValueV(shaderRecolor, indexTarget, (const void*)palRedAlien, SHADER_UNIFORM_VEC4, COLORS_PER_PALETTE);

    Shader shaderAlpha = LoadShaderFromMemory(NULL, fragAlpha);

    int indexAlpha = GetShaderLocation(shaderAlpha, "alpha");
    if (indexAlpha == -1)
    {
        std::cout << "Failure accessing Alpha Shader." << std::endl;
        return EXIT_FAILURE;
    }
    float alphaAmt = 0.5f;

    SetShaderValue(shaderAlpha, indexAlpha, (const void*)&alphaAmt, SHADER_UNIFORM_FLOAT);

    Music introMusic = LoadMusicStream("audio/intro.xm");
    introMusic.looping = false;

    PlayMusicStream(introMusic);

    Sound laserSound = LoadSound("audio/laser.wav");
    SetSoundVolume(laserSound, 1.0);

    int boss = 74;
    int alien = 12;

    GameState* state = GameState::GetInstance();
    Json::Value jsonImg;
    if (!LoadJson("config/graphics.json", &jsonImg))
        return EXIT_FAILURE;

    Json::Value jsonLevel;
    if (!LoadJson("config/level.json", &jsonLevel))
        return EXIT_FAILURE;

    std::vector<Rectangle> quads;

    std::cout << jsonImg["quads"][2] << std::endl;
    for (auto it = std::begin(jsonImg["quads"]); it != std::end(jsonImg["quads"]); ++it)
    {
        Rectangle r;
        r.x = (*it)["x"].asFloat();
        r.y = (*it)["y"].asFloat();
        r.width = (*it)["w"].asFloat();
        r.height = (*it)["h"].asFloat();
        state->quads.push_back(r);
    }

    float x = (SCREEN_W - state->quads[boss].width) / 2.0f;
    float y = (SCREEN_H - state->quads[boss].height) / 2.0f;
    Vector2 position = { x, y };
    Starfield* starfield = new Starfield();
    SetTargetFPS(60);
    state->Shake = 22.0f;
    while (!WindowShouldClose())
    {
        UpdateMusicStream(introMusic);
        state->input.ReadInput();
        if (state->input.Btnp("escape"))
        {
            state->quit = true;
        }
        IncrementBlink();
        state->currentScene->Update(1 / 60);
        //starfield->Update(1.0, 1.0);
        //if (IsKeyPressed(KEY_SPACE)) PlaySoundMulti(laserSound);
        BeginDrawing();

        rlPushMatrix();
        rlScalef(SCREEN_SCALE, SCREEN_SCALE, 1.0);
        ScreenShake();
        state->currentScene->Draw();
        /*
        ClearBackground(BLACK);
        starfield->Draw();
        DrawLine(0, 0, static_cast<int>(SCREEN_W - 1.0), static_cast<int>(SCREEN_H - 1.0), WHITE);
        DrawLine(static_cast<int>(SCREEN_W - 1.0), 0, 0, static_cast<int>(SCREEN_H - 1.0), WHITE);
        DrawTextureRec(state->texture, state->quads[alien], { 32, 16 }, WHITE);

        BeginShaderMode(shaderRecolor);
        DrawTextureRec(state->texture, state->quads[alien], { 48, 16 }, WHITE);
        EndShaderMode();

        BeginShaderMode(shaderAlpha);
        DrawTextureRec(state->texture, state->quads[boss], position, WHITE);
        EndShaderMode();
        DrawTextureRec(state->texture, state->quads[boss], { position.x, position.y + 20 }, WHITE);
        DrawTextEx(state->font, "Score: 90", { 0.0, 0.0 }, 8, 1, GREEN);
        */
        
        rlPopMatrix();
        EndDrawing();
    }
    // Cleanup
    UnloadShader(shaderRecolor);
    UnloadShader(shaderAlpha);
    UnloadMusicStream(introMusic);
    CloseAudioDevice();
    CloseWindow();
    quads.clear();
    delete starfield;
    return 0;
}
