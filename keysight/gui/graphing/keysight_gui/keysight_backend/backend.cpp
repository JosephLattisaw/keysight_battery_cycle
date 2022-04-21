#include "backend.hpp"

#include <iostream>
#include <memory>

Backend::Backend(boost::asio::io_service &io_service, LoadSequencesCallback ls_cb) : io_service(io_service), load_sequences_callback{ls_cb} {
    sequence_parser = std::make_shared<SequenceParser>([&](sequences_info_map_type sequence_info) { load_sequences_callback(sequence_info); });
}

Backend::~Backend() { std::cout << "BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" << std::endl; }