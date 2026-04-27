library package system_test{
    doc /* This is the top-level system that will intagrate all subsystem for the application. */

    /* ===================================================================
         * IMPORTS [PARTS]
     * =================================================================== */
    public import conditioning_unit::*;
    public import elaboration_unit::*;
    public import balancing_unit::*;

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
		 * MESSAGE TYPE DEFINITIONS (V2X)
	 * =================================================================== */
    item def CAM{
        doc /* Cooperative Awareness Message (CAM) - Contains information about the vehicle's position, speed, and heading. */
        // Cooperative Awareness Message – ETSI EN 302 637-2
        attribute stationID : Integer;
        attribute generationDeltaTime : Integer; // ms
        attribute latitude : Real; // gradi WGS84
        attribute longitude : Real;
        attribute altitude : Real; // m
        attribute speed : Real; // m/s
        attribute heading : Real; // gradi
        attribute acceleration : Real; // m/s^2
        attribute driveDirection : DriveDirectionKind;
        attribute vehicleLength : Real; // m
        attribute vehicleWidth : Real; // m
        attribute vehicleRole : VehicleRoleKind; // es. publicTransport, emergency
        attribute certificateDigest : Binary; // per cybersecurity
    }

    item def SPaT{
        doc /* Signal Phase and Timing (SPaT) - Contains information about traffic signal phases and timing at intersections. */
        // Signal Phase and Timing – SAE J2735
        attribute intersectionID : Integer;
        attribute timestamp : Integer; // decimi di secondo nell'ora corrente
        attribute states : MovementState[*];
    }
    item def MAP{
        doc /* Map Data (MAP) - Contains information about the road network and infrastructure. */
        // Map Data – SAE J2735
        attribute intersectionID : Integer;
        attribute lanes : Lane[*];
        attribute referencePoint : GeoReference;
    }
    item def DENM{
        doc /* Denial Message (DENM) - Contains information about road hazards and emergencies. */
        // Decentralized Environmental Notification Message – ETSI EN 302 637-3
        attribute cause : CauseCodeKind; // es. accidente, lavori, ghiaccio
        attribute subCause : Integer;
        attribute latitude : Real;
        attribute longitude : Real;
        attribute relevanceDistance : Real; // m
        attribute eventPositionConfidence : ConfidenceLevel;
        attribute eventSpeedConfidence : ConfidenceLevel;
        attribute heading : Real; // gradi
        attribute speed : Real; // m/s
    }
    item def IVS{
        doc /* Intelligent Vehicle Safety (IVS) - Contains information about vehicle safety systems and alerts. */
        // In-Vehicle Signage – ISO/TS 17425 (trasmesso via TIM, messaggio J2735)
        attribute signType : SignTypeKind; // es. limite di velocità
        attribute speedLimit : Real; // km/h
        attribute roadSignCode : String; // codice segnale stradale
        attribute applicableLane : Integer; // opzionale
        attribute startLatitude : Real;
        attribute startLongitude : Real;
        attribute endLatitude : Real;
        attribute endLongitude : Real;
    }
    item def EVA{
        doc /* Environmental Vision Application (EVA) - Contains information about the vehicle's environment and perception. */
        // Emergency Vehicle Alert – SAE J2735
        attribute vehicleID : Integer;
        attribute vehicleType : EmergencyVehicleTypeKind; // police, ambulance...
        attribute latitude : Real;
        attribute longitude : Real;
        attribute speed : Real; // m/s
        attribute heading : Real; // gradi
        attribute routePath : GeoPath; // opzionale, percorso previsto
    }
    item def VRU{
        doc /* Vulnerable Road User (VRU) - Contains information about pedestrians and cyclists. */
        // Vulnerable Road User Awareness Message (VAM) – ETSI TS 103 300-3
        attribute vruID : Integer;
        attribute vruType : VRUTypeKind; // pedone, ciclista
        attribute latitude : Real;
        attribute longitude : Real;
        attribute speed : Real; // m/s
        attribute heading : Real; // gradi
        attribute clusterSize : Integer; // opzionale, dimensione gruppo
    }
    item def CPM{
        doc /* Coordinated Perception Message (CPM) - Contains information about the vehicle's perception of its surroundings. */
        // Collective Perception Message – ETSI TS 103 324
        attribute stationID : Integer;
        attribute sensorCapabilities : SensorCapability[*];
        attribute perceivedObjects : PerceivedObject[*];
    }
    item def MCM{
        doc /* Message for Coordination (MCM) - Contains information about vehicle coordination and communication. */
        // Maneuver Coordination Message – ETSI TS 103 561
        attribute stationID : Integer;
        attribute generationDeltaTime : Integer;
        attribute plannedTrajectory : TrajectoryPoint[*];
        attribute desiredTrajectory : TrajectoryPoint[*]; // manovra richiesta
        attribute maneuverType : ManeuverTypeKind; // es. cutIn, merge
        attribute requestID : Integer; // identificativo richiesta
        attribute response : ResponseKind; // accettato/rifiutato
    }
    item def GNSSData{
        doc /* Global Navigation Satellite System Data (GNSSData) - Contains information about GPS and other satellite navigation data. */
    }
    item def IMUData{
        doc /* Inertial Measurement Unit Data (IMUData) - Contains information about the vehicle's inertial measurement unit. */
    }
    item def OdometryData{
        doc /* Odometry Data (OdometryData) - Contains information about the vehicle's odometry measurements. */
    }
    item def VehicleControlCommand{
        doc /* Vehicle Control Command (VehicleControlCommand) - Contains information about commands for controlling the vehicle. */
    }
    item def SoftwareUpdatePackage{
        doc /* Software Update Package (SoftwareUpdatePackage) - Contains information about software updates for the vehicle. */
    }
    item def SecurityAlert{
        doc /* Security Alert (SecurityAlert) - Contains information about security threats and alerts. */
    }
    item def DriverNotification{
        doc /* Driver Notification (DriverNotification) - Contains information about notifications for the driver. */
    }
    item def TrajectoryPoint {
        doc /* A point in a vehicle's trajectory, used in maneuver coordination messages. */
        attribute timeOffset : Integer; // ms dal riferimento
        attribute latitude : Real;
        attribute longitude : Real;
        attribute speed : Real;
        attribute heading : Real;
    }
    item def MovementState {
        doc /* Represents the state of a movement phase at an intersection, used in SPaT messages. */
        attribute signalGroup : Integer;
        attribute eventState : MovementPhaseStateKind; // stop, go, caution
        attribute minEndTime : Integer; // decimi di secondo
        attribute maxEndTime : Integer; // opzionale
        attribute likelyTime : Integer; // opzionale
    }
    item def Lane {
        doc /* Represents a lane in the road network, used in MAP messages. */
        attribute laneID : Integer;
        attribute maneuvers : PermittedManeuvers[*]; // left, right, straight
        attribute width : Integer; // cm
    }
    item def PerceivedObject {
        doc /* Represents an object perceived by the vehicle's sensors, used in CPM messages. */
        attribute objectID : Integer;
        attribute latitude : Real;
        attribute longitude : Real;
        attribute speed : Real;
        attribute heading : Real;
        attribute classification : ObjectTypeKind; // vehicle, pedestrian, cyclist...
        attribute confidence : Real; // 0-1
    }
    item def SensorCapability {
        doc /* Represents the capabilities of a sensor, used in CPM messages. */
        attribute sensorType : SensorTypeKind; // lidar, radar, camera
        attribute detectionRange : Real; // m
        attribute fieldOfView : Real; // gradi
    }

    // ========== Tipi di dato di supporto ==========

    item def GeoReference {
        doc /* A geographic reference point, used in various messages for location data. */
        attribute latitude : Real;
        attribute longitude : Real;
        attribute altitude : Real;
    }

    item def GeoPath {
        doc /* A geographic path, used in EVA messages for route information. */
        attribute points : GeoReference[*];
    }

    item def ConfidenceLevel {
        doc /* A confidence level for a perceived object, used in CPM messages. */
        attribute level : Integer; // 0-100
        attribute semiMajor : Real;
        attribute semiMinor : Real;
    }

    // ========== Enumerazioni pertinenti ==========

    enum def DriveDirectionKind {
        doc /* Enumeration for drive direction, used in CAM messages. */
        forward; 
        backward; 
        stationary; 
    }

    enum def VehicleRoleKind {
        doc /* Enumeration for vehicle roles, used in various messages. */
        privateR; 
        publicTransport; 
        emergency; 
        roadWorks; 
    }

    enum def ManeuverTypeKind {
        doc /* Enumeration for maneuver types, used in various messages. */
        cutIn; 
        mergeT; 
        laneChange; 
        emergencyManeuver; 
    }

    enum def MovementPhaseStateKind {
        doc /* Enumeration for movement phase states, used in SPaT messages. */
        stop; 
        go; 
        caution; 
        preCaution; 
    }

    enum def CauseCodeKind {
        doc /* Enumeration for cause codes, used in various messages. */
        accident; 
        roadworks; 
        hazardousLocation; 
        adverseWeather; 
    }

    enum def SignTypeKind {
        doc /* Enumeration for sign types, used in various messages. */
        speedLimit; 
        roadSign; 
        advisory; 
    }

    enum def EmergencyVehicleTypeKind {
        doc /* Enumeration for emergency vehicle types, used in various messages. */
        police; 
        ambulance;
        fire; 
    }

    enum def VRUTypeKind {
        doc /* Enumeration for vulnerable road user types, used in various messages. */
        pedestrian; 
        cyclist; 
        motorcyclist; 
        animal; 
    }

    enum def SensorTypeKind {
        doc /* Enumeration for sensor types, used in various messages. */
        lidar; 
        radar; 
        camera; 
        ultrasonic; 
    }

    enum def ObjectTypeKind {
        doc /* Enumeration for object types, used in various messages. */
        vehicle; 
        pedestrian; 
        cyclist; 
        obstacle; 
    }

    enum def PermittedManeuvers {
        doc /* Enumeration for permitted maneuvers, used in various messages. */
        left; 
        right; 
        straight; 
        uturn; 
    }

    enum def ResponseKind {
        doc /* Enumeration for response kinds, used in various messages. */
        acceptR; 
        reject; 
    }

    enum def CarFollowingModelKind {
        doc /* Enumeration for car-following models, used in car-following attributes. */
        Newell;
        IDM;
        OVM;
        Gipps;
    }
    enum def CarFollowingModeKind {
        doc /* Enumeration for car-following modes, used in car-following attributes. */
        CACC;
        FallbackSensorsOnly;
        Disabled;
    }
    enum def CommStatusKind {
        doc /* Enumeration for communication status, used in various messages. */
        OK;
        Degraded;
        Lost;
    }
    enum def ThreatLevelKind {
        doc /* Enumeration for threat levels, used in various messages. */
        Normal;
        Suspicious;
        Attack;
        Compromised;
    }

    /* ===================================================================
		 * PORT DEFINITIONS — Energy and Signal Flows
	 * =================================================================== */
	port def V2VCommPort {
        doc /* A port for Vehicle-to-Vehicle (V2V) communication. */
        in camIn: CAM;
        out camOut: CAM;
        // MCM per coordinamento manovre
    }

    port def V2ICommPort {
        doc /* A port for Vehicle-to-Infrastructure (V2I) communication. */
        in spat: SPaT;
        in map: MAP;
        in denm: DENM;
        in ivs: IVS;
        in eva: EVA;
        in vru: VRU;
        in cpm: CPM;
    }

    port def VehicleBusPort {
        doc /* A port for internal vehicle communication, such as CAN bus or Ethernet. */
        in gnss: GNSSData;
        in imu: IMUData;
        in odometry: OdometryData;  // WIP (because is an internal sensor data, and maybe it should be used only by the 'fast' model)
        out controlCommand: VehicleControlCommand;
    }

    port def HMIPort {
        doc /* A port for human-machine interface communications. */
        out notification: DriverNotification;
    }

    port def SecurityMonitorPort {
        doc /* A port for monitoring security-related data and alerts. */
        out alert: SecurityAlert;
    }
    
     port def DataPort {
        doc /* A generic port for data transfer between components. */
        in dataIn :> power;
        out dataOut :> power;
    }

    port def SupplyPort {
        doc /* A port for supplying power or resources to components. */
        in supplyIn :> power;
        out supplyOut :> power;
    }

    /* ===================================================================
         * INTERFACE DEFINITIONS — How ports connect
     * =================================================================== */
    interface def V2VInterface {
        doc /* Interface for Vehicle-to-Vehicle (V2V) communication. */
        end sender: V2VCommPort;
        end receiver: V2VCommPort;
        flow sender.camOut to receiver.camIn;
    }

    interface def V2IInterface {
        doc /* Interface for Vehicle-to-Infrastructure (V2I) communication. */
        end infrastructure: ~V2ICommPort;
        end vehicle: V2ICommPort;
        flow infrastructure.spat to vehicle.spat;
        flow infrastructure.map to vehicle.map;
        flow infrastructure.denm to vehicle.denm;
        flow infrastructure.ivs to vehicle.ivs;
        flow infrastructure.eva to vehicle.eva;
        flow infrastructure.vru to vehicle.vru;
        flow infrastructure.cpm to vehicle.cpm;
    }

    interface def VehicleControlInterface {
        doc /* Interface for vehicle control commands and sensor data flow. */
        end controller: VehicleBusPort;
        end vehicle: ~VehicleBusPort;
        flow controller.controlCommand to vehicle.controlCommand;
        flow vehicle.gnss to controller.gnss;
        flow vehicle.imu to controller.imu;
        flow vehicle.odometry to controller.odometry;
    }

    interface def SecurityInterface {
        doc /* Interface for security-related communications. */
        end monitor: SecurityMonitorPort;
        end securityManager: ~SecurityMonitorPort;
        flow monitor.alert to securityManager.alert;
    }

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







        part conditioner : conditioning_unit::conditioning_unit_v1;
        part elaborator : elaboration_unit::elaboration_unit_v1;
        part balancer : balancing_unit::balancing_unit_v1;
        
        /* Internal Connections via Interface Usages */
        connection conditioned_signals : DataFlow connect conditioner to elaborator;
        connection generated_parameters : DataFlow connect elaborator to balancer;

        /* ===================================================================
		     * STATE MACHINE USAGE (TODO)
	     * =================================================================== */


    }





    /* ===================================================================
		 * VIEWPOINT DEFINITIONS — Filtered Views on the System
	 * =================================================================== */
	viewpoint def SignalFlowViewpoint {
		doc /* Viewpoint for signal and data flow visualization.
			 * Filters: Emphasize ports, interfaces, and data movement.
			 * Suitable for understanding:
			 * - How signals flow through the system
			 * - Port-to-port connections
			 * - External interfaces
			 * - Latency and throughput characteristics */
	}

}