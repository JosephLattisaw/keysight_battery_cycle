#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <visa.h>

#include <boost/asio.hpp>
#include <functional>
#include <memory>

#include "keysight.hpp"
#include "sequence_parser.hpp"
#include "types.hpp"

class Backend {
public:
    Backend(boost::asio::io_service &io_service, ActiveCardsCallback active_cards_callback, ConnectionStatusCallback connection_status_callback,
            PortDoubleCallback port_double_callback, PortUint16Callback port_uint16_callback);
    ~Backend();

    // TODO find out if we can make this private
    void active_cards_request(active_cards_type active_cards);
    void connection_status_request(bool status);
    void port_double_data_request(PortTypes::port_double_data_type data_type, map_double_data_type data);
    void port_uint16_data_request(PortTypes::port_uint16_data_type data_type, map_uint16_data_type data);

    std::shared_ptr<SequenceParser> sequence_parser;

    void connect_keysight();
    void disconnect_keysight();

private:
    // thread management
    void keysight_thread_is_up();  // TODO this will get removed
    void worker_thread();

    boost::asio::io_service &io_service;
    boost::asio::io_service keysight_service;

    std::shared_ptr<Keysight> keysight;
    std::thread keysight_thread;

    // callbacks
    ActiveCardsCallback active_cards_callback;
    ConnectionStatusCallback connection_status_callback;
    PortDoubleCallback port_double_callback;
    PortUint16Callback port_uint16_callback;
};

#endif