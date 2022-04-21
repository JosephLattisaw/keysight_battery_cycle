#include "controller.hpp"

#include <thread>

#include "common.hpp"
#include "logger.hpp"
#include "types.hpp"

#define LOG_OUT LogOut("controller")
#define LOG_ERR LogOut("controller")

Controller::Controller(boost::asio::io_service& io_service, ActiveCardsCallback ac_cb, CapAhrDataCallback cahr_cb, CapWhrDataCallback cawh_cb)
    : io_service(io_service), active_cards_callback{ac_cb}, cap_ahr_data_callback{cahr_cb}, cap_whr_data_callback{cawh_cb} {
    // starting thread to start keysight stuff
    keysight_thread = std::thread(std::bind(&Controller::worker_thread, this));
}

Controller::~Controller() {
    if (keysight_thread.joinable()) keysight_thread.join();
}

void Controller::worker_thread() {
    // TODO should just double bind these if possible
    keysight = std::make_shared<Keysight>(
        keysight_service,
        [&](active_cards_type active_cards) {
            // active cells callback
            io_service.post(std::bind(&Controller::active_cards_request, this, active_cards));
        },
        [&](cap_ahr_data_type data) {
            // cap ahr data callback
            io_service.post(std::bind(&Controller::cap_ahr_data_request, this, data));
        },
        [&](cap_whr_data_type data) {
            // cap whr data callback
            io_service.post(std::bind(&Controller::cap_whr_data_request, this, data));
        });

    io_service.post(std::bind(&Controller::keysight_thread_is_up, this));

    // This stops the thread from exiting just because we don't have any tasks that currently
    // need completing
    boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work_guard(keysight_service.get_executor());
    keysight_service.run();
}

void Controller::active_cards_request(active_cards_type active_cards) { active_cards_callback(active_cards); }

void Controller::cap_ahr_data_request(cap_ahr_data_type cap_ahr_data) { cap_ahr_data_callback(cap_ahr_data); }

void Controller::cap_whr_data_request(cap_whr_data_type data) { cap_whr_data_callback(data); }

// TODO this should have some sort of conditional variable to wait for thread instead of this post thing
void Controller::keysight_thread_is_up() { keysight_service.post(std::bind(&Keysight::connect, keysight)); }