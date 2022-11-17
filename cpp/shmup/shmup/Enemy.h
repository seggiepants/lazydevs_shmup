#pragma once
#ifndef __ENEMY_H__
#define __ENEMY_H__

#include <list>
#include <string>
#include <json/json.h>
#include "Sprite.h"

class Enemy : Sprite
{
public:
    Enemy(Json::Value* prototype);
    ~Enemy();
private:
    int hp;
    int wait;
    int time;
    bool visible;
    float animationSpeed;
    int points;
    std::string type;
};

#endif