#include "sequence_parser.hpp"

#include <boost/property_tree/ini_parser.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <boost/property_tree/ptree.hpp>
#include <iostream>

#include "logger.hpp"

#define LOG_OUT LogOut("sequence_parser")
#define LOG_ERR LogOut("sequence parser")

// typedef std::vector<sequence_step_type> sequence_step_vector;
// typedef std::vector<sequence_test_type> sequence_test_vector;

// typedef std::map<std::string, sequence_info_type> sequence_info_map;
// typedef std::map<int, sequence_test_vector> sequence_test_map;

SequenceParser::SequenceParser() {}

void SequenceParser::start_save_sequence(std::string name, std::string serial_number, std::string comments) {
    LOG_OUT << "saving sequence called, name: " << name << ", serial number: " << serial_number << ", comments: " << comments;

    last_started_saved_sequence = name;

    // first things first, clear any instances of a sequence by that name
    clear_all_maps();

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
        sequence_step_vector x = std::any_cast<sequence_step_vector>(sequences_steps.at(last_started_saved_sequence));
        LOG_OUT << "attempting to add additional step to a sequence " << x.size() << " name: " << last_started_saved_sequence;
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
        LOG_OUT << "steps size: " << steps.size();
        test_map.insert({steps.size() - 1, sequence_test_vector{{static_cast<double>(test_type), static_cast<double>(test_action), value,
                                                                 static_cast<double>(time_type), static_cast<double>(time_limit)}}});

        sequences_tests.insert({last_started_saved_sequence, test_map});
    } else {
        LOG_OUT << "attempting to add next test to test in a sequence step";

        // first thing is to get the number step we are on
        auto steps = std::any_cast<sequence_step_vector>(sequences_steps.at(last_started_saved_sequence));

        // next thing todo is get our test map
        auto test_map = std::any_cast<sequence_test_map>(sequences_tests.at(last_started_saved_sequence));

        LOG_OUT << "total steps: " << steps.size();

        // now we add to the mapping

        LOG_OUT << "bad any cast?";

        sequence_test_type stt = {static_cast<double>(test_type), static_cast<double>(test_action), value, static_cast<double>(time_type),
                                  static_cast<double>(time_limit)};

        if (test_map.find(steps.size() - 1) != test_map.end()) {
            LOG_OUT << "found test map";
            sequence_test_vector x = test_map.at(steps.size() - 1);
            x.push_back(stt);
            test_map.at(steps.size() - 1) = x;
        } else {
            LOG_OUT << "didnt find test map";
            test_map.insert({steps.size() - 1, sequence_test_vector{stt}});
        }

        sequences_tests.at(last_started_saved_sequence) = test_map;
        LOG_OUT << "bad any cast?4";
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

    property_tree.get_child("sequences").erase(name);

    boost::property_tree::json_parser::write_json("sequences.json", property_tree);
}

void SequenceParser::finish_save_sequence() {
    LOG_OUT << "finish save sequence called";
    boost::property_tree::ptree property_tree;
    try {
        boost::property_tree::json_parser::read_json("sequences.json", property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
    }

    // putting in an api number in case we ever change up the format after a versions been released
    property_tree.put("api", 1.0);

    // delete the node (because we are overwriting it)
    // auto seq_tree
    auto seq_ptr = property_tree.get_child_optional("sequences");
    if (seq_ptr.get_ptr()) {
        seq_ptr->erase(last_started_saved_sequence);
    }
    // first we're going to get the sequences info
    auto info = std::any_cast<sequence_info_type>(sequences_info.at(last_started_saved_sequence));

    // place the sequences info in the property tree
    property_tree.put("sequences." + last_started_saved_sequence + ".serial_number",
                      info.at(SequenceTypes::sequence_info_access_type::SERIAL_NUMBER));
    property_tree.put("sequences." + last_started_saved_sequence + ".comments", info.at(SequenceTypes::sequence_info_access_type::COMMENTS));

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
        property_tree.put("sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".mode",
                          s.at(SequenceTypes::sequence_step_access_type::MODE));
        property_tree.put("sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".seconds",
                          s.at(SequenceTypes::sequence_step_access_type::SECONDS));
        property_tree.put("sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".current",
                          s.at(SequenceTypes::sequence_step_access_type::CURRENT));
        property_tree.put("sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".voltage",
                          s.at(SequenceTypes::sequence_step_access_type::VOLTAGE));

        if (test_map.find(i) != test_map.end()) {
            auto stv = test_map.at(i);
            std::cout << "STV SIZE: " << stv.size() << std::endl;
            for (auto k = 0; k < stv.size(); k++) {
                auto st = stv.at(k);
                property_tree.put(
                    "sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".test_type",
                    st.at(SequenceTypes::sequence_test_access_type::TEST_TYPE));
                property_tree.put(
                    "sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".test_action",
                    st.at(SequenceTypes::sequence_test_access_type::TEST_ACTION));
                property_tree.put(
                    "sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".value",
                    st.at(SequenceTypes::sequence_test_access_type::VALUE));
                property_tree.put(
                    "sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".time_type",
                    st.at(SequenceTypes::sequence_test_access_type::TIME_TYPE));
                property_tree.put(
                    "sequences." + last_started_saved_sequence + ".steps." + std::to_string(i) + ".tests." + std::to_string(k) + ".time_limit",
                    st.at(SequenceTypes::sequence_test_access_type::TIME_LIMIT));
            }
        }
    }

    try {
        boost::property_tree::json_parser::write_json("sequences.json", property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
        return;
    }

    LOG_OUT << "finished writing sequence: ";
}

void SequenceParser::delete_key(const std::string &name, std::map<std::string, std::any> &map) const {
    // key was found if this happens
    std::cout << "deleting key" << std::endl;
    if (map.find(name) != map.end()) {
        std::cout << "found map" << std::endl;
        map.erase(name);
    } else
        std::cout << "didn't find map" << std::endl;
}

void SequenceParser::delete_all_keys(const std::string &name) {
    if (sequences_info.find(name) != sequences_info.end()) {
        sequences_info.erase(name);
    }

    if (sequences_steps.find(name) != sequences_steps.end()) {
        std::cout << "deleted steps!" << std::endl;
        sequences_steps.erase(name);
    }

    if (sequences_tests.find(name) != sequences_tests.end()) {
        sequences_tests.erase(name);
    }
}

void SequenceParser::clear_all_maps() {
    sequences_info.clear();
    sequences_steps.clear();
    sequences_tests.clear();
}

std::array<std::map<std::string, std::any>, 3> SequenceParser::load_all_sequences() {
    LOG_OUT << "load all sequences called";

    clear_all_maps();

    boost::property_tree::ptree property_tree;
    try {
        boost::property_tree::json_parser::read_json("sequences.json", property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
    }

    for (auto &it : property_tree) {
        if (std::string("sequences").compare(it.first) == 0) {
            LOG_OUT << "found sequences";
            auto seq_tree = property_tree.get_child(it.first);
            for (auto &st_it : seq_tree) {
                LOG_OUT << "found sequence name: " << st_it.first;  // sequencename
                auto name = st_it.first;
                auto serial_number = st_it.second.get<std::string>("serial_number");
                auto comments = st_it.second.get<std::string>("comments");
                sequences_info.insert({name, sequence_info_type{serial_number, comments}});

                auto steps_tree = st_it.second.get_child_optional("steps");
                sequence_step_vector ssv;
                sequence_test_map stm;
                if (steps_tree.get_ptr()) {
                    for (auto &steps_it : *steps_tree) {
                        LOG_OUT << "steps " << steps_it.first;
                        auto mode = steps_it.second.get<double>("mode");
                        auto seconds = steps_it.second.get<double>("seconds");
                        auto current = steps_it.second.get<double>("current");
                        auto voltage = steps_it.second.get<double>("voltage");
                        ssv.push_back({mode, seconds, current, voltage});

                        auto tests_tree = steps_it.second.get_child_optional("tests");
                        if (tests_tree.get_ptr()) {
                            sequence_test_vector stv;
                            LOG_OUT << "found tests: " << ssv.size();
                            for (auto &tests_it : *tests_tree) {
                                LOG_OUT << "test: " << tests_it.first;
                                auto test_type = tests_it.second.get<double>("test_type");
                                auto test_action = tests_it.second.get<double>("test_action");
                                auto value = tests_it.second.get<double>("value");
                                auto time_type = tests_it.second.get<double>("time_type");
                                auto time_limit = tests_it.second.get<double>("time_limit");
                                stv.push_back({test_type, test_action, value, time_type, time_limit});
                            }

                            stm.insert({ssv.size() - 1, stv});
                        }
                    }
                }

                sequences_steps.insert({name, ssv});
                sequences_tests.insert({name, stm});
            }
        }
    }

    return {sequences_info, sequences_steps, sequences_tests};
}