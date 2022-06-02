
#include <boost/asio.hpp>
#include <logger.hpp>

#include "backend.hpp"

// dart api headers
#include "include/dart_api.h"
#include "include/dart_api_dl.h"
#include "include/dart_native_api.h"

#define LOG_OUT LogOut("keysight backend")
#define LOG_ERR LogErr("keysight backend")

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

using work_guard_type = boost::asio::executor_work_guard<boost::asio::io_context::executor_type>;

namespace {
// These are needed for the actual backend
// Creating an actual object within frontend is overtly complicated and still being developed within
// the language itself. No one should be accessing these outside of the library itself
boost::asio::io_service io_service;
std::shared_ptr<Backend> backend;

void print_backend_doesnt_exist_error() { LOG_ERR << "backend object doesn't exist"; }

// Test for Seqeunce
struct Test {
    std::uint8_t test_type;
    std::uint8_t test_action;
    std::double_t value;
    std::uint8_t time_type;
    std::uint32_t time_limit;
};

// Step for Seqeuence
struct Step {
    std::uint8_t mode;
    std::uint32_t seconds;
    std::double_t current;
    std::double_t voltage;
    Test **tests;
    std::uint32_t tests_size;
};

struct Sequence {
    const char *name;
    const char *comments;
    Step **steps;
    std::uint32_t steps_size;
};

struct Sequences {
    Sequence **sequences;
    std::uint32_t size;
};

char *copy_string_get_ptr(std::string name) {
    char *result = (char *)malloc((name.length() + 1) * sizeof(char));
    std::strcpy(result, name.c_str());

    return result;
}
}  // namespace

extern "C" {
EXPORT std::intptr_t InitializeDartApi(void *data) { return Dart_InitializeApiDL(data); }

EXPORT void create_backend() {
    if (!backend) {
        backend = std::make_shared<Backend>(io_service);
    } else
        print_backend_doesnt_exist_error();
}

EXPORT void run_service() {
    std::thread t([&] {
        work_guard_type work_guard(io_service.get_executor());
        io_service.run();
    });
    t.detach();
}

EXPORT struct Sequences get_sequences() {
    LOG_OUT << "get_seqeunces()";
    struct Sequences sequences;

    if (backend) {
        auto seqs_vec = backend->get_sequence_parser()->load_all_sequences();

        // allocating our sequences size
        sequences.size = seqs_vec.size();
        sequences.sequences = (Sequence **)malloc(sequences.size * sizeof(Sequence *));

        int x = 0;
        for (const auto &i : seqs_vec) {
            Sequence *seq = (Sequence *)malloc(sizeof(Sequence));
            sequences.sequences[x] = seq;
            x++;

            // adding names to our structure
            seq->name = copy_string_get_ptr(i->get_name());
            seq->comments = copy_string_get_ptr(i->get_comments());

            auto steps = i->get_steps();

            // recording the total amount of steps and allocating space
            seq->steps_size = steps.size();
            seq->steps = (Step **)malloc(seq->steps_size * sizeof(Step *));

            for (auto k = 0; k < seq->steps_size; k++) {
                Step *step = (Step *)malloc(sizeof(Step));
                auto step_obj = steps.at(k);

                // setting all of our values for the step
                step->mode = static_cast<std::uint8_t>(step_obj->get_mode());
                step->seconds = step_obj->get_duration();
                step->current = step_obj->get_current_limit();
                step->voltage = step_obj->get_voltage_limit();

                seq->steps[k] = step;

                auto tests = step_obj->get_tests();

                // setting size and allocating space for tests
                step->tests_size = tests.size();
                step->tests = (Test **)malloc(step->tests_size * sizeof(Test *));

                for (auto j = 0; j < tests.size(); j++) {
                    Test *test = (Test *)malloc(sizeof(Test *));
                    auto test_obj = tests.at(j);

                    test->test_type = static_cast<decltype(test->test_type)>(test_obj->get_test_type());
                    test->test_action = static_cast<decltype(test->test_action)>(test_obj->get_test_action());
                    test->time_limit = test_obj->get_time_limit();
                    test->time_type = static_cast<decltype(test->time_type)>(test_obj->get_time_type());
                    test->value = test_obj->get_value();
                    step->tests[j] = test;
                }
            }
        }
    } else {
        sequences.size = 0;
    }

    return sequences;
}
}

int main(int argc, char **argv) { return 0; }