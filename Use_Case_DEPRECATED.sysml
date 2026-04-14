library package Use_Case_Definitions_wrong_definitions{
    doc /* This package defines the use cases for car-following project. */

    /* ===================================================================
         * IMPORTS [PARTS]
     * =================================================================== */
    public import FPGA_Hardware::*;
    private import system_test::*;

    /* ===================================================================
         * ACTIONS DEFINITIONS (da valutare se è meglio definirli da questi o direttamente)
     * =================================================================== */
    action def ReceiveV2XData{
        doc /* Action to receive V2X data from the environment, which includes information about the following vehicle's speed, distance, and behavior. */
    }
    action def AnalizeDataIntegrity{
            doc /* Action to analyze the integrity of the received V2X data, checking for completeness and consistency to ensure reliable information for decision-making. */
    }
    action def ReconstructMissingData{
            doc /* Action to reconstruct missing data due to packet loss, using techniques such as interpolation or machine learning models or particles filter. */
    }
    action def ProduceReconstructedV2XData{
            doc /* Action to produce the reconstructed V2X data for further use. */
    }
    
    action def acquireV2XData{
        doc /* Action to acquire V2X data from the environment, which includes information about the following vehicle's speed, distance, and behavior. */
        
        first start;
        then action receiveV2XData:ReceiveV2XData;
        then action analizeDataIntegrity:AnalizeDataIntegrity;
        then action reconstructMissingData:ReconstructMissingData;
        then action produceRecostrctedV2XData:ProduceReconstructedV2XData;
        then done;
    }


    /* ===================================================================
         * USE CASE DEFINITIONS
     * =================================================================== */
    
    
    
    
    
    
    
    
     use case def N1_MaintainSecurityDistance {
        subject system;
        objective{
            doc /* Use case for maintaining a safe distance from the following vehicle, by adjusting the speed and acceleration of the vehicle based on the V2X data. */
        }
        action acquireV2XData;
        action computeSafeDistance;
        action adjustParameters;

        first acquireV2XData then computeSafeDistance;
        first computeSafeDistance then adjustParameters;
        first adjustParameters then done;
        
    }

    use case def N2_SpeedAdaptation{
        subject system;
        objective{
            doc /* Use case for adapting the speed of the vehicle based on the follower's speed. */
        }
        action acquireV2XData;
        action computeFollowingSpeed;
        action adjustParameters;

        first acquireV2XData then computeFollowingSpeed;
        first computeFollowingSpeed then adjustParameters;
        first adjustParameters then done;
    }

    use case def N3_EmergencyBraking{
        subject system;
        objective{
            doc /* Use case for emergency braking when the following vehicle is too close. */
        }
        action acquireV2XData;
        action detectFollowingEmergency;
        action applyBrakes;

        first acquireV2XData then detectFollowingEmergency;
        first detectFollowingEmergency then applyBrakes;
        first applyBrakes then done;
    }

    use case def N4_AnticipateVehiclesBehavior{
        subject system;
        objective{
            doc /* Use case for anticipating the behavior of the following vehicle based on historical data and current conditions. */
        }
        action acquireV2XData;
        action analyzeHistoricalData;
        action predictFollowingBehavior;
        action adjustParameters;

        first acquireV2XData then analyzeHistoricalData;
        first analyzeHistoricalData then predictFollowingBehavior;
        first predictFollowingBehavior then adjustParameters;
        first adjustParameters then done;
    }

    use case def N5_CutInDetection{
        subject system;
        objective{
            doc /* Use case for detecting cut-in maneuvers by the following vehicle and responding accordingly. */
        }
        action acquireV2XData;
        action detectCutInManeuver;
        action adjustParameters;

        first acquireV2XData then detectCutInManeuver;
        first detectCutInManeuver then adjustParameters;
        first adjustParameters then done;
    }

    use case def N6_StopAndGoMitigation{
        subject system;
        objective{
            doc /* Use case for mitigating stop-and-go traffic conditions by adjusting the speed of the vehicle based on the behavior of the following vehicle. */
        }
        action acquireV2XData;
        action understandStopandGoWaves;
        action adjustParameters;

        first acquireV2XData then understandStopandGoWaves;
        first understandStopandGoWaves then adjustParameters;
        first adjustParameters then done;
    }

    use case def N7_PacketLossResilience{
        subject system;
        objective{
            doc /* Use case for ensuring resilience to packet loss in V2X communication, by implementing strategies to maintain safe operation even when data are fragmenteted. */
        }
        action acquireV2XData;
        action detectPacketLoss;
        action implementResilienceStrategies;

        first acquireV2XData then detectPacketLoss;
        first detectPacketLoss then implementResilienceStrategies;
        first implementResilienceStrategies then done;
    }

    use case def N8_CrossroadAdaptiveDriving{
        subject system;
        objective{
            doc /* Use case for adaptive driving at crossroads, considering the behavior of surrounding vehicles and traffic conditions. */
        }
        action acquireV2XData;
        action analyzeCrossroadConditions;
        action adjustParameters{
            doc /* Action to adjust driving parameters (e.g., speed, acceleration) based on the analysis of crossroad conditions and the behavior of surrounding vehicles. */
        }

        first acquireV2XData then analyzeCrossroadConditions;
        first analyzeCrossroadConditions then adjustParameters;
        first adjustParameters then done;
    }

    use case def N9_FollowingVehicleClassification{
        subject system;
        objective{
            doc /* Use case for classifying the following vehicle based on its behavior and characteristics, to enable more tailored responses. */
        }
        action acquireV2XData;
        action extractVehicleFeatures;
        action classifyFollowingVehicle{
            doc /* Action to classify the following vehicle (e.g., aggressive, cautious) based on extracted features, using machine learning models or rule-based systems. */
        }
        action adjustDrivingStrategy{
            doc /* Action to adjust the driving strategy based on the classification of the following vehicle, to enhance safety and comfort. */
        }

        first acquireV2XData then extractVehicleFeatures;
        first extractVehicleFeatures then classifyFollowingVehicle;
        first classifyFollowingVehicle then adjustDrivingStrategy;
        first adjustDrivingStrategy then done;

    }




}
