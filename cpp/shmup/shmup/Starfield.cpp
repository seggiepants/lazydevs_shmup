#include <cstdlib>
#include "Starfield.h"
#include "common.h"
#include "draw.h"

Starfield::Starfield()
{
    this->Init();
}

Starfield::~Starfield()
{
    this->stars.clear();
}

void Starfield::Draw()
{

    for (std::list<Star>::iterator i = stars.begin(); i != stars.end(); ++i)
    {
        int clr = 7;
        float speed = (*i).spd;
        if (speed < 1)
            clr = 1;
        else if (speed < 1.25)
            clr = 13;
        else if (speed < 1.5)
            clr = 6;

        if (speed < 1.5)
        {
            DrawRectangle((*i).x, (*i).y, 1, 1, Pal(clr));
        }
        else
        {
            DrawRectangle((*i).x, (*i).y - 3, 1, 3, Pal(5));
            DrawRectangle((*i).x, (*i).y - 1, 1, 1, Pal(clr));
        }
    }
}

void Starfield::Init()
{
    const int NUM_STARS = 100;
    this->stars.clear();
    
    for (int i = 0; i < NUM_STARS; ++i)
    {
        Star star;
        star.x = rand() % SCREEN_W;
        star.y = rand() % SCREEN_H;
        star.spd = (randf() * 1.5) + 0.05f;
        this->stars.push_back(star);
    }
}

void Starfield::Update(float dt, float speed = 1.0)
{
    for (std::list<Star>::iterator i = stars.begin(); i != stars.end(); ++i)
    {
        (*i).y = (*i).y + ((*i).spd * speed);
        if ((*i).y >= SCREEN_H)
        {
            (*i).x = rand() % SCREEN_W;
            (*i).y -= SCREEN_H - TILE_SIZE;
        }
    }
}
