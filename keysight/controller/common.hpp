#ifndef COMMON_HPP
#define COMMON_HPP

#include <visa.h>

#include <string>

namespace keysight {
void verify_vi_status(const ViStatus &status, const std::string &message_success, const std::string &message_failure);
}

#endif