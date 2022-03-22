#ifndef CONTROLLER_HPP
#define CONTROLLER_HPP

#include <string>

#include "visa.h"

class Controller {
public:
    Controller();
    ~Controller();

private:
    // opening visa sessions
    void open_instrument();
    void open_resource_manager();

    void verify_vi_status(const ViStatus &status, const std::string &message_success, const std::string &message_failure);

    // session to instrument
    ViSession resource_manager = 0;
    ViSession session = 0;

    const ViRsrc VISA_ADDRESS_BT2203A = "USB0::0x008D::0x3502::MY58000516::0::INSTR";  // usb address of battery cycler
};

#endif