#include "controller.hpp"

#include "common.hpp"
#include "logger.hpp"

#define LOG_OUT LogOut("controller")
#define LOG_ERR LogOut("controller")

Controller::Controller() {
    ieee488_common_commands = std::make_shared<IEEE488CommonCommands>();

    // opening the Keysight BT2203A
    open_resource_manager();
    open_instrument();
    enable_read_termination_character();

    // getting the id of the machine we're connected with
    ieee488_common_commands->identification_query(session);
}

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

    keysight::verify_vi_status(status, "opened resource manager", "There was a problem opening the default resource manager, error code: ");
}

void Controller::open_instrument() {
    LOG_OUT << "attempting to open instrument";

    ViStatus status = 0;
    status = viOpen(resource_manager, VISA_ADDRESS_BT2203A, VI_NO_LOCK, 0, &session);

    keysight::verify_vi_status(status, "opened instrument", "There was a problem opening the connection to the instrument, error code: ");
}

void Controller::enable_read_termination_character() {
    // For Serial and TCP/IP socket connections enable the read Termination character, or read's will timeout
    ViChar full_address[100];
    viGetAttribute(session, VI_ATTR_RSRC_NAME, full_address);

    if (std::string("ASRL").compare(full_address) == 0 || std::string("SOCKET").compare(full_address) == 0) {
        LOG_OUT << "controller: detected Serial or TCP/IP connection, enabling read termination character";
        viSetAttribute(session, VI_ATTR_TERMCHAR_EN, VI_TRUE);
    }
}