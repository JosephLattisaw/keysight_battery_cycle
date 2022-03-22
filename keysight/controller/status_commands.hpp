#ifndef STATUS_COMMANDS_HPP
#define STATUS_COMMANDS_HPP

#include <string>

class StatusCommands {
public:
    StatusCommands();

    // Returns the latest probe check result. If a sequence is active, it reports the latest result from probe
    // check which runs continuously. If a sequence was completed, it will report the probe check result from
    // the end of the sequence. A 1 is returned if probe check failed; otherwise a 0 (zero) is returned,
    // indicating success. A zero is also returned if no probe check measurements have ever been done.
    void cell_probe(std::string cell_list);

    // Returns a status report for the specified cells. The following values can be returned:
    // 0=NONE is returned if the cell has not run a sequence.
    // 1=RUNNING indicates the cell is running a sequence and has no failures.
    // 2=FAIL indicates a test has failed.
    // 3=ABORT indicates the sequence has been aborted.
    // 4=OK indicates the cell has completed a sequence with no failures.
    void cell_report(std::string cell_list);

    // Returns how many cells are still running a sequence. The count is returned regardless of whether the
    // cells are running the same or different sequences. The return value will be an integer from 0 to 256.
    void cell_run_count();

    // Returns information about a completed step in the sequence. The query only returns a valid response
    // after a step has completed - otherwise a string of zeroes is returned.
    void cell_step();

    // Returns a summary of the current state or "snapshot" of the cell.
    void cell_verbose();

    // Returns the sum of the bits in the event register for the Standard Operation Register group. An event
    // register is a read-only register that latches events from the condition register. While an event bit is
    // set, subsequent events corresponding to that bit are ignored. The register bits are cleared when you
    // read the register.
    void operation_event();

    // Returns the sum of the bits in the condition register for the Standard Operation Register group. This
    // register is read-only; bits are not cleared when read.
    void operation_condition();

    // Sets and queries bits in the enable register for the Standard Operation Register group. The enable
    // register is a mask for enabling specific bits from the Operation Event register to set the OPER
    //(operation summary) bit of the Status Byte register. STATus:PRESet clears all bits in the enable
    // register.
    // Note that *CLS does not clear the enable register, but does clear the event register.
    void operation_enable(std::string value);
    void operation_enable();
};

#endif