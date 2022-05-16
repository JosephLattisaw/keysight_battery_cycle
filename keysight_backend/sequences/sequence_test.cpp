#include "sequence_test.hpp"

#include <cassert>
namespace sequences {
SequenceTest::SequenceTest(std::uint8_t _test_id, test::test_type_t _test_type, std::double_t _value, test::time_type_t _time_type,
                           std::uint32_t _time_limit, test::test_action_type _test_action)
    : test_id(_test_id), test_type(_test_type), value(_value), time_type(_time_type), time_limit(_time_limit), test_action(_test_action) {
    // test id checks
    assert((test_id <= MAX_TEST_ID) && "test id was greater than maximum test id");

    // time limit checks
    assert((time_limit >= MIM_TIME_LIMIT_SECONDS) && "time limit was less than minimum time limit");
}
}  // namespace sequences