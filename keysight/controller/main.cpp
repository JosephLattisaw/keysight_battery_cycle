#include <boost/asio.hpp>
#include <iostream>

#include "controller.hpp"
#include "visa.h"

int main(int, char**) {
    boost::asio::io_service io_service;

    Controller controller(io_service);

    io_service.run();

    return 0;
}
