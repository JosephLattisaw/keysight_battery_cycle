#include "sequence_step.hpp"

#include <cassert>

namespace sequences {
SequenceStep::SequenceStep(std::uint8_t _step_id, step::mode_type _mode, std::int32_t _duration, std::double_t _current_limit,
                           std::double_t _voltage_limit, std::vector<std::shared_ptr<SequenceTest>> _tests)
    : step_id(_step_id), mode(_mode), duration(_duration), current_limit(_current_limit), voltage_limit(_voltage_limit), tests(_tests) {
    // duration checks
    assert((duration >= 1) && "minumum duration was not set");
    if (mode == step::mode_type::PRECHARGE) {
        assert((duration <= MAX_PRECHARGE_DURATION_SECONDS) && "duration for precharge not less than maximum allowed");
    }

    // current limit checks
    assert((current_limit >= MIN_CURRENT_LIMIT) && "current limit cannot be less than minimum allowed");
    assert((current_limit <= MAX_CURRENT_LIMIT) && "current limit cannot be more than maximum allowed");

    // voltage limit checks
    if (mode == step::mode_type::PRECHARGE) {
        assert((voltage_limit >= MIN_VOLTAGE_LIMIT_PRECHARGE) && "precharge voltage limit cannot be less than minimum allowed");
        assert((voltage_limit <= MAX_VOLTAGE_LIMIT_PRECHARGE) && "precharge voltage limit cannot be greater than maximum allowed");
    } else {
        assert((voltage_limit >= MIN_VOLTAGE_LIMIT) && "voltage limit cannot be less than minimum allowed");
        assert((voltage_limit <= MAX_VOLTAGE_LIMIT) && "voltage limit cannot be greater than maximum allowed");
    }

    // tests size check
    assert((tests.size() <= MAX_TESTS_PER_STEP) && "total test per step must be less than minimum allowed");
}
}  // namespace sequences