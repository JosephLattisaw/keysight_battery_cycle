#ifndef COMMON_HPP
#define COMMON_HPP

#include <visa.h>

#include <string>

namespace keysight {
bool verify_vi_status(const ViSession &session, const ViStatus &status, const std::string &message_success, const std::string &message_failure);
}  // namespace keysight

#endif