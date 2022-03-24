#ifndef SEQUENCE_COMMANDS_HPP
#define SEQUENCE_COMMANDS_HPP

#include <visa.h>

#include <string>

// Sequence commands define the forming process, which is comprised of a sequence of charge,
// discharge, and rest steps.

class SequenceCommands {
public:
    SequenceCommands();

    // Returns which sequences are valid. A valid sequence must have at least one step defined.
    void catalog();

    // Clears the specified sequence. Omitting the <seq_id> clears all sequences. Note that even after the
    // definition of the sequence has been cleared, the cells remain assigned to that sequence, until they are
    // re-assigned to a different sequence.
    void clear(const ViSession &session, std::string sequence_id) const;

    // Returns how many valid steps are defined in the sequence specified by <seq_id>. A valid sequence
    // must have at least one step defined at <step_id> 1.
    void step_count(std::string sequence_id);

    // Defines a step in a sequence. The query returns the defined values.
    //<seq_id> - specifies the sequence to which the step is added. Sequences are numbered from 1 to 8.
    //<step_id> - specifies which step number is being added. Steps are numbered from 1 to 256. A missing
    // or unspecified step will cause the sequence to end and exit to the Rest state at the missing step.
    //<mode> can be specified as PRECHARGE, CHARGE, DISCHARGE, or REST. This specifies whether the
    // channel is sinking current, sourcing current, or resting with the output is disconnected. If resting, the
    //<CC>and<CV> parameters are ignored.
    //<duration> is the maximum allowable step time in seconds. Values range from 1 to 2147483647. Note
    // that the step can terminate earlier than the duration due to a test condition being met. For a
    // Precharge step, the maximum allowable step time is limited to 900 seconds (15 minutes). You can use
    // multiple Precharge steps if more than 15 minutes of precharge is desired.
    //<CC> is the current limit for the step. The channel will limit the current to this value. In charge mode
    //<CC> refers to the current source limit. In discharge mode, the <CC> refers to the current sink limit.
    // The minimum lower limit to this parameter is determined by the number of channel’s paralleled
    // together such that MinCC is ≥ (#ofParalleledChannels * 0.01A). The maximum upper limit to this
    // parameter is determined by the number of channel’s paralleled together such that MaxCC is ≤
    //(#ofParalleledChannels * 6.25A). For a Precharge step, the MaxCC is ≤ (#ofParalleledChannels * 1A).
    //<CV> is the voltage limit for the step. The channel will limit the voltage to this value. Values range
    // from 2.0 V to 4.5 V. For a Precharge step, the cell voltage range is fro 1.0 V to 2.0 V.
    void step_define(const ViSession &session, std::string sequence_id, std::string step_id, std::string mode, std::string duration,
                     std::string cc = "", std::string cv = "") const;
    void step_define(std::string sequence_id, std::string step_id);

    // Returns a count of how many sequence tests are defined for the step given by <seq_id>,<step_id>.
    void test_count();

    // Defines a test that will monitor during a particular step. Tests define conditions to verify that cells are
    // performing properly, and will transition to the next step based on cell performance. Up to 32 tests can
    // be defined per step. Tests are not active during Rest steps. The query returns the defined values.
    //<seq_id> - specifies the sequence to which the step is added. Sequences are numbered from 1 to 8.
    //<step_id> - specifies which step number is being added. Steps are numbered from 1 to 256. A missing
    // or unspecified step will cause the sequence to end and exit to the Rest state at the missing step.
    //<test_id> - specifies which test is being added to the step. Tests are numbered from 1 to 32.
    //<test_type> - specifies one of the following test types
    void test_define(std::string sequence_id, std::string step_id, std ::string test_id, std::string test_type, std::string value,
                     std::string time_type, std::string time_limit, std::string test_action);
    void test_define(std::string sequence_id, std::string step_id, std::string test_id);
};

#endif