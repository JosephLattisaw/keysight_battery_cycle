#ifndef CONTROLLER_HPP
#define CONTROLLER_HPP

#include <visa.h>

#include <boost/asio.hpp>
#include <memory>
#include <string>

#include "keysight.hpp"
#include "sequence_commands.hpp"
#include "types.hpp"

class Controller {
public:
    using ActiveCardsCallback = std::function<void(active_cards_type)>;
    using CapAhrDataCallback = std::function<void(cap_ahr_data_type)>;
    using CapWhrDataCallback = std::function<void(cap_whr_data_type)>;
    Controller(boost::asio::io_service &io_service, ActiveCardsCallback active_cards_callback, CapAhrDataCallback cap_ahr_data_callback,
               CapWhrDataCallback cap_whr_data_callback);
    ~Controller();

    void active_cards_request(active_cards_type active_cards);
    void cap_ahr_data_request(cap_ahr_data_type data);
    void cap_whr_data_request(cap_whr_data_type data);

private:
    // thread management
    void keysight_thread_is_up();  // TODO this will get removed
    void worker_thread();

    boost::asio::io_service &io_service;

    std::shared_ptr<Keysight> keysight;
    boost::asio::io_service keysight_service;
    std::thread keysight_thread;

    // callbacks
    ActiveCardsCallback active_cards_callback;
    CapAhrDataCallback cap_ahr_data_callback;
    CapWhrDataCallback cap_whr_data_callback;
};

#endif