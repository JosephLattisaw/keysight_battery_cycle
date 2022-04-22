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
    const std::size_t request_length = data.size();
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

static void post_data_object(std::int64_t port, std::vector<std::uint16_t> data) {
    void *request_buffer = malloc(sizeof(std::uint16_t) * data.size());
    const std::size_t request_length = data.size();
    std::copy(data.begin(), data.end(), reinterpret_cast<std::uint16_t *>(request_buffer));

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kExternalTypedData;
    dart_object.value.as_external_typed_data.type = Dart_TypedData_kUint16;
    dart_object.value.as_external_typed_data.length = request_length;
    dart_object.value.as_external_typed_data.data = reinterpret_cast<std::uint8_t *>(request_buffer);
    dart_object.value.as_external_typed_data.peer = request_buffer;
    dart_object.value.as_external_typed_data.callback = FreeFinalizer;

    Dart_PostCObject_DL(port, &dart_object);
}

static void post_data_object(std::int64_t port, std::vector<std::double_t> data) {
    void *request_buffer = malloc(sizeof(std::double_t) * data.size());
    const std::size_t request_length = data.size();
    std::copy(data.begin(), data.end(), reinterpret_cast<std::double_t *>(request_buffer));

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kExternalTypedData;
    dart_object.value.as_external_typed_data.type = Dart_TypedData_kFloat64;
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

namespace keysight {
extern ViSession resource_manager;
extern ViSession session;
}  // namespace keysight

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

    if (backend) {
        backend->sequence_parser->finish_save_sequence();
    } else
        print_backend_doesnt_exist_error();
}

void create_backend(bool using_dart = false, std::int64_t load_sequences_port = 0, std::int64_t fin_load_sequences_port = 0,
                    std::int64_t load_steps_port = 0, std::int64_t load_tests_port = 0, std::int64_t active_cards_port = 0,
                    std::int64_t keysight_connection_port = 0, std::int64_t keysight_double_port = 0, std::int64_t cell_state_port = 0,
                    std::int64_t cell_status_port = 0, std::int64_t keysight_uint16_port = 0) {
    if (!backend)
        backend = std::make_shared<Backend>(
            io_service,
            [&, using_dart, active_cards_port](active_cards_type data) {
                // active cells callback
                LOG_OUT << "got the active cards callback " << static_cast<int>(using_dart);
                if (using_dart) {
                    if (data.size() == 8) {
                        LOG_OUT << "posting data object: " << active_cards_port;
                        post_data_object(active_cards_port, data);
                    } else
                        LOG_ERR << "received invalid active cards size";
                }
            },
            [&, using_dart, load_sequences_port, fin_load_sequences_port](sequences_info_map_type sequences_info) {
                if (using_dart) {
                    for (auto const &[name, val] : sequences_info) {
                        post_data_string(load_sequences_port, name);  // sending name

                        // sending info
                        for (auto const &info : val) {
                            post_data_string(load_sequences_port, info);
                        }
                    }
                }
            },
            [&, using_dart, keysight_connection_port](bool status) {
                // connection callback status
                if (using_dart) {
                    LOG_OUT << "received connection status callback";
                    post_data_bool(keysight_connection_port, status);
                }
            },
            [&, using_dart, keysight_double_port](PortTypes::port_double_data_type data_type, map_double_data_type data) {
                if (using_dart) {
                    for (auto [key, val] : data) {
                        val.insert(val.begin(), key);        // second number is row
                        val.insert(val.begin(), data_type);  // first number is data type
                        post_data_object(keysight_double_port, val);
                    }
                }
            },
            [&, using_dart, keysight_uint16_port](PortTypes::port_uint16_data_type data_type, map_uint16_data_type data) {
                if (using_dart) {
                    for (auto [key, val] : data) {
                        val.insert(val.begin(), key);        // second number is row
                        val.insert(val.begin(), data_type);  // first number is data type
                        post_data_object(keysight_uint16_port, val);
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

void connect_keysight() {
    if (backend)
        backend->connect_keysight();
    else
        print_backend_doesnt_exist_error();
}

void disconnect_keysight() {
    if (backend)
        backend->disconnect_keysight();
    else
        print_backend_doesnt_exist_error();
}
}

int main(int argc, char **argv) {
    try {
        // TODO might not need all this gibberish if locking works correctly
        // boost::asio::io_service joe_service;
        // Block all signals for background thread.
        sigset_t new_mask;
        sigfillset(&new_mask);
        sigset_t old_mask;
        pthread_sigmask(SIG_BLOCK, &new_mask, &old_mask);

        boost::asio::io_service io_service;
        boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work_guard(io_service.get_executor());
        {
            std::thread t([&io_service] {
                Backend backend(
                    io_service,
                    [&](active_cards_type data) {
                        // active cells callback
                        std::cout << "got the active cards callback " << data.size() << std::endl;
                    },
                    [&](sequences_info_map_type sequences_info) {
                        // sequences info data callback
                    },
                    [&](bool) {
                        // connection callback status
                    },
                    [&](PortTypes::port_double_data_type data_type, map_double_data_type data) {

                    },
                    [&](PortTypes::port_uint16_data_type data_type, map_uint16_data_type data) {

                    });
                io_service.run();
            });
            t.detach();
        }

        // Restore previous signals.
        pthread_sigmask(SIG_SETMASK, &old_mask, 0);

        sigset_t wait_mask;
        sigemptyset(&wait_mask);
        sigaddset(&wait_mask, SIGINT);
        sigaddset(&wait_mask, SIGQUIT);
        sigaddset(&wait_mask, SIGTERM);
        pthread_sigmask(SIG_BLOCK, &wait_mask, 0);
        int sig = 0;
        sigwait(&wait_mask, &sig);

        work_guard.reset();
        viUnlock(keysight::session);
        viClose(keysight::session);

    } catch (std::exception &e) {
        std::cerr << "exception: " << e.what() << std::endl;
    }

    return 0;
}