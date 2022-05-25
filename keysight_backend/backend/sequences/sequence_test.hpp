#ifndef SEQUENCE_TEST_HPP
#define SEQUENCE_TEST_HPP

#include <cmath>
#include <cstdint>

#include "../types.hpp"

namespace sequences {
class SequenceTest {
public:
    SequenceTest(std::uint8_t test_id, test::test_type_t test_type, std::double_t value, test::time_type_t time_type, std::uint32_t time_limit,
                 test::test_action_type test_action);

    std::uint8_t get_test_id() { return test_id; }
    test::test_type_t get_test_type() { return test_type; }
    std::double_t get_value() { return value; }
    test::time_type_t get_time_type() { return time_type; }
    std::uint32_t get_time_limit() { return time_limit; }
    test::test_action_type get_test_action() { return test_action; }

private:
    std::uint8_t test_id;
    test::test_type_t test_type;
    std::double_t value;
    test::time_type_t time_type;
    std::uint32_t time_limit;
    test::test_action_type test_action;

    const std::uint8_t MAX_TEST_ID = 31;
    const std::uint32_t MIM_TIME_LIMIT_SECONDS = 20;
};
}  // namespace sequences

#endif