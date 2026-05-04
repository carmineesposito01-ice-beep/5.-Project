package system_test{
    doc /* This is the top-level system that will intagrate all subsystem for the application. */

    /* ===================================================================
         * IMPORTS [PARTS]
     * =================================================================== */
    public import ComponentDefinition::*;

    /* ===================================================================
         * IMPORTS [LIBRARIES]
     * =================================================================== */
    private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;
    private import Attribute_Definitions::*;
    private import Requirement_Definitions::*;
    private import Use_Case_Definitions::*;   

    

    

     /* ===================================================================
		 * PART DEFINITIONS — Subsystem Definitions
	 * =================================================================== */
	
    part def topLevelSystem {
        doc /* The top-level system representing the entire S.L.O.W. architecture. */
        attribute clockFrequency: ClockFrequency = 100 [mega*Hz];
        attribute used_power : PowerValue = 15.0 [W]; // Based on post-synthesis power estimates
        attribute logicElements : LogicElements = 50000; // Based on post-synthesis resource usage estimates
        attribute dspBlocks : DSPBlocks = 200; // Based on post-synthesis resource usage estimates
        attribute blockRAM : BlockRAM = 10 [mega*B]; // Based on post-synthesis resource usage estimates
        attribute ioPins : IOPins = 100; // Based on post-synthesis resource usage estimates
        attribute performance : Performance{
            attribute :>> maxThroughput = 6 [giga*bit/s];
            attribute :>> latency = 10 [nano*s];
        }  // Based on post-synthesis performance estimates
        attribute safetyDetectionTime : TimeValue = 50 [milli*s]; // Based on safety analysis
        attribute safetyRecoveryTime : TimeValue = 30 [milli*s]; // Based on safety analysis
        attribute temperature : TemperatureValue = 70 [C]; // Based on thermal analysis

        // Car-Following Attributes
        // ---------- Attributi di configurazione car‑following ----------
        attribute headwayTime : Real; // s
        attribute headwayIncrementPercentage : Real = 10.0; // %
        attribute carFollowingModel : CarFollowingModelKind = CarFollowingModelKind::IDM;
        attribute conservativeParameters : CarFollowingParams;
        attribute maxComfortDeceleration : Real; // m/s^2
        attribute maxComfortAcceleration : Real; // m/s^2
        attribute minSpeed : Real; // km/h
        attribute maxSpeed : Real; // km/h

        // ---------- Soglie di sicurezza ----------
        attribute emergencyBrakingMaxReactionTime : Real = 200.0; // ms
        attribute signalViolationEmergencyDistance : Real; // m
        attribute signalViolationAttentionDistance : Real; // m
        attribute pedestrianTTAAttentionThreshold : Real; // s
        attribute pedestrianTTADangerThreshold : Real; // s
        attribute pedestrianLateralSafetyBuffer : Real = 1.0; // m
        attribute maxLateralAcceleration : Real = 4.0; // m/s^2
        attribute maxOvershootSpeed : Real; // km/h
        attribute jamRateInstabilityThreshold : Real; // 1/s
        attribute stabilityValidationVehicleCount : Integer = 10;

        // ---------- Soglie SOTIF ----------
        attribute leaderProfileConfidenceThresholdLow : Real = 60.0; // %
        attribute glosaUnreachableDecelerationProfile : DecelerationProfile;
        attribute denmConfidenceValidationRequired : Boolean = true;
        attribute pedestrianSensorValidationTimeout : Real = 3.0; // s

        // ---------- Performance ----------
        attribute maxV2VEndToEndLatency : Real = 100.0; // ms
        attribute maxV2IEndToEndLatency : Real = 200.0; // ms
        attribute camUpdateRateMin : Real = 10.0; // Hz
        attribute safetyDistanceAccuracyLowSpeed : Real = 3.0; // m
        attribute safetyDistanceAccuracyHighSpeedPercent : Real = 2.0; // %
        attribute glosaComputationTimeMax : Real = 50.0; // ms

        // ---------- Degradazione e fault tolerance ----------
        attribute v2vSignalLossTimeout : Real = 500.0; // ms
        attribute v2vReactivationWindow : Real = 5.0; // s
        attribute transitionSmoothTime : Real = 2.0; // s
        attribute messageFragmentationThresholdPercent : Real = 15.0; // %
        attribute fragmentationPersistenceTime : Real = 3.0; // s
        attribute internalHeartbeatTimeout : Real = 200.0; // ms
        attribute failOperationalArchitecture : Boolean = false;

        // ---------- Cybersecurity ----------
        attribute signatureAlgorithm : String = "ETS ITS 103 097";
        attribute symmetricEncryptionAlgorithm : String = "AES-256";
        attribute intrusionLogMaxTime : Real = 10.0; // ms
        attribute messageFrequencyDeviationAlarmThreshold : Real = 20.0; // %
        attribute defenseInDepthLayersMin : Integer = 2;
        attribute cyberAttackFallbackTime : Real = 500.0; // ms

        // ---------- Variabili di stato runtime ----------
        attribute carFollowingMode : CarFollowingModeKind = CarFollowingModeKind::Disabled;
        attribute v2vCommunicationStatus : CommStatusKind = CommStatusKind::Lost;
        attribute v2iCommunicationStatus : CommStatusKind = CommStatusKind::Lost;
        attribute cybersecurityThreatLevel : ThreatLevelKind = ThreatLevelKind::Normal;
        attribute leaderProfileConfidence : Real; // %
        attribute currentJamRate : Real;
        attribute glosaActive : Boolean = false;
        attribute emergencyManeuverInProgress : Boolean = false;

        // ---------- Porte (riferimento alla definizione precedente) ----------
        port v2v : V2VCommPort;
        port v2i : V2ICommPort;
        port vehicleBus : VehicleBusPort;
        port securityMonitor : SecurityMonitorPort;

        /* ===================================================================
		     * PART USAGE
	     * =================================================================== */
        part inputGateway : InputGateway_Unit;
        part elaboration : Elaboration_Unit;
        part camComposer : CAMComposer_Unit;
        part outputGateway : OutputGateway_Unit;

        connection conditioned_signals : DataFlow connect conditioner to elaborator;
        connection generated_parameters : DataFlow connect elaborator to balancer;

        


    }



}