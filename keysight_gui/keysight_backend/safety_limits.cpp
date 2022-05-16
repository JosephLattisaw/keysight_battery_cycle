#include "safety_limits.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("safety_limits")
#define LOG_ERR LogOut("safety_limits")

SafetyLimits::SafetyLimits(LoadSafetiesCallback _load_safeties_callback) : load_safeties_callback(_load_safeties_callback) {}

void SafetyLimits::set_safety_limits(double min_yellow_voltage, double min_red_voltage, double max_yellow_voltage, double max_red_voltage,
                                     double max_red_current) {
    LOG_OUT << "set_safety_limits called";
    boost::property_tree::ptree property_tree;
    try {
        boost::property_tree::json_parser::read_json("safety.json", property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
    }

    // putting in an api number in case we ever change up the format after a versions been released
    property_tree.put("api", 1.0);

    // putting all the values into our property tree
    property_tree.put("min_yellow_voltage", min_yellow_voltage);
    property_tree.put("min_red_voltage", min_red_voltage);
    property_tree.put("max_yellow_voltage", max_yellow_voltage);
    property_tree.put("max_red_voltage", max_red_voltage);
    property_tree.put("max_red_current", max_red_current);

    try {
        boost::property_tree::json_parser::write_json("safety.json", property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
        return;
    }
}

void SafetyLimits::load_safety_limits() {
    boost::property_tree::ptree property_tree;
    try {
        boost::property_tree::json_parser::read_json("safety.json", property_tree);
    } catch (const boost::property_tree::json_parser::json_parser_error &e) {
        LOG_ERR << e.what();
    }

    load_safety_value(property_tree, min_yellow_voltage, "min_yellow_voltage");
    load_safety_value(property_tree, min_red_voltage, "min_red_voltage");
    load_safety_value(property_tree, max_yellow_voltage, "max_yellow_voltage");
    load_safety_value(property_tree, max_red_voltage, "max_red_voltage");
    load_safety_value(property_tree, max_red_current, "max_red_current");

    load_safeties_callback({min_yellow_voltage, min_red_voltage, max_yellow_voltage, max_red_voltage, max_red_current});
}

void SafetyLimits::load_safety_value(boost::property_tree::ptree &tree, double &value, std::string key) {
    auto val_ptr = tree.get_optional<double>(key);
    if (val_ptr.get_ptr()) {
        value = val_ptr.value();
    }
}