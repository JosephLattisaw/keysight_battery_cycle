#include "controller.hpp"

#include <thread>

#include "common.hpp"
#include "logger.hpp"

#define LOG_OUT LogOut("controller")
#define LOG_ERR LogOut("controller")

Controller::Controller() {
    cell_commands = std::make_shared<CellCommands>();
    ieee488_common_commands = std::make_shared<IEEE488CommonCommands>();
    sequence_commands = std::make_shared<SequenceCommands>();

    // opening the Keysight BT2203A
    open_resource_manager();
    open_instrument();
    enable_read_termination_character();

    // getting the id of the machine we're connected with
    ieee488_common_commands->identification_query(session);

    // ieee488_common_commands->reset_command(session);
    ieee488_common_commands->identification_query(session);
    /*
        // sequence example

        // clear any initial setups
        cell_commands->abort(session, "0");

        // define four parallel channels
        cell_commands->define(session, "1025", "125");
        cell_commands->define(session, "1026", "126");
        cell_commands->define(session, "1027", "127");
        cell_commands->define(session, "1028", "128");
        cell_commands->define(session, "1029", "129");

        // define a small sequence
        sequence_commands->step_define(session, "1", "1", "REST", "30");

        // assign the cells to run sequence 1
        cell_commands->enable(session, "(@1025,1026)", "1");

        cell_commands->initiate(session, "(@1025,1026)");

        std::this_thread::sleep_for(std::chrono::seconds(2));
        viPrintf(session, "CELL:STEP:TIME? (@1025,1026)\n");
        ViChar step_time_response[65535];
        viScanf(session, "%t", step_time_response);
        std::cout << "step time: " << step_time_response << std::endl;*/

    viPrintf(session, "CELL:ABORT 0\n");
    viPrintf(session, "CELL:CLEAR 0\n");
    viPrintf(session, "SEQ:CLEAR 0\n");

    viPrintf(session, "CELL:DEFINE 1025,(@125)\n");
    viPrintf(session, "CELL:DEFINE 1026,(@126)\n");
    viPrintf(session, "CELL:DEFINE 1027,(@127)\n");
    viPrintf(session, "CELL:DEFINE 1028,(@128)\n");

    viPrintf(session, "SEQ:STEP:DEF 1, 1, REST, 300\n");
    viPrintf(session, "SEQ:STEP:DEF 2, 1, REST, 30\n");

    viPrintf(session, "CELL:ENABLE (@1025,1026),1\n");
    viPrintf(session, "CELL:ENABLE (@1027,1028),2\n");

    ViChar enab_response[65535];
    viScanf(session, "%t", enab_response);
    std::cout << "response: " << enab_response << std::endl;

    viPrintf(session, "CELL:INITiate (@1025,1026)\n");

    std::this_thread::sleep_for(std::chrono::seconds(10));
    viPrintf(session, "CELL:INITiate (@1027,1028)\n");
    ViChar step_time_response[65535];
    viScanf(session, "%t", step_time_response);
    std::cout << "response: " << step_time_response << std::endl;

    viPrintf(session, "STAT:CELL:VERBose? 1025\n");
    viScanf(session, "%t", step_time_response);

    std::cout << "response: " << step_time_response << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(10));
    viPrintf(session, "CELL:STEP:TIME? (@1025,1026)\n");
    viScanf(session, "%t", step_time_response);
    std::cout << "response: " << step_time_response << std::endl;

    viPrintf(session, "STAT:CELL:VERBose? 1027\n");
    viScanf(session, "%t", step_time_response);

    std::cout << "response: " << step_time_response << std::endl;

    viPrintf(session, "CELL:STEP:TIME? (@1027,1028)\n");
    viScanf(session, "%t", step_time_response);
    std::cout << "response: " << step_time_response << std::endl;
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