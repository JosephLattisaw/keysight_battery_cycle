#include "ieee488_common_commands.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("iee488_command_handler")
#define LOG_ERR LogOut("iee488_command_handler")

IEEE488CommonCommands::IEEE488CommonCommands() {}

void IEEE488CommonCommands::abort() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::calibrate(std::string channels) {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::clear_status() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::event_status_enable_command(std::string value) {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::event_status_enable_query() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::event_status_event_query() {
    // TODO do we need to implement?
}

std::string IEEE488CommonCommands::identification_query(const ViSession &session) const {
    LOG_OUT << "sending the identification query command";

    viPrintf(session, "*IDN?\n");  // sending identification query command

    // getting the response from the identification query
    ViChar idn_response[65535];
    viScanf(session, "%t", idn_response);

    LOG_OUT << "identification query response: " << idn_response;

    return idn_response;
}

void IEEE488CommonCommands::operation_complete_command() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::operation_complete_query() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::reset_command() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::status_byte_query() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::self_test_query() {
    // TODO do we need to implement?
}

void IEEE488CommonCommands::wait() {
    // TODO do we need to implement?
}