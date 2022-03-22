#ifndef CELL_COMMANDS_HPP
#define CELL_COMMANDS_HPP

#include <string>

// Cell commands program a group of channels that have been paralleled together using the
// CELL:DEFine command. Use the <cell_ID> or <cell_list> parameter to send commands to multiple
// cells. Refer to Cell ID for more information.

class CellCommands {
public:
    CellCommands();

    // Aborts specific cells that may be running a sequence. After this command the cell connections open
    // into a high impedance state, and the sequence moves to the rest state. The parameter specifies which
    // cells to abort. If the parameter is omitted (or 0), all running cells will abort. This is the same as ABORt.
    void abort(std::string cell_list);

    // Ungroups a paralleled cell into its constituent channels. If the parameter is omitted (or 0), all
    // paralleled cells will ungroup.
    void clear(std::string cell_list);

    // Defines a paralleled group of channels into a cell. The <cell_id> assigned using this command can be
    // used in other SCPI commands that accept a <cell_list> parameter to send commands to the cell.
    void define(std::string cell_id, std::string channel_list);
    void define(std::string cell_id);

    // Automatically defines cells of size <cell_size> across all charge-discharge modules. This parallels
    // multiple channels to match the desired current rating of a cell. This is useful only if ALL batteries
    // connected to the CDS are of the same type, having the same maximum current limit.
    // As cell charge-discharge sequences can only be run on cells, not channels, this command provides a
    // quick way to define cells of a certain size without sending many CELL:DEFine commands. Cells are
    // defined for all modules installed in the mainframe.
    void define_quick(std::string cell_size);

    // Assigns a sequence to a cell list, enabling it to participate in a sequence. The first parameter specifies
    // which cells are being enabled. The second <seq_id> parameter specifies which sequence to assign to
    // the cells. If the <seq_id> parameter is from 1 to 8, it is assigning a sequence to the cell. If the
    // parameter is 0, then the cell list is removed from the sequence.
    void enable(std::string cell_list, std::string sequence_id);
    void enable(std::string cell_list);

    // Initiates the specified cells to start their sequence. All cells listed or included in the cell list must be
    // valid cells and must have been assigned a valid sequence.
    void initiate(std::string cell_list);

    // Returns the step number and the time elapsed in seconds in the current step for the specified cells.
    void step_time(std::string cell_list);

    // Returns the time that the sequence has been running on the specified cells in seconds. The time is
    // returned regardless of whether the indicated cells are running the same or different sequences.
    void time(std::string cell_list);
};

#endif