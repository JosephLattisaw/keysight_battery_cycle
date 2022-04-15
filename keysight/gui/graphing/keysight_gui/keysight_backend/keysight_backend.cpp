#include <boost/asio.hpp>
#include <iostream>

#include "backend.hpp"
#include "logger.hpp"
#include "types.hpp"

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
std::shared_ptr<Backend> backend;

void print_backend_doesnt_exist_error() { LOG_ERR << "backend: backend object doesn't exist "; }

static void FreeFinalizer(void *, void *value) { free(value); }

static void post_data_object(std::int64_t port, std::vector<std::uint8_t> data) {
    void *request_buffer = malloc(sizeof(uint8_t) * data.size());
    const size_t request_length = sizeof(uint8_t) * data.size();
    std::copy(data.begin(), data.end(), reinterpret_cast<std::uint8_t *>(request_buffer));

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kExternalTypedData;
    dart_object.value.as_external_typed_data.type = Dart_TypedData_kUint8;
    dart_object.value.as_external_typed_data.length = request_length;
    dart_object.value.as_external_typed_data.data = reinterpret_cast<std::uint8_t *>(request_buffer);
    dart_object.value.as_external_typed_data.peer = request_buffer;
    dart_object.value.as_external_typed_data.callback = FreeFinalizer;

    Dart_PostCObject_DL(port, &dart_object);
}

static void post_data_string(std::int64_t port, std::string str) {
    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kString;
    dart_object.value.as_string = &str[0];
    Dart_PostCObject_DL(port, &dart_object);
}

static void post_data_int(std::int64_t port, int val) {
    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kInt64;
    dart_object.value.as_int64 = val;
    Dart_PostCObject_DL(port, &dart_object);
}

static void post_data_bool(std::int64_t port, bool value) {
    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kBool;
    dart_object.value.as_bool = value;
    Dart_PostCObject_DL(port, &dart_object);
}
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

void create_backend(bool using_dart = false, std::int64_t load_sequences_port = 0, std::int64_t fin_load_sequences_port = 0,
                    std::int64_t load_steps_port = 0, std::int64_t load_tests_port = 0) {
    if (!backend)
        backend = std::make_shared<Backend>(io_service,
                                            [&, using_dart, load_sequences_port, fin_load_sequences_port](sequences_info_map_type sequences_info) {
                                                for (auto const &[name, val] : sequences_info) {
                                                    post_data_string(load_sequences_port, name);  // sending name

                                                    // sending info
                                                    for (auto const &info : val) {
                                                        post_data_string(load_sequences_port, info);
                                                    }
                                                }
                                            });
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

void load_all_sequences() {
    if (backend)
        backend->sequence_parser->load_all_sequences();
    else
        print_backend_doesnt_exist_error();
}

void run_service() {
    std::thread t([&] {
        work_guard_type work_guard(io_service.get_executor());
        io_service.run();
    });
    t.detach();
}
}

int main(int argc, char **argv) {
    io_service.run();
    return 0;
}