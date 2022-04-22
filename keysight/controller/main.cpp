#include <boost/asio.hpp>
#include <boost/asio/signal_set.hpp>
#include <boost/bind/bind.hpp>
#include <iostream>

#include "common.hpp"
#include "controller.hpp"
#include "types.hpp"
#include "visa.h"

namespace keysight {
extern ViSession resource_manager;
extern ViSession session;
}  // namespace keysight

int main(int, char **) {
    try {
    boost::asio::io_service io_service;
    Controller controller(
                    io_service,
                    [&](active_cards_type) {
                        // active cells callback
                    },
                    [&](cap_ahr_data_type) {
                        // cap ahr data callback
                    },
                    [&](cap_whr_data_type) {
                        // cap whr data callback
                    });
                    boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work_guard(io_service.get_executor());
                    io_service.run();
        // TODO might not need all this gibberish if locking works correctly
        // boost::asio::io_service joe_service;
        // Block all signals for background thread.
        /*sigset_t new_mask;
        sigfillset(&new_mask);
        sigset_t old_mask;
        pthread_sigmask(SIG_BLOCK, &new_mask, &old_mask);

        boost::asio::io_service io_service;
        boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work_guard(io_service.get_executor());
        {
            std::thread t([&io_service] {
                Controller controller(
                    io_service,
                    [&](active_cards_type) {
                        // active cells callback
                    },
                    [&](cap_ahr_data_type) {
                        // cap ahr data callback
                    },
                    [&](cap_whr_data_type) {
                        // cap whr data callback
                    });
                io_service.run();
            });
            t.detach();
        }

        // Restore previous signals.
        pthread_sigmask(SIG_SETMASK, &old_mask, 0);

        sigset_t wait_mask;
        sigemptyset(&wait_mask);
        sigaddset(&wait_mask, SIGINT);
        sigaddset(&wait_mask, SIGQUIT);
        sigaddset(&wait_mask, SIGTERM);
        pthread_sigmask(SIG_BLOCK, &wait_mask, 0);
        int sig = 0;
        sigwait(&wait_mask, &sig);

        work_guard.reset();
        //viUnlock(keysight::session);
        //viClose(keysight::session);*/

    } catch (std::exception &e) {
        std::cerr << "exception: " << e.what() << std::endl;
    }

    return 0;
}
