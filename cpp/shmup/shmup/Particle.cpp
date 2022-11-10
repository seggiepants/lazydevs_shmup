#include "Particle.h"
#include "draw.h"

Particle::Particle(float x, float y, float sx, float sy, float lifeTime, int clr, float radius, ParticleType type)
{
	this->forPlayer = false;
	this->x = x;
	this->y = y;
	this->startX = x;
	this->startY = y;
	this->sx = sx;
	this->sy = sy;
	this->maxAge = lifeTime;
	this->clr = clr;
	this->radius = radius;
	this->type = type;
}

void Particle::Draw()
{
	if (this->type == ParticleType::Beam)
	{
		DrawLine(startX, startY, x, y, Pal(clr));
	}
	else if (this->type == ParticleType::Spark)
	{
		DrawRectangle(x, y, 1, 1, Pal(clr));
	}
	else
	{
		DrawCircle(static_cast<int>(x), static_cast<int>(y), radius, Pal(clr));
	}
}

void Particle::Update(float dt)
{
	x += sx;
	y += sy;
	
	if ((type == ParticleType::Beam) && (age > 10))
		type = ParticleType::Generic;

	if (type == ParticleType::Explosion)
	{
		sx *= 0.9;
		sy *= 0.9;
		clr = GetParticleColor();

	}
	age += 1;
	if (age >= maxAge)
		radius -= 0.5;
}

int Particle::GetParticleColor()
{
	int c = 7;
	if (forPlayer)
	{
		if (age > 10)
			c = 6;
		if (age > 14)
			c = 12;
		if (age > 20)
			c = 13;
		if (age > 24)
			c = 1;
		if (age > 30)
			c = 1;
	}
	else
	{
		if (age > 10)
			c = 10;
		if (age > 14)
			c = 9;
		if (age > 20)
			c = 8;
		if (age > 24)
			c = 2;
		if (age > 30)
			c = 5;
	}
	return c;
}



