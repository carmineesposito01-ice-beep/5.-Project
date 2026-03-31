package TOP_LEVEL{
    doc /* Top-Level System Definition:
         * This package defines the overall structure of the S.L.O.W. system, including the main components and their interactions.
         * It serves as the central point for integrating the various subsystems (Conditioning Unit, Elaboration Unit, Balancing Unit) and defining the top-level architecture. 
         * */
    
    private import system_test::*;
    
    
    
    part system : topLevelSystem {
        doc /*   */
    
        /* ===================================================================
            * ATTRIBUTE USAGE
         * =================================================================== */
        

        /* ===================================================================
		     * PART USAGE
	     * =================================================================== */        

        part :>> conditioner {
            /* Configuration for the Condition Unit */
        }
        part :>> elaborator {
            /* Configuration for the Elaboration Unit */
        }
        part :>> balancer {
            /* Configuration for the Balancing Unit */
        }

        /*connection Supply : SupplyEnergy connect system to elaborator;
        */
    }
}