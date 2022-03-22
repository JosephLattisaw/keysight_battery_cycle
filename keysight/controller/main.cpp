#include <iostream>

#include "visa.h"

int main(int, char**) {
    ViRsrc VISA_ADDRESS_BT2203A = "USB0::0x008D::0x3502::MY58000516::0::INSTR";  // usb address of battery cycler

    // create a connection (session) to the instrument
    ViSession resource_manager = 0;
    ViSession session = 0;
    ViStatus status = 0;

    std::cout << "controller: attempting to open resource manager..." << std::endl;
    status = viOpenDefaultRM(&resource_manager);  // opening resource manager

    // handling failure condition of resource manager on open
    if (status < VI_SUCCESS) {
        std::cerr << "controller: There was a problem opening the default resource manager, error code: " << status << std::endl;
        std::exit(EXIT_FAILURE);
    } else
        std::cout << "controller: opened resource manager" << std::endl;

    std::cout << "controller: attempting to open instrument" << std::endl;
    status = viOpen(resource_manager, VISA_ADDRESS_BT2203A, VI_NO_LOCK, 0, &session);

    if (status < VI_SUCCESS) {
        std::cerr << "controller: There was a problem opening the connection to the instrument, error code: " << status << std::endl;
        std::exit(EXIT_FAILURE);
    } else
        std::cout << "controller: opened instrument" << std::endl;

    // For Serial and TCP/IP socket connections enable the read Termination character, or read's will timeout
    ViChar full_address[100];
    viGetAttribute(session, VI_ATTR_RSRC_NAME, full_address);

    if (std::string("ASRL").compare(full_address) == 0 || std::string("SOCKET").compare(full_address) == 0) {
        std::cout << "controller: detected Serial or TCP/IP connection, enabling read termination character" << std::endl;
        viSetAttribute(session, VI_ATTR_TERMCHAR_EN, VI_TRUE);
    }

    // Sending the *IDN? command and reading the response
    std::cout << "controller: sending the *IDN? commnad" << std::endl;
    viPrintf(session, "*IDN?\n");
    ViChar idn_response[100];
    viScanf(session, "%t", idn_response);

    std::cout << "controller: *IDN? returned: " << idn_response << std::endl;

    // close the connection to the instrument
    viClose(session);
    viClose(resource_manager);

    return 0;
}
