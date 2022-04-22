#include "backend.hpp"

#include <iostream>
#include <memory>

Backend::Backend(boost::asio::io_service &io_service, ActiveCardsCallback ac_cb, LoadSequencesCallback ls_cb, ConnectionStatusCallback conn_cb,
                 PortDoubleCallback pd_cb, PortUint16Callback pu16_cb)
    : io_service(io_service),
      active_cards_callback{ac_cb},
      load_sequences_callback{ls_cb},
      connection_status_callback{conn_cb},
      port_double_callback{pd_cb},
      port_uint16_callback{pu16_cb} {
    sequence_parser = std::make_shared<SequenceParser>([&](sequences_info_map_type sequence_info) { load_sequences_callback(sequence_info); });

    // starting thread to start keysight stuff
    keysight_thread = std::thread(std::bind(&Backend::worker_thread, this));
}

Backend::~Backend() {
    if (keysight_thread.joinable()) keysight_thread.join();
}

void Backend::worker_thread() {
    // TODO should just double bind these if possible
    keysight = std::make_shared<Keysight>(
        keysight_service,
        [&](active_cards_type active_cards) {
            // active cells callback
            io_service.post(std::bind(&Backend::active_cards_request, this, active_cards));
        },
        [&](bool status) {
            // connection status
            io_service.post(std::bind(&Backend::connection_status_request, this, status));
        },
        [&](PortTypes::port_double_data_type data_type, map_double_data_type data) {
            // double data type
            io_service.post(std::bind(&Backend::port_double_data_request, this, data_type, data));
        },
        [&](PortTypes::port_uint16_data_type data_type, map_uint16_data_type data) {
            io_service.post(std::bind(&Backend::port_uint16_data_request, this, data_type, data));
        });

    io_service.post(std::bind(&Backend::keysight_thread_is_up, this));

    // This stops the thread from exiting just because we don't have any tasks that currently
    // need completing
    boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work_guard(keysight_service.get_executor());
    keysight_service.run();
}

void Backend::active_cards_request(active_cards_type active_cards) { active_cards_callback(active_cards); }

void Backend::connection_status_request(bool status) { connection_status_callback(status); }

void Backend::port_double_data_request(PortTypes::port_double_data_type data_type, map_double_data_type data) {
    port_double_callback(data_type, data);
}

void Backend::port_uint16_data_request(PortTypes::port_uint16_data_type data_type, map_uint16_data_type data) {
    port_uint16_callback(data_type, data);
}

// TODO this should have some sort of conditional variable to wait for thread instead of this post thing
void Backend::keysight_thread_is_up() {  // ysight_service.post(std::bind(&Keysight::connect, keysight));
}

void Backend::connect_keysight() { keysight_service.post(std::bind(&Keysight::connect, keysight)); }
void Backend::disconnect_keysight() { keysight_service.post(std::bind(&Keysight::disconnect, keysight)); }