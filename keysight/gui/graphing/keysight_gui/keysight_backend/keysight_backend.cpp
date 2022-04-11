#include <boost/asio.hpp>
#include <iostream>

// dart api headers
#include "include/dart_api.h"
#include "include/dart_api_dl.h"
#include "include/dart_native_api.h"

namespace {
// These are needed for the actual backend
// Creating an actual object within frontend is overtly complicated and still being developed within
// the language itself. No one should be accessing these outside of the library itself
boost::asio::io_service io_service;
}  // namespace

extern "C" {
DART_EXPORT intptr_t InitializeDartApi(void *data) { return Dart_InitializeApiDL(data); }
}

int main(int argc, char **argv) {
    io_service.run();
    return 0;
}