#include "sequence_parser.hpp"

#include <boost/property_tree/ini_parser.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <boost/property_tree/ptree.hpp>

#include "../logger.hpp"

#define LOG_OUT LogOut("sequence_parser")
#define LOG_ERR LogOut("sequence parser")

namespace sequences {
SequenceParser::SequenceParser() {}

void SequenceParser::save_sequence(std::shared_ptr<Sequence> sequence) {
    LOG_OUT << "save sequence called";
    if (sequence) {
        boost::property_tree::ptree property_tree;

        // we can continue if this fails because this just means that the original sequences.json file does not exists
        try {
            boost::property_tree::json_parser::read_json(SEQUENCES_FILENAME, property_tree);
        } catch (const boost::property_tree::json_parser::json_parser_error &e) {
            LOG_ERR << "failed to open sequences config file because: " << e.what();
        }

        // putting in an api number in case we ever change up the format after a versions been released
        property_tree.put(API_PATHNAME, API_VERSION_NUMBER);

        // delete the node (because we are overwriting it)
        // auto seq_tree
        auto sequence_name = sequence->get_name();
        auto seq_ptr = property_tree.get_child_optional(SEQUENCES_PATHNAME);
        if (seq_ptr.get_ptr()) {
            seq_ptr->erase(sequence_name);
        }

        // place the sequences info in the property tree
        property_tree.put(SEQUENCES_PATHNAME + "." + sequence_name + "." + COMMENTS_PATHNAME, sequence->get_comments());

        // get the seqeunces steps
        auto steps = sequence->get_steps();

        LOG_OUT << "found total steps: " << steps.size();

        for (const auto &step : steps) {
            if (step) {
                auto step_id = step->get_step_id() + 1;
                auto steps_pretext = SEQUENCES_PATHNAME + "." + sequence_name + "." + STEPS_PATHNAME + "." + std::to_string(step_id) + ".";
                property_tree.put(steps_pretext + MODE_PATHNAME, step->get_mode());
                property_tree.put(steps_pretext + DURATION_PATHNAME, step->get_duration());
                property_tree.put(steps_pretext + CURRENT_LIMIT_PATHNAME, step->get_current_limit());
                property_tree.put(steps_pretext + VOLTAGE_LIMIT_PATHNAME, step->get_voltage_limit());

                auto tests = step->get_tests();
                for (const auto &test : tests) {
                    if (test) {
                        auto test_id = test->get_test_id() + 1;
                        auto test_pretext = steps_pretext + TESTS_PATHNAME + "." + std::to_string(test_id) + ".";
                        property_tree.put(test_pretext + TEST_TYPE_PATHNAME, test->get_test_type());
                        property_tree.put(test_pretext + TEST_ACTION_PATHNAME, test->get_test_action());
                        property_tree.put(test_pretext + TEST_VALUE_PATHNAME, test->get_value());
                        property_tree.put(test_pretext + TEST_TIME_TYPE_PATHNAME, test->get_time_type());
                        property_tree.put(test_pretext + TEST_TIME_LIMIT_PATHNAME, test->get_time_limit());

                    } else
                        LOG_ERR << "test pointer did not exist?";
                }
            } else
                LOG_ERR << "step pointer did not exist?";
        }

        try {
            boost::property_tree::json_parser::write_json(SEQUENCES_FILENAME, property_tree);
        } catch (const boost::property_tree::json_parser::json_parser_error &e) {
            LOG_ERR << "failed to save sequences config file because: " << e.what();
            return;
        }
    } else
        LOG_ERR << "save sequence pointer did not exist?";
}

void SequenceParser::delete_sequence(std::string name) {
    LOG_OUT << "delete sequence called: " << name;

    boost::property_tree::ptree property_tree;
    try {
        boost::property_tree::json_parser::read_json(SEQUENCES_FILENAME, property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << "failed to open sequences filename, " << e.what();
        return;  // can't delete something that doesn't exist
    }

    auto seq_ptr = property_tree.get_child_optional(SEQUENCES_PATHNAME);
    if (seq_ptr.get_ptr()) {
        seq_ptr->erase(name);
    } else {
        LOG_ERR << "sequence didn't exists so we can't erase";
        return;
    }

    try {
        boost::property_tree::json_parser::write_json(SEQUENCES_FILENAME, property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << "failed to save sequences file, " << e.what();
        return;  // can't delete something that doesn't exist
    }
}

std::vector<std::shared_ptr<Sequence>> SequenceParser::load_all_sequences() {
    LOG_OUT << "load all sequences called";
    std::vector<std::shared_ptr<Sequence>> sequences;

    boost::property_tree::ptree property_tree;
    try {
        boost::property_tree::json_parser::read_json(SEQUENCES_FILENAME, property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << "failed to load a sequence file: " << e.what();
        return sequences;
    }

    for (const auto &it : property_tree) {
        if (SEQUENCES_PATHNAME.compare(it.first) == 0) {
            LOG_OUT << "found sequences";
            auto seq_tree = property_tree.get_child(it.first);

            for (const auto &st_it : seq_tree) {
                LOG_OUT << "found sequence name: " << st_it.first;
                auto name = st_it.first;                                           // name
                auto comments = st_it.second.get<std::string>(COMMENTS_PATHNAME);  // comments

                auto steps_tree = st_it.second.get_child_optional(STEPS_PATHNAME);
                std::vector<std::shared_ptr<SequenceStep>> steps;
                if (steps_tree.get_ptr()) {
                    for (const auto &steps_it : *steps_tree) {
                        LOG_OUT << "steps " << steps_it.first;

                        std::uint8_t step_id = std::stoi(steps_it.first) - 1;
                        auto mode = steps_it.second.get<step::mode_type>(MODE_PATHNAME);
                        auto duration = steps_it.second.get<std::int32_t>(DURATION_PATHNAME);
                        auto current_limit = steps_it.second.get<std::double_t>(CURRENT_LIMIT_PATHNAME);
                        auto voltage_limit = steps_it.second.get<std::double_t>(VOLTAGE_LIMIT_PATHNAME);

                        auto tests_tree = steps_it.second.get_child_optional(TESTS_PATHNAME);
                        std::vector<std::shared_ptr<SequenceTest>> tests;
                        if (tests_tree.get_ptr()) {
                            LOG_OUT << "found tests";

                            for (const auto &tests_it : *tests_tree) {
                                LOG_OUT << "test: " << tests_it.first;
                                std::uint8_t test_id = std::stoi(tests_it.first) - 1;
                                auto test_type = tests_it.second.get<test::test_type_t>(TEST_TYPE_PATHNAME);
                                auto test_action = tests_it.second.get<test::test_action_type>(TEST_ACTION_PATHNAME);
                                auto value = tests_it.second.get<std::double_t>(TEST_VALUE_PATHNAME);
                                auto time_type = tests_it.second.get<test::time_type_t>(TEST_TIME_TYPE_PATHNAME);
                                auto time_limit = tests_it.second.get<std::uint32_t>(TEST_TIME_LIMIT_PATHNAME);

                                auto test = std::make_shared<SequenceTest>(test_id, test_type, value, time_type, time_limit, test_action);
                                tests.push_back(std::move(test));
                            }
                        }

                        auto step = std::make_shared<SequenceStep>(step_id, mode, duration, current_limit, voltage_limit, std::move(tests));
                        steps.push_back(std::move(step));
                    }
                }

                auto sequence = std::make_shared<Sequence>(name, comments, std::move(steps));
                sequences.push_back(std::move(sequence));
            }
        }
    }

    return sequences;
}
}  // namespace sequences