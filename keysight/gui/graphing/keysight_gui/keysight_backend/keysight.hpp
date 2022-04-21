#ifndef KEYSIGHT_HPP
#define KEYSIGHT_HPP

#include <visa.h>

#include <boost/asio.hpp>

#include "types.hpp"

#define SOFTWARE_ONLY 1

class Keysight {
public:
    using ActiveCardsCallback = std::function<void(active_cards_type)>;
    using CapAhrDataCallback = std::function<void(cap_ahr_data_type)>;
    using CapWhrDataCallback = std::function<void(cap_whr_data_type)>;
    using ConnectionStatusCallback = std::function<void(bool)>;

    Keysight(boost::asio::io_service &io_service, ActiveCardsCallback active_cards_callback, CapAhrDataCallback cap_ahr_data_callback,
             CapWhrDataCallback cap_whr_data_callback, ConnectionStatusCallback connection_status_callback);
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
    bool get_cap_ahr();
    bool get_cap_whr();
    bool get_cell_verbose();

    // polling
    void start_polling_cell_status();

    void update_connection_status(bool flag);

    // data
    active_cards_type active_cards;
    std::vector<std::string> cell_names;
    cap_ahr_data_type cell_cap_ahr_data;
    cap_whr_data_type cell_cap_whr_data;

    boost::asio::io_service &io_service;
    boost::asio::steady_timer cell_status_timer;

    // callbacks
    ActiveCardsCallback active_cards_callback;
    CapAhrDataCallback cap_ahr_data_callback;
    CapWhrDataCallback cap_whr_data_callback;
    ConnectionStatusCallback connection_status_callback;

    const std::string VISA_ADDRESS_BT2203A = "USB0::0x008D::0x3502::MY58000516::0::INSTR";  // usb address of battery cycler

    bool connected = false;
};

#endif