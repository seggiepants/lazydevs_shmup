#include <cmath>
#include <string>
#include "SceneStart.h"
#include "common.h"
#include "draw.h"
#include "game.h"

SceneStart::SceneStart() 
{
    peekerX = SCREEN_W / 2;
}

SceneStart::~SceneStart()
{
}

void SceneStart::Draw()
{
    const int titleSpr = 77;
    const int peekerSpr = 12;
    GameState* state = GameState::GetInstance();
    ClearBackground(Pal(0));
    state->starfield.Draw();
    Rectangle r = state->quads[titleSpr];
    float x = (SCREEN_W - r.width) / 2.0;
    float y = TILE_SIZE * 3;
    float delta = sin(GetTime() * 4);
    DrawTextureRec(state->texture, state->quads[peekerSpr], { peekerX, y + delta * (TILE_SIZE / 2) }, WHITE);
    if (delta > 0.75)
    {
        peekerX = x + (TILE_SIZE * 2) + (rand() % (static_cast<int>(r.width) - (TILE_SIZE * 3)));
    }
    DrawTextureRec(state->texture, state->quads[titleSpr], { x, y }, WHITE);
    DrawText("My", x + (TILE_SIZE / 2), y - TILE_SIZE, TILE_SIZE, Pal(3));
    state->highScore = 42000;
    if (state->highScore > 0)
    {
        CenterPrint("High Score:", 56, 12);
        CenterPrint(std::to_string(state->highScore), 64, 12);
    }

    CenterPrint("Press any key to start", 80, Blink());

    x = TILE_SIZE;
    y = 90;
#ifdef PLATFORM_WEB
    if (state->input.MouseMode == false) 
        y += 10;
#endif
    Color c = Pal(1);
    c.a = 128;
    DrawRectangle(x, y, SCREEN_W - (x * 2), SCREEN_H - y - TILE_SIZE, c);
    x = x + 2;
    y = y + 2;
    int clr = 13;
#ifdef PLATFORM_ANDROID 
        bool isPhone = false;
#else
        bool isPhone = false;
#endif
    if (state->input.MouseMode)
    {
        std::string message = "Ship follows Mouse";
        if (isPhone)
            message = "Ship follows Touch";
        Vector2 textSize = MeasureTextEx(state->font, message.c_str(), 8, 1);
        DrawTextEx(state->font, message.c_str(), { x, y }, 8, 1, Pal(clr));
        y += (textSize.y + 1);

        message = "Click/Touch to Shoot";
        textSize = MeasureTextEx(state->font, message.c_str(), 8, 1);
        DrawTextEx(state->font, message.c_str(), { x, y }, 8, 1, Pal(clr));
        y += (textSize.y + 1);

        message = "Double Click to Bomb";
        textSize = MeasureTextEx(state->font, message.c_str(), 8, 1);
        DrawTextEx(state->font, message.c_str(), { x, y }, 8, 1, Pal(clr));
        y += (textSize.y + 1);
    }
    else
    {
        std::string message = "Z or Space to Shoot";
        Vector2 textSize = MeasureTextEx(state->font, message.c_str(), 8, 1);
        DrawTextEx(state->font, message.c_str(), { x, y }, 8, 1, Pal(clr));
        y += (textSize.y + 1);

        message = "X or Tab for Bomb";
        textSize = MeasureTextEx(state->font, message.c_str(), 8, 1);
        DrawTextEx(state->font, message.c_str(), { x, y }, 8, 1, Pal(clr));
        y += (textSize.y + 1);
#ifndef PLATFORM_WEB
        message = "Escape to Exit";
        DrawTextEx(state->font, message.c_str(), { x, y }, 8, 1, Pal(clr));        
#endif
    }
    Vector2 textSize = MeasureTextEx(state->font, VERSION, 8, 1);
    x = SCREEN_W - textSize.x - 1;
    y = SCREEN_H - textSize.y;
    DrawTextEx(state->font, VERSION, { x, y }, 8, 1, Pal(1));
}

void SceneStart::Update(float dt)
{
    GameState* state = GameState::GetInstance();

    if (state->input.Btnp("a"))
    {
        state->StartGame();
    }
#ifndef PLATFORM_WEB
    if (state->input.Btnp("b"))
    {
        state->quit = true;
    }
#endif

	state->starfield.Update(dt, 0.5);    
}