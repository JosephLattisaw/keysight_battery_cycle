#include "backend.hpp"

#include <memory>

Backend::Backend(boost::asio::io_service &io_service, LoadSequencesCallback ls_cb) : io_service(io_service), load_sequences_callback{ls_cb} {
    sequence_parser = std::make_shared<SequenceParser>([&] { load_sequences_callback(); });
}
