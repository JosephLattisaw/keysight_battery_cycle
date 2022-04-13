#include "backend.hpp"

#include <memory>

Backend::Backend() { sequence_parser = std::make_shared<SequenceParser>(); }
