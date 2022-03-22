#include "common.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("controller-common")
#define LOG_ERR LogOut("controller-common")

namespace keysight {
void verify_vi_status(const ViStatus &status, const std::string &message_success, const std::string &message_failure) {
    if (status < VI_SUCCESS) {
        LOG_ERR << message_failure << status;
        std::exit(EXIT_FAILURE);
    } else
        LOG_OUT << message_success;
}
}  // namespace keysight