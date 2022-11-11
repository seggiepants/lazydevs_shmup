#include <string>
#include "Sprite.h"
#include "game.h"

Sprite::Sprite()
{
    this->Init(nullptr);
}

Sprite::Sprite(Json::Value* prototype)
{
    this->Init(prototype);
}

Sprite::~Sprite()
{
    this->frames.clear();
}

void Sprite::Init(Json::Value* prototype)
{
    this->position.x = this->position.y = 0.0;
    this->position.width = this->position.height = 0.0;
    this->velocity.x = 0.0;
    this->velocity.y = 1.0;
    this->collision.x = this->collision.y = 0.0;
    this->collision.width = this->collision.height = 0.0;
    this->spriteIndex = 1.0;
    this->sprite = 0;
    this->flash = 0.0;
    this->shake = 0.0;    
    this->dead = false;
    this->frames.clear();

    if (prototype != nullptr)
    {
        if (prototype->isObject())
        {
            std::vector<std::string> members = prototype->getMemberNames();
            for( std::vector<std::string>::iterator i = members.begin() ; i != members.end() ; i++ ) 
            {
                std::string member = (*i);
                if (member == "x")
                {
                    this->position.x = prototype->get(member, this->position.x).asFloat();
                }
                else if (member == "y")
                {
                    this->position.y = prototype->get(member, this->position.y).asFloat();
                }                
                else if (member == "sx")
                {
                    this->velocity.x = prototype->get(member, this->velocity.x).asFloat();
                }
                else if (member == "sy")
                {
                    this->velocity.x = prototype->get(member, this->velocity.x).asFloat();
                }
                else if (member == "colX")
                {
                    this->collision.x = prototype->get(member, this->collision.y).asFloat();
                }
                else if (member == "colY")
                {
                    this->collision.y = prototype->get(member, this->collision.y).asFloat();
                }
                else if (member == "colWidth")
                {
                    this->collision.width = prototype->get(member, this->collision.width).asFloat();
                }
                else if (member == "colHeight")
                {
                    this->collision.height = prototype->get(member, this->collision.height).asFloat();
                }
                else if (member == "spriteIndex")
                {
                    this->spriteIndex = prototype->get(member, this->spriteIndex).asFloat();
                }
                else if (member == "sprite")
                {
                    this->sprite = prototype->get(member, this->sprite).asInt();
                }
                else if (member == "flash")
                {
                    this->flash = prototype->get(member, this->flash).asFloat();
                }
                else if (member == "shake")
                {
                    this->shake = prototype->get(member, this->shake).asFloat();
                }
                else if (member == "dead")
                {
                    this->dead = prototype->get(member, this->dead).asBool();
                }
                else if (member == "frames")
                {
                    Json::Value frames = prototype->get(member, new std::vector<int>());
                    this->frames.clear();
                    for(unsigned int j = 0; j < frames.size(); j++)
                    {
                        this->frames.push_back(frames[j].asInt());
                    }
                }
            }

            if (this->spriteIndex >= this->frames.size())
            {
                this->spriteIndex = 0;
            }

            if (this->frames.size() > 0 && this->sprite <= 0)
            {
                GameState* state = GameState::GetInstance();
                this->sprite = this->frames[0];
                Rectangle r = state->quads[this->sprite];
                this->position.width = r.width;
                this->position.height = r.height;
                if ((this->collision.width == this->collision.height) && (this->collision.width == 0.0))
                {
                    this->collision.x = this->collision.y = 0.0;
                    this->collision.width = this->position.width;
                    this->collision.height = this->position.height;
                }
            }
        }
    }
}