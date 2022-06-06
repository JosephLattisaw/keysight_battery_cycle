#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <visa.h>

#include <boost/asio.hpp>
#include <functional>
#include <memory>

#include "keysight.hpp"
#include "safety_limits.hpp"
#include "sequence_parser.hpp"
#include "types.hpp"

class Backend
{
public:
    Backend(boost::asio::io_service &io_service, ActiveCardsCallback active_cards_callback, ConnectionStatusCallback connection_status_callback,
            PortDoubleCallback port_double_callback, PortUint16Callback port_uint16_callback, LoadedProfilesCallback loaded_profiles_callback,
            ProfilesStatusCallback profiles_status_callback, ProfilesStatusCallback slot_status_callback, TimeStatusCallback time_status_callback,
            ProfilesStatusCallback cycles_status_callback, TimeStatusCallback total_time_callback, LoadSafetiesCallback load_safeties_callback,
            LimitCrossedCallback limit_crossed_callback);
    ~Backend();

    // TODO find out if we can make this private
    void active_cards_request(active_cards_type active_cards);
    void clear_hard_limit(std::uint32_t test);
    void clear_soft_limit(std::uint32_t test);
    void connection_status_request(bool status);
    void loaded_profiles_request(loaded_profile_type profiles);
    void profile_statuses_request(profile_status_type statuses);
    void slot_statuses_request(profile_status_type statuses);
    void cycle_statuses_request(profile_status_type statuses);
    void time_statuses_request(uptime_time_type statuses);
    void total_time_statuses_request(uptime_time_type statuses);
    void port_double_data_request(PortTypes::port_double_data_type data_type, map_double_data_type data);
    void port_uint16_data_request(PortTypes::port_uint16_data_type data_type, map_uint16_data_type data);
    void limit_crossed_request(int critical, int test);

    std::shared_ptr<SequenceParser> sequence_parser;
    std::shared_ptr<SafetyLimits> safety_limits;

    void connect_keysight();
    void disconnect_keysight();

    void load_profile(std::string name, int slot, sequence_step_vector steps, sequence_test_map tests);
    void start_sequence(std::uint32_t test, std::uint32_t slot, std::vector<std::uint32_t> cells, bool successively);
    void stop_sequence(std::uint32_t test, std::uint32_t slot, std::vector<std::uint32_t> cells);

private:
    // thread management
    void keysight_thread_is_up(); // TODO this will get removed
    void worker_thread();

    boost::asio::io_service &io_service;
    boost::asio::io_service keysight_service;

    std::shared_ptr<Keysight> keysight;
    std::thread keysight_thread;

    // callbacks
    ActiveCardsCallback active_cards_callback;
    ConnectionStatusCallback connection_status_callback;
    PortDoubleCallback port_double_callback;
    PortUint16Callback port_uint16_callback;
    LoadedProfilesCallback loaded_profiles_callback;
    ProfilesStatusCallback profiles_status_callback;
    ProfilesStatusCallback slot_status_callback;
    ProfilesStatusCallback cycles_status_callback;
    TimeStatusCallback time_status_callback;
    TimeStatusCallback total_time_callback;
    LoadSafetiesCallback load_safeties_callback;
    LimitCrossedCallback limit_crossed_callback;
};

#endif