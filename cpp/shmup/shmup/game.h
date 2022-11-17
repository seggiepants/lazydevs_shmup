#pragma once
#ifndef __GAME_H__
#define __GAME_H__

#include <list>
#include <string>
#include <unordered_map>
#include <vector>
#include "Input.h"
#include "Particle.h"
#include "Scene.h"
#include "Shockwave.h"
#include "Starfield.h"

class GameState
{
public:
	~GameState();
	static GameState* GetInstance();	
	void StartGame();
	Font font;
	long highScore;
	Input input;
	std::vector<Rectangle> quads;
	int cherries;
	float Shake;
	Starfield starfield;
	Texture2D texture;
	bool quit;
	int blinkT;
	Scene* currentScene;
	long T;
private:
	GameState();
	static GameState* instance;
	std::list<Particle*> particles;
	std::unordered_map<std::string, Scene*> scenes;
	std::list<Shockwave*> shockwaves;
};

#endif
