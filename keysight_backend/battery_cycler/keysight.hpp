#ifndef KEYSIGHT_HPP
#define KEYSIGHT_HPP

#include <boost/asio.hpp>
#include <memory>

#include "../visa_handler.hpp"
#include "module_card.hpp"

//#define SOFTWARE_ONLY 1

class Keysight {
public:
    Keysight(boost::asio::io_service &io_service, ConnectionStatusCallback connection_status_callback);

    void connect();
    void disconnect();

private:
    void detect_cards_at_boot();
    std::array<std::double_t, 32> get_cap_ahr(std::uint8_t card_number);
    std::array<std::double_t, 32> get_cap_whr(std::uint8_t card_number);
    std::array<std::double_t, 32> get_cap(std::uint8_t card_number, std::string capacity_cmd);
    std::array<std::array<std::string, 10>, 32> get_cell_verbose(std::uint8_t card_number);
    void get_cell_status();
    void reset();
    void start_polling_cell_status();
    void update_connection_status(bool flag);

    std::vector<std::string> comma_delimiter(std::string x);

    std::shared_ptr<VisaHandler> visa_handler;

    bool connected = false;

    std::array<std::shared_ptr<ModuleCard>, 8> cards;

    boost::asio::io_service &io_service;
    boost::asio::steady_timer cell_status_timer;

    const std::string VISA_ADDRESS_BT2203A = "USB0::0x008D::0x3502::MY58000516::0::INSTR";  // usb address of battery cycler

    ConnectionStatusCallback connection_status_callback;
};

#endif