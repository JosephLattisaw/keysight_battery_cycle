#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <boost/asio.hpp>

#include "battery_cycler/keysight.hpp"
#include "sequences/sequence_parser.hpp"

class Backend {
public:
    Backend(boost::asio::io_service &io_service, ConnectionStatusCallback connection_status_callback);
    ~Backend();

    void connect_keysight();
    void disconnect_keysight();
    std::shared_ptr<sequences::SequenceParser> get_sequence_parser() { return sequence_parser; }

private:
    void connection_status_request(bool status);
    void set_keysight_thread_is_up();
    void worker_thread();

    // asynchronous services
    boost::asio::io_service &io_service;
    boost::asio::io_service keysight_service;

    // keysight
    std::thread keysight_thread;
    bool keysight_thread_is_up = false;
    std::shared_ptr<Keysight> keysight;

    std::shared_ptr<sequences::SequenceParser> sequence_parser;

    // callbacks
    ConnectionStatusCallback connection_status_callback;
};

#endif