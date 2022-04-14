#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <boost/asio.hpp>
#include <functional>
#include <memory>

#include "sequence_parser.hpp"

class Backend {
    using LoadSequencesCallback = std::function<void()>;

public:
    Backend(boost::asio::io_service &io_service, LoadSequencesCallback load_sequences_callback);

    std::shared_ptr<SequenceParser> sequence_parser;

private:
    boost::asio::io_service &io_service;

    LoadSequencesCallback load_sequences_callback;
};

#endif