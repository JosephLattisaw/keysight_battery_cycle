#include "sequence.hpp"

#include <cassert>

namespace sequences {
Sequence::Sequence(std::string _name, std::string _comments, std::vector<std::shared_ptr<SequenceStep>> _steps)
    : name(_name), comments(_comments), steps(_steps) {
    assert((!name.empty()) && "sequence name cannot be empty");
    assert((_steps.size() <= MAX_STEPS_PER_SEQUENCE) && "steps size cannot be greater than maximum allowed");
}

void save_sequence(std::shared_ptr<Sequence> seqeunce) {}
}  // namespace sequences