#pragma once
#ifndef __BULLET_H__
#define __BULLET_H__

#include <json/json.h>
#include "Sprite.h"

class Bullet : Sprite
{
public:
    Bullet(Json::Value* prototype);
protected:
    float age;
    float maxAge;
    float damage;
};

#endif