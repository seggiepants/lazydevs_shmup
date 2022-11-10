#pragma once
#ifndef __STARFIELD_H__
#define __STARFIELD_H__
#include <list>
#include "Star.h"
#include <raylib.h>

class Starfield
{
public:
	Starfield();
	~Starfield();
	void Draw();
	void Init();
	void Update(float dt, float speed);
private:
	std::list<Star> stars;
};
#endif
