#include "backend.hpp"

Backend::Backend(boost::asio::io_service &io_service, ConnectionStatusCallback _connection_status_callback)
    : io_service(io_service), connection_status_callback{_connection_status_callback} {
    sequence_parser = std::make_shared<sequences::SequenceParser>();
    keysight_thread = std::thread(std::bind(&Backend::worker_thread, this));
}

Backend::~Backend() {
    if (keysight_thread.joinable()) keysight_thread.join();
}

void Backend::worker_thread() {
    keysight = std::make_shared<Keysight>(keysight_service,
                                          [&](bool status) { io_service.post(std::bind(&Backend::connection_status_request, this, status)); });

    // letting the main thread know we've finsihed creating our keysight object and we
    // are ready to go.
    io_service.post(std::bind(&Backend::set_keysight_thread_is_up, this));

    // This stops the thread from exiting just because we don't have any tasks that currently
    // need completing
    boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work_guard(keysight_service.get_executor());
    keysight_service.run();
}

void Backend::set_keysight_thread_is_up() { keysight_thread_is_up = true; }

void Backend::connection_status_request(bool status) {}