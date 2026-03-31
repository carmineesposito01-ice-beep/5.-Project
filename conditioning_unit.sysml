library package conditioning_unit{
    doc /* Conditioning Unit subsystem:
         * Receives raw V2X signals and performs needed:
         * - Filtering (noise reduction)
         * - Normalization
         * - Multiplexing
         * - S&H (Sample and Hold)
         * - Signal conditioning in general */
    
    /* ===================================================================
		 * PART DEFINITIONS — Subsystem Definitions
	 * =================================================================== */
    part def conditioning_unit{
        doc /* Top-Level definition of the conditioner. */
    }

}