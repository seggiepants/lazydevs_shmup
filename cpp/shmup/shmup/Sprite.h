#pragma once
#ifndef __SPRITE_H__
#define __SPRITE_H_

#include <json/json.h>
#include <raylib.h>
#include <vector>

class Sprite
{
public:
    Sprite();
    Sprite(Json::Value* prototype);
    ~Sprite();
    void Init(Json::Value* prototype);
    void Update(float dt);
    void Draw();
private:
    Rectangle position;
    Vector2 velocity;
    Rectangle collision;
    float spriteIndex;
    int sprite;
    float flash;
    float shake;
    bool dead;
    std::vector<int> frames;
};

#endif