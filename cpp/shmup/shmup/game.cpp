#include "game.h"
#include "SceneStart.h"

GameState* GameState::instance = nullptr;

GameState::GameState()
{
    blinkT = 0;
    cherries = 0;
	font = LoadFont("img/mecha.png");
    highScore = 0;
	quads.clear();
	quit = false;
	Shake = 0.0f;
	starfield.Init();
    T = 0;
	Image graphics = LoadImage("img/graphics.png");
	texture = LoadTextureFromImage(graphics);
    SceneStart* sceneStart = new SceneStart();
    scenes["start"] = dynamic_cast<Scene*>(sceneStart);
    currentScene = dynamic_cast<Scene*>(sceneStart);
	UnloadImage(graphics);
}

GameState::~GameState()
{
	quads.clear();
    for (auto x : scenes)
    {
        delete x.second;
    }
    scenes.clear();
	UnloadFont(font);
	UnloadTexture(texture);
}

GameState* GameState::GetInstance()
{
	if (instance == nullptr)
	{
		instance = new GameState();
	}
	return instance;
}

void GameState::StartGame()
{
	/*
	function StartGame()
        T = 0
        Enemies = {}
        EnemyShots = {}
        Particles = {}
        Pickups = {}
        Floats = {}
        Shockwaves = {}
        Shots = {}

        Cherries = 0
        Wave = 0 -- Fix me
        NextWave()
        Ship = MakeSprite(ShipPrototype)
        Ship.x = (ScreenW - TileSize) / 2
        Ship.y = (ScreenH - (TileSize * 3))
        Ship.sx = 0
        Ship.sy = 0
        Ship.spriteIndex = 2
        Ship.sprite = Ship.frames[Ship.spriteIndex]
        Ship.invulnerable = 0
        Ship.shotTimeout = 0
        Ship.deadTime = 0
        Ship.maxDeadTime = 45
        FlameSpr = 4
        Muzzle = 0
        Score = 0
        Lives = 4
        PowerupTimeout = 0
        ShowSkull = 0
        InitStars()
        ShootOK = true
        ShotType = 1
        ButtonReady = false    
    end
    */
}