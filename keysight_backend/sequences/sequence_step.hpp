#ifndef SEQUENCE_STEP_HPP
#define SEQUENCE_STEP_HPP

#include <cmath>
#include <cstdint>
#include <memory>
#include <vector>

#include "../types.hpp"
#include "sequence_test.hpp"

namespace sequences {
class SequenceStep {
public:
    SequenceStep(std::uint8_t step_id, step::mode_type mode, std::int32_t duration, std::double_t current_limit, std::double_t voltage_limit,
                 std::vector<std::shared_ptr<SequenceTest>> tests);

    std::uint8_t get_step_id() { return step_id; }
    step::mode_type get_mode() { return mode; }
    std::int32_t get_duration() { return duration; }
    std::double_t get_current_limit() { return current_limit; }
    std::double_t get_voltage_limit() { return voltage_limit; }
    std::vector<std::shared_ptr<SequenceTest>> get_tests() { return tests; }

private:
    std::uint8_t step_id;
    step::mode_type mode;
    std::int32_t duration;
    std::double_t current_limit;
    std::double_t voltage_limit;
    std::vector<std::shared_ptr<SequenceTest>> tests;

    const std::int32_t MAX_PRECHARGE_DURATION_SECONDS = 900;
    const std::double_t MIN_CURRENT_LIMIT = 0.01;
    const std::double_t MAX_CURRENT_LIMIT = 6.25;
    const std::double_t MIN_VOLTAGE_LIMIT = 2.0;
    const std::double_t MAX_VOLTAGE_LIMIT = 4.5;
    const std::double_t MIN_VOLTAGE_LIMIT_PRECHARGE = 1.0;
    const std::double_t MAX_VOLTAGE_LIMIT_PRECHARGE = 2.0;
    const std::uint32_t MAX_TESTS_PER_STEP = 31;
};
}  // namespace sequences

#endif