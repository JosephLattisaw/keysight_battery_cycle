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

struct Coordinate {
    double latitude;
    double longitude;
    std::int32_t joe[2];
    std::int32_t *jay;

    std::uint32_t size;
    const char *strings;
};

std::int32_t three[2] = {5, 4};
const char *joe[2] = {"joe", "joe1"};

struct Coordinate create_coordinate() {
    struct Coordinate coordinate;
    coordinate.longitude = 12.0;
    coordinate.latitude = 234.2;
    coordinate.joe[0] = 3;
    coordinate.joe[0] = 7;
    coordinate.jay = (std::int32_t *)malloc(2 * sizeof(coordinate.jay));
    coordinate.jay[0] = 12;
    coordinate.jay[1] = 5;
    coordinate.strings = *joe;

    return coordinate;
}

struct Test {
    std::uint32_t test_type;
    std::uint32_t test_action;
    double value;
    std::uint32_t time_type;
    int time_limit;
};

struct Step {
    std::uint32_t mode;
    std::uint32_t seconds;
    std::double_t current;
    std::double_t voltage;
    Test **tests;
    std::uint32_t tests_size;
};

struct Sequence {
    const char *name;
    const char *serial;
    const char *comments;
    Step **steps;
    std::uint32_t steps_size;
};

struct Sequences {
    Sequence **sequences;
    std::uint32_t size;
};

struct Sequences get_sequences() {
    std::cout << "get_sequences()" << std::endl;
    struct Sequences sequences;

    if (backend) {
        std::cout << "backend exists" << std::endl;
        auto load_map = backend->sequence_parser->load_all_sequences();
        auto sequence_info = load_map.at(0);
        auto sequence_steps = load_map.at(1);
        auto sequence_tests = load_map.at(2);

        sequences.size = sequence_info.size();
        sequences.sequences = (Sequence **)malloc(sequences.size * sizeof(Sequence *));

        int x = 0;
        for (const auto &i : sequence_info) {
            Sequence *seq = (Sequence *)malloc(sizeof(Sequence));
            sequences.sequences[x] = seq;
            x++;

            auto seq_info = std::any_cast<sequence_info_type>(i.second);

            auto name = i.first;
            auto serial = seq_info.at(SequenceTypes::SERIAL_NUMBER);
            auto comments = seq_info.at(SequenceTypes::COMMENTS);

            // copying the name
            char *name_c = (char *)malloc((name.length() + 1) * sizeof(char));
            std::strcpy(name_c, name.c_str());

            // copying the serial number
            char *serial_c = (char *)malloc((serial.length() + 1) * sizeof(char));
            std::strcpy(serial_c, serial.c_str());

            // copying the comments
            char *comments_c = (char *)malloc((comments.length() + 1) * sizeof(char));
            std::strcpy(comments_c, comments.c_str());

            // adding the names to our structure
            seq->name = name_c;
            seq->serial = serial_c;
            seq->comments = comments_c;

            // finding out how many steops we have in this sequence
            sequence_step_vector ssv;
            if (sequence_steps.find(i.first) != sequence_steps.end()) {
                // we found some sequence steps
                ssv = std::any_cast<sequence_step_vector>(sequence_steps.at(i.first));
            }

            seq->steps_size = ssv.size();  // recording the total amount of steps

            seq->steps = (Step **)malloc(seq->steps_size * sizeof(Step *));  // allocating space for steps

            // look to see if we have any test at all for this particular sequence
            sequence_test_map stm;
            if (sequence_tests.find(i.first) != sequence_tests.end()) {
                stm = std::any_cast<sequence_test_map>(sequence_tests.at(i.first));
            }

            for (auto k = 0; k < seq->steps_size; k++) {
                Step *step = (Step *)malloc(sizeof(Step));
                auto steps_info = ssv.at(k);

                // recording all of the values for the steps
                step->mode = steps_info.at(SequenceTypes::sequence_step_access_type::MODE);
                step->seconds = steps_info.at(SequenceTypes::sequence_step_access_type::SECONDS);
                step->current = steps_info.at(SequenceTypes::sequence_step_access_type::CURRENT);
                step->voltage = steps_info.at(SequenceTypes::sequence_step_access_type::VOLTAGE);

                seq->steps[k] = step;  // adding our step to the structure

                sequence_test_vector stv;

                // check if we have any tests for this sequence
                if (stm.find(k) != stm.end()) {
                    stv = stm.at(k);
                }

                // allocating the size of our test
                step->tests_size = stv.size();
                step->tests = (Test **)malloc(step->tests_size * sizeof(Test *));

                for (auto j = 0; j < stv.size(); j++) {
                    Test *test = (Test *)malloc(sizeof(Test));
                    auto stt = stv.at(j);
                    test->test_type = stt.at(SequenceTypes::sequence_test_access_type::TEST_TYPE);
                    test->test_action = stt.at(SequenceTypes::sequence_test_access_type::TEST_ACTION);
                    test->time_limit = stt.at(SequenceTypes::sequence_test_access_type::TIME_LIMIT);
                    test->time_type = stt.at(SequenceTypes::sequence_test_access_type::TIME_TYPE);
                    test->value = stt.at(SequenceTypes::sequence_test_access_type::VALUE);
                    step->tests[j] = test;
                }
            }
        }
    } else {
        sequences.size = 0;
    }

    return sequences;
    /*
        // Sequences -----------------------------------
        struct Sequences seqs;
        seqs.size = 2;
        seqs.sequences = (Sequence **)malloc(seqs.size * sizeof(Sequence *));
        //---------------------------------------------

        // Sequence ------------------------------------
        Sequence *seq1 = (Sequence *)malloc(sizeof(Sequence));
        seq1->steps_size = 1;

        std::string name = "joe2";
        std::string serial = "";
        std::string comments = "what is thissss?";

        char *name_c = (char *)malloc((name.length() + 1) * sizeof(char));
        strcpy(name_c, name.c_str());

        char *serial_c = (char *)malloc((serial.length() + 1) * sizeof(char));
        strcpy(serial_c, serial.c_str());

        char *comments_c = (char *)malloc((comments.length() + 1) * sizeof(char));
        strcpy(comments_c, comments.c_str());

        seq1->name = name_c;
        seq1->serial = serial_c;
        seq1->comments = comments_c;

        seq1->steps = (Step **)malloc(seq1->steps_size * sizeof(Step *));

        // steps 1------------------------------------------------
        Step *step1 = (Step *)malloc(sizeof(Step));
        step1->tests_size = 1;

        step1->mode = 3;
        step1->seconds = 2;
        step1->current = 3.0;
        step1->voltage = 24.0;

        seq1->steps[0] = step1;

        step1->tests = (Test **)malloc(step1->tests_size * sizeof(Test *));

        // test 1
        Test *test1 = (Test *)malloc(sizeof(Test));
        test1->test_action = 0;
        test1->test_type = 1;
        test1->time_limit = 2;
        test1->time_type = 3;
        test1->value = 34.3;
        step1->tests[0] = test1;

        // Sequence 2 ------------------------------------------
        Sequence *seq2 = (Sequence *)malloc(sizeof(Sequence));
        seq2->steps_size = 0;

        std::string name2 = "joe27";
        std::string serial2 = "323";
        std::string comments2 = "what is thissss?";

        char *name_c2 = (char *)malloc((name2.length() + 1) * sizeof(char));
        strcpy(name_c2, name2.c_str());

        char *serial_c2 = (char *)malloc((serial2.length() + 1) * sizeof(char));
        strcpy(serial_c2, serial2.c_str());

        char *comments_c2 = (char *)malloc((comments2.length() + 1) * sizeof(char));
        strcpy(comments_c2, comments2.c_str());

        seq2->name = name_c2;
        seq2->serial = serial_c2;
        seq2->comments = comments_c2;

        seqs.sequences[0] = seq1;
        seqs.sequences[1] = seq2;
        return seqs;*/
}

struct Sequence get_sequence(Sequences *seq) {
    std::cout << "get_sequence called" << std::endl;
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