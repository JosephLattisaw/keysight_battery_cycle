#ifndef SAFETY_LIMITS_HPP
#define SAFETY_LIMITS_HPP

#include <boost/property_tree/ini_parser.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <boost/property_tree/ptree.hpp>

#include "types.hpp"

class SafetyLimits {
public:
    SafetyLimits(LoadSafetiesCallback load_safeties_callback);

    void load_safety_limits();
    void set_safety_limits(double min_yellow_voltage, double min_red_voltage, double max_yellow_voltage, double max_red_voltage,
                           double max_red_current);

private:
    void load_safety_value(boost::property_tree::ptree &tree, double &value, std::string key);

    double min_yellow_voltage = 2.6;
    double max_yellow_voltage = 4.21;
    double min_red_voltage = 2.4;
    double max_red_voltage = 4.22;
    double max_red_current = 6;

    LoadSafetiesCallback load_safeties_callback;
};

#endif