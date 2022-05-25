#ifndef SEQUENCE_PARSER_HPP
#define SEQUENCE_PARSER_HPP

#include "sequence.hpp"

namespace sequences {
class SequenceParser {
public:
    SequenceParser();

    void delete_sequence(std::string name);
    std::vector<std::shared_ptr<Sequence>> load_all_sequences();
    void save_sequence(std::shared_ptr<Sequence> sequence);

private:
    // constants
    const std::double_t API_VERSION_NUMBER = 1.0;
    const std::string SEQUENCES_FILENAME = "sequences.json";

    // path names
    const std::string API_PATHNAME = "api";
    const std::string SEQUENCES_PATHNAME = "sequences";
    const std::string STEPS_PATHNAME = "steps";
    const std::string TESTS_PATHNAME = "tests";
    const std::string COMMENTS_PATHNAME = "comments";

    // steps path names
    const std::string MODE_PATHNAME = "mode";
    const std::string DURATION_PATHNAME = "duration";
    const std::string CURRENT_LIMIT_PATHNAME = "current_limit";
    const std::string VOLTAGE_LIMIT_PATHNAME = "voltage_limit";

    // tests path names
    const std::string TEST_TYPE_PATHNAME = "test_type";
    const std::string TEST_ACTION_PATHNAME = "test_action";
    const std::string TEST_VALUE_PATHNAME = "value";
    const std::string TEST_TIME_TYPE_PATHNAME = "time_type";
    const std::string TEST_TIME_LIMIT_PATHNAME = "time_limit";
};

}  // namespace sequences

#endif