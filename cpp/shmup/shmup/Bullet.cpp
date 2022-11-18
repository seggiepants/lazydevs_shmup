#include "Bullet.h"

Bullet::Bullet(Json::Value* prototype)
{
    this->age = 0;
    this->maxAge = 10.0;
    if (prototype != nullptr)
    {
        if (prototype->isObject())
        {
            std::vector<std::string> members = prototype->getMemberNames();
            for( std::vector<std::string>::iterator i = members.begin() ; i != members.end() ; i++ ) 
            {
                std::string member = (*i);
                if (member == "age")
                {
                    this->age = prototype->get(member, this->age).asFloat();
                }
                else if (member == "maxAge")
                {
                    this->maxAge = prototype->get(member, this->maxAge).asFloat();
                }
            }
        }
    }
}