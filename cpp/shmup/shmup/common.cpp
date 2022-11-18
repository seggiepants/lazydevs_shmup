#include <cstdlib>
#include <fstream>
#include <iostream>
#include <raylib.h>
#include <rlgl.h>
#include <json/json.h>
#include "game.h"

const int blinkAni[] = { 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 7, 7, 6, 6, 5, 5 };

int Blink()
{    
    GameState* state = GameState::GetInstance();
    return blinkAni[state->blinkT];
}

void IncrementBlink()
{
    GameState* state = GameState::GetInstance();
    state->blinkT++;
    if (state->blinkT >= (sizeof(blinkAni) / sizeof(int)))
    {
        state->blinkT = 0;
    }
}

bool LoadJson(const char* fileName, Json::Value* object)
{
    std::ifstream ifs;
    ifs.open(fileName, std::ios_base::in);
    Json::CharReaderBuilder builder;
    builder["collectComments"] = false;
    JSONCPP_STRING errors;
    try
    {
        if (!parseFromStream(builder, ifs, object, &errors)) {
            std::cout << errors << std::endl;
            return false;
        }
    }
    catch (const std::exception& ex)
    {
        std::cout << "File Access Exception: " << ex.what() << std::endl;
        return false;
    }
    return true;
}

float randf()
{
    return (static_cast<float>(rand()) / static_cast<float>(RAND_MAX));
}

void ScreenShake()
{
    float Shake = GameState::GetInstance()->Shake;
    if (Shake <= 0)
        return;
    float x = randf() * Shake - (Shake / 2);
    float y = randf() * Shake - (Shake / 2);
    rlTranslatef(x, y, 0.0);
    if (Shake > 10)
        Shake = Shake * 0.9;
    else
        Shake -= 1.0f;

    if (Shake < 0.0f)
        Shake = 0.0f;

    GameState::GetInstance()->Shake = Shake;
}