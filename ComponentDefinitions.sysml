package ComponentDefinition{
    doc /* 
        /* This package contains the definitions of the components used in the system. 
        /* Each component is defined with its properties, behaviors, and interactions with 
        /* other sub-components. The components are organized on system hierarchy based."
        */ 
    
    private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;

    private import StandardLibrary::**;

    // LEVEL - 0: Top-Level System Definition
    part def topLevelSystem {
        doc /* The top-level system representing the entire system architecture. */

        // Car-Following Attributes
        attribute carFollowingModel : CarFollowingModelKind;  //TODO: Creare un'allocazione dinamica dei parametri, dove questi possono essere mutati semplicemente modificando il modello imposto su questa riga (o meglio, nella usage corrispondente)
        attribute followingParameters : CarFollowingParams;
        attribute headwayIncrementPercentage : Real; // 10.0 %

        // ---------- Soglie di sicurezza ----------
        attribute emergencyBrakingMaxReactionTime : Real; // 200.0 ms
        attribute signalViolationEmergencyDistance : Real; // m
        attribute signalViolationAttentionDistance : Real; // m
        attribute pedestrianTTAAttentionThreshold : Real; // s
        attribute pedestrianTTADangerThreshold : Real; // s
        attribute pedestrianLateralSafetyBuffer : Real; // 1.0 m
        attribute maxOvershootSpeed : Real; // km/h
        attribute jamRateInstabilityThreshold : Real; // 1/s
        attribute stabilityValidationVehicleCount : Integer; // 10

        // ---------- Soglie SOTIF ----------
        attribute leaderProfileConfidenceThresholdLow : Real; // 60.0 %
        attribute glosaUnreachableDecelerationProfile : Real;
        attribute denmConfidenceValidationRequired : Boolean; // true;
        attribute pedestrianSensorValidationTimeout : Real; //3.0 s

        // ---------- Performance ----------
        attribute maxV2VEndToEndLatency : Real; // 100.0 ms
        attribute maxV2IEndToEndLatency : Real; // 200.0 ms
        attribute camUpdateRateMin : Real; // 10.0 Hz
        attribute safetyDistanceAccuracyLowSpeed : Real; // 3.0 m
        attribute safetyDistanceAccuracyHighSpeedPercent : Real; // 2.0 %
        attribute glosaComputationTimeMax : Real; // 50.0 ms

        // ---------- Degradazione e fault tolerance ----------
        attribute v2vSignalLossTimeout : Real; // 500.0 ms
        attribute transitionSmoothTime : Real; // 2.0 s
        attribute messageFragmentationThresholdPercent : Real; // 15.0 %
        attribute fragmentationPersistenceTime : Real; // 3.0 s
        attribute internalHeartbeatTimeout : Real; // 200.0 ms
        attribute failOperationalArchitecture : Boolean; // false

        // ---------- Variabili di stato runtime ----------
        attribute carFollowingMode : CarFollowingModeKind; // CarFollowingModeKind::Disabled
        attribute v2vCommunicationStatus : CommStatusKind; // CommStatusKind::Lost
        attribute v2iCommunicationStatus : CommStatusKind; // CommStatusKind::Lost
        attribute leaderProfileConfidence : Real; // %
        attribute currentJamRate : Real;
        attribute glosaActive : Boolean; // false;
        attribute emergencyManeuverInProgress : Boolean; // false

        // ---------- Porte (riferimento alla definizione precedente) ----------
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        in port egoVehicleInfoIn : VehicleBusPort;
        out port camOut : CAM;
        out port modelParametersOut : ControlParametersPort;
        out port platooningInfoOut : PlatooningInfoPort;
        out port monitoringOut : MonitoringPort;

        /* ===================================================================
		     * PART USAGE
	     * =================================================================== */
        //part inputGateway : InputGateway_Unit;
        //part elaboration : Elaboration_Unit;
        //part camComposer : CAMComposer_Unit;
        //part outputGateway : OutputGateway_Unit;
    }

    // LEVEL 1: Subsystem Definitions
    part def InputGateway_Unit{
        doc /* Part representing the input gateway of the system, responsible for receiving data 
            /* from external sources (V2X signals). */
        
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        in port egoSignalsIn : VehicleBusPort;

        out port egoSignalsOut : VehicleBusPort;
        out port v2vOut : V2VCommPort;
        out port v2iOut : V2ICommPort;
        out port platooningInfoOut : PlatooningInfoPort;
        
        
    }

    part def Elaboration_Unit{
        doc /* Part representing the elaboration unit of the system, responsible for processing 
            /* the received data and generate the model's parameters. */
        in port v2vIn : V2VCommPort;          
        in port v2iIn : V2ICommPort;          

        out port modelParametersOut : ControlParametersPort;
        out port camOut : CAM;
        out port monitoringOut : MonitoringPort;
        out port platooningInfoOut : PlatooningInfoPort;
        
        //part analyzer : Analyzer_Unit;
        //part v2v_own_message : V2V_OwnMessage_Unit;
        //part parameter_generator : ParameterGenerator_Unit;
        //part output_gateway : OutputGateway_Unit;
    }

    part def OutputGateway_Unit{
        doc /* Part representing the output gateway of the system, responsible for sending the generated data (parameters, CAM message). */
    
        in port modelParametersIn : ControlParametersPort; // da Elaboration
        in port camIn : CAM_Port;                  // da CAM composer
        in port platooningInfoIn : PlatooningInfoPort; 

        // Porte esterne (verso i canali reali)
        out port camOut : V2VCommPort;          // invia CAM
        out port modelParametersOut : ControlParametersOutPort; // invia comandi attuatori
        out port monitoringIn : MonitoringPort;
        out port monitoringOut : MonitoringPort;   
        out port platooningInfoOut : PlatooningInfoPort;           // notifiche HMI

        //part send_v2v_message : Send_V2VMessage_Unit;
        //part send_parameters : Send_Parameters_Unit;
        //part send_platooning_info : Send_Platooning_Info_Unit;
    }

    part def CAMComposer_Unit{
        doc /* Part representing the CAM composer unit of the system, responsible for composing the CAM messages based on the ego vehicle state and other relevant data. */
        
        in port egoIn : EgoVehicleData_Flow;   // da InputGateway
        out port camOut : CAM_Port;
    }

    part def Allineator_Unit{
        doc /* Part representing the allineator unit of the system, responsible for aligning the data from different sources and ensuring their timestamp is compatible. */
        
        in port egoIn : EgoVehicleData_Flow;
        out port egoOut : EgoVehicleData_Flow;

    }

    part def TriggerCAM_Unit{
        doc /* Part representing the trigger CAM unit of the system, responsible for triggering the composition and sending of CAM messages based on specific events or conditions. */

        in port egoIn : EgoVehicleStateInPort;
        out port triggerOut : Boolean;

    }

    part def CAMMessageComposer_Unit{
        doc /* Part representing the CAM message composer unit of the system, responsible for composing the CAM messages based on the aligned data and the trigger signal. */
        in port egoIn : VehicleBusPort;
        out port camOut : CAM_Port;
        in port triggerIn : Boolean;
    }

    part def SampleANDHold{
        doc /* Part representing the sample and hold unit of the system, responsible for sampling the last CAM Message produced by the system. */
        in port camIn : CAM_Port;
        out port camOut : CAM_Port;
    }

    // LEVEL 2: Component Definitions
    part def Conditioning_Unit{
        doc /* Part representing the conditioning unit of the system, responsible for filtering operations,
            /* and refining operations for the input signals. */
        
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        in port egoSignalsIn : VehicleBusPort;

        out port v2vOut : V2VCommPort;
        out port v2iOut : V2ICommPort;
        out port egoSignalsOut : VehicleBusPort;

        
    }

    part def SignalValidation_Unit{
        doc /* Part representing the signal validation unit of the system, responsible for validating the 
            /* received signals and ensuring their integrity and reliability. */

        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        in port egoSignalsIn : VehicleBusPort;

        out port validatedDataOut : ValidatedDataOutPort;
        out port platooningInfoOut : PlatooningInfoOutPort;
        out port egoSignalsOut : VehicleBusPort;
                    

        //part check_degradation :CheckDegradation_Unit;
        part signal_reconstruction : SignalRecostruction_Unit;
    }

    part def Evaluation_Unit{
        doc /* Part representing the evaluation unit of the system, responsible for evaluating the validated signals and generating insights for the following parameter generation. */
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        out port conditioningVariablesOut : ConditioningVariablePort;
    }

    part def ParameterGenerator_Unit{
        doc /* Part representing the parameter generator unit of the system, responsible for generating the parameters for the following model based on the analyzed data. */
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        in port conditioningVariablesIn : ConditioningVariablePort;
        out port forHmiOut;
        out port modelParametersOut : ControlParametersPort;
    }

    part def MonitoringComposer_Unit{
        doc /* Part representing the monitoring composer unit of the system, responsible for composing the monitoring data based on the validated signals and the system's state. */
        in port conditioningVariablesIn : ConditioningVariablePort;
        in port modelParametersIn : ControlParametersPort;
        out port monitoringOut : MonitoringPort;
    }

    part def CheckDegradation_Unit{
        doc /* Part representing the check degradation unit of the system, responsible for checking the degradation of the received signals and ensuring their reliability. */

    }

    part def SignalRecostruction_Unit{
        doc /* Part representing the signal reconstruction unit of the system, responsible for reconstructing the received signals in case of degradation or loss. */

    }



    

    part def Analyzer_Unit{
        doc /* Part representing the analyzer unit of the system, responsible for analyzing the validated signals data and generating data for following parameter generation insights. */
        


        //part v2v_analyzer : V2V_Analyzer_Unit;
        //part v2i_analyzer : V2I_Analyzer_Unit;
    }

    part def V2V_Analyzer_Unit{
        doc /* Part representing the V2V analyzer unit of the system, responsible for analyzing the validated signals data and generating data for following parameter generation insights. */
        
    }

    part def V2I_Analyzer_Unit{
        doc /* Part representing the V2I analyzer unit of the system, responsible for analyzing the validated signals data and generating data for following parameter generation insights. */
        
    }

    part def ParameterGenerator_Unit{
        doc /* Part representing the parameter generator unit of the system, responsible for generating the parameters for the following model based on the analyzed data. */
    }

    part def V2V_OwnMessage_Unit{
        doc /* Part representing the V2V own message unit of the system, responsible for generating the V2V own message from own actual data (speed, position, ecc). */
        
    }

    

    part def Send_V2VMessage_Unit{
        doc /* Part representing the send V2V message unit of the system, responsible for sending the generated V2V own message to other vehicles. */
    }

    part def Send_Parameters_Unit{
        doc /* Part representing the send parameters unit of the system, responsible for sending the generated parameters to the vehicle's control system. */
    }

    part def Send_Platooning_Info_Unit{
        doc /* Part representing the send platooning info unit of the system, responsible for sending the generated platooning information to other vehicles. */
    }






}