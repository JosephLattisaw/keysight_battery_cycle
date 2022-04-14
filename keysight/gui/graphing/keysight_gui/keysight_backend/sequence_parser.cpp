#include "sequence_parser.hpp"

#include <unistd.h>

#include <boost/property_tree/ini_parser.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <boost/property_tree/ptree.hpp>
#include <iostream>

#include "logger.hpp"

#define LOG_OUT LogOut("sequence_parser")
#define LOG_ERR LogOut("sequence parser")

typedef std::array<std::string, 2> sequence_info_type;
typedef std::array<double, 4> sequence_step_type;
typedef std::array<double, 5> sequence_test_type;

typedef std::vector<sequence_step_type> sequence_step_vector;
typedef std::vector<sequence_test_type> sequence_test_vector;

typedef std::map<std::string, sequence_info_type> sequence_info_map;
typedef std::map<int, sequence_test_vector> sequence_test_map;

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

SequenceParser::SequenceParser() {}

void SequenceParser::start_save_sequence(std::string name, std::string serial_number, std::string comments) {
    LOG_OUT << "saving sequence called, name: " << name << ", serial number: " << serial_number << ", comments: " << comments;

    last_started_saved_sequence = name;

    // first things first, clear any instances of a sequence by that name
    delete_all_keys(name);

    // next step is adding sequence to the sequence info map
    sequences_info.insert({name, sequence_info_type{serial_number, comments}});
}

void SequenceParser::add_save_sequence_step(int mode, int seconds, double current, double voltage) {
    LOG_OUT << "add save sequence step called, mode: " << mode << ", seconds: " << seconds << ", current: " << current << ", voltage: " << voltage;
    if (sequences_steps.find(last_started_saved_sequence) == sequences_steps.end()) {
        LOG_OUT << "attempting to add first step to a sequence";
        sequences_steps.insert(
            {last_started_saved_sequence, sequence_step_vector{{static_cast<double>(mode), static_cast<double>(seconds), current, voltage}}});
    } else {
        LOG_OUT << "attempting to add additional step to a sequence";
        sequence_step_vector x = std::any_cast<sequence_step_vector>(sequences_steps.at(last_started_saved_sequence));
        x.push_back({static_cast<double>(mode), static_cast<double>(seconds), current, voltage});

        sequences_steps.at(last_started_saved_sequence) = x;
    }
}

void SequenceParser::add_save_sequence_test(int test_type, int test_action, double value, int time_type, int time_limit) {
    LOG_OUT << "add save sequence test called, test type: " << test_type << ", test action: " << test_action << ", value: " << value
            << ", time type: " << time_type << ", time limit: " << time_limit;
    if (sequences_tests.find(last_started_saved_sequence) == sequences_tests.end()) {
        LOG_OUT << "attempting to add first test to a sequence step";
        sequence_test_map test_map;

        auto steps = std::any_cast<sequence_step_vector>(sequences_steps.at(last_started_saved_sequence));
        test_map.insert({steps.size() - 1, sequence_test_vector{{static_cast<double>(test_type), static_cast<double>(test_action), value,
                                                                 static_cast<double>(time_type), static_cast<double>(time_limit)}}});

        sequences_tests.insert({last_started_saved_sequence, test_map});
    } else {
        LOG_OUT << "attempting to add next step to test in a sequence step";

        // first thing is to get the number step we are on
        auto total_steps = std::any_cast<sequence_step_vector>(sequences_steps.at(last_started_saved_sequence)).size();

        // now we add to the mapping
        std::any_cast<sequence_test_map>(sequences_tests.at(last_started_saved_sequence))
            .at(total_steps)
            .push_back({static_cast<double>(test_type), static_cast<double>(test_action), value, static_cast<double>(time_type),
                        static_cast<double>(time_limit)});
    }
}

void SequenceParser::delete_sequence(std::string name) {
    LOG_OUT << "delete sequence called: " << name;

    boost::property_tree::ptree property_tree;
    try {
        boost::property_tree::json_parser::read_json("sequences.json", property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
    }

    property_tree.erase(name);

    boost::property_tree::json_parser::write_json("sequences.json", property_tree);
}

void SequenceParser::finish_save_sequence() {
    LOG_OUT << "finish save sequence called";
    boost::property_tree::ptree property_tree;
    try {
        // boost::property_tree::ini_parser::read_ini("sequences.ini", property_tree);
        boost::property_tree::json_parser::read_json("sequences.json", property_tree);
        //} catch (const boost::property_tree::ini_parser::ini_parser_error &e) {
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
    }

    // putting in an api number in case we ever change up the format after a versions been released
    property_tree.put("api", 1.0);

    // delete the node (because we are overwriting it)
    property_tree.erase(last_started_saved_sequence);

    // first we're going to get the sequences info
    auto info = std::any_cast<sequence_info_type>(sequences_info.at(last_started_saved_sequence));

    // place the sequences info in the property tree
    property_tree.put(last_started_saved_sequence + ".serial_number", info.at(sequence_info_access_type::SERIAL_NUMBER));
    property_tree.put(last_started_saved_sequence + ".comments", info.at(sequence_info_access_type::COMMENTS));

    // get the sequences steps
    sequence_step_vector steps;
    sequence_test_map test_map;

    if (sequences_steps.find(last_started_saved_sequence) != sequences_steps.end()) {
        steps = std::any_cast<sequence_step_vector>(sequences_steps.at(last_started_saved_sequence));
        LOG_OUT << "found total steps: " << steps.size();
    }

    if (sequences_tests.find(last_started_saved_sequence) != sequences_tests.end()) {
        test_map = std::any_cast<sequence_test_map>(sequences_tests.at(last_started_saved_sequence));
    }

    // placing the steps in the property tree
    for (auto i = 0; i < steps.size(); i++) {
        auto s = steps.at(i);
        property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".mode", s.at(sequence_step_access_type::MODE));
        property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".seconds", s.at(sequence_step_access_type::SECONDS));
        property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".current", s.at(sequence_step_access_type::CURRENT));
        property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".voltage", s.at(sequence_step_access_type::VOLTAGE));

        if (test_map.find(i) != test_map.end()) {
            auto stv = test_map.at(i);
            for (auto k = 0; k < stv.size(); k++) {
                auto st = stv.at(k);
                property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".test_type",
                                  st.at(sequence_test_access_type::TEST_TYPE));
                property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".test_action",
                                  st.at(sequence_test_access_type::TEST_ACTION));
                property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".value",
                                  st.at(sequence_test_access_type::VALUE));
                property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".time_type",
                                  st.at(sequence_test_access_type::TIME_TYPE));
                property_tree.put(last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".time_limit",
                                  st.at(sequence_test_access_type::TIME_LIMIT));
            }
        }
    }

    char tmp[66535];
    getcwd(tmp, 65535);

    // boost::property_tree::ini_parser::write_ini("sequences.ini", property_tree);
    boost::property_tree::json_parser::write_json("sequences.json", property_tree);
    LOG_OUT << "finished writing sequence: " << tmp;
}

void SequenceParser::delete_key(const std::string &name, std::map<std::string, std::any> &map) const {
    // key was found if this happens
    if (map.find(name) != map.end()) {
        map.erase(name);
    }
}

void SequenceParser::delete_all_keys(const std::string &name) {
    std::array<std::map<std::string, std::any>, 3> key_array = {sequences_info, sequences_steps, sequences_tests};

    for (auto i : key_array) {
        delete_key(name, i);
    }

    sequences_info = key_array.at(0);
    sequences_steps = key_array.at(1);
    sequences_tests = key_array.at(2);
}