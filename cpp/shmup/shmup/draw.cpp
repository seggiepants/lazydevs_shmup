#include <raylib.h>
#include "common.h"
#include "draw.h"
#include "game.h"

static float pal[] = {
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

static float palRedAlien[] = {
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

void CenterPrint(std::string message, int y, int clr)
{
    Color c = Pal(clr);
    GameState* state = GameState::GetInstance();
    Vector2 textSize = MeasureTextEx(state->font, message.c_str(), TILE_SIZE, 1);
    int x = (SCREEN_W - textSize.x) / 2;
    DrawTextEx(state->font, message.c_str(), { static_cast<float>(x), static_cast<float>(y) }, TILE_SIZE, 1, c);
}

void PointPrint(std::string message, int x, int y, int clr)
{
    Color c = Pal(clr);
    GameState* state = GameState::GetInstance();
    Vector2 textSize = MeasureTextEx(state->font, message.c_str(), TILE_SIZE, 1);
    float posX = x - (textSize.x / 2);
    float posY = y - (textSize.y / 2);
    DrawTextEx(state->font, message.c_str(), { posX, posY }, TILE_SIZE, 1, c);
}

Color Pal(int idx)
{
    Color clr;
    int i = (idx) * 4;
    clr.r = pal[i] * 255; 
    clr.g = pal[i + 1] * 255; 
    clr.b = pal[i + 2] * 255; 
    clr.a = pal[i + 3] * 255;
    return clr;
}
