library package balancing_unit{
    doc /* Balancing Unit subsystem:
         * Responsible for balancing the parameters from two different model, to generate total parameters for the upper systems and ensure their stable operation.
         * It may include components such as:
         * - Load balancers
         * - Power distribution units
         * - Feedback control systems */
    
    /* ===================================================================
         * IMPORTS & DEFINITIONS
     * =================================================================== */
    private import ScalarValues::*;

    enum def DataStatus {
        doc /*
            * Status indicator for the balancing unit's output parameters, indicating whether the data is fresh, interpolated, or using a fallback.
         */
        enum FRESH;
        enum INTERPOLATED;
        enum FALLBACK;
    }

    /* ===================================================================
         * ATTRIBUTE DEFINITIONS
    * =================================================================== */
    attribute def UpdateRateOut_Hz :> Real {
        doc /* The update rate of the output parameters from the balancing unit, in hertz (Hz), indicating how frequently the balanced parameters are updated. */
    }
    attribute def ValidityFlag :> DataStatus {
        doc /* A flag indicating the validity of the output parameters from the balancing unit, using the DataStatus enumeration defined in the system_test package. */
    }
    
    /* ===================================================================
		 * PART DEFINITIONS — Subsystem Definitions
	 * =================================================================== */
    part def balancing_unit_v1{
        doc /* Top-Level definition of the conditioner. */

        /* ===================================================================
             * ATTRIBUTE USAGE
        * =================================================================== */
        attribute weightingFactors : Real [3]; 
        attribute updateRateOut_Hz : UpdateRateOut_Hz = 100.0;
        attribute validityFlag : ValidityFlag;
    }





}