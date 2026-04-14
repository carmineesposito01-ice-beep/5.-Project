library package conditioning_unit{
    doc /* Conditioning Unit subsystem:
         * Receives raw V2X signals and performs needed:
         * - Filtering (noise reduction)
         * - Normalization
         * - Multiplexing
         * - S&H (Sample and Hold)
         * - Signal conditioning in general */
    
    /* ===================================================================
         * IMPORTS & DEFINITIONS
     * =================================================================== */
    private import ScalarValues::*;

    /* ===================================================================
         * ATTRIBUTE DEFINITIONS
    * =================================================================== */
    attribute def InputDataRate_Mbps :> Real {
        doc /* The data rate of the input signals to the conditioning unit, in megabits per second (Mbps). */
    }
    attribute def FractionalBits :> Integer{
        doc /* The number of bits used for the fractional part of the data. */
    }
    attribute def PacketLossTolerance_percent :> Real{
        doc /* The maximum percentage of packets that can be lost without affecting system performance. */
    }

    /* ===================================================================
		 * PART DEFINITIONS — Subsystem Definitions
	 * =================================================================== */
    part def conditioning_unit_v1{
    part def conditioning_unit_v1{
        doc /* Top-Level definition of the conditioner. */
        
        /* ===================================================================
             * ATTRIBUTE USAGE
        * =================================================================== */
        attribute inputDataRate_Mbps : InputDataRate_Mbps;
        attribute fractionalBits : FractionalBits = 12;
        attribute packetLossTolerance_percent : PacketLossTolerance_percent = 1.5;
        
    }



    /* ===================================================================
             * REQUIREMENTS DEFINITIONS (Trying to understande...)
    * =================================================================== */
    requirement def SafetyRequirement {
        doc /* A requirement specifying the safety constraints that the conditioning unit must adhere to, ensuring safe operation within the system. */
        subject conditioning_unit_v1;
        text "The conditioning unit shall meet the specified safety requirements to ensure safe operation within the system.";
        actor "System Safety Engineer";
        rationale "Ensuring that the conditioning unit meets safety requirements is critical to prevent hazards and ensure the overall safety of the system.";
        verificationMethod "Safety analysis, testing, and validation to confirm compliance with safety requirements."; 

        assume{
            doc /* It is assumed that the conditioning unit will be designed and implemented in accordance with industry best practices for safety and reliability, and that it will undergo rigorous testing and validation to ensure compliance with safety requirements. */  
        }
        require{
            doc /* The conditioning unit must be designed to meet the specified safety requirements, including compliance with relevant safety standards and regulations. */
        }
         verify{
            doc /* Verification activities will include safety analysis, testing, and validation to confirm that the conditioning unit meets the specified safety requirements. */          
        }
    }

    /* ===================================================================
             * VERIFICATION DEFINITIONS
    * =================================================================== */
    
}
}


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
}
}

