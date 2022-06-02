#include "backend.hpp"

Backend::Backend(boost::asio::io_service &io_service) : io_service(io_service) {
    keysight_thread = std::thread(std::bind(&Backend::worker_thread, this));
}

void Backend::worker_thread() {
    keysight = std::make_shared<Keysight>(keysight_service, [&](bool status) {

    });

    // letting the main thread know we've finsihed creating our keysight object and we
    // are ready to go.
    io_service.post(std::bind(&Backend::keysight_thread_is_up, this));

    // This stops the thread from exiting just because we don't have any tasks that currently
    // need completing
    boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work_guard(keysight_service.get_executor());
    keysight_service.run();
}

void Backend::keysight_thread_is_up() {}