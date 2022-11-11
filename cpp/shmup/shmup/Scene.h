#pragma once
#ifndef __SCENE_H__
#define __SCENE_H__

class Scene
{
public:
		Scene();
		virtual ~Scene();
		virtual void Draw();
		virtual void Update(float dt);
};

#endif
