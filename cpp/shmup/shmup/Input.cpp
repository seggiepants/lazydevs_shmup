#include <raylib.h>
#include "common.h"
#include "Input.h"

Input::Input()
{
	current.clear();
	previous.clear();
	MouseMode = false; // TODO: more later
}

Input::~Input()
{
	current.clear();
	previous.clear();
}

bool Input::Btn(std::string key)
{
	std::unordered_map<std::string, bool>::iterator i = this->current.find(key);
	if (i == this->current.end())
		return false;

	return this->current[key];
}

bool Input::Btnp(std::string key)
{
	std::unordered_map<std::string, bool>::iterator i = this->current.find(key);
	std::unordered_map<std::string, bool>::iterator j = this->previous.find(key);
	if (i == this->current.end())
		return false;

	if (j == this->previous.end())
		return current[key];

	return this->current[key] && !this->previous[key];
}

void Input::ReadInput()
{
	for (auto pair : this->current)
	{
		this->previous[pair.first] = pair.second;
		pair.second = false;
	}

	// Read the mouse
	/*
	if (this - MouseMode)
	{
		Vector2 mouse = GetMousePosition();
		mouse.x /= SCREEN_SCALE;
		mouse.y /= SCREEN_SCALE;

			if Ship ~= nil and Ship.x ~= nil and Ship.y ~= nil then
				if math.abs(mouseX - Ship.x) > 5 then
					if mouseX > Ship.x then
						Keys.right = true
						elseif mouseX < Ship.x then
						Keys.left = true
						end
						end

						if math.abs(mouseY - Ship.y) > 5 then
							if mouseY > Ship.y then
								Keys.down = true
								elseif mouseY < Ship.y then
								Keys.up = true
								end
								end
								end

								if MouseDoubleClick == true then
									MouseDoubleClick = false
									Keys.b = true
									end
									Keys.a = MouseDown
									end
	}
	*/

	// Read the keyboard
	this->current["a"] = IsKeyDown(KEY_Z) || IsKeyDown(KEY_SPACE);
	this->current["b"] = IsKeyDown(KEY_X) || IsKeyDown(KEY_TAB);
	this->current["up"] = IsKeyDown(KEY_W) || IsKeyDown(KEY_UP);
	this->current["down"] = IsKeyDown(KEY_S) || IsKeyDown(KEY_DOWN);
	this->current["left"] = IsKeyDown(KEY_A) || IsKeyDown(KEY_LEFT);
	this->current["right"] = IsKeyDown(KEY_D) || IsKeyDown(KEY_RIGHT);
#ifndef PLATFORM_WEB
	this->current["escape"] = IsKeyDown(KEY_ESCAPE) || IsKeyDown(KEY_Q);
#else
	this->current["escape"] = false;
#endif
	this->current["p"] = IsKeyDown(KEY_P);
	this->current["m"] = IsKeyDown(KEY_M);

	// Read the joystick
	// D-PAD
	this->current["up"] |= IsGamepadButtonDown(0, GAMEPAD_BUTTON_LEFT_FACE_UP);
	this->current["down"] |= IsGamepadButtonDown(0, GAMEPAD_BUTTON_LEFT_FACE_DOWN);
	this->current["left"] |= IsGamepadButtonDown(0, GAMEPAD_BUTTON_LEFT_FACE_LEFT);
	this->current["right"] |= IsGamepadButtonDown(0, GAMEPAD_BUTTON_LEFT_FACE_RIGHT);
	// Back
	this->current["escape"] |= IsGamepadButtonDown(0, GAMEPAD_BUTTON_MIDDLE_LEFT);
	// A,B (or actually A, X
	this->current["b"] |= IsGamepadButtonDown(0, GAMEPAD_BUTTON_RIGHT_FACE_LEFT);
	this->current["a"] |= IsGamepadButtonDown(0, GAMEPAD_BUTTON_RIGHT_FACE_DOWN);

	// Joystick
	if (GetGamepadAxisCount(0) >= 2)
	{
		const float threshold = 0.2;
		float value;
		// 0 -- left/right
		value = GetGamepadAxisMovement(0, 0);
		if (abs(value) > threshold)
		{
			if (value < 0)
			{
				this->current["left"] = true;
				this->current["right"] = false;
			}
			else
			{
				this->current["left"] = false;
				this->current["right"] = true;
			}
		}

		// 1 -- up/down
		value = GetGamepadAxisMovement(0, 1);
		if (abs(value) > threshold)
		{
			if (value < 0)
			{
				this->current["up"] = true;
				this->current["down"] = false;
			}
			else
			{
				this->current["up"] = false;
				this->current["down"] = true;
			}
		}
	}

	if (this->Btnp("m"))
	{
		this->MouseMode = !this->MouseMode;
	}
}
