
#include <boost/asio.hpp>
#include <logger.hpp>

#include "backend.hpp"

// dart api headers
#include "include/dart_api.h"
#include "include/dart_api_dl.h"
#include "include/dart_native_api.h"

#define LOG_OUT LogOut("keysight backend")
#define LOG_ERR LogErr("keysight backend")

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

namespace {
// These are needed for the actual backend
// Creating an actual object within frontend is overtly complicated and still being developed within
// the language itself. No one should be accessing these outside of the library itself
boost::asio::io_service io_service;
std::shared_ptr<Backend> backend;

void print_backend_doesnt_exist_error() { LOG_ERR << "backend object doesn't exist"; }
}  // namespace

extern "C" {
EXPORT std::intptr_t InitializeDartApi(void *data) { return Dart_InitializeApiDL(data); }

EXPORT void create_backend() {
    if (!backend) {
        backend = std::make_shared<Backend>(io_service);
    } else
        print_backend_doesnt_exist_error();
}
}

int main(int argc, char **argv) { return 0; }