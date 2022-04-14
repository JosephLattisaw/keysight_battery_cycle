#include "backend.hpp"

#include <memory>

Backend::Backend(boost::asio::io_service &io_service) : io_service(io_service) { sequence_parser = std::make_shared<SequenceParser>(); }
