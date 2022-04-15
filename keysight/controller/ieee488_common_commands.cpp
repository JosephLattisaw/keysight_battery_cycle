#include "ieee488_common_commands.hpp"

#include <chrono>
#include <thread>

#include "logger.hpp"

#define LOG_OUT LogOut("iee488_command_handler")
#define LOG_ERR LogOut("iee488_command_handler")

IEEE488CommonCommands::IEEE488CommonCommands() {}

std::string IEEE488CommonCommands::identification_query(const ViSession &session) const {
    LOG_OUT << "sending the identification query command";

    viPrintf(session, "*IDN?\n");  // sending identification query command

    // getting the response from the identification query
    ViChar idn_response[65535];
    viScanf(session, "%t", idn_response);

    LOG_OUT << "identification query response: " << idn_response;

    return idn_response;
}