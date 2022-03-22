#ifndef OUTPUT_COMMANDS_HPP
#define OUTPUT_COMMANDS_HPP

class OutputCommands {
public:
    OutputCommands();

    // Resets any protection events that have occurred.
    void protection_clear();
};

#endif