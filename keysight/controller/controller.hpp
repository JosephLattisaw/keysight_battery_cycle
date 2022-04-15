#ifndef CONTROLLER_HPP
#define CONTROLLER_HPP

#include <visa.h>

#include <memory>
#include <string>

#include "cell_commands.hpp"
#include "ieee488_common_commands.hpp"
#include "sequence_commands.hpp"
#include "system_commands.hpp"

class Controller {
public:
    Controller();
    ~Controller();

private:
    // opening visa sessions
    void open_instrument();
    void open_resource_manager();

    void enable_read_termination_character();

    // commands
    std::shared_ptr<CellCommands> cell_commands;
    std::shared_ptr<IEEE488CommonCommands> ieee488_common_commands;
    std::shared_ptr<SequenceCommands> sequence_commands;
    std::shared_ptr<SystemCommands> system_commands;

    // session to instrument
    ViSession resource_manager = 0;
    ViSession session = 0;

    const ViRsrc VISA_ADDRESS_BT2203A = "USB0::0x008D::0x3502::MY58000516::0::INSTR";  // usb address of battery cycler
};

#endif