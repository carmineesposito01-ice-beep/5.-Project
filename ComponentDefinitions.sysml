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

        // Global instrumentation
        attribute systemTime : ScalarValues::DateTime;
        attribute testRunId : String;
        attribute scenarioId : String;
        attribute measuredUpdateRate : Real; // Hz
        attribute actualReceiveRate : Real; // Hz — alias for CAM_ReceptionRate requirement
        attribute measuredLatencyE2E : Real; // ms
        attribute measuredProcessingTime : Real; // ms
        attribute observedFailures : Integer; // count
        attribute verificationEvidence : String[*]; // links to test artifacts / run outputs
        attribute verificationLog : String[*];

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
        attribute requiredRate : Real; // Hz — alias for CAM_ReceptionRate requirement
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

        // ---------- Safety events / observable flags (for verification) ----------
        attribute rearEndCollisionDueToV2VError : Boolean; // false — maps to VC_NoRearEndCollision
        attribute cutInCollisionOccurred : Boolean; // false — maps to VC_CutIn_Safety, VC_NoUnstableEvasion
        attribute intersectionCollisionDueToV2IError : Boolean; // false — maps to VC_NoIntersectionCollision
        attribute noPedestrianIncident : Boolean; // true — maps to VC_NoPedestrianIncident
        attribute noEmergencyVehicleCollision : Boolean; // true — maps to VC_NoEmergencyVehicleCollision
        attribute noWrongWayVehicleCollision : Boolean; // true — maps to VC_NoWrongWayVehicleCollision

        // ---------- Porte (riferimento alla definizione precedente) ----------
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        in port egoVehicleInfoIn : VehicleBusPort;
        out port camOut : CAM_Port;
        out port modelParametersOut : ControlParametersPort;
        out port platooningInfoOut : PlatooningInfoPort;
        out port monitoringOut : MonitoringPort;

        /* ===================================================================
		     * PART USAGE
	     * =================================================================== */
        part inputGateway : InputGateway_Unit;
        part elaboration : Elaboration_Unit;
        part camComposer : CAMComposer_Unit;
        part outputGateway : OutputGateway_Unit;

        // Connections between parts
        
 
        // Connessioni interne
        
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
        
        // Instrumentation & quality metrics
        attribute v2vPacketLossRate : Real; // percent
        attribute v2vAvgLatency : Real; // ms
        attribute messageFragmentationRate : Real; // percent
        attribute DENM_confidence : Real; // 0..100
        attribute camIntegrityScore : Real; // 0..1
        attribute validationLatency : Real; // ms
        attribute msgReceivedCount : Integer; // total messages received
        attribute msgLossCount : Integer; // total messages lost
        attribute lastMsgTimestamp : ScalarValues::DateTime;
        attribute camReceptionTimestamp : ScalarValues::DateTime;
        attribute heartbeatLastSeen : ScalarValues::DateTime;
        attribute heartbeatMissedCount : Integer;
        attribute confidenceCategory : StandardLibrary::Metadata_Definitions::ConfidenceCategory; // HIGH|MEDIUM|LOW
        attribute validationPassFlag : Boolean;
        attribute validationDetail : String;
        
    }

    part def Elaboration_Unit{
        doc /* Part representing the elaboration unit of the system, responsible for processing 
            /* the received data and generate the model's parameters. */
        in port v2vIn : V2VCommPort;          
        in port v2iIn : V2ICommPort;          

        out port modelParametersOut : ControlParametersPort;
        out port monitoringOut : MonitoringPort;
        
        // Decision & control attributes
        attribute currentHeadway : Real; // m or s depending on model
        attribute desiredHeadway : Real; // m or s
        attribute speedLimitEnforced : Boolean;
        attribute glosaActive : Boolean;
        attribute glosaComputationTime : Real; // ms
        attribute processingLatency : Real; // ms per cycle
        attribute stringStabilityIndex : Real; // unitless metric
        attribute leaderProfileConfidence : Real; // percent
        attribute currentJamRate : Real; // 1/s
        // Requirement-observable attributes (mapped from StandardLibrary requirements)
        attribute camDataAvailable : Boolean;
        attribute followingParamsValid : Boolean;
        attribute cutInScenarioOnV2V : Boolean;
        attribute cutInDetected : Boolean;
        attribute emergencyBrakeCommand : Boolean;
        attribute timeToBrakeActuation : Real; // ms
        attribute cutInRequestReceived : Boolean;
        attribute feasibilityCheckPerformed : Boolean;
        attribute cutInActive : Boolean;
        attribute carFollowingMode : CarFollowingModeKind;
        attribute multipleFollowerCAMs : Boolean;
        attribute jamRateCalculated : Boolean;
        attribute camHistoryAvailable : Boolean;
        attribute leaderProfileDetermined : Boolean;
        attribute spatMapDataAvailable : Boolean;
        attribute glosaFeasible : Boolean;
        attribute signalViolationWarningReceived : Boolean;
        attribute signalViolationActionTaken : Boolean;
        attribute legalSpeedLimitCompliance : Boolean;
        attribute validationPassFlag : Boolean;
        attribute validationDetail : String;
        attribute verificationEvidence : String[*];
        
        //part analyzer : Analyzer_Unit;
        //part v2v_own_message : V2V_OwnMessage_Unit;
        //part parameter_generator : ParameterGenerator_Unit;
        //part output_gateway : OutputGateway_Unit;
        part imm_tracker     : IMM_LeaderTracker;
        part feature_norm    : FeatureNormalizer_Unit;
        part snn_inference   : SNN_Inference_Unit;
        part param_projection: ParameterProjection_Unit;
        part glosa           : GLOSA_Unit;
        part dead_reckoning  : DeadReckoning_Unit;
    }

    part def OutputGateway_Unit{
        doc /* Part representing the output gateway of the system, responsible for sending the generated data (parameters, CAM message). */
    
        in port modelParametersIn : ControlParametersPort; // da Elaboration
        in port camIn : CAM_Port;                  // da CAM composer
        in port platooningInfoIn : PlatooningInfoPort; 

        // Porte esterne (verso i canali reali)
        out port camOut : CAM_Port;          // invia CAM
        out port modelParametersOut : ControlParametersPort; // invia comandi attuatori
        out port monitoringIn : MonitoringPort;
        out port monitoringOut : MonitoringPort;   
        out port platooningInfoOut : PlatooningInfoPort;

        // Forwarding metrics
        attribute camOutputRate : Real; // Hz
        attribute actualCamSendRate : Real; // Hz — alias for CAM_Transmission requirement
        attribute requiredCamSendRate : Real; // Hz = 10.0 — alias for CAM_Transmission requirement
        attribute camForwardingLatency : Real; // ms
        attribute camForwardingRetries : Integer;
        attribute controlForwardingLatency : Real; // ms
        attribute forwardingSuccessRate : Real; // percent
        attribute forwardingLastError : String;
        attribute verificationEvidence : String[*];

        //part send_v2v_message : Send_V2VMessage_Unit;
        //part send_parameters : Send_Parameters_Unit;
        //part send_platooning_info : Send_Platooning_Info_Unit;
    }

    part def CAMComposer_Unit{
        doc /* Part representing the CAM composer unit of the system, responsible for composing the CAM messages based on the ego vehicle state and other relevant data. */
        
        in port egoIn : EgoVehicleData_Flow;   // da InputGateway
        out port camOut : CAM_Port;
        
        // CAM / sample-and-hold attributes
        attribute lastCamTimestamp : ScalarValues::DateTime;
        attribute camGenerationLatency : Real; // ms
        attribute camSequenceNumber : Integer;
        attribute camSignatureValid : Boolean;
        attribute camReceptionTimestamp : ScalarValues::DateTime;
        attribute actualCamSendRate : Real; // Hz — observable for CAM_Transmission requirement
        attribute verificationEvidence : String[*];
    }

    part def Allineator_Unit{
        doc /* Part representing the allineator unit of the system, responsible for aligning the data from different sources and ensuring their timestamp is compatible. */
        
        in port egoIn : EgoVehicleData_Flow;
        out port egoOut : EgoVehicleData_Flow;

    }

    part def TriggerCAM_Unit{
        doc /* Part representing the trigger CAM unit of the system, responsible for triggering the composition and sending of CAM messages based on specific events or conditions. */

        in port egoIn : EgoVehicleData_Flow;
        out port triggerOut : Boolean;

    }

    part def CAMMessageComposer_Unit{
        doc /* Part representing the CAM message composer unit of the system, responsible for composing the CAM messages based on the aligned data and the trigger signal. */
        in port egoIn : EgoVehicleData_Flow;
        out port camOut : CAM_Port;
        in port triggerIn : Boolean;
    }

    part def SampleANDHold{
        doc /* Part representing the sample and hold unit of the system, responsible for sampling the last CAM Message produced by the system. */
        in port camIn : CAM_Port;
        out port camOut : CAM_Port;
        
        // Sample-and-hold instrumentation
        attribute sampleHoldTimeout : Real; // s
        attribute sampleAge : Real; // ms
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

        out port v2vOut : V2VCommPort;
        out port v2iOut : V2ICommPort;
        out port platooningInfoOut : PlatooningInfoPort;
        out port egoSignalsOut : VehicleBusPort;
                    

        //part check_degradation :CheckDegradation_Unit;
        part signal_reconstruction : SignalRecostruction_Unit;
    }

    part def Evaluation_Unit{
        doc /* Part representing the evaluation unit of the system, responsible for evaluating the validated signals and generating insights for the following parameter generation. */
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
    }

    part def ParameterGenerator_Unit{
        doc /* Part representing the parameter generator unit of the system, responsible for generating the parameters for the following model based on the analyzed data. */
        in port v2vIn : V2VCommPort;
        in port v2iIn : V2ICommPort;
        in port physicsStateIn : PhysicsStatePort;
        in port contextIn : ContextFlagsPort;
        out port forHmiOut;
        out port modelParametersOut : ControlParametersPort;
    }

    part def MonitoringComposer_Unit{
        doc /* Part representing the monitoring composer unit of the system, responsible for composing the monitoring data based on the validated signals and the system's state. */
        in port conditioningVariablesIn : ConditioningVariablesPort;
        in port modelParametersIn : ControlParametersPort;
        out port monitoringOut : MonitoringPort;
    }

    part def ModelParametersOuting_Unit{
        doc /* Part representing the model parameters outing unit of the system, responsible for sending the generated model parameters to the vehicle's control system. */
        in port modelParametersIn : ControlParametersPort;
        in port platooningInfoIn : PlatooningInfoPort;
        out port modelParametersOut : ControlParametersPort;
    }
    part def CAMMessageOuting_Unit{
        doc /* Part representing the CAM message outing unit of the system, responsible for sending the composed CAM messages to other vehicles. */
        in port camIn : CAM_Port;
        in port platooningInfoIn : PlatooningInfoPort;
        out port camOut : V2VCommPort;
    }
    part def MonitoringOuting_Unit{
        doc /* Part representing the monitoring outing unit of the system, responsible for sending the composed monitoring data to the vehicle's HMI or other monitoring systems. */
        in port monitoringIn : MonitoringPort;
        in port platooningInfoIn : PlatooningInfoPort;
        out port monitoringOut : MonitoringPort;
    }


    part def CheckDegradation_Unit{
        doc /* Part representing the check degradation unit of the system, responsible for checking the degradation of the received signals and ensuring their reliability. */

    }

    part def SignalRecostruction_Unit{
        doc /* Part representing the signal reconstruction unit of the system, responsible for reconstructing the received signals in case of degradation or loss. */
        part imm : IMM_LeaderTracker;
        part deadReckoning : DeadReckoning_Unit;
    }



    part def ParameterProjection_Unit{
        doc /* Part that impose constraint on the string stability */
    }





    part def IMM_LeaderTracker {
        in  port camIn         : CAM_Port;
        out port leaderStateOut: LeaderStatePort;
        attribute modelTransitionMatrix : Real[*];  // 3x3 markovian
        attribute processNoiseQ_CV      : Real;
        attribute processNoiseQ_CA      : Real;
        attribute processNoiseQ_brake   : Real;
    }

    part def FeatureNormalizer_Unit {
        in  port physicsRawIn  : PhysicsStatePort;
        in  port contextRawIn  : ContextFlagsPort;
        out port physicsNormOut: PhysicsStatePort;   // normalizzato + fixed-point
        out port contextNormOut: ContextFlagsPort;
        attribute quantizationFormat : String;       // es. "Q1.15"
    }


    part def SNN_Inference_Unit {
        in  port physicsIn  : PhysicsStatePort;
        in  port contextIn  : ContextFlagsPort;
        out port rawParams  : ControlParametersPort;
        attribute networkArchitecture : String;     // es. "ALIF-LIF, 3 layers"
        attribute inferenceLatency   : Real;        // microseconds
    }

    part def ParameterProjection_Unit {
        in  port rawIn       : ControlParametersPort;
        in  port leaderState : LeaderStatePort;
        out port safeParams  : ControlParametersPort;
        assert constraint stringStability : StringStabilityConstraint;
        assert constraint parameterRange  : ParameterRangeConstraint;
    }


    part def GLOSA_Unit {
        in  port spatIn       : V2ICommPort;
        in  port mapIn        : V2ICommPort;
        in  port egoSpeedIn   : VehicleBusPort;
        out port advisoryOut  : GLOSAAdvisoryPort;
        attribute computationTime : Real;  // ms
    }

    part def DeadReckoning_Unit {
        in  port lastLeaderState : LeaderStatePort;
        in  port v2vStatusIn     : V2VCommPort;
        out port predictedState  : LeaderStatePort;
        attribute predictionHorizon : Real;  // ms
        attribute pessimisticAccel  : Real;  // m/s^2 (assunzione conservativa)
    }







    

    





}