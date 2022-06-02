#include "keysight.hpp"

#include "../../logger/logger.hpp"

#define LOG_OUT LogOut("keysight")
#define LOG_ERR LogOut("keysight")

Keysight::Keysight(boost::asio::io_service &io_service, ConnectionStatusCallback _connection_status_callback)
    : io_service(io_service), cell_status_timer(io_service), connection_status_callback{_connection_status_callback} {
    cards.fill(std::make_shared<ModuleCard>());

    visa_handler = std::make_shared<VisaHandler>(VISA_ADDRESS_BT2203A, [&](bool connection_status) { update_connection_status(connection_status); });
}

void Keysight::connect() { visa_handler->connect(); }

void Keysight::disconnect() { visa_handler->disconnect(); }

void Keysight::update_connection_status(bool flag) {
    // handle the state appropriately
    if (connected && !flag) {
        // disconnecting state
        connected = false;
        // TODO reset all states
    } else if (!connected && flag) {
        connected = true;
        // connecting state
        detect_cards_at_boot();
        if (connected) {
            reset();
            if (connected) {
                connection_status_callback(true);
                start_polling_cell_status();
            } else
                LOG_ERR << "error resetting state";
        } else
            LOG_ERR << "error detecting cards at boot";
    }
}

void Keysight::get_cell_status() {
    // TODO
    for (auto i = 0; i < cards.size(); i++) {
        auto active = cards.at(i)->is_active();

        if (active) {
            // TODO
            auto cap_ahr = get_cap_ahr(i);
            auto cap_whr = get_cap_whr(i);
        }
    }
}

std::array<std::double_t, 32> Keysight::get_cap_ahr(std::uint8_t card_number) {
#ifndef SOFTWARE_ONLY
    auto result = get_cap(card_number, "MEAS:CELL:CAP:AHR? (@");
    return result;

#else
    std::array<std::double_t, 32> cell_cap_ahr = {0.0,  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                                  16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};

    return cell_cap_ahr;
#endif
}

std::array<std::double_t, 32> Keysight::get_cap_whr(std::uint8_t card_number) {
#ifndef SOFTWARE_ONLY
    auto result = get_cap(card_number, "MEAS:CELL:CAP:WHR? (@");
    return result;

#else
    std::array<std::double_t, 32> cell_cap_whr = {0.0,  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                                  16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};

    return cell_cap_whr;
#endif
}

std::array<std::double_t, 32> Keysight::get_cap(std::uint8_t card_number, std::string capacity_cmd) {
    std::array<std::double_t, 32> result;
    result.fill(0);

    auto s1 = capacity_cmd;
    auto s2 = std::to_string(card_number + 1);
    auto s3 = "001:";
    auto s4 = s2;
    auto s5 = "032)";
    auto s = s1 + s2 + s3 + s4 + s5;

    auto res = visa_handler->send_command(s);
    if (res) {
        std::string cap_ahr;
        res = visa_handler->get_response(cap_ahr);
        if (res) {
            auto s_vec = comma_delimiter(cap_ahr);

            for (auto i = 0; i < s_vec.size() && i < result.size(); i++) {
                result.at(i) = std::stod(s_vec.at(i));
            }

        } else
            LOG_ERR << "error getting cap ahr";
    } else
        LOG_ERR << "sending getting cap ahr";

    return result;
}

std::array<std::array<std::string, 10>, 32> Keysight::get_cell_verbose(std::uint8_t card_number) {
    std::array<std::array<std::string, 10>, 32> result;
    std::array<std::string, 10> result_sub;
    result_sub.fill("");
    result.fill(result_sub);

#ifndef SOFTWARE_ONLY
    for (auto k = 1; k < 33; k++) {
        std::string s1 = "STAT:CELL:VERB? ";
        std::string s2 = std::to_string(card_number + 1);
        std::string s3 = (k < 10) ? "00" : "0";
        std::string s4 = std::to_string(k);
        std::string s = s1 + s2 + s3 + s4;

        auto res = visa_handler->send_command(s);

        if (res) {
            std::string verb_resp;
            res = visa_handler->get_response(verb_resp);
            if (res) {
                auto vec = comma_delimiter(verb_resp);
                if (vec.size() == 10) {
                    // valid response size
                } else {
                    LOG_ERR << "received invalid cell response size";
                    break;
                }
            } else {
                LOG_ERR << "error getting cell verbose response";
                break;
            }
        }
    }
#else

#endif
    return result;
}

void Keysight::start_polling_cell_status() {
    cell_status_timer.expires_after(std::chrono::seconds(1));
    cell_status_timer.async_wait([&](const boost::system::error_code &error) {
        if (error == boost::asio::error::operation_aborted) {
            LOG_OUT << "cell status timer was cancelled";  // this isn't necessarily an error
        } else if (error) {
            LOG_ERR << "timer encountered error: " << error.message();
            disconnect();
        } else {
            // LOG_OUT << "getting cell status";
            get_cell_status();
            start_polling_cell_status();
        }
    });
}

void Keysight::reset() {
    LOG_OUT << "attempting to reset state";

#ifndef SOFTWARE_ONLY
    auto res = visa_handler->send_command("CELL:ABORT 0");
    if (res) {
        res = visa_handler->send_command("CELL:CLEAR 0");
        if (res) {
            res = visa_handler->send_command("SEQ:CLEAR 0");
            if (!res) LOG_ERR << "error clearing sequences";
        } else
            LOG_ERR << "error clearing cells";
    } else
        LOG_ERR << "error aborting cells";
#endif
}

void Keysight::detect_cards_at_boot() {
    LOG_OUT << "sending the detect cards command";

#ifndef SOFTWARE_ONLY
    auto res = visa_handler->send_command("SYST:CARD:DET:BOOT? 0");
    if (res) {
        std::string cards_detected;
        res = visa_handler->get_response(cards_detected);
        if (res) {
            LOG_OUT << "cards detected: " << cards_detected;
            auto s_vec = comma_delimiter(cards_detected);

            std::vector<std::uint8_t> result;

            for (const auto &i : s_vec) {
                LOG_OUT << "stoi-ing: " << i;
                result.push_back(std::stoi(i));
            }

            if (result.size() == 1) {
                // if result is same number across the board we need to initialize the entire vector
                bool val = result.at(0);
                result = std::vector<std::uint8_t>(8, val);
                LOG_OUT << "all cards were same value: " << static_cast<int>(val);
            } else if (result.size() != 8) {
                // if we get an invalid result size, just say all the cards are off to be safe
                result = std::vector<std::uint8_t>(8, false);
                LOG_ERR << "cards returned an invalid size: " << result.size() << ", marking all cards off";
            } else {
                LOG_OUT << "successfully detected all the cards";
            }

            // setting cards active
            for (auto i = 0; i < result.size() && i < cards.size(); i++) {
                cards.at(i)->set_card_active(result.at(i));
            }

        } else {
            LOG_ERR << "error getting active cards response";
            return;
        }
    } else {
        LOG_ERR << "detecting cards at boot command failed";
        return;
    }
#else
    for (auto i = 0; i < 3 && i < cards.size(); i++) {
        cards.at(i)->set_card_active(true);
    }
#endif
}

std::vector<std::string> Keysight::comma_delimiter(std::string x) {
    std::string s = x;
    std::string delimiter = ",";
    std::size_t pos = 0;
    std::string token;

    std::vector<std::string> result;

    while ((pos = s.find(delimiter)) != std::string::npos) {
        token = s.substr(0, pos);
        result.push_back(token);
        s.erase(0, pos + delimiter.length());
    }

    result.push_back(s);

    return result;
}