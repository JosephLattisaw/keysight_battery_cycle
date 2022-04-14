#ifndef SEQUENCE_PARSER_HPP
#define SEQUENCE_PARSER_HPP

#include <any>
#include <functional>
#include <map>
#include <string>
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

class SequenceParser {
    using LoadSequencesCallback = std::function<void()>;

public:
    SequenceParser(LoadSequencesCallback load_sequences_callback);

    // function set for saving a sequence
    void add_save_sequence_step(int mode, int seconds, double current, double voltage);
    void add_save_sequence_test(int test_type, int test_action, double value, int time_type, int time_limit);
    void finish_save_sequence();
    void start_save_sequence(std::string name, std::string serial_number, std::string comments);

    void delete_sequence(std::string name);
    void load_all_sequences();

private:
    void delete_all_keys(const std::string &name);
    void delete_key(const std::string &name, std::map<std::string, std::any> &map) const;

    std::map<std::string, std::any> sequences_info;
    std::map<std::string, sequence_step_vector> sequences_steps;
    std::map<std::string, std::any> sequences_tests;
    std::string last_started_saved_sequence;

    LoadSequencesCallback load_sequences_callback;
};

#endif