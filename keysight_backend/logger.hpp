#ifndef LOGGER_HPP
#define LOGGER_HPP

#include <iostream>
#include <string>

// TODO clean this up, multiple classes
// TODO if possible make this thread safe
class LogOut {
public:
    LogOut(const std::string &class_name);
    ~LogOut();

    template <class T>
    LogOut &operator<<(const T &v) {
        std::cout << v;
        return *this;
    }
};

class LogErr {
public:
    LogErr(const std::string &class_name);
    ~LogErr();

    template <class T>
    LogErr &operator<<(const T &v) {
        std::cerr << v;
        return *this;
    }
};

#endif