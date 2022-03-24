#include "sequence_commands.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("sequence_command_handler")
#define LOG_ERR LogOut("sequence_command_handler")

SequenceCommands::SequenceCommands() {}

void SequenceCommands::catalog() {
    // TODO do we need to implement?
}

void SequenceCommands::clear(const ViSession &session, std::string sequence_id) const {
    // TODO do we need to implement?
    LOG_OUT << "sending the clear command";

    viPrintf(session, "SEQ:CLE\n");  // sending command
}

void SequenceCommands::step_count(std::string sequence_id) {
    // TODO do we need to implement?
}

void SequenceCommands::step_define(const ViSession &session, std::string sequence_id, std::string step_id, std::string mode, std::string duration,
                                   std::string cc, std::string cv) const {
    // TODO do we need too return anything?

    std::string out = "SEQ:STEP:DEF" + sequence_id + ", " + step_id + ", " + mode + ", " + duration + "\n";
    LOG_OUT << "sending the step define command: " << out;

    viPrintf(session, out.c_str());
}

void SequenceCommands::step_define(std::string sequence_id, std::string step_id) {
    // TODO do we need to implement?
}

void SequenceCommands::test_count() {
    // TODO do we need to implement?
}

void SequenceCommands::test_define(std::string sequence_id, std::string step_id, std ::string test_id, std::string test_type, std::string value,
                                   std::string time_type, std::string time_limit, std::string test_action) {
    // TODO do we need to implement?
}

void SequenceCommands::test_define(std::string sequence_id, std::string step_id, std::string test_id) {
    // TODO do we need to implement?
}