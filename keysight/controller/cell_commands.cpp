#include "cell_commands.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("cell_command_handler")
#define LOG_ERR LogOut("cell_command_handler")

CellCommands::CellCommands() {}

void CellCommands::abort(const ViSession &session, std::string cell_list) const {
    // TODO actually send command with parameters
    LOG_OUT << "sending the abort command";

    viPrintf(session, "CELL:ABOR 0\n");
}

void CellCommands::clear(const ViSession &session, std::string cell_list) const {
    // TODO actually send with parameters
    LOG_OUT << "sending the abort command";

    viPrintf(session, "CELL:CLE 0\n");  // sending command
}

void CellCommands::define(const ViSession &session, std::string cell_id, std::string channel_list) const {
    // TODO implement and read what it returns

    std::string out = "CELL:DEF " + cell_id + ",(@" + channel_list + ")\n";
    LOG_OUT << "sending define command: " << out;

    viPrintf(session, out.c_str());
}
void CellCommands::define(std::string cell_id) {
    // TODO do we need to implement?
}
void CellCommands::define_quick(std::string cell_size) {
    // TODO do we need to implement?
}
void CellCommands::enable(const ViSession &session, std::string cell_list, std::string sequence_id) const {
    // TODO implement return

    std::string out = "CELL:ENAB " + cell_list + ", " + sequence_id + "\n";
    LOG_OUT << "sending enable command: " << out;

    viPrintf(session, out.c_str());
}
void CellCommands::enable(std::string cell_list) {
    // TODO do we need to implement?
}
void CellCommands::initiate(const ViSession &session, std::string cell_list) const {
    // TODO implement return

    std::string out = "CELL:INIT " + cell_list;
    LOG_OUT << "sending init command: " << out;

    viPrintf(session, out.c_str());
}
void CellCommands::step_time(std::string cell_list) {
    // TODO do we need to implement?
}
void CellCommands::time(std::string cell_list) {
    // TODO do we need to implement?
}