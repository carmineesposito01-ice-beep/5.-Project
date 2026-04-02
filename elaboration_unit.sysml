library package elaboration_unit{
    doc /* Elaboration Unit subsystem:
         * Responsible for performing elaboration on conditioned signals, to generate parameters for the upper systems.
         * It may include components such as:
         * - Signal processing algorithms
         * - Parameter generation logic
         * - Data transformation modules
         * - Data syncronization modules
         * - Deep Learing applications */

    /* ===================================================================
         * IMPORTS & DEFINITIONS
     * =================================================================== */
    private import ScalarValues::*;

    /* ===================================================================
         * ATTRIBUTE DEFINITIONS
    * =================================================================== */
    attribute def ProcessingLatencyCycles :> Integer {
        doc /* The number of clock cycles required for the elaboration unit to process input signals and generate output parameters. */        
    }
    attribute def AlgorithmicErrorMargin_percent :> Real {
        doc /* The margin of error allowed in the algorithmic computations of the elaboration unit, expressed as a percentage. */
    }
    attribute def DSPSliceUtilization :> Integer {
        doc /* The utilization rate of the digital signal processing (DSP) slices in the elaboration unit, indicating how fully they are being used. */
    }


     /* ===================================================================
		 * PART DEFINITIONS — Subsystem Definitions
	 * =================================================================== */
    part def elaboration_unit_v1{
        doc /* Top-Level definition of the elaboration unit. */

        /* ===================================================================
             * ATTRIBUTE DEFINITIONS
        * =================================================================== */
        attribute processingLatencyCycles : ProcessingLatencyCycles;
        attribute algorithmicErrorMargin_percent : AlgorithmicErrorMargin_percent;
        attribute dspSliceUtilization : DSPSliceUtilization;
    }
}