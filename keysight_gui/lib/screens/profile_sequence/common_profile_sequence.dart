const List<List<String>> testTypeDescription = [
  /*[
    "NONE",
    "Value when the test is undefined; also returned when the test result is within test limits",
  ],*/
  [
    "VOLT_GE",
    "The cell voltage that is greater than or equal to the programmed <value>",
  ],
  [
    "VOLT_LE",
    "The cell voltage that is less than or equal to the programmed <value>",
  ],
  [
    "CURR_GE",
    "The cell current that is greater than or equal to the programmed <value>",
  ],
  [
    "CURR_LE",
    "The cell current that is less than or equal to the programmed <value>",
  ],
  [
    "POWER_GE",
    "The absolute value of cell power in Watts (cell voltage x cell current) that is greater than or equal to the programmed <value>",
  ],
  [
    "POWER_LE",
    "The absolute value of cell power in Watts (cell voltage x cell current) that is less than or equal to the programmed <value>",
  ],
  [
    "AMPH_GE",
    "The absolute value of cell capacity in Ampere-hours that is greater than or equal to the programmed <value>",
  ],
  [
    "AMPH_LE",
    "The absolute value of cell capacity in Ampere-hours that is less than or equal to the programmed <value>",
  ],
  [
    "WATTH_GE",
    "The absolute value of cell capacity in Watt-hours that is greater than or equal to the programmed <value>",
  ],
  [
    "WATTH_LE",
    "The absolute value of cell capacity in Watt-hours that is less than or equal to the programmed <value>",
  ],
  [
    "POS_DVDT_GE",
    "The change in voltage during the 1-second sampling interval that is positive and greater than or equal to the programmed <value>",
  ],
  [
    "POS_DVDT_LE",
    "The change in voltage during the 1-second sampling interval that is positive and less than or equal to the programmed <value>",
  ],
  [
    "NEG_DVDT_GE",
    "The change in voltage during the 1-second sampling interval that is negative, and the magnitude of the change is greater than or equal to the programmed <value>",
  ],
  [
    "NEG_DVDT_LE",
    "The change in voltage during the 1-second sampling interval that is negative, and the magnitude of the change is less than or equal to the programmed <value>",
  ],
  [
    "POS_DIDT_GE",
    "The change in the magnitude of current during the 1-second sampling interval that is positive and greater than or equal to the programmed <value>",
  ],
  [
    "POS_DIDT_LE",
    "The change in the magnitude of current during the 1-second sampling interval that is positive and less than or equal to the programmed limit",
  ],
  [
    "NEG_DIDT_GE",
    "The change in the magnitude of current during the 1-second sampling interval that is negative, and the magnitude of the change is greater than or equal to the programmed limit",
  ],
  [
    "NEG_DIDT_LE",
    "The change in the magnitude of current during the 1-second sampling interval that is negative, and the magnitude of the change is less than or equal to the programmed <value>",
  ],
  [
    "DVMAX_GE",
    "The magnitude of the difference between the voltage and the maximum voltage observed during the step that is greater than or equal to the programmed <value>",
  ],
  [
    "DVMAX_LE",
    "The magnitude of the difference between the voltage and the maximum voltage observed during the step that is less than or equal to the programmed <value>",
  ],
  [
    "DVMIN_GE",
    "The magnitude of the difference between the voltage and the minimum voltage observed during the step that is greater than or equal to the programmed <value>",
  ],
  [
    "DVMIN_LE",
    "The magnitude of the difference between the voltage and the minimum voltage observed during the step that is less than or equal to the programmed <value>",
  ],
  [
    "DIMAX_GE",
    "The magnitude of the difference between the absolute value of current and the maximum absolute value of current observed during the step that is greater than or equal to the programmed <value>",
  ],
  [
    "DIMAX_LE",
    "The magnitude of the difference between the absolute value of current and the maximum absolute value of current observed during the step that is less than or equal to the programmed <value>",
  ],
  [
    "DIMIN_GE",
    "The magnitude of the difference between the absolute value of current and the minimum absolute value of current observed during the step that is greater than or equal to the programmed <value>",
  ],
  [
    "DIMIN_LE",
    "The magnitude of the difference between the absolute value of current and the minimum absolute value of current observed during the step that is less than or equal to the programmed <value>"
  ],
];

const List<List<String>> timeTypeDescription = [
  ["AT", "The test is evaluated once at the <time limit>"],
  [
    "AFTER",
    "The test is evaluated continuously from the <time_limit> until the step is finished"
  ],
  [
    "BEFORE",
    "The test is evaluated continuously from the start of the step until the <time limit>"
  ],
  [
    "BEFORE_START",
    "The test is evaluated before starting the associated step. This test is performed during the step setup procedure when only the voltage sense lines are connected to the cell."
  ]
];

const List<List<String>> testActionDescriptions = [
  ["FAIL", "When met, the test action indicates the test failed."],
  [
    "NEXT",
    "When met, the test action indicates the test passed and the sequence\nproceeds to the next step"
  ]
];

const List<String> modeDescription = [
  "Rest",
  "Charge",
  "Discharge",
];
