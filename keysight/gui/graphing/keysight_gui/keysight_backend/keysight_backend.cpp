#include <boost/asio.hpp>
#include <iostream>

#include "backend.hpp"
#include "logger.hpp"

// dart api headers
#include "include/dart_api.h"
#include "include/dart_api_dl.h"
#include "include/dart_native_api.h"

#define LOG_OUT LogOut("keysight backend")
#define LOG_ERR LogOut("keysight backend")

using work_guard_type = boost::asio::executor_work_guard<boost::asio::io_context::executor_type>;

namespace {
// These are needed for the actual backend
// Creating an actual object within frontend is overtly complicated and still being developed within
// the language itself. No one should be accessing these outside of the library itself
boost::asio::io_service io_service;
Backend *backend = nullptr;

void print_backend_doesnt_exist_error() { LOG_ERR << "backend: backend object doesn't exist "; }
}  // namespace

extern "C" {
DART_EXPORT intptr_t InitializeDartApi(void *data) { return Dart_InitializeApiDL(data); }

// saving a sequence
void start_save_sequence(const char *name, const char *serial_number, const char *comments) {
    if (backend) {
        backend->sequence_parser->start_save_sequence(name, serial_number, comments);
    } else
        print_backend_doesnt_exist_error();
}

void add_save_sequence_step(int mode, int seconds, double current, double voltage) {
    if (backend) {
        backend->sequence_parser->add_save_sequence_step(mode, seconds, current, voltage);
    } else
        print_backend_doesnt_exist_error();
}

void add_save_sequence_test(int test_type, int test_action, double value, int time_type, int time_limit) {
    if (backend) {
        backend->sequence_parser->add_save_sequence_test(test_type, test_action, value, time_type, time_limit);
    } else
        print_backend_doesnt_exist_error();
}

void finish_save_sequence() {
    std::thread::id this_id = std::this_thread::get_id();
    std::cout << "this thread: " << this_id << std::endl;

    if (backend) {
        backend->sequence_parser->finish_save_sequence();
    } else
        print_backend_doesnt_exist_error();
}

void create_backend(bool using_dart = false) {
    if (!backend)
        // backend = std::make_shared<Backend>(io_service);
        backend = new Backend(io_service);
    else
        print_backend_doesnt_exist_error();
}

void sequence_remove(const char *name) {
    if (backend) {
        LOG_OUT << "seq remove works";
        backend->sequence_parser->delete_sequence(name);
    } else
        print_backend_doesnt_exist_error();
}

void run_service() {
    std::thread t([&] {
        // work_guard_type work_guard(io_service.get_executor());
        io_service.run();
    });
    t.detach();
}
}

int main(int argc, char **argv) {
    io_service.run();
    return 0;
}