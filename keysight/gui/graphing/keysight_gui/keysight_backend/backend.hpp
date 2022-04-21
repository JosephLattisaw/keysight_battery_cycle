#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <visa.h>

#include <boost/asio.hpp>
#include <functional>
#include <memory>

#include "keysight.hpp"
#include "sequence_parser.hpp"
#include "types.hpp"

class Backend {
    using ActiveCardsCallback = std::function<void(active_cards_type)>;
    using CapAhrDataCallback = std::function<void(cap_ahr_data_type)>;
    using CapWhrDataCallback = std::function<void(cap_whr_data_type)>;
    using LoadSequencesCallback = std::function<void(sequences_info_map_type)>;

public:
    Backend(boost::asio::io_service &io_service, ActiveCardsCallback active_cards_callback, CapAhrDataCallback cap_ahr_data_callback,
            CapWhrDataCallback cap_whr_data_callback, LoadSequencesCallback load_sequences_callback);
    ~Backend();

    // TODO find out if we can make this private
    void active_cards_request(active_cards_type active_cards);
    void cap_ahr_data_request(cap_ahr_data_type data);
    void cap_whr_data_request(cap_whr_data_type data);

    std::shared_ptr<SequenceParser> sequence_parser;

private:
    // thread management
    void keysight_thread_is_up();  // TODO this will get removed
    void worker_thread();

    boost::asio::io_service &io_service;
    boost::asio::io_service keysight_service;

    std::shared_ptr<Keysight> keysight;
    std::thread keysight_thread;

    // callbacks
    ActiveCardsCallback active_cards_callback;
    CapAhrDataCallback cap_ahr_data_callback;
    CapWhrDataCallback cap_whr_data_callback;
    LoadSequencesCallback load_sequences_callback;
};

#endif