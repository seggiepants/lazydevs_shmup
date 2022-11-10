#pragma once
#ifndef __SHOCKWAVE_H__
#define __SHOCKWAVE_H__

class Shockwave
{
public: 
	Shockwave(int x, int y, int clr, bool isBig);
	void Draw();
	void Update(float dt);
	int clr;
	int x;
	int y;
private:
	float radius;
	float speed;
	float targetRadius;
};

#endif