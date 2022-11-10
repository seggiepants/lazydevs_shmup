#pragma once

#ifndef __COMMON_H__
#define __COMMON_H__

#include <json/json.h>

#define COLORS_PER_PALETTE 16
#define SCREEN_SCALE 4
#define SCREEN_W 128
#define SCREEN_H 128
#define TILE_SIZE 8
#define VERSION "v1.2"

int Blink();
void IncrementBlink();
bool LoadJson(const char* fileName, Json::Value* object);
float randf();
void ScreenShake();

#endif