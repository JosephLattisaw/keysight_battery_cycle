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

namespace {
// These are needed for the actual backend
// Creating an actual object within frontend is overtly complicated and still being developed within
// the language itself. No one should be accessing these outside of the library itself
boost::asio::io_service io_service;
std::shared_ptr<Backend> backend;

void print_backend_doesnt_exist_error() { LOG_ERR << "backend: backend object doesn't exist"; }
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
    if (backend) {
        backend->sequence_parser->finish_save_sequence();
    } else
        print_backend_doesnt_exist_error();
}

void create_backend(bool using_dart = false) {
    if (!backend)
        backend = std::make_shared<Backend>();
    else
        print_backend_doesnt_exist_error();
}
}

int main(int argc, char **argv) {
    io_service.run();
    return 0;
}