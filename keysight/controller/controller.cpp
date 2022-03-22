#include "controller.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("controller")
#define LOG_ERR LogOut("controller")

Controller::Controller() { open_resource_manager(); }

Controller::~Controller() {
    if (session) viClose(session);
    if (resource_manager) viClose(resource_manager);
}

void Controller::open_resource_manager() {
    LOG_OUT << "attempting to open resource manager...";

    ViStatus status = 0;
    status = viOpenDefaultRM(&resource_manager);  // opening resource manager
                                                  /*
                                                      // handling failure condition of resource manager on open
                                                      if (status < VI_SUCCESS) {
                                                          LOG_ERR << "There was a problem opening the default resource manager, error code: " << status;
                                                          std::exit(EXIT_FAILURE);
                                                      } else
                                                          LOG_OUT << "opened resource manager";*/

    verify_vi_status(status, "opened resource manager", "There was a problem opening the default resource manager, error code: ");
}

void Controller::open_instrument() {
    LOG_OUT << "attempting to open instrument";

    ViStatus status = 0;
    status = viOpen(resource_manager, VISA_ADDRESS_BT2203A, VI_NO_LOCK, 0, &session);

    verify_vi_status(status, "opened instrument", "There was a problem opening the connection to the instrument, error code: ");
}

void Controller::verify_vi_status(const ViStatus &status, const std::string &message_success, const std::string &message_failure) {
    if (status < VI_SUCCESS) {
        LOG_ERR << message_failure << status;
        std::exit(EXIT_FAILURE);
    } else
        LOG_OUT << message_success;
}