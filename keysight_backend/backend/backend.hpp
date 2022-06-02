#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <boost/asio.hpp>

#include "battery_cycler/keysight.hpp"

class Backend {
public:
    Backend(boost::asio::io_service &io_service);

private:
    void keysight_thread_is_up();
    void worker_thread();

    boost::asio::io_service &io_service;
    boost::asio::io_service keysight_service;

    std::thread keysight_thread;
    std::shared_ptr<Keysight> keysight;
};

#endif