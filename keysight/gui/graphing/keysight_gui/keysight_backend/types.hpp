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

typedef std::vector<std::uint8_t> active_cards_type;
typedef std::map<int, std::vector<double>> cap_ahr_data_type;
typedef std::map<int, std::vector<double>> cap_whr_data_type;

#endif