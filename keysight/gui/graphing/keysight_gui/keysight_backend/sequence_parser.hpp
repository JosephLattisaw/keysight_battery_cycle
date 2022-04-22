#ifndef SEQUENCE_PARSER_HPP
#define SEQUENCE_PARSER_HPP

#include <any>
#include <functional>
#include <map>
#include <string>
#include <vector>

#include "types.hpp"

class SequenceParser {
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
    void clear_all_maps();
    void delete_all_keys(const std::string &name);
    void delete_key(const std::string &name, std::map<std::string, std::any> &map) const;

    sequences_info_map_type sequences_info;
    seqeunces_steps_map_type sequences_steps;
    sequences_tests_map_type sequences_tests;
    std::string last_started_saved_sequence;

    LoadSequencesCallback load_sequences_callback;
};

#endif