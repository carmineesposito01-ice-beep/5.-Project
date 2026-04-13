library package Use_Case_Definitions{
    doc /* This package defines the use cases for car-following project. */

    /* ===================================================================
         * IMPORTS [PARTS]
     * =================================================================== */
    public import FPGA_Hardware::*;

    /* ===================================================================
         * ACTIONS DEFINITIONS (da valutare se è meglio definirli da questi o direttamente)
     * =================================================================== */
    action def receiveV2XData{
        doc /* Action to receive V2X data from the environment, which includes information about the following vehicle's speed, distance, and behavior. */
    }
    action def analizeDataIntegrity{
            doc /* Action to analyze the integrity of the received V2X data, checking for completeness and consistency to ensure reliable information for decision-making. */
    }
    action def reconstructMissingData{
            doc /* Action to reconstruct missing data due to packet loss, using techniques such as interpolation or machine learning models or particles filter. */
    }
    action def produceReconstructedV2XData{
            doc /* Action to produce the reconstructed V2X data for further use. */
    }
    
    action def acquireV2XData{
        doc /* Action to acquire V2X data from the environment, which includes information about the following vehicle's speed, distance, and behavior. */
        action receiveV2XData : receiveV2XData;
        action analizeDataIntegrity : analizeDataIntegrity;
        action reconstructMissingData : reconstructMissingData;
        action produceReconstructedV2XData : produceReconstructedV2XData;


    /* ===================================================================
         * USE CASE DEFINITIONS
     * =================================================================== */
    use case def N1_MaintainSecurityDistance {
        doc /* Use case for maintaining a secure distance between the vehicle and following vehicle, which involves managing the speed accordingly. */ 
        first start;
        then action acquireV2XData;
        then action computeSafeDistance;
        then action adjustParameters;
        then done;
    }

    use case def N2_SpeedAdaptation{
        doc /* Use case for adapting the speed of the vehicle based on the follower's speed. */
        first start;
        then action acquireV2XData;
        then action computeFollowingSpeed;
        then action adjustParameters;
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
        then action adjustParameters;
        then done;
    }

    use case def N5_CutInDetection{
        doc /* Use case for detecting cut-in maneuvers by the following vehicle and responding accordingly. */
        first start;
        then action acquireV2XData;
        then action detectCutInManeuver;
        then action adjustParameters;
        then done;
    }

    use case def N6_StopAndGoMitigation{
        doc /* Use case for mitigating stop-and-go traffic conditions by adjusting the speed of the vehicle based on the behavior of the following vehicle. */
        first start;
        then action acquireV2XData;
        then action understandStopandGoWaves;
        then action absorbWave{
            doc /* Action to adjust the speed to mitigate stop-and-go waves, based on the analysis of the following vehicle's behavior. */
        };
        then done;
    }

    use case def N7_PacketLossResilience{
        doc /* Use case for ensuring resilience to packet loss in V2X communication, by implementing strategies to maintain safe operation even when data are fragmenteted. */
        first start;
        then action receiveV2XData;
        then action analizeDataIntegrity;
        then action reconstructMissingData{
            doc /* Action to reconstruct missing data due to packet loss, using techniques such as interpolation or machine learning models or particles filter. */
        };
        then action produceReconstructedV2XData;
        then done;
    }

    use case def N8_CrossroadAdaptiveDriving{
        doc /* Use case for adaptive driving at crossroads, considering the behavior of surrounding vehicles and traffic conditions. */
        first start;
        then action acquireV2XData;
        then action analyzeCrossroadConditions;
        then action adjustParameters{
            doc /* Action to adjust driving parameters (e.g., speed, acceleration) based on the analysis of crossroad conditions and the behavior of surrounding vehicles. */
        };
        then done;
    }

    use case def N9_FollowingVehicleClassification{
        doc /* Use case for classifying the following vehicle based on its behavior and characteristics, to enable more tailored responses. */
        first start;
        then action acquireV2XData;
        then action extractVehicleFeatures;
        then action classifyFollowingVehicle{
            doc /* Action to classify the following vehicle (e.g., aggressive, cautious) based on extracted features, using machine learning models or rule-based systems. */
        };
        then action adjustDrivingStrategy{
            doc /* Action to adjust the driving strategy based on the classification of the following vehicle, to enhance safety and comfort. */
        };
        then done;
    }




}
}