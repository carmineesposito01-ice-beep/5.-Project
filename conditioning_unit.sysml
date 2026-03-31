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
    attribute def inputDataRate_Mbps :> Real{
        doc /* The data rate of the input signals to the conditioning unit, in megabits per second (Mbps). */
    }
    attribute def wordLength_bits :> Integer{
        doc /* The length of each data word in bits. */
    }
    attribute def fractionalBits :> Integer{
        doc /* The number of bits used for the fractional part of the data. */
    }
    attribute def fifoDepth :> Integer{
        doc /* The depth of the FIFO buffer in samples. */
    }
    attribute def packetLossTolerance_percent :> Real{
        doc /* The maximum percentage of packets that can be lost without affecting system performance. */
    }

    /* ===================================================================
		 * PART DEFINITIONS — Subsystem Definitions
	 * =================================================================== */
    part def conditioning_unit_v1{
        doc /* Top-Level definition of the conditioner. */
        
        /* ===================================================================
             * ATTRIBUTE USAGE
        * =================================================================== */
        attribute inputDataRate_Mbps : Real;
        attribute wordLength_bits : Integer = 16;
        attribute fractionalBits : Integer = 12;
        attribute fifoDepth : Integer = 1024;
        attribute packetLossTolerance_percent : Real = 1.5;
        
    }

}


