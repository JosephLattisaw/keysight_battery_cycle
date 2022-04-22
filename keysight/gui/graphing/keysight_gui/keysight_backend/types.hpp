#ifndef BACKEND_TYPES_HPP
#define BACKEND_TYPES_HPP

#include <array>
#include <map>
#include <vector>

// TODO
// create an array of maps or a map of maps so we can iterate through them
typedef std::array<std::string, 2> sequence_info_type;
typedef std::array<double, 4> sequence_step_type;
typedef std::array<double, 5> sequence_test_type;

typedef std::vector<sequence_step_type> sequence_step_vector;
typedef std::vector<sequence_test_type> sequence_test_vector;

typedef std::map<std::string, sequence_info_type> sequence_info_map;
typedef std::map<int, sequence_test_vector> sequence_test_map;

typedef std::map<std::string, sequence_info_type> sequences_info_map_type;
typedef std::map<std::string, sequence_step_vector> seqeunces_steps_map_type;
typedef std::map<std::string, sequence_test_map> sequences_tests_map_type;

namespace SequenceTypes {
enum sequence_info_access_type {
    SERIAL_NUMBER = 0,
    COMMENTS = 1,
};

enum sequence_step_access_type {
    MODE = 0,
    SECONDS = 1,
    CURRENT = 2,
    VOLTAGE = 3,
};

enum sequence_test_access_type {
    TEST_TYPE = 0,
    TEST_ACTION = 1,
    VALUE = 2,
    TIME_TYPE = 3,
    TIME_LIMIT = 4,
};
}  // namespace SequenceTypes

typedef std::vector<std::uint8_t> active_cards_type;
typedef std::map<int, std::vector<double>> map_double_data_type;
typedef std::map<int, std::vector<std::string>> state_data_type;
typedef std::map<int, std::vector<std::string>> status_data_type;
typedef std::map<int, std::vector<std::uint16_t>> map_uint16_data_type;

namespace PortTypes {
enum port_double_data_type {
    CAP_AHR = 0,
    CAP_WHR = 1,
    VOLTAGE = 2,
    CURRENT = 3,
};

enum port_string_data_type {
    STATE,
    STATUS,
};

enum port_uint16_data_type {
    SEQUENCE = 0,
    STEP = 1,
};
}  // namespace PortTypes

using ActiveCardsCallback = std::function<void(active_cards_type)>;
using ConnectionStatusCallback = std::function<void(bool)>;
using LoadSequencesCallback = std::function<void(sequences_info_map_type)>;

using PortDoubleCallback = std::function<void(PortTypes::port_double_data_type, map_double_data_type)>;
using PortUint16Callback = std::function<void(PortTypes::port_uint16_data_type, map_uint16_data_type)>;

#endif