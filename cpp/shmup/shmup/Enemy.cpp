#include "Enemy.h"

Enemy::Enemy(Json::Value* prototype) : Sprite(prototype)
{
    this->type = "eye";
    this->hp = 1;
    this->wait = 0;
    this->animationSpeed = 0.4;
    this->time = 0;
    this->visible = false;
    if (prototype != nullptr)
    {
        if (prototype->isObject())
        {
            std::vector<std::string> members = prototype->getMemberNames();
            for( std::vector<std::string>::iterator i = members.begin() ; i != members.end() ; i++ ) 
            {
                std::string member = (*i);
                if (member == "hp")
                {
                    this->hp = prototype->get(member, this->hp).asInt();
                }
                else if (member == "points")
                {
                    this->points = prototype->get(member, this->points).asInt();
                }
                else if (member == "animationSpeed")
                {
                    this->animationSpeed = prototype->get(member, this->animationSpeed).asFloat();
                }
            }
        }
    }
}

Enemy::~Enemy()
{

}