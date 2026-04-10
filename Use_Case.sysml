library package Use_Case_Definitions{
    doc /* This package defines the use cases for car-following project. */

    /* ===================================================================
         * IMPORTS [PARTS]
     * =================================================================== */
    public import FPGA_Hardware::*;



    use case def N1_MaintainSecurityDistance {
        doc /* Use case for maintaining a secure distance between the vehicle and following vehicle, which involves managing the speed accordingly. */ 
        first start;
        then action acquireV2XData;
        then action computeSafeDistance;
        then action adjustSpeed;
        then done;
    }

    use case def N2_SpeedAdaptation{
        doc /* Use case for adapting the speed of the vehicle based on the follower's speed. */
        first start;
        then action acquireV2XData;
        then action computeFollowingSpeed;
        then action adjustSpeed;
        then done;
    }

    use case def N3_EmergencyBraking{
        doc /* Use case for emergency braking when the following vehicle is too close. */
        first start;
        then action acquireV2XData;
        then action detectFollowingEmergency;
        then action applyBrakes;
        then done;
    }

    use case def N4_AnticipateVehiclesBehavior{
        doc /* Use case for anticipating the behavior of the following vehicle based on historical data and current conditions. */
        first start;
        then action acquireV2XData;
        then action analyzeHistoricalData;
        then action predictFollowingBehavior;
        then action adjustSpeed;
        then done;
    }

    use case def N5_CutInDetection{
        doc /* Use case for detecting cut-in maneuvers by the following vehicle and responding accordingly. */
        first start;
        then action acquireV2XData;
        then action detectCutInManeuver;
        then action adjustSpeed;
        then done;
    }

}
