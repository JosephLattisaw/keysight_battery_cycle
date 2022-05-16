#ifndef SEQUENCE_HPP
#define SEQUENCE_HPP

#include "sequence_step.hpp"

namespace sequences {
class Sequence {
public:
    Sequence(std::string name, std::string comments, std::vector<std::shared_ptr<SequenceStep>> steps);

    std::string get_name() { return name; }
    std::string get_comments() { return comments; }

    std::vector<std::shared_ptr<SequenceStep>> get_steps() { return steps; }

private:
    std::string name;
    std::string comments;
    std::vector<std::shared_ptr<SequenceStep>> steps;

    const std::uint8_t MAX_STEPS_PER_SEQUENCE = 255;
};
}  // namespace sequences

#endif