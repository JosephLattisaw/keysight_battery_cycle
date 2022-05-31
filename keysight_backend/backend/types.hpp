#ifndef BACKEND_TYPES_HPP
#define BACKEND_TYPES_HPP

#include <functional>

namespace sequences {
namespace step {
const std::uint8_t MAX_SEQUENCE_ID = 7;
enum class mode_type : std::uint8_t {
    PRECHARGE = 0,
    CHARGE = 1,
    DISCHARGE = 2,
    REST = 3,
};
}  // namespace step

namespace test {
enum class test_type_t : std::uint8_t {
    NONE = 0,
    VOLT_GE = 1,
    VOLT_LE = 2,
    CURR_GE = 3,
    CURR_LE = 4,
    POWER_GE = 5,
    POWER_LE = 6,
    AMPH_GE = 7,
    AMPH_LE = 8,
    WATTH_GE = 9,
    WATTH_LE = 10,
    POS_DVDT_GE = 11,
    POS_DVDT_LE = 12,
    NEG_DVDT_GE = 13,
    NEG_DVDT_LE = 14,
    POS_DIDT_GE = 15,
    POS_DIDT_LE = 16,
    NEG_DIDT_GE = 17,
    NEG_DIDT_LE = 18,
    DVMAX_GE = 19,
    DVMAX_LE = 20,
    DVMIN_GE = 21,
    DVMIN_LE = 22,
    DIMAX_GE = 23,
    DIMAX_LE = 24,
    DIMIN_GE = 25,
    DIMIN_LE = 26,
};

enum class time_type_t : std::uint8_t {
    AT = 0,
    AFTER = 1,
    BEFORE = 2,
    BEFORE_START = 3,
};

enum class test_action_type : std::uint8_t {
    FAIL = 0,
    NEXT = 1,
};
}  // namespace test
}  // namespace sequences

using ConnectionStatusCallback = std::function<void(bool)>;

#endif