#ifndef VISA_HANDLER_HPP
#define VISA_HANDLER_HPP

#include <visa.h>

#include <string>

#include "types.hpp"

//#define SOFTWARE_ONLY 1

class VisaHandler {
public:
    VisaHandler(std::string visa_address, ConnectionStatusCallback connection_status_callback);

    void connect();
    void disconnect();

    bool get_response(std::string &response);
    bool send_command(std::string command);

private:
    bool enable_read_termination_character();
    bool identification_query();
    bool open_instrument();
    bool open_resource_manager();
    void update_connection_status(bool flag);
    bool verify_vi_status(const ViSession &session, const ViStatus &status, const std::string &message_success, const std::string &message_failure);

    bool connected = false;
    std::string visa_address;

    ConnectionStatusCallback connection_status_callback;
};

#endif