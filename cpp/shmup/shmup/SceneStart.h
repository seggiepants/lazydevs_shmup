#pragma once
#ifndef __SCENESTART_H__
#define __SCENESTART_H__

#include "Scene.h"
class SceneStart : public Scene
{
public:
    SceneStart();
    ~SceneStart();
    void Draw();
    void Update(float dt);
private:
    float peekerX;
};

#endif