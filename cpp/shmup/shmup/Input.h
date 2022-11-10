#pragma once
#ifndef __INPUT_H__
#define __INPUT_H__

#include <string>
#include <unordered_map>
#include <raylib.h>

class Input
{
public:
	Input();
	~Input();
	bool Btn(std::string key);
	bool Btnp(std::string key);
	void ReadInput();
	bool MouseMode;
private:
	std::unordered_map<std::string, bool> current;
	std::unordered_map<std::string, bool> previous;
};

#endif