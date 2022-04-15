#include "system_commands.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("system_commands")
#define LOG_ERR LogOut("system_commands")

SystemCommands::SystemCommands() {}

std::vector<int> SystemCommands::detect_cards_at_boot(const ViSession &session) {
    LOG_OUT << "sending the detect cards command";

    viPrintf(session, "SYST:CARD:DET:BOOT? 0\n");  // sending the detect all cards command

    // getting the response for the card detection query
    ViChar cards_detected[65535];
    viScanf(session, "%t", cards_detected);

    LOG_OUT << "cards detected: " << cards_detected;

    std::vector<int> result;

    // std::string s = "0,0,0,0,0,0,0,0";
    // std::string s = "1";
    std::string s = std::string(cards_detected);
    std::string delimiter = ",";

    std::size_t pos = 0;
    std::string token;

    std::size_t expected_size = 7;

    while ((pos = s.find(delimiter)) != std::string::npos) {
        token = s.substr(0, pos);
        result.push_back(static_cast<bool>(std::stoi(token)));
        s.erase(0, pos + delimiter.length());
    }

    result.push_back(std::stoi(s));

    if (result.size() == 1) {
        // if result is same number across the board we need to initialize the entire vector
        bool val = result.at(0);
        result = std::vector<int>(8, val);
        LOG_OUT << "all cards were same value: " << static_cast<int>(val);
    } else if (result.size() != 8) {
        // if we get an invalid result size, just say all the cards are off to be safe
        result = std::vector<int>(8, false);
        LOG_ERR << "cards returned an invalid size: " << result.size() << ", marking all cards off";
    } else {
        LOG_OUT << "successfully detected all the cards";
    }

    return result;
}