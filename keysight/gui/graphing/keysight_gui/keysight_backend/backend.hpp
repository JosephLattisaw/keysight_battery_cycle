#ifndef BACKEND_HPP
#define BACKEND_HPP

#include <memory>

#include "sequence_parser.hpp"

class Backend {
public:
    Backend();

    std::shared_ptr<SequenceParser> sequence_parser;

private:
};

#endif