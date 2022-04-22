#ifndef KEYSIGHT_HPP
#define KEYSIGHT_HPP

#include <visa.h>

#include <boost/asio.hpp>

#include "types.hpp"

//#define SOFTWARE_ONLY 1

class Keysight {
public:
    Keysight(boost::asio::io_service &io_service, ActiveCardsCallback active_cards_callback, ConnectionStatusCallback connection_status_callback,
             PortDoubleCallback port_double_callback, PortUint16Callback port_uint16_callback);
    ~Keysight();

    void connect();
    void disconnect();

private:
    // opening visa sessions
    bool open_instrument();
    bool open_resource_manager();
    bool enable_read_termination_character();
    bool identification_query();

    // commands
    // NOTE: all cell names are defined 1:1
    // i.e: cell 1001 equals channel 101
    bool define_cells_for_all_cards();  // defining all cell names
    bool detect_cards_at_boot();        // getting all the active cards in the hardware

    // status updates
    bool get_cell_status();
    // status telemetry
    bool get_cap_ahr(int card_number);
    bool get_cap_whr(int card_number);
    bool get_cell_verbose(int card_number);

    // polling
    void start_polling_cell_status();

    void update_connection_status(bool flag);

    std::vector<std::string> comma_delimiter(std::string x);

    // data
    active_cards_type active_cards;
    std::vector<std::string> cell_names;
    map_double_data_type cell_cap_ahr_data;
    map_double_data_type cell_cap_whr_data;
    map_double_data_type cell_voltage_data;
    map_double_data_type cell_current_data;
    map_uint16_data_type cell_sequence_id_data;
    map_uint16_data_type cell_step_id_data;

    boost::asio::io_service &io_service;
    boost::asio::steady_timer cell_status_timer;

    // callbacks
    PortDoubleCallback port_double_callback;
    PortUint16Callback port_uint16_callback;
    ActiveCardsCallback active_cards_callback;
    ConnectionStatusCallback connection_status_callback;

    std::vector<std::vector<std::string>> last_valid_verbose_response;

    const std::string VISA_ADDRESS_BT2203A = "USB0::0x008D::0x3502::MY58000516::0::INSTR";  // usb address of battery cycler

    bool connected = false;
};

#endif