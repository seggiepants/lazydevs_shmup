#pragma once
#ifndef __PARTICLE_H__
#define __PARTICLE_H__

enum ParticleType
{
    Beam = 0
    , Explosion
    , Spark
    , Generic
};

class Particle
{
public:
    Particle(float x, float y, float sx, float sy, float lifeTime, int clr, float radius, ParticleType type);
    void Draw();
    void Update(float dt);
    int GetParticleColor();
    bool forPlayer;
private:
    float x;
    float y;
    float sx;
    float sy;
    float startX;
    float startY;
    float lifeTime;
    int clr;
    float radius;
    float age;
    float maxAge;
    ParticleType type;
};

#endif