#include "backend.hpp"

#include <iostream>
#include <memory>

#include "logger.hpp"

#define LOG_OUT LogOut("backend")
#define LOG_ERR LogOut("backend")

Backend::Backend(boost::asio::io_service &io_service, ActiveCardsCallback ac_cb, ConnectionStatusCallback conn_cb, PortDoubleCallback pd_cb,
                 PortUint16Callback pu16_cb, LoadedProfilesCallback lp_cb, ProfilesStatusCallback ps_cb)
    : io_service(io_service),
      active_cards_callback{ac_cb},
      connection_status_callback{conn_cb},
      port_double_callback{pd_cb},
      port_uint16_callback{pu16_cb},
      loaded_profiles_callback{lp_cb},
      profiles_status_callback{ps_cb} {
    sequence_parser = std::make_shared<SequenceParser>();

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
        },
        [&](loaded_profile_type loaded_profiles) { io_service.post(std::bind(&Backend::loaded_profiles_request, this, loaded_profiles)); },
        [&](profile_status_type statuses) { io_service.post(std::bind(&Backend::profile_statuses_request, this, statuses)); });

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

void Backend::loaded_profiles_request(loaded_profile_type profiles) { loaded_profiles_callback(profiles); }

void Backend::profile_statuses_request(profile_status_type statuses) { profiles_status_callback(statuses); };

// TODO this should have some sort of conditional variable to wait for thread instead of this post thing
void Backend::keysight_thread_is_up() {  // ysight_service.post(std::bind(&Keysight::connect, keysight));
}

void Backend::connect_keysight() { keysight_service.post(std::bind(&Keysight::connect, keysight)); }
void Backend::disconnect_keysight() { keysight_service.post(std::bind(&Keysight::disconnect, keysight)); }

void Backend::load_profile(std::string name, int slot, sequence_step_vector steps, sequence_test_map tests) {
    LOG_OUT << "load profile called";
    keysight_service.post(std::bind(&Keysight::load_sequence, keysight, name, slot, steps, tests));
}

void Backend::start_sequence(std::uint32_t slot, std::vector<std::uint32_t> cells) {
    LOG_OUT << "start sequence called";
    keysight_service.post(std::bind(&Keysight::start_sequence, keysight, slot, cells));
}