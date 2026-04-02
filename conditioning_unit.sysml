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


