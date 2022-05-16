#include "visa_handler.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("VisaHandler")
#define LOG_ERR LogOut("VisaHandler")

#define BUFFER_SIZE 65535

namespace visa_data {
ViSession resource_manager = NULL;
ViSession session = NULL;
}  // namespace visa_data

VisaHandler::VisaHandler(std::string _visa_address, ConnectionStatusCallback _connection_status_callback)
    : visa_address(_visa_address), connection_status_callback{_connection_status_callback} {}

void VisaHandler::connect() {
    if (!connected) {
        if (open_resource_manager()) {
            if (open_instrument()) {
                if (enable_read_termination_character()) {
                    if (identification_query()) {
                        LOG_OUT << "identified " << visa_address;
                        update_connection_status(true);
                    } else {
                        LOG_ERR << "failed to identify " << visa_address;
                        disconnect();
                    }
                } else {
                    LOG_ERR << "failed to enabled read termination character";
                    disconnect();
                }
            } else {
                LOG_ERR << "failed to open instrument";
                disconnect();
            }
        } else {
            LOG_ERR << "failed to open resource manager";
            disconnect();
        }
    } else
        LOG_ERR << "not attempting connection, already connected";
}

void VisaHandler::disconnect() {
    LOG_OUT << "disconnect called";
    if (connected) {
        viUnlock(visa_data::session);
        viClose(visa_data::session);
        viClose(visa_data::resource_manager);

        visa_data::resource_manager = NULL;
        visa_data::session = NULL;

        update_connection_status(false);
    } else
        LOG_ERR << "can't disconnect because already disconnected";
}

void VisaHandler::update_connection_status(bool flag) {
    connected = flag;
    connection_status_callback(connected);
}

bool VisaHandler::identification_query() {
    LOG_OUT << "sending the identification query command";

#ifndef SOFTWARE_ONLY
    bool res;

    auto status = viPrintf(visa_data::session, "*IDN?\n");  // sending identification query command
    res = verify_vi_status(visa_data::session, status, "sent id query command", "There was a problem sending the id queury, error code: ");

    if (res) {
        // getting the response from the identification query
        ViChar idn_response[BUFFER_SIZE];
        status = viScanf(visa_data::session, "%t", idn_response);
        res = verify_vi_status(visa_data::session, status, "read id query response",
                               "There was a problem reading the id queury response, error code: ");

        if (res) {
            LOG_OUT << "identification query response: " << idn_response;

            return res;
        } else {
            LOG_ERR << "unable to retrieve identification query response";
            return false;
        }
    } else {
        LOG_ERR << "unabled to send identification query command " << status;
        return false;
    }
#else
    return true;
#endif
}

bool VisaHandler::enable_read_termination_character() {
#ifndef SOFTWARE_ONLY
    // For Serial and TCP/IP socket connections enable the read Termination character, or read's will timeout
    ViChar full_address[BUFFER_SIZE];
    ViStatus status;
    bool res;

    status = viGetAttribute(visa_data::session, VI_ATTR_RSRC_NAME, full_address);
    res = verify_vi_status(visa_data::session, status, "enabled read termination character",
                           "There was a problem getting the attributes resource name, error code: ");

    if (res) {
        if (std::string("ASRL").compare(full_address) == 0 || std::string("SOCKET").compare(full_address) == 0) {
            LOG_OUT << "controller: detected Serial or TCP/IP connection, enabling read termination character";
            status = viSetAttribute(visa_data::session, VI_ATTR_TERMCHAR_EN, VI_TRUE);
            res = verify_vi_status(visa_data::session, status, "enabled read termination character",
                                   "There was a problem setting the attributes termination character name, error code: ");

            status = viSetAttribute(visa_data::session, VI_ATTR_TMO_VALUE, 2000);
            res = verify_vi_status(visa_data::session, status, "timeout", "There was a problem setting the attributes timeout, error code: ");
            return res;
        } else
            return true;  // success
    } else
        return false;  // we failed
#else
    return true;
#endif
}

bool VisaHandler::open_resource_manager() {
    LOG_OUT << "attempting to open resource manager";

#ifndef SOFTWARE_ONLY
    auto status = viOpenDefaultRM(&visa_data::resource_manager);
    auto res = verify_vi_status(visa_data::session, status, "opened resource manager",
                                "There was a problem opening the default resource manager, error code: ");
#else
    auto res = true;
#endif

    return res;
}

bool VisaHandler::open_instrument() {
    LOG_OUT << "attempting to open instrument";

#ifndef SOFTWARE_ONLY
    auto status = viOpen(visa_data::resource_manager, visa_address.c_str(), VI_NULL, VI_NULL, &visa_data::session);

    auto res = verify_vi_status(visa_data::session, status, "opened instrument",
                                "There was a problem opening the connection to the instrument, error code: ");

    if (res) {
        ViChar full_address[BUFFER_SIZE];
        // TODO check that this lock crap works
        status = viLock(visa_data::session, VI_SHARED_LOCK, VI_TMO_IMMEDIATE, "IBEOS", full_address);
        res = verify_vi_status(visa_data::session, status, "locked instrument", "There was a problem locking the instrument, error code: ");
        if (res) {
            return true;
        }
    }

    return false;
#else
    return true;
#endif
}

bool VisaHandler::verify_vi_status(const ViSession &session, const ViStatus &status, const std::string &message_success,
                                   const std::string &message_failure) {
    if (status < VI_SUCCESS) {
        LOG_ERR << message_failure << status;
        ViChar response[BUFFER_SIZE];
        viStatusDesc(session, status, response);
        LOG_ERR << "status description: " << response;
        return false;
    } else {
        // LOG_OUT << message_success;
        return true;
    }
}

bool VisaHandler::send_command(std::string command) {
    LOG_OUT << "sending command: " << command << "\n";

    bool res = false;

    if (connected) {
        auto cmd = command + "\n";
        auto status = viPrintf(visa_data::session, cmd.c_str());

        res = verify_vi_status(visa_data::session, status, "error sending command", "There was a problem sending " + command + ", error code: ");

        if (!res) {
            LOG_ERR << "failed reading response";
            disconnect();
        }
    }

    return res;
}

bool VisaHandler::get_response(std::string &response) {
    LOG_OUT << "reading response";

    bool res = false;

    if (connected) {
        ViChar buffer[BUFFER_SIZE];
        auto status = viScanf(visa_data::session, "%t", buffer);
        auto res = verify_vi_status(visa_data::session, status, "getting response", "There was a problem getting the response, error code: ");

        if (!res) {
            LOG_ERR << "failed reading response";
            disconnect();
        } else {
            response = buffer;
        }
    }

    return res;
}