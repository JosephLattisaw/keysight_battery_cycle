#include "keysight.hpp"

#include <algorithm>

#include "common.hpp"
#include "logger.hpp"

#define LOG_OUT LogOut("keysight")
#define LOG_ERR LogOut("keysight")

namespace keysight
{
    extern ViSession resource_manager;
    extern ViSession session;

} // namespace keysight

using namespace keysight;

Keysight::Keysight(boost::asio::io_service &io_service, ActiveCardsCallback ac_cb, ConnectionStatusCallback conn_cb, PortDoubleCallback pd_cb,
                   PortUint16Callback pu16_cb, LoadedProfilesCallback lp_cb, ProfilesStatusCallback ps_cb, ProfilesStatusCallback ss_cb,
                   TimeStatusCallback ts_cb, ProfilesStatusCallback cyc_cb, TimeStatusCallback tt_cb, LimitCrossedCallback lc_cb)
    : io_service(io_service),
      cell_status_timer(io_service),
      active_cards_callback{ac_cb},
      connection_status_callback{conn_cb},
      port_double_callback{pd_cb},
      port_uint16_callback{pu16_cb},
      loaded_profiles_callback{lp_cb},
      profile_status_callback{ps_cb},
      slot_status_callback{ss_cb},
      time_status_callback{ts_cb},
      cycles_status_callback{cyc_cb},
      total_time_callback{tt_cb},
      limit_crossed_callback{lc_cb}
{
    currently_loaded_profiles.fill("");
    current_profile_statuses.fill(0);
    current_seq_uptime.fill(0.0);
    total_seq_uptime.fill(0.0);
    total_seq_uptime_offset.fill(0.0);
    cycles_count.fill(0);
    logging_files.fill(nullptr);
}

Keysight::~Keysight() { disconnect(); }

void Keysight::connect()
{
    if (!connected)
    {
        // opening the Keysight BT2203A
        if (open_resource_manager())
        {
            if (open_instrument())
            {
                if (enable_read_termination_character())
                {
                    if (identification_query())
                    {
                        LOG_OUT << "identified " << VISA_ADDRESS_BT2203A;

                        if (detect_cards_at_boot())
                        {
                            if (reset())
                            {
                                LOG_OUT << "successfully detected all cards at boot";
                                if (define_cells_for_all_cards())
                                {
                                    LOG_OUT << "successfully set all cell names";
                                    update_connection_status(true);
                                    start_polling_cell_status();
                                }
                                else
                                {
                                    LOG_ERR << "failed to set all active cells";
                                    disconnect();
                                }
                            }
                            else
                            {
                                LOG_ERR << "failed to reset all data";
                                disconnect();
                            }
                        }
                        else
                        {
                            LOG_ERR << "failed to determine the active cards";
                            disconnect();
                        }
                    }
                    else
                    {
                        LOG_ERR << "failed to find identify: " << VISA_ADDRESS_BT2203A;
                        disconnect();
                    }
                }
                else
                {
                    LOG_ERR << "failed to enabled read termination character";
                    disconnect();
                }
            }
            else
            {
                LOG_ERR << "failed to open instrument";
                disconnect();
            }
        }
        else
        {
            LOG_ERR << "failed to open resoucrce manager";
            disconnect();
        }
    }
    else
        LOG_ERR << "already connected";
}

void Keysight::update_connection_status(bool flag)
{
    connected = flag;
    connection_status_callback(connected);
}

void Keysight::disconnect()
{
    if (connected)
    {
        viUnlock(session);
        viClose(session);
        viClose(resource_manager);

        keysight::resource_manager = 0;
        keysight::session = 0;

        active_cards.clear();
        cell_names.clear();
        cell_cap_ahr_data.clear();
        cell_cap_whr_data.clear();
        cell_voltage_data.clear();
        cell_current_data.clear();
        cell_sequence_id_data.clear();
        cell_step_id_data.clear();

        cell_status_timer.cancel();

        currently_loaded_profiles.fill("");
        current_profile_statuses.fill(0);

        update_connection_status(false);
        loaded_profiles_callback(currently_loaded_profiles);
        profile_status_callback(current_profile_statuses);
    }
}

bool Keysight::open_resource_manager()
{
    LOG_OUT << "attempting to open resource manager...";

#ifndef SOFTWARE_ONLY
    auto status = viOpenDefaultRM(&resource_manager); // opening resource manager

    auto res = keysight::verify_vi_status(session, status, "opened resource manager",
                                          "There was a problem opening the default resource manager, error code: ");
#else
    auto res = true;
#endif

    return res;
}

bool Keysight::open_instrument()
{
    LOG_OUT << "attempting to open instrument";

#ifndef SOFTWARE_ONLY
    auto status = viOpen(resource_manager, VISA_ADDRESS_BT2203A.c_str(), VI_NULL, VI_NULL, &session);

    auto res = keysight::verify_vi_status(session, status, "opened instrument",
                                          "There was a problem opening the connection to the instrument, error code: ");

    if (res)
    {
        ViChar full_address[65535];
        // TODO check that this lock crap works
        status = viLock(session, VI_SHARED_LOCK, VI_TMO_IMMEDIATE, "IBEOS", full_address);

        res = keysight::verify_vi_status(session, status, "locked instrument", "There was a problem locking the instrument, error code: ");
        if (res)
        {
            return true;
        }
    }

    return false;
#else
    return true;
#endif
}

bool Keysight::enable_read_termination_character()
{
#ifndef SOFTWARE_ONLY
    // For Serial and TCP/IP socket connections enable the read Termination character, or read's will timeout
    ViChar full_address[100];
    ViStatus status;
    bool res;

    status = viGetAttribute(session, VI_ATTR_RSRC_NAME, full_address);
    res = keysight::verify_vi_status(session, status, "enabled read termination character",
                                     "There was a problem getting the attributes resource name, error code: ");

    if (res)
    {
        if (std::string("ASRL").compare(full_address) == 0 || std::string("SOCKET").compare(full_address) == 0)
        {
            LOG_OUT << "controller: detected Serial or TCP/IP connection, enabling read termination character";
            status = viSetAttribute(session, VI_ATTR_TERMCHAR_EN, VI_TRUE);
            res = keysight::verify_vi_status(session, status, "enabled read termination character",
                                             "There was a problem setting the attributes termination character name, error code: ");

            status = viSetAttribute(session, VI_ATTR_TMO_VALUE, 2000);
            res = keysight::verify_vi_status(session, status, "timeout", "There was a problem setting the attributes timeout, error code: ");
            return res;
        }
        else
            return true; // success
    }
    else
        return false; // we failed
#else
    return true;
#endif
}

bool Keysight::reset()
{
    LOG_OUT << "attempting to reset state";

#ifndef SOFTWARE_ONLY
    bool res;

    auto status = viPrintf(session, "CELL:ABORT 0\n"); // sending identification query command
    res = keysight::verify_vi_status(session, status, "aborting any cells", "There was a problem aborting cells, error code: ");

    if (res)
    {
        status = viPrintf(session, "CELL:CLEAR 0\n"); // sending identification query command
        res = keysight::verify_vi_status(session, status, "clearing cells", "There was a problem clearing cells, error code: ");
        if (res)
        {
            status = viPrintf(session, "SEQ:CLEAR 0\n"); // sending identification query command
            res = keysight::verify_vi_status(session, status, "clearing sequences", "There was a problem clearing any sequences, error code: ");
        }
    }

    return res;
#endif

    return true;
}

bool Keysight::identification_query()
{
    LOG_OUT << "sending the identification query command";

#ifndef SOFTWARE_ONLY
    bool res;

    auto status = viPrintf(session, "*IDN?\n"); // sending identification query command
    res = keysight::verify_vi_status(session, status, "sent id query command", "There was a problem sending the id queury, error code: ");

    if (res)
    {
        // getting the response from the identification query
        ViChar idn_response[65535];
        status = viScanf(session, "%t", idn_response);
        res =
            keysight::verify_vi_status(session, status, "read id query response", "There was a problem reading the id queury response, error code: ");

        if (res)
        {
            LOG_OUT << "identification query response: " << idn_response;

            return res;
        }
        else
        {
            LOG_ERR << "unable to retrieve identification query response";
            return false;
        }
    }
    else
    {
        LOG_ERR << "unabled to send identification query command " << status;
        return false;
    }
#else
    return true;
#endif
}

std::vector<std::string> Keysight::comma_delimiter(std::string x)
{
    std::string s = x;
    std::string delimiter = ",";
    std::size_t pos = 0;
    std::string token;

    std::vector<std::string> result;

    while ((pos = s.find(delimiter)) != std::string::npos)
    {
        token = s.substr(0, pos);
        result.push_back(token);
        s.erase(0, pos + delimiter.length());
    }

    result.push_back(s);

    return result;
}

bool Keysight::detect_cards_at_boot()
{
    LOG_OUT << "sending the detect cards command";

#ifndef SOFTWARE_ONLY
    std::vector<std::uint8_t> result;

    auto status = viPrintf(session, "SYST:CARD:DET:BOOT? 0\n"); // sending the detect all cards command
    auto res =
        keysight::verify_vi_status(session, status, "detect system cards at boot", "There was a problem detecting the system cards, error code: ");

    if (res)
    {
        // getting the response for the card detection query
        ViChar cards_detected[65535];
        status = viScanf(session, "%t", cards_detected);
        res =
            keysight::verify_vi_status(session, status, "reading system cards at boot", "There was a problem reading the system cards, error code: ");

        if (res)
        {
            LOG_OUT << "cards detected: " << cards_detected;

            std::string s = std::string(cards_detected);
            auto s_vec = comma_delimiter(s);

            for (auto i : s_vec)
            {
                LOG_OUT << "stoi-ing" << i;
                result.push_back(std::stoi(i));
            }

            if (result.size() == 1)
            {
                // if result is same number across the board we need to initialize the entire vector
                bool val = result.at(0);
                result = std::vector<std::uint8_t>(8, val);
                LOG_OUT << "all cards were same value: " << static_cast<int>(val);
            }
            else if (result.size() != 8)
            {
                // if we get an invalid result size, just say all the cards are off to be safe
                result = std::vector<std::uint8_t>(8, false);
                LOG_ERR << "cards returned an invalid size: " << result.size() << ", marking all cards off";
            }
            else
            {
                LOG_OUT << "successfully detected all the cards";
            }
        }
        else
            return false;
    }
    else
        return false;

    active_cards = result;
#else
    active_cards = {true, true, true, false, false, false, false, false};
#endif
    active_cards_callback(active_cards);
    return true;
}

bool Keysight::define_cells_for_all_cards()
{
    std::string s1 = "CELL:DEFINE ";
    std::string s2 = "0";
    std::string s3 = ",(@";
    std::string s4 = "";
    std::string s5 = ")\n";

    std::vector<std::string> result;

    for (auto i = 0; i < active_cards.size(); i++)
    {
        if (static_cast<bool>(active_cards.at(i)))
        {
            // card is active if we make it here
            for (auto k = 0; k < 32; k++)
            {
                auto mod_nbr = std::to_string(i + 1);
                auto card_nbr = std::to_string(k + 1);

                s2 = ((k + 1) < 10) ? "00" : "0";
                s4 = ((k + 1) < 10) ? "0" : "";

                auto s = s1 + mod_nbr + s2 + card_nbr + s3 + mod_nbr + s4 + card_nbr + s5;
                auto sx = mod_nbr + s2 + card_nbr;
                LOG_OUT << "command: " << s;
                LOG_OUT << "cell number: " << sx;
#ifndef SOFTWARE_ONLY
                auto status = viPrintf(session, s.c_str());
                auto res =
                    keysight::verify_vi_status(session, status, "defining cell number", "There was a problem defining a cell number, error code: ");
                if (res)
                    result.push_back(sx);
                else
                {
                    LOG_ERR << "error defining cell number: " << s.c_str();
                    return false;
                }
#else
                result.push_back(sx);
#endif
            }
        }
    }

    cell_names = result;
    return true;
}

void Keysight::start_polling_cell_status()
{
    cell_status_timer.expires_after(std::chrono::seconds(1));
    cell_status_timer.async_wait([&](const boost::system::error_code &error)
                                 {
                                     if (error == boost::asio::error::operation_aborted)
                                     {
                                         LOG_OUT << "cell status timer was cancelled"; // this isn't necessarily an error
                                     }
                                     else if (error)
                                     {
                                         LOG_ERR << "timer encountered error: " << error.message();
                                         disconnect();
                                     }
                                     else
                                     {
                                         // LOG_OUT << "getting cell status";
                                         if (get_cell_status())
                                         {
                                             start_polling_cell_status();
                                         }
                                         else
                                         {
                                             LOG_ERR << "error getting the cell status";
                                             disconnect();
                                         }
                                     }
                                 });
}

bool Keysight::get_cell_status()
{
    for (auto i = 0; i < active_cards.size(); i++)
    {
        auto active = active_cards.at(i);

        if (active)
        {
            auto res = get_cap_ahr(i);
            if (!res)
                return false;

            res = get_cap_whr(i);
            if (!res)
                return false;

            last_valid_verbose_response.clear();

            res = get_cell_verbose(i);
            if (!res)
                return false;

            std::vector<std::uint16_t> sequences;
            std::vector<std::uint16_t> steps;
            std::vector<double> volts;
            std::vector<double> current;
            std::vector<std::uint16_t> states;
            std::vector<std::uint16_t> statuses;
            for (auto k = 0; k < last_valid_verbose_response.size(); k++)
            {
                auto x = last_valid_verbose_response.at(k);
                if (x.size() == 10)
                {
                    // 0 = state
                    // 1 = sequence id
                    // 2 = step id
                    // 3 = volts
                    // 4 = amps
                    // 5 = cellStat
                    // TODO 6 = testId
                    // TODO 7 = testType
                    // TODO 8 = expLim
                    // TODO 9 = meadLim
                    if (x.at(0).compare("RUNNING") == 0)
                        states.push_back(2);
                    else
                        states.push_back(1);

                    if (x.at(5).compare("NEXT") == 0)
                    {
                        statuses.push_back(5);
                    }
                    else if (x.at(5).compare("ABORTED") == 0)
                    {
                        statuses.push_back(4);
                    }
                    else if (x.at(5).compare("FAIL") == 0)
                    {
                        statuses.push_back(3);
                    }
                    else if (x.at(5).compare("OK") == 0)
                    {
                        statuses.push_back(2);
                    }
                    else
                    {
                        statuses.push_back(1);
                    }

                    sequences.push_back(std::stoi(x.at(1)));
                    steps.push_back(std::stoi(x.at(2)));
                    volts.push_back(std::stod(x.at(3)));
                    current.push_back(std::stod(x.at(4)));
                }
                else
                {
                    LOG_ERR << "invalid response size";
                    return false;
                }
            }

            cell_sequence_id_data[i] = sequences;
            cell_step_id_data[i] = steps;
            cell_voltage_data[i] = volts;
            cell_current_data[i] = current;
            cell_run_state_data[i] = states;
            cell_run_status_data[i] = statuses;
        }
    }

    for (const auto &i : cells_being_run_map)
    {
        log_data(i.first, i.second);
    }

    port_double_callback(PortTypes::port_double_data_type::CAP_AHR, cell_cap_ahr_data);
    port_double_callback(PortTypes::port_double_data_type::CAP_WHR, cell_cap_whr_data);
    port_double_callback(PortTypes::port_double_data_type::VOLTAGE, cell_voltage_data);
    port_double_callback(PortTypes::port_double_data_type::CURRENT, cell_current_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::SEQUENCE, cell_sequence_id_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::STEP, cell_step_id_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::STATES, cell_run_state_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::STATUSES, cell_run_status_data);

    auto res = get_cells_running_uptime();
    if (!res)
    {
        return res;
    }
    else
    {
        res = check_cells_sequence_rollover_and_failures();
        if (!res)
            return res;
    }

    cycles_status_callback(cycles_count);

    return true;
}

bool Keysight::get_cap_ahr(int card_number)
{
#ifndef SOFTWARE_ONLY
    ViChar cap_ahr[65535];

    auto s1 = "MEAS:CELL:CAP:AHR? (@";
    auto s2 = std::to_string(card_number + 1);
    auto s3 = "001:";
    auto s4 = s2;
    auto s5 = "032)\n";
    auto s = s1 + s2 + s3 + s4 + s5;

    auto status = viPrintf(session, s.c_str());
    auto res =
        keysight::verify_vi_status(session, status, "retrieving capacity ahr", "There was a problem sending capacity ahr command, error code: ");

    if (res)
    {
        status = viScanf(session, "%t", cap_ahr);
        res = keysight::verify_vi_status(session, status, "getting capacity ahr", "There was a problem getting capacity ahr command, error code: ");
        if (res)
        {
            status = viFlush(session, VI_READ_BUF); // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
            if (res)
            {
                // LOG_OUT << "got cap ahr status: " << cap_ahr;
                std::string s = std::string(cap_ahr);
                auto s_vec = comma_delimiter(s);

                std::vector<double> result;
                for (auto i : s_vec)
                {
                    result.push_back(std::stod(i));
                }
                cell_cap_ahr_data[card_number] = result;
            }
            else
            {
                LOG_ERR << "error flushing buffer";
                return false;
            }
        }
        else
        {
            LOG_ERR << "error getting cap ahr data";
            return false;
        }
    }
    else
    {
        LOG_ERR << "error sending cap ahr command";
        return false;
    }

    return true;
#else
    std::vector<double> cell_cap_ahr = {0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};

    cell_cap_ahr_data[0] = cell_cap_ahr;
    cell_cap_ahr_data[1] = cell_cap_ahr;
    cell_cap_ahr_data[2] = cell_cap_ahr;
    port_double_callback(PortTypes::port_double_data_type::CAP_AHR, cell_cap_ahr_data);
    return true;
#endif
}

std::vector<int> Keysight::get_catalog()
{
    std::string s = "SEQ:CAT?\n";
    ViChar catalog[65535];
    auto status = viPrintf(session, s.c_str());
    auto res = keysight::verify_vi_status(session, status, "get catalog", "There was a problem sending get catalog command, error code: ");

    std::vector<int> result;

    if (res)
    {
        status = viScanf(session, "%t", catalog);
        res = keysight::verify_vi_status(session, status, "get catalog", "There was a problem getting catalog, error code: ");
        if (res)
        {
            status = viFlush(session, VI_READ_BUF); // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");

            LOG_OUT << "get_catalog: " << catalog;
            auto values = comma_delimiter(catalog);

            for (const auto &i : values)
            {
                try
                {
                    auto val = std::stoi(i) - 1;
                    result.push_back(val);
                }
                catch (...)
                {
                    // do nothing
                }
            }
        }
        else
        {
            disconnect();
        }
    }
    else
    {
        disconnect();
    }

    return result;
}

bool Keysight::get_cap_whr(int card_number)
{
#ifndef SOFTWARE_ONLY
    ViChar cap_whr[65535];

    // TODO this is hardcoded, don't do that
    auto s1 = "MEAS:CELL:CAP:WHR? (@";
    auto s2 = std::to_string(card_number + 1);
    auto s3 = "001:";
    auto s4 = s2;
    auto s5 = "032)\n";
    auto s = s1 + s2 + s3 + s4 + s5;

    // auto status = viPrintf(session, "MEAS:CELL:CAP:WHR? (@1001:3032)\n");
    auto status = viPrintf(session, s.c_str());
    auto res =
        keysight::verify_vi_status(session, status, "retrieving capacity whr", "There was a problem sending capacity whr command, error code: ");

    if (res)
    {
        status = viScanf(session, "%t", cap_whr);
        res = keysight::verify_vi_status(session, status, "getting capacity whr", "There was a problem getting capacity whr command, error code: ");
        if (res)
        {
            status = viFlush(session, VI_READ_BUF); // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
            if (res)
            {
                // LOG_OUT << "got cap whr status: " << cap_whr;
                std::string s = std::string(cap_whr);
                auto s_vec = comma_delimiter(s);

                std::vector<double> result;
                for (auto i : s_vec)
                {
                    result.push_back(std::stod(i));
                }
                cell_cap_whr_data[card_number] = result;
            }
            else
            {
                LOG_ERR << "error flushing buffer";
                return false;
            }
        }
        else
        {
            LOG_ERR << "error getting cap whr data";
            return false;
        }
    }
    else
    {
        LOG_ERR << "error sending cap whr command";
        return false;
    }

    return true;
#else
    std::vector<double> cell_cap_whr = {34.0, 1.0, 42.0, 33.0, 44.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};

    cell_cap_whr_data[0] = cell_cap_whr;
    cell_cap_whr_data[1] = cell_cap_whr;
    cell_cap_whr_data[2] = cell_cap_whr;
    port_double_callback(PortTypes::port_double_data_type::CAP_WHR, cell_cap_whr_data);
    return true;
#endif
}

bool Keysight::get_cell_verbose(int card_number)
{
#ifndef SOFTWARE_ONLY
    for (auto k = 1; k < 33; k++)
    {
        std::string s1 = "STAT:CELL:VERB? ";
        std::string s2 = std::to_string(card_number + 1);
        std::string s3 = (k < 10) ? "00" : "0";
        std::string s4 = std::to_string(k);
        std::string s5 = "\n";
        std::string s = s1 + s2 + s3 + s4 + s5;

        // LOG_OUT << "sending: " << s;

        ViChar verb[65535];
        auto status = viPrintf(session, s.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending cell verbose", "There was a problem sending the cell verbose command");

        if (res)
        {
            status = viScanf(session, "%t", verb);
            res = keysight::verify_vi_status(session, status, "getting cell verbose", "There was a problem reading the cell verbose response");
            if (res)
            {
                status = viFlush(session, VI_READ_BUF);
                res = keysight::verify_vi_status(session, status, "flushing buffer", "There was a problem flushing the buffer");
                if (!res)
                    return false;
            }
            else
                return false;
        }
        else
            return false;

        auto vec = comma_delimiter(verb);
        if (vec.size() == 10)
        {
            // LOG_OUT << "got cell verbose: " << verb;
            last_valid_verbose_response.push_back(vec);
        }
        else
        {
            LOG_ERR << "received invalid verb response size: " << vec.size();
            return false;
        }
    }

    return true;
#else
    std::vector<double> cell_voltage = {4.032331, 4.028462, 42.0, 33.0, 44.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};
    std::vector<double> cell_current = {-0.0003, -0.00026, 42.0, 33.0, 44.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};
    std::vector<std::uint16_t> cell_sequence = {12, 1, 42, 33, 44, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
                                                16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
    std::vector<std::uint16_t> cell_step = {3, 2, 12, 33, 44, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
                                            16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
    std::vector<std::uint16_t> cell_state = {0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1};
    std::vector<std::uint16_t> cell_status = {0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1};

    cell_voltage_data[0] = cell_voltage;
    cell_voltage_data[1] = cell_voltage;
    cell_voltage_data[2] = cell_voltage;
    port_double_callback(PortTypes::port_double_data_type::VOLTAGE, cell_voltage_data);

    cell_current_data[0] = cell_current;
    cell_current_data[1] = cell_current;
    cell_current_data[2] = cell_current;
    port_double_callback(PortTypes::port_double_data_type::CURRENT, cell_current_data);

    cell_sequence_id_data[0] = cell_sequence;
    cell_sequence_id_data[1] = cell_sequence;
    cell_sequence_id_data[2] = cell_sequence;
    port_uint16_callback(PortTypes::port_uint16_data_type::SEQUENCE, cell_sequence_id_data);

    cell_step_id_data[0] = cell_step;
    cell_step_id_data[1] = cell_step;
    cell_step_id_data[2] = cell_step;
    port_uint16_callback(PortTypes::port_uint16_data_type::STEP, cell_step_id_data);

    cell_run_state_data[0] = cell_state;
    cell_run_state_data[0] = cell_state;
    cell_run_state_data[0] = cell_state;
    port_uint16_callback(PortTypes::port_uint16_data_type::STATES, cell_run_state_data);

    cell_run_status_data[0] = cell_status;
    cell_run_status_data[0] = cell_status;
    cell_run_status_data[0] = cell_status;
    port_uint16_callback(PortTypes::port_uint16_data_type::STATUSES, cell_run_status_data);
    return true;
#endif
}

std::string Keysight::get_mode(int value)
{
    switch (value)
    {
    case 1:
        return "CHARGE";
    case 2:
        return "DISCHARGE";
    default:
        return "REST";
    }
}

std::string Keysight::get_time_type(int value)
{
    switch (value)
    {
    case 1:
        return "AFTER";
    case 2:
        return "BEFORE";
    case 3:
        return "BEFORE_START";
    default:
        return "AT";
    }
}

std::string Keysight::get_test_action(int value)
{
    switch (value)
    {
    case 1:
        return "NEXT";
    default:
        return "FAIL";
    }
}

std::string Keysight::get_test_type(int value)
{
    switch (value)
    {
    case 0:
        return "VOLT_GE";
    case 1:
        return "VOLT_LE";
    case 2:
        return "CURR_GE";
    case 3:
        return "CURR_LE";
    case 4:
        return "POWER_GE";
    case 5:
        return "POWER_LE";
    case 6:
        return "AMPH_GE";
    case 7:
        return "AMPH_LE";
    case 8:
        return "WATTH_GE";
    case 9:
        return "WATTH_LE";
    case 10:
        return "POS_DVDT_GE";
    case 11:
        return "POS_DVDT_LE";
    case 12:
        return "NEG_DVDT_GE";
    case 13:
        return "NEG_DVDT_LE";
    case 14:
        return "POS_DIDT_GE";
    case 15:
        return "POS_DIDT_LE";
    case 16:
        return "NEG_DIDT_GE";
    case 17:
        return "NEG_DIDT_LE";
    case 18:
        return "DVMAX_GE";
    case 19:
        return "DVMAX_LE";
    case 20:
        return "DVMIN_GE";
    case 21:
        return "DVMIN_LE";
    case 22:
        return "DIMAX_GE";
    case 23:
        return "DIMAX_LE";
    case 24:
        return "DIMIN_GE";
    case 25:
        return "DIMIN_LE";
    default:
        return "NONE";
    }
}

void Keysight::start_logging(std::uint32_t test, std::vector<std::uint32_t> cells)
{
    if (logging_files.at(test) == nullptr)
    {
        std::ofstream csv_file;
        auto c = new std::ofstream;
        auto timestamp = get_timestamp();
        logging_files.at(test) = c;
        logging_files.at(test)->open("test" + std::to_string(test) + "_" + timestamp + ".csv", std::ios::out | std::ios::app);

        std::string s_commas;
        for (const auto &i : cells)
        {
            s_commas += ",";
        }
        
        *logging_files.at(test) << "Serial Number," << serial_numbers[test] << "\n";
        *logging_files.at(test) << ",,,Voltage(V)" << s_commas << ",Current (A)" << s_commas << ",Capacity (Ah)" << s_commas << ",Capacity (Wh)\n";

        //*logging_files.at(test) << "Cell Number, Voltage (V), Current (A), Capacity (aH), Capacity (Wh), Timestamp\n";
        *logging_files.at(test) << "Timestamp,Elapsed Time,Step";

        for (const auto &i : cells)
        {
            *logging_files.at(test) << "cell " << i << ",";
        }

        *logging_files.at(test) << ",";

        for (const auto &i : cells)
        {
            *logging_files.at(test) << "cell " << i << ",";
        }

        *logging_files.at(test) << ",";

        for (const auto &i : cells)
        {
            *logging_files.at(test) << "cell " << i << ",";
        }

        *logging_files.at(test) << ",";

        for (const auto &i : cells)
        {
            *logging_files.at(test) << "cell " << i << ",";
        }

        *logging_files.at(test) << "\n";

        logging_files.at(test)->flush();
    }
}

void Keysight::stop_logging(std::uint32_t test, std::vector<std::uint32_t> cells)
{
    auto x = logging_files.at(test);
    if (x != nullptr)
    {
        x->close();
        delete x;
        logging_files.at(test) = nullptr;
    }
}

std::string Keysight::get_timestamp()
{
    std::time_t time = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    auto timestamp = std::string(std::ctime(&time));
    timestamp.erase(std::remove(timestamp.begin(), timestamp.end(), '\r'), timestamp.end());
    timestamp.erase(std::remove(timestamp.begin(), timestamp.end(), '\n'), timestamp.end());
    std::replace(timestamp.begin(), timestamp.end(), ':', '_');

    return timestamp;
}

void Keysight::log_data(std::uint32_t test, std::vector<std::uint32_t> cells)
{
    auto timestamp = get_timestamp();

    auto elapsed_time = total_seq_uptime.at(test);
    int seconds = static_cast<std::uint64_t>(elapsed_time) % 60;
    int minutes = (seconds / 60) % 60;
    int hours = (minutes / 60) % 24;
    int days = hours / 24;

    auto elapsed_time_string =
        std::to_string(days) + "d " + std::to_string(hours) + "h " + std::to_string(minutes) + "m " + std::to_string(seconds) + "s";

    std::vector<double> voltages;
    std::vector<double> currents;
    std::vector<double> cell_cap_ahrs;
    std::vector<double> cell_cap_whrs;
    std::vector<std::uint16_t> step_numbers;

    for (const auto &i : cells)
    {
        LOG_OUT << "logging cells: " << i;
        int card_number = (i / 1000) - 1;
        int cell_number = i - ((i / 1000) * 1000) - 1;
        LOG_OUT << "card number: " << card_number;
        LOG_OUT << "cell index: " << cell_number;

        if (cell_voltage_data.find(card_number) != cell_voltage_data.end())
        {
            auto cell_voltage_vector = cell_voltage_data.at(card_number);
            if (cell_number < cell_voltage_vector.size())
            {
                voltages.push_back(cell_voltage_vector.at(cell_number));
            }
        }

        if (cell_current_data.find(card_number) != cell_current_data.end())
        {
            auto cell_current_vector = cell_current_data.at(card_number);
            if (cell_number < cell_current_vector.size())
            {
                currents.push_back(cell_current_vector.at(cell_number));
            }
        }

        if (cell_cap_ahr_data.find(card_number) != cell_cap_ahr_data.end())
        {
            auto cell_cap_vector = cell_cap_ahr_data.at(card_number);
            if (cell_number < cell_cap_vector.size())
            {
                cell_cap_ahrs.push_back(cell_cap_vector.at(cell_number));
            }
        }

        if (cell_cap_whr_data.find(card_number) != cell_cap_whr_data.end())
        {
            auto cell_cap_vector = cell_cap_whr_data.at(card_number);
            if (cell_number < cell_cap_vector.size())
            {
                cell_cap_whrs.push_back(cell_cap_vector.at(cell_number));
            }
        }
        
        if(cell_step_id_data.find(card_number) != cell_step_id_data.end()) {
            auto cell_id_vector = cell_step_id_data.at(card_number);
            if(cell_number < cell_id_vector.size()) {
                step_numbers.push_back(cell_id_vector.at(cell_number));
            }
        }
    }

    if (voltages.size() == currents.size() && voltages.size() == cell_cap_ahrs.size() && voltages.size() == cell_cap_whrs.size())
    {
        auto s = timestamp + "," + elapsed_time_string + "," + std::to_string(step_numbers.at(0)) + ",";

        for (const auto &i : voltages)
        {
            s += std::to_string(i) + ",";
        }

        s += ",";

        for (const auto &i : currents)
        {
            s += std::to_string(i) + ",";
        }

        s += ",";

        for (const auto &i : cell_cap_ahrs)
        {
            s += std::to_string(i) + ",";
        }

        s += ",";

        for (const auto &i : cell_cap_whrs)
        {
            s += std::to_string(i) + ",";
        }

        s += "\n";
        *logging_files.at(test) << s;
        logging_files.at(test)->flush();
    }

    // check for voltage limits first
    for (const auto &i : voltages)
    {
        if (i < min_red_voltage || i > max_red_voltage)
        {
            LOG_OUT << "voltage safety limit hit: " << i << ", min: " << min_red_voltage << ", max: " << max_red_voltage;
            *logging_files.at(test) << "voltage safety limit hit: " << i << ", min: " << min_red_voltage << ", max: " << max_red_voltage << "\n";
            logging_files.at(test)->flush();
            io_service.post(std::bind(&Keysight::stop_sequence2, this, test, 0, cells, 3));
            limit_crossed_callback(1, test);

            return;
        }
        else if (i < min_yellow_voltage || i > max_yellow_voltage)
        {
            limit_crossed_callback(0, test);
            if (test < slot_status.size())
            {
                slot_status[test] = 4;
                slot_status_callback(slot_status);
            }
        }
    }

    for (const auto &i : currents)
    {
        if (std::abs(i) > max_red_current)
        {
            LOG_OUT << "current safety limit hit: " << i << ", max: " << max_red_current;
            *logging_files.at(test) << "current safety limit hit: " << i << ", max: " << max_red_current << "\n";
            logging_files.at(test)->flush();
            io_service.post(std::bind(&Keysight::stop_sequence2, this, test, 0, cells, 3));
            limit_crossed_callback(1, test);
            return;
        }
    }
}

void Keysight::clear_hard_limit(std::uint32_t test)
{
    if (test < slot_status.size())
    {
        if (slot_status[test] == 3)
        {
            slot_status[test] = 0;
        }
        slot_status_callback(slot_status);
    }
}

void Keysight::clear_soft_limit(std::uint32_t test)
{
    if (test < slot_status.size())
    {
        if (slot_status[test] == 4)
        {
            slot_status[test] = 2;
        }
        slot_status_callback(slot_status);
    }
}

bool Keysight::check_cells_sequence_rollover_and_failures()
{
    LOG_OUT << "checking cells seq rollover";
    for (const auto &i : cells_being_run_map)
    {
        std::string s1 = "(@";
        for (auto k = 0; k < i.second.size(); k++)
        {
            s1 += std::to_string(i.second.at(k));
            if (k != i.second.size() - 1)
                s1 += ",";
        }

        std::string report = "STAT:CELL:REP? " + s1 + ")\n";
        LOG_OUT << "getting report: " << report;

#ifndef SOFTWARE_ONLY
        auto status = viPrintf(session, report.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending report query", "There was a problem sendfing report error code: ");

        if (res)
        {
            ViChar report_res[65535];
            status = viScanf(session, "%t", report_res);
            res = keysight::verify_vi_status(session, status, "getting cell report", "There was a problem getting cell report error code: ");
            LOG_OUT << "report: " << report_res;
            if (res)
            {
                status = viFlush(session, VI_READ_BUF); // discards any read buf so next scan is fine
                res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
                if (res)
                {
                    auto cell_rep = comma_delimiter(report_res);

                    // check if they are all "OK"
                    bool cell_rep_finished = true;
                    for (auto t : cell_rep)
                    {
                        t.erase(std::remove_if(t.begin(), t.end(), ::isspace), t.end());
                        if (t.compare("4") != 0)
                        {
                            LOG_OUT << "didnt match: " << t;
                            cell_rep_finished = false;
                            break;
                        }
                    }

                    LOG_OUT << "cell rep finished: " << cell_rep_finished;

                    if (cell_rep_finished && (successively_slots.at(i.first) == true))
                    {
                        if (cells_being_run_map.find(i.first) != cells_being_run_map.end() &&
                            cells_slots_being_run_map.find(i.first) != cells_slots_being_run_map.end())
                        {
                            auto c = cells_being_run_map.at(i.first);
                            auto slot = cells_slots_being_run_map.at(i.first);
                            total_seq_uptime_offset[i.first] += current_seq_uptime[i.first];
                            start_sequence(i.first, slot, c, true, serial_numbers[i.first]);
                            cycles_count[i.first]++;
                        }
                    }
                    else if (cell_rep_finished && (successively_slots.at(i.first) == false))
                    {
                        if (i.first < slot_status.size())
                        {
                            if (slot_status[i.first] == 2 || slot_status[i.first] == 4)
                            {
                                auto c = cells_being_run_map.at(i.first);
                                io_service.post(std::bind(&Keysight::stop_sequence2, this, i.first, 0, c, 5));
                            }
                        }
                    }
                }
                else
                    return false;
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }
#endif
    }
    return true;
}

bool Keysight::get_cells_running_uptime()
{
    for (const auto &i : cells_being_run_map)
    {
        std::string s1 = "(@";
        for (auto k = 0; k < i.second.size(); k++)
        {
            s1 += std::to_string(i.second.at(k));
            if (k != i.second.size() - 1)
                s1 += ",";
        }

        std::string time = "CELL:TIME? " + s1 + ")\n";
        LOG_OUT << "getting uptime: " << time;

#ifndef SOFTWARE_ONLY
        auto status = viPrintf(session, time.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending cell time", "There was a problem sendfing cell time error code: ");

        if (res)
        {
            ViChar time_res[65535];
            status = viScanf(session, "%t", time_res);
            res = keysight::verify_vi_status(session, status, "getting cell time", "There was a problem getting cell time error code: ");
            LOG_OUT << "uptime: " << time_res;
            if (res)
            {
                status = viFlush(session, VI_READ_BUF); // discards any read buf so next scan is fine
                res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
                if (res)
                {
                    auto times = comma_delimiter(time_res);
                    double greatest_time = 0.0;
                    for (const auto &t : times)
                    {
                        double current_time = std::stod(t);
                        if (current_time > greatest_time)
                            greatest_time = current_time;
                    }
                    current_seq_uptime[i.first] = greatest_time;
                    total_seq_uptime[i.first] = greatest_time + total_seq_uptime_offset[i.first];
                }
                else
                    return false;
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }

#endif
    }
    time_status_callback(current_seq_uptime);
    total_time_callback(total_seq_uptime);
    return true;
}

void Keysight::start_sequence(std::uint32_t test, std::uint32_t slot, std::vector<std::uint32_t> cells, bool successively, std::string serialNumber)
{
    std::string s1 = "(@";

    for (auto i = 0; i < cells.size(); i++)
    {
        s1 += std::to_string(cells.at(i));
        if (i != cells.size() - 1)
            s1 += ",";
    }

    std::string enab = "CELL:ENABLE " + s1 + ")," + std::to_string(slot + 1) + "\n";
    std::string init = "CELL:INIT " + s1 + ")\n";

    LOG_OUT << "enabled cells: " << enab;
    LOG_OUT << "init cells: " << init;

    if (test < slot_status.size())
    {
        slot_status[test] = 2;
        successively_slots[test] = successively;
        serial_numbers[test] = serialNumber;
        slot_status_callback(slot_status);
    }

#ifndef SOFTWARE_ONLY
    auto status = viPrintf(session, enab.c_str());
    auto res = keysight::verify_vi_status(session, status, "sending enab", "There was a problem enabling cells error code: ");

    if (!res)
    {
        disconnect();
        return;
    }

    status = viPrintf(session, init.c_str());
    res = keysight::verify_vi_status(session, status, "sending enab", "There was a problem enabling cells error code: ");

    if (!res)
    {
        disconnect();
        return;
    }
#endif

    cells_being_run_map[test] = cells;
    cells_slots_being_run_map[test] = slot;
    start_logging(test, cells);
}

void Keysight::stop_sequence(std::uint32_t test, std::uint32_t slot, std::vector<std::uint32_t> cells)
{
    stop_sequence2(test, slot, cells, 0);
}

void Keysight::stop_sequence2(std::uint32_t test, std::uint32_t slot, std::vector<std::uint32_t> cells, std::uint8_t _slot_status)
{
    std::string s1 = "(@";

    for (auto i = 0; i < cells.size(); i++)
    {
        s1 += std::to_string(cells.at(i));
        if (i != cells.size() - 1)
            s1 += ",";
    }

    std::string abort = "CELL:ABORT " + s1 + ")\n";
    LOG_OUT << "sending command: " << abort;

    if (test < slot_status.size())
    {
        slot_status[test] = _slot_status;
        successively_slots[test] = false;
        serial_numbers[test] = "";
        slot_status_callback(slot_status);
    }
    LOG_OUT << "slot status updated";

#ifndef SOFTWARE_ONLY
    auto status = viPrintf(session, abort.c_str());
    auto res = keysight::verify_vi_status(session, status, "sending enab", "There was a problem enabling cells error code: ");

    if (!res)
    {
        disconnect();
        return;
    }
#endif

    stop_logging(test, cells);
    LOG_OUT << "logging stopped";

    if (cells_being_run_map.find(test) != cells_being_run_map.end())
    {
        cells_being_run_map.erase(test);
    }

    if (cells_slots_being_run_map.find(test) != cells_slots_being_run_map.end())
    {
        cells_slots_being_run_map.erase(test);
    }
}

void Keysight::load_sequence(std::string name, int slot, sequence_step_vector steps, sequence_test_map tests)
{
    if (slot < currently_loaded_profiles.size())
    {
        currently_loaded_profiles[slot] = name;
        loaded_profiles_callback(currently_loaded_profiles);

#ifdef SOFTWARE_ONLY

        current_profile_statuses[slot] = 1;
        if (slot > 3)
            current_profile_statuses[slot] = 2;
        profile_status_callback(current_profile_statuses);
#else
        auto clear_str = "SEQ:CLE " + std::to_string(slot + 1) + "\n";
        auto status = viPrintf(session, clear_str.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending sequence clear", "There was a problem cearing sequence: ");
        if (!res)
        {
            disconnect();
            return;
        }
#endif
        for (auto i = 0; i < steps.size(); i++)
        {
            auto step = steps.at(i);
            auto mode_value = step.at(SequenceTypes::sequence_step_access_type::MODE);

            auto seq_id = slot + 1; // 1 indexed
            auto step_id = i + 1;
            auto mode = get_mode(mode_value);
            auto duration = static_cast<int>(step.at(SequenceTypes::sequence_step_access_type::SECONDS));
            auto current = step.at(SequenceTypes::sequence_step_access_type::CURRENT);
            auto voltage = step.at(SequenceTypes::sequence_step_access_type::VOLTAGE);

            std::string s1 = "SEQ:STEP:DEF ";
            std::string s2 = std::to_string(seq_id) + ",";
            std::string s3 = std::to_string(step_id) + ",";
            std::string s4 = mode + ",";
            std::string s5 = std::to_string(duration) + ",";
            std::string s6 = std::to_string(current) + ",";
            std::string s7 = std::to_string(voltage) + "\n";

            auto s = s1 + s2 + s3 + s4 + s5 + s6 + s7;

            LOG_OUT << "step command: " << s;
#ifndef SOFTWARE_ONLY

            // LOG_OUT << "clear command: " << clear_str;
            //
            //

            status = viPrintf(session, s.c_str());
            res = keysight::verify_vi_status(session, status, "sending step", "There was a problem sending step error code: ");

            if (!res)
            {
                disconnect();
                return;
            }
#endif
        }

        for (const auto &i : tests)
        {
            auto test_vec = i.second;

            for (auto k = 0; k < test_vec.size(); k++)
            {
                auto test = test_vec.at(k);
                auto test_type_value = test.at(SequenceTypes::sequence_test_access_type::TEST_TYPE);
                auto time_type_value = test.at(SequenceTypes::sequence_test_access_type::TIME_TYPE);
                auto test_action_value = test.at(SequenceTypes::sequence_test_access_type::TEST_ACTION);

                auto seq_id = slot + 1;
                auto step_id = i.first + 1;
                auto test_id = k + 1;
                auto test_type = get_test_type(test_type_value);
                auto value = test.at(SequenceTypes::sequence_test_access_type::VALUE);
                auto time_type = get_time_type(time_type_value);
                auto time_limit = test.at(SequenceTypes::sequence_test_access_type::TIME_LIMIT);
                auto test_action = get_test_action(test_action_value);

                std::string s1 = "SEQ:TEST:DEF ";
                std::string s2 = std::to_string(seq_id) + ",";
                std::string s3 = std::to_string(step_id) + ",";
                std::string s4 = std::to_string(test_id) + ",";
                std::string s5 = test_type + ",";
                std::string s6 = std::to_string(value) + ",";
                std::string s7 = time_type + ",";
                std::string s8 = std::to_string(time_limit) + ",";
                std::string s9 = test_action + "\n";

                auto s = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9;

                LOG_OUT << "test command: " << s;
#ifndef SOFTWARE_ONLY
                auto status = viPrintf(session, s.c_str());
                auto res = keysight::verify_vi_status(session, status, "sending step", "There was a problem sending step error code: ");

                if (!res)
                {
                    disconnect();
                    return;
                }
#endif
            }
        }

#ifndef SOFTWARE_ONLY
        auto catalog = get_catalog();
        for (const auto &i : catalog)
        {
            if (i == slot)
            {
                current_profile_statuses[slot] = 2;
                profile_status_callback(current_profile_statuses);
                return;
            }
        }

        current_profile_statuses[slot] = 1;
        profile_status_callback(current_profile_statuses);
#endif
    }
}

void Keysight::set_safety_limits(double _min_yellow_voltage, double _min_red_voltage, double _max_yellow_voltage, double _max_red_voltage,
                                 double _max_red_current)
{
    min_yellow_voltage = _min_yellow_voltage;
    min_red_voltage = _min_red_voltage;
    max_yellow_voltage = _max_yellow_voltage;
    max_red_voltage = _max_red_voltage;
    max_red_current = _max_red_current;
}
