#include "logger.hpp"

LogOut::LogOut(const std::string &class_name) { std::cout << class_name << ": "; }

LogOut::~LogOut() { std::cout << std::endl; }

LogErr::LogErr(const std::string &class_name) { std::cerr << class_name << ": "; }

LogErr::~LogErr() { std::cerr << std::endl; }