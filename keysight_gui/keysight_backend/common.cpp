#include "common.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("controller-common")
#define LOG_ERR LogOut("controller-common")

namespace keysight {
bool verify_vi_status(const ViSession &session, const ViStatus &status, const std::string &message_success, const std::string &message_failure) {
    if (status < VI_SUCCESS) {
        LOG_ERR << message_failure << status;
        ViChar response[65535];
        viStatusDesc(session, status, response);
        LOG_ERR << "status description: " << response;
        return false;
    } else {
        // LOG_OUT << message_success;
        return true;
    }
}

ViSession resource_manager = 0;
ViSession session = 0;
}  // namespace keysight