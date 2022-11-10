#include "Shockwave.h"
#include "draw.h"
#include <raylib.h>

Shockwave::Shockwave(int x, int y, int clr = -1, bool isBig = false)
{
	this->x = x;
	this->y = y;
	this->radius = 3.0f;
    if (isBig)
    {
        this->targetRadius = 25.0f;
        this->speed = 3.5;
        this->clr = 7;
    }
    else
    {
        this->targetRadius = 6.0f;
        this->speed = 1;
        this->clr = 9;
    }
    if (clr >= 0)
        this->clr = clr;
}

void Shockwave::Draw()
{
	DrawCircleLines(x, y, radius, Pal(clr));
}

void Shockwave::Update(float dt)
{
    this->radius += this->speed;
}
