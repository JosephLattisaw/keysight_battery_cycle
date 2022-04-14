#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <boost/asio.hpp>
#include <memory>

#include "sequence_parser.hpp"

class Backend {
public:
    Backend(boost::asio::io_service &io_service);

    std::shared_ptr<SequenceParser> sequence_parser;

private:
    boost::asio::io_service &io_service;
};

#endif