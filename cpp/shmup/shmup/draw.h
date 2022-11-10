#pragma once
#ifndef __DRAW_H__
#define __DRAW_H__
#include <string>
#include <raylib.h>

//static const float* pal;
//static const float* palRedAlien;

Color Pal(int idx);
void CenterPrint(std::string message, int y, int clr);
void PointPrint(std::string message, int x, int y, int clr);

#endif
