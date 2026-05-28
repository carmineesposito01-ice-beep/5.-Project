library package StandardLibrary {
    doc /* This package defines the standard library for the system, including common data types, units of measurement, and utility functions. */
    library package Metadata_Definitions{
        doc /* This package defines the metadata for the system, including documentation and import statements for necessary libraries. */
        private import ScalarValues::*;
        private import Quantities::*;
        private import MeasurementReferences::*;
        private import ISQ::*;
        private import SI::*;
        private import Time::*;
        
        enum def ReqState{
            doc /* Enumeration to represent the state of requirements, such as "Draft", "Review", "Approved" and "Rejected" */
            Draft;
            Review;
            Approved;
            Rejected;
        }

        enum def ConfidenceCategory {
            doc /* Confidence categories for message/measurement confidence used in verification and analysis */
            High;
            Medium;
            Low;
            Unknown;
        }

        metadata def RequirementStatus{
            doc /* Metadata to track the status of requirements, including review status, approver, and date. */
            attribute status : ReqState; // e.g., "Draft", "Review", "Approved", "Rejected"
            attribute approver : String; // e.g., "HW Lead"
            attribute date : String; // e.g., "2026-04-25"
            attribute reqId : String; //  e.g, "SYS-F-003";
            attribute group : String; // e.s, "Functional Requirements"
        
        }

        metadata def AnalysisInfo {
            doc /* Annotates a view instance with display and analysis-grouping metadata.
                * Used by the Visualizer to build the Analysis Dashboard tree and
                * to show human-readable labels in the views list. */
            attribute label       : ScalarValues::String;   // e.g. "Use Case View"
            attribute groupName   : ScalarValues::String;   // group header label
            attribute domain      : ScalarValues::String;   // e.g. "Functional"
            attribute icon        : ScalarValues::String;   // emoji icon
            attribute level       : ScalarValues::String;   // "L1" | "L2" | "L3" | ""
            attribute kind        : ScalarValues::String;   // "BlackBox" | "WhiteBox" | ""
            attribute component   : ScalarValues::String;   // "" = system; component name = subsystem
            attribute parentGroup : ScalarValues::String;   // "B_W" = BB/WB hierarchy; "" = standalone
        }

        metadata def ViewRendering {
            doc /* Export hints for a view instance.
                * fileName is used as the base name for PNG/SVG export downloads. */
            attribute fileName : ScalarValues::String;   // e.g. "ActionFlowView"
        }
                        
    }


    library package Attribute_Definitions{
        doc /* FPGA System Definition:
            * This package defines the overall structure where the system will be allocated, with all the main components and their interactions.
            * It serves as the central point for integrating the various subsystem. 
            * */
        private import ScalarValues::*;
        private import Quantities::*;
        private import MeasurementReferences::*;
        private import ISQ::*;
        private import SI::*;

        
        /* ===================================================================
            * ATTRIBUTE DEFINITIONS (da cambiare con quelli definiti in Attribute_Definitions)
        * =================================================================== */
        attribute def ClockFrequency:> QuantityValue{
            doc /* The operating clock frequency of the FPGA system, in megahertz (MHz). */
        }
        attribute def LogicElements:> ScalarValue {
            doc /* The number of logic elements available in the FPGA, which determines the complexity of the designs that can be implemented. */
        }
        attribute def DSPBlocks:> ScalarValue {
            doc /* The number of digital signal processing (DSP) blocks available in the FPGA, which are specialized for high-speed arithmetic operations. */
        }
        attribute def BlockRAM:> QuantityValue{
            doc /* The amount of block RAM available in the FPGA, which is used for storing data and instructions. */
        }
        attribute def IOPins:> ScalarValue {
            doc /* The number of input/output pins available on the FPGA, which determines how many external connections can be made. */
        }
        attribute def Power:> PowerValue{
            doc /* The power consumption of the FPGA system, typically measured in watts (W). */
            attribute maxPower: PowerValue;
        }
        attribute def VoltageCore:> ElectricPotentialValue {
            doc /* The core voltage of the FPGA, which is the voltage level at which the internal logic operates. */
        }
        attribute def Temperature:> TemperatureValue{
            doc /* The operating temperature range of the FPGA, which is important for ensuring reliable performance. */
            attribute tempMin: TemperatureValue;
            attribute tempMax: TemperatureValue;
            
            assert constraint {
                tempMin <= tempMax
            }
        }
        attribute def Performance:> QuantityValue{
            doc /* The performance characteristics of the FPGA system, including maximum throughput and latency. */
            attribute maxThroughput: QuantityValue;
            attribute latency: TimeValue;
        }
        attribute def ReconfigurationTime:> TimeValue{
            doc /* The time required to reconfigure the FPGA, which is important for applications that require dynamic changes to the hardware configuration. */
        }
        attribute def SecurityFeatures:> Boolean {
            doc /* The security features implemented in the FPGA system, which may include secure boot, bitstream encryption, and tamper detection. */
            attribute SecureBoot: Boolean;
            attribute BitstreamEncryption: Boolean;
            attribute TamperDetection: Boolean;
        }
        attribute def MaxAllowedTime:> TimeValue{
            doc /* The maximum allowed time to identify safety fault. */
        }    
        attribute def MTBF:> TimeValue{
            doc /* The mean time between failures (MTBF) of the FPGA system, which is a measure of its reliability. */
        }

        attribute def CarFollowingParams {
            doc /* Parameters for car-following behavior, used in car-following algorithms. */
            attribute wantedSpeed : Real{
                doc /* Speed ​​at which the vehicle tends in the absence of obstacles (km/h). */
            }
            attribute headwayTime : Real{
                doc /* Desired safety time from the vehicle in front (s). */
            }
            attribute minDistance : Real{
                doc /* Minimum safe distance from the vehicle in front (m). */
            }
            attribute maxAcceleration : Real{
                doc /* Maximum acceleration of the vehicle (m/s^2). */
            }
            attribute wantedDecceleration : Real{
                doc /* Desired deceleration of the vehicle (m/s^2). */
            }
            attribute accelerationExponent : Real{
                doc /* Adjusts the acceleration progression towards the desired speed (dimensionless). */
            }
            attribute coolness : Real{
                doc /* Adjusts the sensitivity to speed differences with the leading vehicle (dimensionless). */
            }
        }

        
        /* ===================================================================
            * MESSAGE TYPE DEFINITIONS (V2X)
        * =================================================================== */
        item def CAM{
            @UnitInfo{unit = "test";}
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
            attribute certificateDigest : Boolean; // per cybersecurity
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
            attribute carrierWaves : Real{
                doc /* Pure Radio frequency wave. Used to calculate the distance*/
            }
            attribute pseudoRandomNoise: Real{
                doc /* Binary sequence for identify the satellite. Used to calculate the signal Travel Time. */
            }
            item navigationMessage{
                doc /* Navigation message for GNSS data. */
                item ephemeris{
                    doc /* Ephemeris data for GNSS, used to calculate the satellite's position. */
                    attribute orbitalX : Real;
                    attribute orbitalY : Real;
                    attribute orbitalZ : Real;
                }
                item almanac{
                    doc /* Almanac data for GNSS, contain the position of the other satellites in the costellation. */
                    item satellitePosition : Real[*];
                }
                item clockCorrection{
                    doc /* Clock correction data for GNSS, used to correct the satellite's clock. */
                    item clockBias : Real[*]{
                        doc /* Coefficient to correct the difference between the satellite's clock and the reference clock. */
                    }
                    item ionosphericDelay : Real[*]{
                        doc /* Coefficient to correct the delay caused by the ionosphere on the GNSS signal. */
                    }
                }

            }
        }
        item def IMUData{
            doc /* Inertial Measurement Unit Data (IMUData) - Contains information about the vehicle's inertial measurement unit. */
            attribute accelerationX : Real; // m/s^2
            attribute accelerationY : Real; // m/s^2
            attribute accelerationZ : Real; // m/s^2
            attribute angularVelocityPitch : Real; // rad/s
            attribute angularVelocityRoll : Real; // rad/s
            attribute angularVelocityYaw : Real; // rad/s
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


        item def EgoVehicleState {
            doc /* Own data to compose CAM message, that will be transmitted to other vehicles. */
            attribute stationID : Integer;
            attribute latitude : Real;
            attribute longitude : Real;
            attribute altitude : Real;
            attribute speed : Real;
            attribute heading : Real;
            attribute acceleration : Real;
            attribute timestamp : Integer; // ms
        }

        item def VehicleBodyInfo{
            doc /* Represents the physical characteristics of the vehicle, used for various calculations and message compositions. */
            attribute length : Real; // m
            attribute width : Real; // m
            attribute height : Real; // m
        }

        item def DataInformation{
            doc /* A data structure for information sent to the human-machine interface, including system status and relevant parameters. */
            item fragmentationRate : ScalarValue;
            item latency : TimeValue;
            item platooningAvailable : PlatooningAvailability;
            item conditioningVariables : PhysicsStateVector[*];
            item followingParameters : CarFollowingParams;
        }

        item def PhysicsStateVector {
            doc /* A vector of physical state variables for the vehicle, used in car-following calculations. */
            attribute gap         : Real; // m
            attribute relSpeed    : Real; // m/s
            attribute egoSpeed    : Real; // m/s
            attribute leaderSpeed : Real; // m/s
            attribute leaderAccel : Real; // m/s^2
            attribute leaderCovP  : Real; // m  (sigma_p dell'IMM)
        }

        item def ContextFlagsVector {
            attribute cutInRequested       : Boolean;
            attribute glosaActive          : Boolean;
            attribute signalViolationWarn  : Boolean;
            attribute emergencyManeuver    : Boolean;
            attribute platoonRole          : VehicleRoleKind;
            attribute degradedTracking     : Boolean;
        }

        item def LeaderStateEstimate {
            attribute position     : Real;
            attribute velocity     : Real;
            attribute acceleration : Real;
            attribute sigmaP       : Real;
            attribute sigmaV       : Real;
            attribute modeCV       : Real;
            attribute modeCA       : Real;
            attribute modeBrake    : Real;
        }

        item def GLOSA_Advisory {
            attribute glosaFeasible : Boolean;
            attribute vAdvisory     : Real;   // m/s, valido solo se glosaFeasible=true
            attribute stopProfile   : Real;   // valore di decelerazione richiesto, se non fattibile
        }

        attribute def PlatooningAvailability :> Boolean{
            doc /* Indicates whether the vehicle is available for platooning, based on its current state and system conditions. */
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
            IIDM;          // sostituisce IDM_2D
            ACC_IIDM;       // ACC-IIDM con coolness CAH
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

        enum def InfrastructureMessageKind {
            doc /* Enumeration for infrastructure message types, used in V2I communication. */
            SPaT; 
            MAP; 
            DENM; 
            IVS; 
            EVA; 
            VRU; 
            CPM; 
            SVW; 
        }

        enum def StatOfWork{
            doc /* Enumeration for system working states, used in platooning information. */
            Disabled;
            Active;
            Passive;
        }

        enum def LeaderMotionMode {
            doc /* Enumeration for leader motion modes, used in MMI reconstruction process. */
            ConstantVelocity;
            ConstantAcceleration;
            HardBrake;
        }


    }


    library package PortandInterfaceDefinitions{
        private import Attribute_Definitions::*;
        /* ===================================================================
            * PORT DEFINITIONS — Energy and Signal Flows
        * =================================================================== */
        port def V2XCommPort{
            doc /* A generic port for Vehicle-to-Everything (V2X) communication, which can be specialized for V2V and V2I communication. */
            in port v2v : V2VCommPort;
            in port v2i : V2ICommPort;
        }

        port def V2VCommPort{
            doc /* A port for Vehicle-to-Vehicle (V2V) communication. */
            in cam: CAM;
        }

        port def V2ICommPort{
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
            in vehicle_following_info: EgoVehicleState;
            in vehicle_body_info: VehicleBodyInfo;
        }

        port def MonitoringPort {
            doc /* A port for human-machine interface communications. */
            out data_information: DataInformation;
        }                   

        port def ConditioningVariablesPort{
            doc /* A port for in/outputting conditioning variables generated by the evaluation unit, sent to the parameter generator and monitoring composer for further processing. */
            in conditioningVariables : Real[*];
        }

        port def ControlParametersPort {
            doc /* A port for in/outputting control parameters generated by the elaboration unit, sent to the output gateway for transmission to the vehicle's control system. */
            in control : CarFollowingParams;
        }        

        port def CAM_Port {
            @UnitInfo{unit = "test";}
            doc /* A port for in/outputting CAM messages to other vehicles. */
            in cam : CAM;
        }

        port def PlatooningInfoPort{
            doc /* A port for outputting platooning information, such as the system working state (disabled, active, passive) and availability for platooning (0-1). */
            out stateOfWork : StatOfWork;
            out platooningAvailability : PlatooningAvailability; // True/False
        }

        port def PhysicsStatePort {
            in physicsState : PhysicsStateVector;  
        }
        port def ContextFlagsPort {
            in contextFlags : ContextFlagsVector;  
        }
        port def LeaderStatePort {
            in leaderState : LeaderStateEstimate; 
        }
        port def GLOSAAdvisoryPort {
            in advisory : GLOSA_Advisory;      
        }


        /* ===================================================================
            * INTERFACE DEFINITIONS — How ports connect
        * =================================================================== */
        interface def V2XInterface{
            doc /* Interface for Vehicle-to-Everything (V2X) communication, encompassing both V2V and V2I interactions. */
            end sender : ~V2XCommPort;
            end receiver : V2XCommPort;
            flow sender.v2v to receiver.v2v;
            flow sender.v2i to receiver.v2i;
        }
        
        interface def V2VInterface {
            doc /* Interface for Vehicle-to-Vehicle (V2V) communication. */
            end sender: ~V2VCommPort;
            end receiver: V2VCommPort;
            flow sender.cam to receiver.cam;
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
        

        interface def EgoVehicleData_Flow {
            doc /* Interface for the flow of ego vehicle state data from the input gateway to the CAM composer, used for composing CAM messages. */
            end provider : ~VehicleBusPort;
            end consumer : VehicleBusPort;
            flow provider.gnss to consumer.gnss;
            flow provider.imu to consumer.imu;
            flow provider.vehicle_body_info to consumer.vehicle_body_info;
            flow provider.vehicle_following_info to consumer.vehicle_following_info;
        }

        interface def ConditioningVariables_Flow{
            doc /* Interface for the flow of conditioning variables from the evaluation unit to the parameter generator and monitoring composer. */
            end provider : ~ConditioningVariablesPort;
            end consumer : ConditioningVariablesPort;
            flow provider.conditioningVariables to consumer.conditioningVariables;            
        }



        interface def ControlFlow {
            doc /* Interface for the flow of control parameters from the elaboration unit to the output gateway for transmission to the vehicle's control system. */
            end provider : ~ControlParametersPort;
            end consumer : ControlParametersPort;
            flow provider.control to consumer.control;
        }

        interface def CAM_Flow {
            doc /* Interface for the flow of CAM messages from the CAM composer to the output gateway for transmission to other vehicles. */
            end provider : ~CAM_Port;
            end consumer : CAM_Port;
            flow provider.cam to consumer.cam;
        }

        interface def Monitoring_Flow{
            doc /* Interface for the flow of driver notifications from the system to the human-machine interface. */
            end provider : MonitoringPort;
            end consumer : ~MonitoringPort;
            flow provider.data_information to consumer.data_information;
        }

        interface def PlatooningInfo_Flow{
            doc /* Interface for the flow of platooning information from the system to the human-machine interface and for transmission to other vehicles. */
            end provider : PlatooningInfoPort;
            end consumer : ~PlatooningInfoPort;
            flow provider.stateOfWork to consumer.stateOfWork;
            flow provider.platooningAvailability to consumer.platooningAvailability;
        }
    }

    library package Constraint_Definitions{
        constraint def StringStabilityConstraint {
            in params : CarFollowingParams;
            in v_e    : Real;
            // m_stab > 0 = stabile
            // forma chiusa per IIDM, espressa in patterns/forms documentati
        }

        constraint def ParameterRangeConstraint {
            //TODO: Dalla tabella dei range
        }
    }


    library package Requirement_Definitions {
        private import ScalarValues::*;
        private import Quantities::*;
        private import MeasurementReferences::*;
        private import ISQ::*;
        private import SI::*;
        private import Attribute_Definitions::*;

        package FPGARequirement {
            requirement def FPGA_ResourceRequirements {
                doc /* Resource requirements for the FPGA system, including logic elements, DSP blocks, block RAM, and I/O pins. */
                id = "RES-001";
                requirement LogicElementsRequirement {
                    id = "RES-001-LE";
                    doc /* Constraint to ensure that the number of logic elements used in the design does not exceed the available logic elements on the FPGA. */
                    attribute actual : LogicElements;
                    attribute required : LogicElements;

                    require constraint {actual <= required}
                }
                requirement DSPBlocksRequirement {
                    id = "RES-001-DSP";
                    doc /* Constraint to ensure that the number of DSP blocks used in the design does not exceed the available DSP blocks on the FPGA. */
                    attribute actual : DSPBlocks;
                    attribute required : DSPBlocks;

                    require constraint {actual <= required}
                }
                requirement BlockRAMRequirement {
                    id = "RES-001-BRAM";
                    doc /* Constraint to ensure that the amount of block RAM used in the design does not exceed the available block RAM on the FPGA. */
                    attribute actual : BlockRAM;
                    attribute required : BlockRAM;

                    require constraint {actual <= required}
                }
                requirement IOPinsRequirement {
                    id = "RES-001-IO";
                    doc /* Constraint to ensure that the number of I/O pins used in the design does not exceed the available I/O pins on the FPGA. */
                    attribute actual : IOPins;
                    attribute required : IOPins;

                    require constraint {actual <= required}
                }

                text = "Il sistema FPGA deve rispettare i limiti di risorse hardware, inclusi logic elements, DSP blocks, block RAM e I/O pins.";
            }

            requirement def FPGA_PerformanceRequirements {
                doc /* Performance requirements for the FPGA system, including throughput and latency. */
                id = "PERF-001";
                text = "Il sistema FPGA deve garantire una throughput minimo e latenza massima.";
                
                attribute actual : Performance;
                attribute required : Performance;

                require constraint {
                    actual.maxThroughput >= required.maxThroughput and
                    actual.latency <= required.latency
                }
                    
            }

            requirement def FPGA_SafetyRequirement{
                doc /* Safety requirements for the FPGA system, including fault detection and safe-state transition. */
                id = "SAFE-001";
                text = "Il sistema FPGA deve rilevare e gestire i fault hardware entro un certo tempo, passando in safe‑state.";
                    
                attribute actualDetectionTime : TimeValue;
                attribute actualRecoveryTime : TimeValue;
                attribute requiredTime : TimeValue;

                require constraint {
                    (actualDetectionTime + actualRecoveryTime) <= requiredTime
                }
            }

            requirement def FPGA_SecurityRequirement{
                doc /* Security requirements for the FPGA system, including secure boot and bitstream encryption. */
                id = "SEC-001";
                text = "Il sistema FPGA deve implementare SecureBoot e BitstreamEncryption per proteggere contro accessi non autorizzati.";
                    
                attribute actualFeatures : SecurityFeatures;
            
                require constraint {
                    actualFeatures.SecureBoot == true and 
                    actualFeatures.BitstreamEncryption == true and
                    actualFeatures.TamperDetection ==true
                }
            }

            requirement def FPGA_ReliabilityRequirement{
                doc /* Reliability requirements for the FPGA system, including mean time between failures (MTBF). */
                id = "REL-001";
                text = "Il sistema FPGA deve avere un MTBF ≥ 10.000 h in condizioni operative (‑40 °C … +85 °C).";
                    
                attribute actual_MTBF : TimeValue;
                attribute required_MTBF : TimeValue;
                attribute actual_temperature : TemperatureValue;
                attribute required_temperature : Temperature;

                assume constraint{required_temperature.tempMin <= actual_temperature <= required_temperature.tempMax}
                require constraint{
                    actual_MTBF >= required_MTBF
                }

            }

            requirement def FPGA_PowerRequirement{
                doc /* Constraint to ensure that the power consumption of the design does not exceed the maximum power limit of the FPGA. */
                id = "POWER-001";
                text = "Il sistema FPGA deve consumare ≤ potenza massima in condizioni operative.";
                
                attribute actual : PowerValue;
                attribute required : PowerValue;

                require constraint {actual <= required}        
            }

            requirement def FPGA_ThermalRequirement{
                doc /* Constraint to ensure that the operating temperature of the FPGA does not exceed the specified limits. */
                id = "THERMAL-001";
                text = "Il sistema FPGA deve operare entro i limiti di temperatura specificati.";
                
                attribute actual : TemperatureValue;
                attribute required : Temperature;

                require constraint {required.tempMin <= actual <= required.tempMax}        
            }
        }

        package SystemRequirement{
            requirement def StringStabilityRequirement {
                doc /* Parameters generated by the elaboration unit shall satisfy
                    the IIDM string-stability criterion m_stab > 0 at all times. */
                id = "SYS-STR-001";
                assert constraint { subject.params satisfies StringStabilityConstraint }
            }
            
            /* ===================================================================
                * SYSTEM REQUIREMENTS (WIP)
            * =================================================================== */
            // SYS-F-001: ricezione CAM >= 10 Hz
            requirement def CAM_ReceptionRate {
                doc /* SYS-F-001: The system shall receive CAM messages at a minimum frequency of 10 Hz. */
                id = "SYS-F-001";
                text = "The system shall receive CAM messages at a minimum frequency of 10 Hz.";
                attribute actualReceiveRate : Real;   // Hz
                attribute requiredRate : Real; // Hz
                require constraint { actualReceiveRate >= requiredRate }
            }

            // SYS-F-002: calcolo parametri following da CAM
            requirement def CAM_BasedFollowingComputation {
                doc /* SYS-F-002: The system shall compute car‑following parameters based on received CAM signals. */
                id = "SYS-F-002";
                text = "The system shall compute car‑following parameters based on received CAM signals.";
                attribute camDataAvailable : Boolean;
                attribute followingParamsValid : Boolean;
                require constraint { camDataAvailable implies followingParamsValid }
            }

            // SYS-F-003: invio CAM aggiornati
            requirement def CAM_Transmission {
                doc /* SYS-F-003: The system shall send its own updated CAM to the following vehicle. */
                id = "SYS-F-003";
                text = "The system shall send its own updated CAM to the following vehicle.";
                attribute actualCamSendRate : Real; // Hz
                attribute requiredCamSendRate : Real = 10.0;
                require constraint { actualCamSendRate >= requiredCamSendRate }
            }

            // SYS-F-004: riconoscimento cut‑in improvviso via V2V
            requirement def CutInDetection {
                doc /* SYS-F-004: The system shall detect a sudden cut‑in event based on V2V information. */
                id = "SYS-F-004";
                text = "The system shall detect a sudden cut‑in event based on V2V information.";
                attribute cutInScenarioOnV2V : Boolean;
                attribute cutInDetected : Boolean;
                require constraint { cutInScenarioOnV2V implies cutInDetected }
            }

            // SYS-F-005: frenata immediata dopo cut‑in
            requirement def CutInEmergencyBraking {
                doc /* SYS-F-005: If a sudden cut‑in occurs, the system shall command an immediate brake to avoid collision. */
                id = "SYS-F-005";
                text = "If a sudden cut‑in occurs, the system shall command an immediate brake to avoid collision.";
                attribute cutInDetected : Boolean;
                attribute emergencyBrakeCommand : Boolean;
                attribute timeToBrakeActuation : Real; // ms
                attribute maxReactionTime : Real = 200.0; // ms (from SYS‑SAF‑TR‑002)
                require constraint { cutInDetected implies (emergencyBrakeCommand and timeToBrakeActuation <= maxReactionTime) }
            }

            // SYS-F-006a: ricezione richiesta cut‑in e verifica fattibilità
            requirement def CutInRequestFeasibilityCheck {
                doc /* SYS-F-006a: The system shall receive a cut‑in request from a side vehicle and verify its feasibility. */
                id = "SYS-F-006a";
                text = "The system shall receive a cut‑in request from a side vehicle and verify its feasibility.";
                attribute cutInRequestReceived : Boolean;
                attribute feasibilityCheckPerformed : Boolean;
                require constraint { cutInRequestReceived implies feasibilityCheckPerformed }
            }

            // SYS-F-006b: trasmissione accettazione se fattibile
            requirement def CutInAccept {
                doc /* SYS-F-006b: If the request is feasible, the system shall transmit acceptance via maneuver coordination protocols. */
                id = "SYS-F-006b";
                text = "If the request is feasible, the system shall transmit acceptance via maneuver coordination protocols.";
                attribute feasibilityResult : ResponseKind;
                attribute mcmAcceptSent : Boolean;
                require constraint { feasibilityResult == ResponseKind::acceptR implies mcmAcceptSent}
            }

            // SYS-F-006c: trasmissione rifiuto se non fattibile
            requirement def CutInReject {
                doc /* SYS-F-006c: If the request is not feasible, the system shall transmit rejection. */
                id = "SYS-F-006c";
                text = "If the request is not feasible, the system shall transmit rejection.";
                attribute feasibilityResult : ResponseKind;
                attribute mcmRejectSent : Boolean;
                require constraint { feasibilityResult == ResponseKind::reject implies mcmRejectSent }
            }

            // SYS-F-007: ripristino car‑following dopo cut‑in
            requirement def CutInCompletionRevert {
                doc /* SYS-F-007: After the cut‑in is completed or cancelled, the system shall revert to standard car‑following logic. */
                id = "SYS-F-007";
                text = "After the cut‑in is completed or cancelled, the system shall revert to standard car‑following logic.";
                attribute cutInActive : Boolean;
                attribute carFollowingMode : CarFollowingModeKind;
                require constraint { not cutInActive implies carFollowingMode == CarFollowingModeKind::CACC }
            }

            // SYS-F-008a: calcolo Jam Rate da CAM follower
            requirement def JamRateCalculation {
                doc /* SYS-F-008a: The system shall receive CAM from multiple following vehicles and compute the string instability probability (Jam Rate). */
                id = "SYS-F-008a";
                text = "The system shall receive CAM from multiple following vehicles and compute the string instability probability (Jam Rate).";
                attribute multipleFollowerCAMs : Boolean;
                attribute jamRateCalculated : Boolean;
                require constraint { multipleFollowerCAMs implies jamRateCalculated }
            }

            // SYS-F-008b: aumento headway quando instabilità supera soglia
            requirement def JamMitigationHeadwayIncrease {
                doc /* SYS-F-008b: If instability exceeds a defined threshold, the system shall increase headway by 10% (default) while staying within safe ranges. */
                id = "SYS-F-008b";
                text = "If instability exceeds a defined threshold, the system shall increase headway by 10% (default) while staying within safe ranges.";
                attribute currentJamRate : Real;
                attribute jamThreshold : Real;
                attribute headwayTime : Real;
                attribute nominalHeadway : Real;
                attribute incrementPercent : Real = 10.0;
                require constraint {
                    currentJamRate > jamThreshold implies
                    headwayTime == nominalHeadway * (1.0 + incrementPercent/100.0)
                }
            }

            // SYS-F-009a: determinazione profilo comportamentale leader
            requirement def LeaderProfileClassification {
                doc /* SYS-F-009a: The system shall determine the behavioral profile of the leading vehicle by analyzing historical CAM data. */
                id = "SYS-F-009a";
                text = "The system shall determine the behavioral profile of the leading vehicle by analyzing historical CAM data.";
                attribute camHistoryAvailable : Boolean;
                attribute leaderProfileDetermined : Boolean;
                attribute leaderProfileConfidence : Real; // %
                require constraint { camHistoryAvailable implies (leaderProfileDetermined and leaderProfileConfidence >= 0.0) }
            }

            // SYS-F-009b: applicazione modificatori parametri in base al profilo
            requirement def ProfileBasedParameterModifiers {
                doc /* SYS-F-009b: Based on the identified profile, the system shall apply modifiers to car‑following parameters. */
                id = "SYS-F-009b";
                text = "Based on the identified profile, the system shall apply modifiers to car‑following parameters.";
                attribute leaderProfile : LeaderProfileKind;
                attribute headwayTime : Real;
                attribute baseHeadway : Real;
                // mapping semplificato: profilo aggressivo -> headway ridotto, timido -> aumentato
                require constraint {
                    (leaderProfile == LeaderProfileKind::aggressive implies headwayTime <= baseHeadway * 0.9) and
                    (leaderProfile == LeaderProfileKind::timid implies headwayTime >= baseHeadway * 1.1)
                }
            }

            // SYS-F-0010a: ricezione informazioni ciclo semaforico (SPaT/MAP)
            requirement def SPAT_MAP_Reception {
                doc /* SYS-F-0010: The system shall receive traffic light information (SPaT/MAP) from the V2I infrastructure. */
                id = "SYS-F-0010";
                text = "The system shall receive traffic light information (SPaT/MAP) from the V2I infrastructure.";
                attribute spatMapDataAvailable : Boolean;
                require constraint { spatMapDataAvailable == true }
            }

            // SYS-F-010b: calcolabilità onda verde (GLOSA)
            requirement def GLOSAFeasibilityCalculation {
                doc /* SYS-F-010a: The system shall compute whether a green wave (GLOSA) is achievable. */
                id = "SYS-F-010a";
                text = "The system shall compute whether a green wave (GLOSA) is achievable.";
                attribute spatMapDataAvailable : Boolean;
                attribute glosaFeasible : Boolean;
                require constraint { spatMapDataAvailable implies glosaFeasible != null }
            }

            // SYS-F-010c: adattamento velocità se onda verde raggiungibile
            requirement def GLOSASpeedAdaptation {
                doc /* SYS-F-010b: If the green wave is attainable, the system shall adapt the speed within longitudinal comfort limits. */
                id = "SYS-F-010b";
                text = "If the green wave is attainable, the system shall adapt the speed within longitudinal comfort limits.";
                attribute glosaFeasible : Boolean;
                attribute speedAdaptationActive : Boolean;
                attribute speed : Real;
                attribute maxComfortAccel : Real;
                attribute minComfortDecel : Real;
                require constraint {
                    glosaFeasible implies
                    speedAdaptationActive and
                    (speed' - speed) <= maxComfortAccel * deltaT and
                    (speed - speed') <= abs(minComfortDecel) * deltaT   // esemplificativo
                }
            }

            // SYS-F-010d: decelerazione progressiva se onda verde non raggiungibile
            requirement def GLOSANonGreenDeceleration {
                doc /* SYS-F-010c: If the green wave is not attainable, the system shall perform a progressive and comfortable deceleration. */
                id = "SYS-F-010c";
                text = "If the green wave is not attainable, the system shall perform a progressive and comfortable deceleration.";
                attribute glosaFeasible : Boolean;
                attribute decelerationActive : Boolean;
                attribute decelerationProfile : DecelerationProfile;
                attribute comfortProfile : DecelerationProfile; // quello definito come confortevole
                require constraint {
                    (not glosaFeasible) implies
                    decelerationActive and
                    decelerationProfile.maxDeceleration <= comfortProfile.maxDeceleration and
                    decelerationProfile.jerk <= comfortProfile.jerk
                }
            }

            // SYS-F-011: applicazione limiti di velocità da infrastruttura
            requirement def SpeedLimitEnforcement {
                doc /* SYS-F-011: The system shall receive current speed limits from the infrastructure and enforce them as a maximum speed constraint. */
                id = "SYS-F-011";
                text = "The system shall receive current speed limits from the infrastructure and enforce them as a maximum speed constraint.";
                attribute receivedSpeedLimit : Real; // km/h
                attribute maxSpeed : Real;
                require constraint { maxSpeed <= receivedSpeedLimit }
            }

            // SYS-F-012: riduzione velocità per lavori stradali (DENM)
            requirement def RoadHazardWarningResponse {
                doc /* SYS-F-012: The system shall receive road work warnings and progressively reduce cruise speed. */
                id = "SYS-F-012";
                text = "The system shall receive road work warnings and progressively reduce cruise speed.";
                attribute roadWorksWarningActive : Boolean;
                attribute speed : Real;
                attribute nominalSpeed : Real;
                require constraint { roadWorksWarningActive implies speed <= nominalSpeed and decelerationComfortable }
            }

            // SYS-F-013: ricezione notifica infrazione semaforica (Signal Violation Warning)
            requirement def SignalViolationWarningReception {
                doc /* SYS-F-013: The system shall receive a Signal Violation Warning (SVW) from the infrastructure. */
                id = "SYS-F-013";
                text = "The system shall receive a Signal Violation Warning (SVW) from the infrastructure.";
                attribute svwReceived : Boolean;
                require constraint { svwReceived == true }
            }

            // SYS-F-014a: (già coperto da SYS-F-013) ma tabella lo distingue; lo teniamo come requisito distinto di ricezione
            requirement def SVW_ReceptionForAction {
                doc /* SYS-F-014a: The system shall be capable of receiving a Signal Violation Warning from the infrastructure. */
                id = "SYS-F-014a";
                text = "The system shall be capable of receiving a Signal Violation Warning from the infrastructure.";
                attribute svwReceived : Boolean;
                require constraint { svwReceived == true }
            }

            // SYS-F-014b: frenata di emergenza se distanza < soglia_emergenza
            requirement def SVW_EmergencyBrake {
                doc /* SYS-F-014b: If the distance to the violation point is less than the emergency threshold, the system shall perform an emergency brake. */
                id = "SYS-F-014b";
                text = "If the distance to the violation point is less than the emergency threshold, the system shall perform an emergency brake.";
                attribute distanceToViolation : Real; // m
                attribute emergencyThreshold : Real;
                attribute emergencyBrakeActive : Boolean;
                require constraint { distanceToViolation < emergencyThreshold implies emergencyBrakeActive == true }
            }

            // SYS-F-014c: decelerazione moderata se distanza tra soglia_emergenza e soglia_attenzione
            requirement def SVW_ModerateDeceleration {
                doc /* SYS-F-014c: If the distance is between the emergency and attention thresholds, the system shall perform a moderate deceleration. */
                id = "SYS-F-014c";
                text = "If the distance is between the emergency and attention thresholds, the system shall perform a moderate deceleration.";
                attribute distanceToViolation : Real;
                attribute emergencyThreshold : Real;
                attribute attentionThreshold : Real;
                attribute moderateDecelActive : Boolean;
                require constraint {
                    (distanceToViolation >= emergencyThreshold and distanceToViolation <= attentionThreshold) implies
                    moderateDecelActive == true
                }
            }

            // SYS-F-015a: aumento headway laterale per veicolo contromano
            requirement def WrongWayVehicle_LateralHeadwayIncrease {
                doc /* SYS-F-015a: In case of a wrong‑way vehicle, the system shall progressively increase lateral headway to the maximum available. */
                id = "SYS-F-015a";
                text = "In case of a wrong‑way vehicle, the system shall progressively increase lateral headway to the maximum available.";
                attribute wrongWayVehicleDetected : Boolean;
                attribute lateralHeadway : Real; // m
                attribute maxAvailableLateralHeadway : Real; // m
                require constraint { wrongWayVehicleDetected implies lateralHeadway == maxAvailableLateralHeadway }
            }

            // SYS-F-015b: manovra di evitamento se veicolo contromano entro soglia critica
            requirement def WrongWayVehicle_EvasionManeuver {
                doc /* SYS-F-015b: If the wrong‑way vehicle comes within a critical threshold, the system shall perform an evasive maneuver. */
                id = "SYS-F-015b";
                text = "If the wrong‑way vehicle comes within a critical threshold, the system shall perform an evasive maneuver.";
                attribute distanceToWrongWayVehicle : Real;
                attribute criticalThreshold : Real;
                attribute evasionManeuverActive : Boolean;
                require constraint { distanceToWrongWayVehicle <= criticalThreshold implies evasionManeuverActive == true }
            }

            // SYS-F-015c: ripristino headway laterale dopo evento
            requirement def WrongWayVehicle_RestoreLateralHeadway {
                doc /* SYS-F-015c: After the event is over, the system shall restore the original lateral headway. */
                id = "SYS-F-015c";
                text = "After the event is over, the system shall restore the original lateral headway.";
                attribute wrongWayEventActive : Boolean;
                attribute lateralHeadway : Real;
                attribute nominalLateralHeadway : Real;
                require constraint { not wrongWayEventActive implies lateralHeadway == nominalLateralHeadway }
            }

            // SYS-F-016a: aumento headway laterale per veicolo di emergenza (EVA)
            requirement def EmergencyVehicle_LateralHeadwayIncrease {
                doc /* SYS-F-016a: Upon receiving an Emergency Vehicle Alert (EVA), the system shall progressively increase lateral headway. */
                id = "SYS-F-016a";
                text = "Upon receiving an Emergency Vehicle Alert (EVA), the system shall progressively increase lateral headway.";
                attribute evaReceived : Boolean;
                attribute lateralHeadway : Real;
                attribute increasedLateralHeadway : Real;
                require constraint { evaReceived implies lateralHeadway >= increasedLateralHeadway }
            }

            // SYS-F-016b: ripristino headway laterale dopo passaggio veicolo emergenza
            requirement def EmergencyVehicle_RestoreLateralHeadway {
                doc /* SYS-F-016b: After the emergency vehicle has passed, the system shall restore the original lateral headway. */
                id = "SYS-F-016b";
                text = "After the emergency vehicle has passed, the system shall restore the original lateral headway.";
                attribute emergencyPassageOver : Boolean;
                attribute lateralHeadway : Real;
                attribute nominalLateralHeadway : Real;
                require constraint { emergencyPassageOver implies lateralHeadway == nominalLateralHeadway }
            }

            // SYS-F-017a: calcolo TTA per pedone (da avviso VRU/CPM)
            requirement def Pedestrian_TTACalculation {
                doc /* SYS-F-017a: Upon receiving a pedestrian alert (VRU/CPM), the system shall compute the Time‑To‑Arrival (TTA). */
                id = "SYS-F-017a";
                text = "Upon receiving a pedestrian alert (VRU/CPM), the system shall compute the Time‑To‑Arrival (TTA).";
                attribute pedestrianAlertReceived : Boolean;
                attribute ttaCalculated : Boolean;
                require constraint { pedestrianAlertReceived implies ttaCalculated == true }
            }

            // SYS-F-017b: procedere normalmente se TTA > soglia attenzione
            requirement def Pedestrian_ProceedIfTTAHigh {
                doc /* SYS-F-017b: If the TTA is above the attention threshold, the system shall proceed normally. */
                id = "SYS-F-017b";
                text = "If the TTA is above the attention threshold, the system shall proceed normally.";
                attribute tta : Real; // s
                attribute attentionThreshold : Real;
                attribute carFollowingMode : CarFollowingModeKind;
                require constraint { tta > attentionThreshold implies carFollowingMode == CarFollowingModeKind::CACC }
            }

            // SYS-F-017c: rallentare per mantenere TTA entro limiti sicurezza
            requirement def Pedestrian_SlowDownForTTA {
                doc /* SYS-F-017c: If the TTA is below the attention threshold, the system shall slow down to keep TTA within safe limits. */
                id = "SYS-F-017c";
                text = "If the TTA is below the attention threshold, the system shall slow down to keep TTA within safe limits.";
                attribute tta : Real;
                attribute attentionThreshold : Real;
                attribute dangerThreshold : Real;
                attribute decelerationActive : Boolean;
                require constraint {
                    (tta <= attentionThreshold and tta > dangerThreshold) implies
                    decelerationActive == true
                }
            }

            // SYS-F-017d: frenata fino all'arresto se TTA < soglia pericolo
            requirement def Pedestrian_EmergencyBrakeForTTA {
                doc /* SYS-F-017d: If the TTA is below the danger threshold, the system shall brake to a full stop. */
                id = "SYS-F-017d";
                text = "If the TTA is below the danger threshold, the system shall brake to a full stop.";
                attribute tta : Real;
                attribute dangerThreshold : Real;
                attribute emergencyBrakeFullStop : Boolean;
                require constraint { tta < dangerThreshold implies emergencyBrakeFullStop == true }
            }

            // SYS-F-017e: riprendere car‑following standard al cessare allarme
            requirement def Pedestrian_ResumeAfterAlarm {
                doc /* SYS-F-017e: When the alarm ceases, the system shall resume standard car‑following. */
                id = "SYS-F-017e";
                text = "When the alarm ceases, the system shall resume standard car‑following.";
                attribute pedestrianAlarmActive : Boolean;
                attribute carFollowingMode : CarFollowingModeKind;
                require constraint { not pedestrianAlarmActive implies carFollowingMode == CarFollowingModeKind::CACC }
            }

            // SYS-F-018: comunicazione disponibilità platooning/funzionamento
            requirement def State_Comunications{
                doc /* SYS-F-018: The system need to comunicate his state at external system (top-level systems, or external) */
                id = "SYS-F-018";
                text = "The system need to comunicate his state at external system (top-level systems, or external).";
                
            }

            // ==================== 2.1 Safety Goal & Integrity Requirements (ISO 26262) ====================

            requirement def NoRearEndCollision_V2VError {
                doc /* SYS-SAF-001: The system shall not cause a rear‑end collision due to incorrect or missing V2V communication information. */
                id = "SYS-SAF-001";
                text = "The system shall not cause a rear‑end collision because of erroneous or missing V2V data.";
                attribute rearEndCollisionDueToV2VError : Boolean;
                require constraint { rearEndCollisionDueToV2VError == false }
            }

            requirement def NoCollisionDuringAssistedCutIn {
                doc /* SYS-SAF-002: The system shall not cause a collision during an assisted cut‑in maneuver. */
                id = "SYS-SAF-002";
                text = "The system shall not cause a collision during an assisted cut‑in.";
                attribute cutInCollisionOccurred : Boolean;
                require constraint { cutInCollisionOccurred == false }
            }

            requirement def NoIntersectionCollision_V2IError {
                doc /* SYS-SAF-003: The system shall not cause a collision at a signalized intersection due to incorrect or missing V2I information. */
                id = "SYS-SAF-003";
                text = "The system shall not cause an intersection collision because of faulty V2I data.";
                attribute intersectionCollisionDueToV2IError : Boolean;
                require constraint { intersectionCollisionDueToV2IError == false }
            }

            requirement def NoPedestrianIncident {
                doc /* SYS-SAF-004: The system shall not cause an accident with a pedestrian due to a missed reaction to a warning. */
                id = "SYS-SAF-004";
                text = "The system shall not cause a pedestrian accident because of a missed warning reaction.";
                attribute pedestrianAccidentOccurred : Boolean;
                require constraint { pedestrianAccidentOccurred == false }
            }

            requirement def NoEmergencyVehicleCollision {
                doc /* SYS-SAF-005: The system shall not cause a collision with an emergency vehicle due to an incorrect maneuver. */
                id = "SYS-SAF-005";
                text = "The system shall not cause a collision with an emergency vehicle because of an erroneous maneuver.";
                attribute emergencyVehicleCollisionOccurred : Boolean;
                require constraint { emergencyVehicleCollisionOccurred == false }
            }

            requirement def NoWrongWayVehicleCollision {
                doc /* SYS-SAF-006: The system shall not cause a collision with a wrong‑way vehicle due to an incorrect evasive maneuver. */
                id = "SYS-SAF-006";
                text = "The system shall not cause a collision with a wrong‑way vehicle because of an erroneous evasive maneuver.";
                attribute wrongWayCollisionOccurred : Boolean;
                require constraint { wrongWayCollisionOccurred == false }
            }

            requirement def NoStringInstabilityAmplification {
                doc /* SYS-SAF-007: The system shall not cause longitudinal instability (shockwave) by amplifying speed oscillations. */
                id = "SYS-SAF-007";
                text = "The system shall not cause longitudinal instability by amplifying speed oscillations.";
                attribute instabilityAmplificationOccurred : Boolean;
                require constraint { instabilityAmplificationOccurred == false }
            }

            requirement def LegalSpeedLimitCompliance {
                doc /* SYS-SAF-008: The system shall not violate legal speed limits. */
                id = "SYS-SAF-008";
                text = "The system shall not exceed legal speed limits.";
                attribute speedLimitViolation : Boolean;
                require constraint { speedLimitViolation == false }
            }

            requirement def NoUnnecessaryOrExcessiveEmergencyBrake {
                doc /* SYS-SAF-009: The system shall not cause a collision due to an unnecessary or excessive emergency braking. */
                id = "SYS-SAF-009";
                text = "The system shall not cause a collision because of an unnecessary/excessive emergency brake.";
                attribute unnecessaryEmergencyBrakeCollision : Boolean;
                require constraint { unnecessaryEmergencyBrakeCollision == false }
            }

            requirement def NoUnstableOrExcessiveEvasionManeuver {
                doc /* SYS-SAF-010: The system shall not cause an accident due to an unstable or excessive evasive maneuver. */
                id = "SYS-SAF-010";
                text = "The system shall not cause an accident because of an unstable/excessive evasive maneuver.";
                attribute unstableEvasionAccident : Boolean;
                require constraint { unstableEvasionAccident == false }
            }

            // ==================== 2.2 Technical Safety Requirements (TSR) ====================

            requirement def CACC_DataCoherenceCheck {
                doc /* SYS-SAF-TR-001: The CACC synchronization function shall include a redundancy check that verifies the consistency of received CAM data (e.g., plausible speed/position change) before computing following parameters. */
                id = "SYS-SAF-TR-001";
                text = "CACC shall perform a coherence check on received CAM data before computing following parameters.";
                attribute camDataReceived : Boolean;
                attribute coherenceCheckPerformed : Boolean;
                attribute dataCoherent : Boolean;
                attribute followingParamsComputed : Boolean;
                require constraint {
                    camDataReceived implies (coherenceCheckPerformed and
                    (followingParamsComputed implies dataCoherent))
                }
            }

            requirement def CutIn_EmergencyBrakeReactionTime {
                doc /* SYS-SAF-TR-002: The emergency brake for a sudden cut‑in shall activate within 200 ms from message reception to actuator command. */
                id = "SYS-SAF-TR-002";
                text = "Cut‑in emergency brake shall activate within 200 ms.";
                attribute cutInDetected : Boolean;
                attribute brakeCommandTime : Real; // ms
                attribute msgReceptionTime : Real; // ms
                require constraint {
                    cutInDetected implies (brakeCommandTime - msgReceptionTime <= 200.0)
                }
            }

            requirement def CutIn_FeasibilityVerificationOnCamData {
                doc /* SYS-SAF-TR-003: The cut‑in feasibility decision shall be verified based on CAM data (position, heading, speed) to confirm the trajectory before acceptance/rejection. */
                id = "SYS-SAF-TR-003";
                text = "Cut‑in feasibility shall be verified using CAM data before responding.";
                attribute cutInRequestReceived : Boolean;
                attribute camDataForFeasibilityValid : Boolean;
                attribute feasibilityDecisionMade : Boolean;
                require constraint {
                    cutInRequestReceived implies (camDataForFeasibilityValid and feasibilityDecisionMade)
                }
            }

            requirement def V2I_MessageValidation {
                doc /* SYS-SAF-TR-004: The system shall validate V2I messages (SPaT/EVA) by evaluating Data Age, spatial consistency via GNSS, and security certificate authenticity (PKI) before activating longitudinal adaptation. */
                id = "SYS-SAF-TR-004";
                text = "V2I messages shall be validated (Data Age, GNSS, PKI) before longitudinal adaptation.";
                attribute v2iMessageReceived : Boolean;
                attribute dataAgeValid : Boolean;
                attribute gnssConsistencyValid : Boolean;
                attribute pkiCertificateValid : Boolean;
                attribute longitudinalAdaptationActive : Boolean;
                require constraint {
                    (v2iMessageReceived implies (dataAgeValid and gnssConsistencyValid and pkiCertificateValid)) and
                    (longitudinalAdaptationActive implies (dataAgeValid and gnssConsistencyValid and pkiCertificateValid))
                }
            }

            requirement def SignalViolation_OnboardSensorValidation {
                doc /* SYS-SAF-TR-005: The Signal Violation Protection function shall validate the computed distance and trajectory with onboard sensor data (GNSS + IMU/Odometry/HD Maps) before activating braking. */
                id = "SYS-SAF-TR-005";
                text = "Signal violation distance/trajectory shall be validated with onboard sensors before braking.";
                attribute svwReceived : Boolean;
                attribute distanceValidatedByOnboardSensors : Boolean;
                attribute svwBrakeActivated : Boolean;
                require constraint {
                    svwBrakeActivated implies distanceValidatedByOnboardSensors
                }
            }

            requirement def Pedestrian_LateralSafetyBuffer {
                doc /* SYS-SAF-TR-006: The pedestrian protection function shall maintain a lateral safety buffer of at least 1.0 m from the pedestrian crossing. */
                id = "SYS-SAF-TR-006";
                text = "Lateral buffer ≥ 1.0 m shall be maintained when a pedestrian crossing alarm is active.";
                attribute pedestrianAlarmActive : Boolean;
                attribute lateralDistanceToCrossing : Real; // m
                attribute requiredBuffer : Real = 1.0;
                require constraint {
                    pedestrianAlarmActive implies lateralDistanceToCrossing >= requiredBuffer
                }
            }

            requirement def EmergencyVehicle_TrajectoryCrossCheck {
                doc /* SYS-SAF-TR-007: The emergency vehicle handling function shall yield only after verifying the actual trajectory of the emergency vehicle by cross‑checking V2I data with onboard sensors. */
                id = "SYS-SAF-TR-007";
                text = "Emergency vehicle trajectory shall be cross‑checked with onboard sensors before yielding.";
                attribute evaReceived : Boolean;
                attribute trajectoryCrossChecked : Boolean;
                attribute yieldManeuverInitiated : Boolean;
                require constraint {
                    yieldManeuverInitiated implies (evaReceived and trajectoryCrossChecked)
                }
            }

            requirement def EvasiveManeuver_LateralAccelerationLimit {
                doc /* SYS-SAF-TR-008: The wrong‑way vehicle evasive maneuver shall respect a dynamic lateral acceleration limit computed from estimated road friction, with an absolute maximum of 4.0 m/s², to maintain vehicle stability. */
                id = "SYS-SAF-TR-008";
                text = "Evasive lateral acceleration ≤ 4.0 m/s² dynamically limited by road friction.";
                attribute evasionActive : Boolean;
                attribute actualLateralAccel : Real;
                attribute frictionLimitedMaxAccel : Real;
                attribute absoluteMaxAccel : Real = 4.0;
                require constraint {
                    evasionActive implies (actualLateralAccel <= min(frictionLimitedMaxAccel, absoluteMaxAccel))
                }
            }

            requirement def ShockwaveDamping_StringStabilityValidation {
                doc /* SYS-SAF-TR-009: The shockwave mitigation algorithm shall be validated to ensure asymptotic string stability for at least 10 consecutive vehicles in mixed traffic conditions. */
                id = "SYS-SAF-TR-009";
                text = "String stability shall be validated for ≥ 10 vehicles in mixed traffic.";
                attribute stringStabilityValidated : Boolean;
                attribute testVehicleCount : Integer;
                require constraint { stringStabilityValidated and testVehicleCount >= 10 }
            }

            requirement def SpeedLimit_OvershootControl {
                doc /* SYS-SAF-TR-010: The control logic shall guarantee, considering actuator tolerances and road slopes, a maximum transient overshoot of X km/h over the detected legal limit, converging to the exact limit. */
                id = "SYS-SAF-TR-010";
                text = "Speed overshoot ≤ X km/h over the legal limit during transient, then convergence.";
                attribute actualSpeed : Real; // km/h
                attribute legalLimit : Real;
                attribute maxOvershoot : Real; // X km/h
                require constraint {
                    actualSpeed <= legalLimit + maxOvershoot
                }
            }

            // ==================== 2.3 SOTIF Requirements (ISO 21448) integrated with ISO 34502 ====================

            requirement def LeaderProfile_ConservativeFallback {
                doc /* SYS-SOTIF-001: If classifier confidence drops below 60%, the following parameters shall revert to the conservative default set. */
                id = "SYS-SOTIF-001";
                text = "When leader profile confidence < 60%, revert to conservative default parameters.";
                attribute leaderProfileConfidence : Real;
                attribute confidenceThresholdLow : Real = 60.0;
                attribute usingConservativeParams : Boolean;
                require constraint {
                    leaderProfileConfidence < confidenceThresholdLow implies usingConservativeParams == true
                }
            }

            requirement def JamRate_FalsePositiveHandling {
                doc /* SYS-SOTIF-002: The shockwave damping function shall identify and handle false positives in the jam rate indicator caused by temporary events (e.g., a vehicle leaving the highway). */
                id = "SYS-SOTIF-002";
                text = "False positive jam rate indicators shall be filtered out.";
                attribute jamRateAlarmTriggered : Boolean;
                attribute transientEventDetected : Boolean;
                attribute falsePositiveHandled : Boolean;
                require constraint {
                    (jamRateAlarmTriggered and transientEventDetected) implies falsePositiveHandled
                }
            }

            requirement def GLOSA_UnreachableGreenWaveHandling {
                doc /* SYS-SOTIF-003: If the green wave is computed but not reachable (e.g., due to non‑communicating traffic), the system shall execute a comfortable deceleration. */
                id = "SYS-SOTIF-003";
                text = "When GLOSA green wave is unattainable, execute a comfortable deceleration.";
                attribute glosaGreenWaveAttainable : Boolean;
                attribute comfortableDecelActive : Boolean;
                require constraint {
                    not glosaGreenWaveAttainable implies comfortableDecelActive == true
                }
            }

            requirement def DENM_ConfidenceLevelValidation {
                doc /* SYS-SOTIF-004: The road hazard warning function shall validate the hazard existence by analyzing Confidence Level fields (Position Confidence, Speed Confidence) in ETSI messages. */
                id = "SYS-SOTIF-004";
                text = "DENM hazard shall be validated using message confidence fields.";
                attribute denmReceived : Boolean;
                attribute positionConfidenceValid : Boolean;
                attribute speedConfidenceValid : Boolean;
                attribute hazardResponseActivated : Boolean;
                require constraint {
                    hazardResponseActivated implies (positionConfidenceValid and speedConfidenceValid)
                }
            }

            requirement def Pedestrian_OnboardVerification {
                doc /* SYS-SOTIF-005: The system shall verify the presence of a pedestrian on the crossing using onboard sensors (e.g., camera) within 3 s after receiving the V2I alert (false negative mitigation). */
                id = "SYS-SOTIF-005";
                text = "Verify pedestrian presence with onboard sensors within 3 s of V2I alert.";
                attribute pedestrianAlertReceived : Boolean;
                attribute onboardVerificationPerformed : Boolean;
                attribute verificationTime : Real; // s
                attribute maxVerificationTime : Real = 3.0;
                require constraint {
                    pedestrianAlertReceived implies (onboardVerificationPerformed and verificationTime <= maxVerificationTime)
                }
            }

            requirement def EmergencyManeuver_ODDRestrictions {
                doc /* SYS-SOTIF-006: The system shall define and document the validation conditions and safety limits for all emergency maneuvers, specifying the ODDs where they are guaranteed (UL 4600). */
                id = "SYS-SOTIF-006";
                text = "Emergency maneuver validation conditions and ODD limits must be documented.";
                attribute emergencyManeuversDefined : Boolean;
                attribute oddDocumented : Boolean;
                require constraint { emergencyManeuversDefined and oddDocumented }
            }

            // ==================== 2.4 Safety Requirements from ISO 34502 (Scenario-Based Safety Evaluation) ====================

            requirement def ScenarioCatalogGeneration {
                doc /* SYS-SCEN-001: For each safety goal, the system shall generate a test scenario catalog including nominal, edge, and failure scenarios following ISO 34502 guidelines. */
                id = "SYS-SCEN-001";
                text = "A scenario catalog (nominal, edge, failure) shall be generated for every safety goal.";
                attribute scenarioCatalogGenerated : Boolean;
                attribute safetyGoals : Boolean[*]; // list of safety goals; simplification: a boolean for each required
                require constraint { scenarioCatalogGenerated == true }
            }

            requirement def ScenarioBasedSafetyIntegration {
                doc /* SYS-SCEN-002: The scenario‑based safety evaluation process shall be integrated into the development flow starting from the concept phase. */
                id = "SYS-SCEN-002";
                text = "Scenario‑based safety evaluation shall be integrated from the concept phase.";
                attribute scenarioProcessIntegrated : Boolean;
                require constraint { scenarioProcessIntegrated == true }
            }

            requirement def ScenarioResultsAgainstAcceptanceCriteria {
                doc /* SYS-SCEN-003: Simulation results shall be compared with the acceptance criteria defined in the Safety Case for each scenario. */
                id = "SYS-SCEN-003";
                text = "Simulation results must meet acceptance criteria per scenario.";
                attribute simulationResults : Boolean; // simplified: true if all meet criteria
                require constraint { simulationResults == true }
            }

            requirement def ODD_ScenarioCoverageDocumentation {
                doc /* SYS-SCEN-004: Scenario coverage shall be documented and justified, demonstrating that the selected set of scenarios is representative of the intended ODD. */
                id = "SYS-SCEN-004";
                text = "Scenario coverage must be documented and ODD‑representative.";
                attribute oddCoverageDocumented : Boolean;
                attribute oddCoverageJustified : Boolean;
                require constraint { oddCoverageDocumented and oddCoverageJustified }
            }

            requirement def V2X_DegradedChannelScenarios {
                doc /* SYS-SCEN-005a: For V2X‑dependent functions, the catalog shall include edge scenarios of channel degradation (e.g., latency > 500 ms, packet loss > 30%, signal shadow zones, radio channel congestion). */
                id = "SYS-SCEN-005a";
                text = "V2X degradation scenarios (latency, packet loss, shadow zones) must be included.";
                attribute v2xDegradationScenariosIncluded : Boolean;
                require constraint { v2xDegradationScenariosIncluded == true }
            }

            requirement def V2X_CybersecurityTestScenarios {
                doc /* SYS-SCEN-005b: The system shall be subjected to cybersecurity test scenarios to verify resilience against data spoofing and network flooding (jamming/DoS), in accordance with ISO/SAE 21434. */
                id = "SYS-SCEN-005b";
                text = "Cybersecurity test scenarios (spoofing, jamming) shall be executed.";
                attribute cybersecurityScenariosExecuted : Boolean;
                require constraint { cybersecurityScenariosExecuted == true }
            }

            // SYS-CYB-001: V2X message authentication (ETSI ITS 103 097)
            requirement def V2xMessageAuthentication {
                doc /* SYS-CYB-001: All V2X messages (V2V and V2I) must be authenticated using a digital signature mechanism compliant with ETSI ITS 103 097 to ensure data integrity and authenticity. */
                id = "SYS-CYB-001";
                text = "All V2X messages shall be authenticated via ETSI ITS 103 097 digital signatures.";
                attribute allV2xMessagesAuthenticated : Boolean;
                require constraint { allV2xMessagesAuthenticated == true }
            }

            // SYS-CYB-002: Sender certificate validation
            requirement def CertificateValidation {
                doc /* SYS-CYB-002: The system must verify the validity of the sender's digital certificate for each received message, discarding messages with expired or revoked certificates. */
                id = "SYS-CYB-002";
                text = "Every received message shall have its sender certificate validated; expired/revoked ones rejected.";
                attribute invalidCertMessagesAccepted : Boolean;
                require constraint { invalidCertMessagesAccepted == false }
            }

            // SYS-CYB-003: Sensitive data encryption (AES-256)
            requirement def SensitiveDataEncryption {
                doc /* SYS-CYB-003: The system must encrypt sensitive data (future position, planned trajectory) in CAM and DENM using AES-256. */
                id = "SYS-CYB-003";
                text = "Sensitive payload fields shall be AES-256 encrypted.";
                attribute sensitiveDataEncrypted : Boolean;
                require constraint { sensitiveDataEncrypted == true }
            }

            // SYS-CYB-004: Intrusion detection, logging, tamper-proof log
            requirement def IntrusionDetectionAndLogging {
                doc /* SYS-CYB-004: The system must detect and log any intrusion, replay attack, or manipulation of V2X messages within 10 ms. The security log must be tamper-proof. */
                id = "SYS-CYB-004";
                text = "Intrusions shall be detected and logged within 10 ms; log must be tamper-proof.";
                attribute intrusionEventOccurred : Boolean;
                attribute detectionAndLogLatency : Real; // ms
                attribute maxLogLatency : Real = 10.0; // ms
                attribute logTampered : Boolean;
                require constraint {
                    intrusionEventOccurred implies ((detectionAndLogLatency <= maxLogLatency) and not logTampered)
                }
            }

            // SYS-CYB-005: Security monitor for message frequency
            requirement def MessageFrequencyMonitoring {
                doc /* SYS-CYB-005: The system must implement a Security Monitor that verifies the message arrival frequency and raises an alarm if the deviation exceeds 20% of the nominal value. */
                id = "SYS-CYB-005";
                text = "Security monitor shall raise alarm if message frequency deviates >20%.";
                attribute messageFrequencyDeviationPercent : Real;
                attribute alarmThresholdPercent : Real = 20.0;
                attribute securityAlarmRaised : Boolean;
                require constraint {
                    (messageFrequencyDeviationPercent > alarmThresholdPercent) implies securityAlarmRaised
                }
            }

            // SYS-CYB-006: Software updates via SUMS (UNECE R156)
            requirement def SoftwareUpdateManagement {
                doc /* SYS-CYB-006: Every software update must be distributed and authenticated via a SUMS compliant with UNECE R156. Updates allowed only stationary with parking brake, except critical security patches which need explicit driver confirmation. */
                id = "SYS-CYB-006";
                text = "Updates shall be managed via SUMS; installation conditions enforced.";
                attribute updateProcessSUMSCompliant : Boolean;
                attribute updateInstallationConditionsSatisfied : Boolean;
                require constraint {
                    updateProcessSUMSCompliant and updateInstallationConditionsSatisfied
                }
            }

            // SYS-CYB-007: Defense in depth (≥2 layers)
            requirement def DefenseInDepth {
                doc /* SYS-CYB-007: The system must support a defense in depth approach with at least two independent layers of protection for V2X communications. */
                id = "SYS-CYB-007";
                text = "At least two independent protection layers shall be active.";
                attribute independentProtectionLayers : Integer;
                require constraint { independentProtectionLayers >= 2 }
            }

            // SYS-CYB-008: Personal data privacy (no clear transmission, pseudonymization)
            requirement def PersonalDataProtection {
                doc /* SYS-CYB-008: User personal data must not be transmitted in clear and must be pseudonymized when used for third-party services. */
                id = "SYS-CYB-008";
                text = "Personal data shall not be transmitted in clear; shall be pseudonymized.";
                attribute personalDataTransmittedInClear : Boolean;
                attribute personalDataPseudonymized : Boolean;
                require constraint {
                    personalDataTransmittedInClear == false and personalDataPseudonymized == true
                }
            }

            // SYS-CYB-009: Automatic fallback to onboard sensors on confirmed cyber-attack
            requirement def CyberAttackFallback {
                doc /* SYS-CYB-009: A confirmed cyber-attack compromising V2V communication must automatically trigger fallback to onboard sensor mode (Fail-Degraded) within 500 ms. */
                id = "SYS-CYB-009";
                text = "Confirmed cyber-attack shall trigger fallback to onboard sensors within 500 ms.";
                attribute cyberAttackConfirmed : Boolean;
                attribute fallbackTime : Real; // ms
                attribute maxFallbackTime : Real = 500.0; // ms
                attribute fallbackToOnboardSensorsActivated : Boolean;
                require constraint {
                    cyberAttackConfirmed implies (fallbackTime <= maxFallbackTime and fallbackToOnboardSensorsActivated)
                }
            }

            // SYS-OPR-001: V2V signal loss for > 500 ms → disable CACC, inform driver, transition to passive within 100 ms
            requirement def V2vSignalLossFallback {
                doc /* SYS-OPR-001: If the V2V signal is lost for more than 500 ms, the system shall disable CACC control, notify the driver (or higher‑level Vehicle Control), and transition to a passive state (yield control to onboard sensors) within 100 ms. */
                id = "SYS-OPR-001";
                text = "On V2V signal loss > 500 ms, disable CACC and transition to passive within 100 ms.";
                attribute v2vSignalLostDuration : Real; // ms
                attribute lossTimeout : Real = 500.0; // ms
                attribute caccDisabled : Boolean;
                attribute driverNotified : Boolean;
                attribute transitionToPassiveTime : Real; // ms from loss detection
                attribute maxTransitionTime : Real = 100.0; // ms
                require constraint {
                    (v2vSignalLostDuration > lossTimeout) implies
                    (caccDisabled and driverNotified and transitionToPassiveTime <= maxTransitionTime)
                }
            }

            // SYS-OPR-002: V2V signal restored within 5 s + data validation → CACC re‑enabled with 2 s smooth transition
            requirement def V2vSignalRestoreAndReactivation {
                doc /* SYS-OPR-002: If the V2V signal is restored within 5 s and data validation is positive, the system may re‑enable CACC mode with a gradual 2‑second transition. */
                id = "SYS-OPR-002";
                text = "If V2V signal recovered within 5 s and data valid, reactivate CACC with 2 s smooth transition.";
                attribute v2vSignalRecovered : Boolean;
                attribute recoveryWindow : Real = 5.0; // s
                attribute dataValidationPositive : Boolean;
                attribute caccReactivationAllowed : Boolean;
                attribute reactivationSmoothTime : Real; // s
                attribute requiredSmoothTime : Real = 2.0; // s
                require constraint {
                    (v2vSignalRecovered and dataValidationPositive) implies
                    (caccReactivationAllowed and reactivationSmoothTime >= requiredSmoothTime)
                }
            }

            // SYS-OPR-003: Message fragmentation > 15% in 1 s → activate signal reconstruction; if persists > 3 s → trigger SYS-OPR-001
            requirement def MessageFragmentationHandling {
                doc /* SYS-OPR-003: When message fragmentation exceeds 15% within a 1‑second window, the system shall activate a signal reconstruction algorithm. If fragmentation persists for more than 3 s, apply SYS-OPR-001. */
                id = "SYS-OPR-003";
                text = "Fragmentation > 15% in 1 s → reconstruct; if persistent > 3 s → fallback as OPR-001.";
                attribute fragmentationRate : Real; // % in last 1 s window
                attribute fragmentationThreshold : Real = 15.0; // %
                attribute reconstructionActive : Boolean;
                attribute fragmentationPersistentDuration : Real; // s
                attribute persistenceLimit : Real = 3.0; // s
                attribute fallbackToOPR001Triggered : Boolean;
                require constraint {
                    (fragmentationRate > fragmentationThreshold implies reconstructionActive) and
                    ((reconstructionActive and fragmentationPersistentDuration > persistenceLimit) implies fallbackToOPR001Triggered)
                }
            }

            // SYS-OPR-004: V2I communication failure → disable V2I functions, use map data for speed limits, proceed with car‑following
            requirement def V2iFailureFallback {
                doc /* SYS-OPR-004: Upon a V2I communication failure, all V2I functions shall be safely disabled. The system shall rely on map data to retrieve necessary information (e.g., speed limits) and continue with car‑following. */
                id = "SYS-OPR-004";
                text = "On V2I failure, disable V2I functions and use map data for speed limits.";
                attribute v2iCommunicationFailed : Boolean;
                attribute v2iFunctionsDisabledSafely : Boolean;
                attribute mapBasedDataUsed : Boolean;
                attribute carFollowingActive : Boolean;
                require constraint {
                    v2iCommunicationFailed implies (v2iFunctionsDisabledSafely and mapBasedDataUsed and carFollowingActive)
                }
            }

            // SYS-OPR-005: GLOSA failure or missing traffic light signal → revert to standard car‑following within safety constraints
            requirement def GLOSAFailureRecovery {
                doc /* SYS-OPR-005: In case of GLOSA failure or missing traffic light signal, the system shall revert to standard car‑following while respecting safety constraints. */
                id = "SYS-OPR-005";
                text = "On GLOSA failure, revert to standard car‑following within safety constraints.";
                attribute glosaFailure : Boolean;
                attribute standardCarFollowingResumed : Boolean;
                attribute safetyConstraintsSatisfied : Boolean;
                require constraint {
                    glosaFailure implies (standardCarFollowingResumed and safetyConstraintsSatisfied)
                }
            }

            // SYS-OPR-006: Internal heartbeat monitoring → detect failure of critical modules, activate fail‑safe mode within 200 ms
            requirement def HeartbeatMonitoring {
                doc /* SYS-OPR-006: The system shall implement an internal heartbeat mechanism to monitor the health of all critical software modules. A detected failure shall activate the appropriate fail‑safe mode within 200 ms. */
                id = "SYS-OPR-006";
                text = "Heartbeat monitoring: on critical module failure, fail‑safe within 200 ms.";
                attribute heartbeatFailureDetected : Boolean;
                attribute failSafeActivationTime : Real; // ms
                attribute maxFailSafeTime : Real = 200.0; // ms
                attribute failSafeModeActivated : Boolean;
                require constraint {
                    heartbeatFailureDetected implies (failSafeModeActivated and failSafeActivationTime <= maxFailSafeTime)
                }
            }

            // SYS-OPR-007: Fail‑safe architecture; on internal critical fault, stop sending parameters to actuation model within FTTI
            requirement def FailSafeArchitecture {
                doc /* SYS-OPR-007: The V2X system shall operate under a Fail‑Safe architecture. Upon a critical internal fault, it shall stop sending actuation parameters within the Fault Tolerant Time Interval (FTTI), ensuring a safe disengagement. */
                id = "SYS-OPR-007";
                text = "Fail‑Safe architecture: cease actuation commands within FTTI on critical fault.";
                attribute criticalInternalFault : Boolean;
                attribute ftti : Real; // ms, Fault Tolerant Time Interval (attribute of system)
                attribute actuationCommandStopped : Boolean;
                attribute commandStopTime : Real; // ms from fault
                require constraint {
                    criticalInternalFault implies (actuationCommandStopped and commandStopTime <= ftti)
                }
            }

            // ==================== Performance Requirements ====================
            requirement def V2V_SafetyEndToEndLatency {
                doc /* SYS-PERF-001: End-to-end latency for safety V2V communication (CAM) must be less than 100 ms. */
                id = "SYS-PERF-001";
                text = "V2V safety end-to-end latency shall be < 100 ms.";
                attribute actualV2vLatency : Real; // ms
                attribute maxAllowedLatency : Real = 100.0; // ms
                require constraint { actualV2vLatency <= maxAllowedLatency }
            }

            requirement def V2I_SafetyEndToEndLatency {
                doc /* SYS-PERF-002: End-to-end latency for safety V2I communication (SPaT, DENM) must be less than 200 ms. */
                id = "SYS-PERF-002";
                text = "V2I safety end-to-end latency shall be < 200 ms.";
                attribute actualV2iLatency : Real; // ms
                attribute maxAllowedLatency : Real = 200.0; // ms
                require constraint { actualV2iLatency <= maxAllowedLatency }
            }

            requirement def CAM_MinimumUpdateRate {
                doc /* SYS-PERF-003: The guaranteed minimum update rate for CAM messages must be 10 Hz. */
                id = "SYS-PERF-003";
                text = "CAM update rate shall be ≥ 10 Hz.";
                attribute actualUpdateRate : Real; // Hz
                attribute minRequiredRate : Real = 10.0; // Hz
                require constraint { actualUpdateRate >= minRequiredRate }
            }

            requirement def SafetyDistanceEstimationAccuracy {
                doc /* SYS-PERF-004: The safety distance estimation accuracy shall be ±3 m for speeds below 50 km/h and ±2 % for speeds above 50 km/h. */
                id = "SYS-PERF-004";
                text = "Distance estimation error ≤ 3 m (speed <50 km/h) or ≤ 2% (speed ≥ 50 km/h).";
                attribute speed : Real; // km/h
                attribute absoluteErrorLowSpeed : Real; // m (absolute value)
                attribute relativeErrorHighSpeedPercent : Real; // % (absolute relative error)
                require constraint {
                    if speed < 50.0 then
                        abs(absoluteErrorLowSpeed) <= 3.0
                    else
                        relativeErrorHighSpeedPercent <= 2.0
                }
            }

            requirement def GLOSA_ComputationTime {
                doc /* SYS-PERF-005: The GLOSA computation time must be less than 50 ms. */
                id = "SYS-PERF-005";
                text = "GLOSA computation shall complete in < 50 ms.";
                attribute actualGlosaComputationTime : Real; // ms
                attribute maxAllowedTime : Real = 50.0; // ms
                require constraint { actualGlosaComputationTime <= maxAllowedTime }
            }

            // ==================== Process Requirements (ASPICE v4.0) ====================
            requirement def RequirementsTraceability {
                doc /* SYS-PROC-001: Requirements shall be traced to original stakeholder needs (SYS.2.BP6) and linked to verification criteria and test cases (SYS.2.BP5, SYS.4.BP5). */
                id = "SYS-PROC-001";
                text = "Requirements shall be fully traced to stakeholder needs and test cases.";
                attribute traceabilityEstablished : Boolean;
                require constraint { traceabilityEstablished == true }
            }

            requirement def RequirementsReview {
                doc /* SYS-PROC-002: Requirements shall be reviewed to ensure completeness, unambiguity, and testability (SYS.2.BP3, SUP.4). */
                id = "SYS-PROC-002";
                text = "Each requirement shall be reviewed for completeness, unambiguity, and testability.";
                attribute allRequirementsReviewed : Boolean;
                require constraint { allRequirementsReviewed == true }
            }

            requirement def ExternalInterfaceSpecification {
                doc /* SYS-PROC-003: External system interfaces (V2V/V2I communication bus, HMI, GNSS/IMU) must be formally specified, including safety and cybersecurity properties. */
                id = "SYS-PROC-003";
                text = "External interfaces shall be formally specified with safety and cybersecurity attributes.";
                attribute interfacesFormallySpecified : Boolean;
                require constraint { interfacesFormallySpecified == true }
            }

            requirement def SafetyCaseDevelopment {
                doc /* SYS-PROC-004: A Safety Case according to UL 4600 shall be developed, including risk analysis, SOTIF validation, and demonstration of robust degraded operations. */
                id = "SYS-PROC-004";
                text = "A UL 4600 Safety Case shall be developed, covering risk, SOTIF, and degraded ops.";
                attribute safetyCaseDeveloped : Boolean;
                require constraint { safetyCaseDeveloped == true }
            }

            requirement def TARA_Conduction {
                doc /* SYS-PROC-005: A TARA (Threat Analysis and Risk Assessment) shall be conducted for all V2X interfaces, producing traceable cybersecurity requirements (ISO/SAE 21434 §15). */
                id = "SYS-PROC-005";
                text = "A TARA shall be performed for all V2X interfaces, yielding traceable cybersecurity requirements.";
                attribute taraConducted : Boolean;
                attribute cyberReqsTraceable : Boolean;
                require constraint { taraConducted and cyberReqsTraceable }
            }

            requirement def ScenarioCatalogDefinition {
                doc /* SYS-PROC-006: The development process shall include definition and validation of a safety scenario catalog conforming to ISO 34502, with documented ODD coverage. */
                id = "SYS-PROC-006";
                text = "A validated scenario catalog per ISO 34502 with documented ODD coverage shall be established.";
                attribute scenarioCatalogValidated : Boolean;
                attribute oddCoverageDocumented : Boolean;
                require constraint { scenarioCatalogValidated and oddCoverageDocumented }
            }
        }

        package InputGatewayRequirements {
        // ---- Requisiti di ricezione e validazione ----
        requirement def MessageReception {
            doc /* All V2X messages shall be received and decoded through the designated Access Layer interfaces (ITS-G5 / C-V2X PC5) and Facilities layer protocols. */
            id = "IGW-REQ-001";
            text = "All V2X messages shall be received and decoded through the designated Access Layer interfaces (ITS-G5 / C-V2X PC5) and Facilities layer protocols.";
            attribute camReceived : Boolean;
            attribute mcmReceived : Boolean;
            attribute spatReceived : Boolean;
            attribute mapReceived : Boolean;
            attribute ivsReceived : Boolean;
            attribute denmReceived : Boolean;
            attribute evaReceived : Boolean;
            attribute vruReceived : Boolean;
            attribute cpmReceived : Boolean;
        }

        requirement def TemporalSpatialValidation {
            doc /* Each message must pass freshness check (data age ≤ limit) and spatial consistency (distance from GNSS position ≤ tolerance). */
            id = "IGW-REQ-002";
            text = "Each message shall pass temporal validation against its specific message-type validity duration (e.g., dynamic for CAM, payload-defined for DENM/MAP) and spatial validation against the host vehicle's current GNSS covariance.";
            attribute messageType : String;      // tipo messaggio
            attribute dataAge : Real;            // ms
            attribute maxAllowedDataAge : Real;  // ms
            attribute spatialCoherenceOk : Boolean;
            require constraint {
                dataAge <= maxAllowedDataAge and spatialCoherenceOk
            }
        }

        requirement def ConfidenceLevelFilter {
            doc /* DENM messages shall be evaluated against standardized ETSI confidence values (e.g., PositionConfidenceEllipse). Messages exceeding the maximum uncertainty radius (e.g., > 5 meters) shall be flagged as 'Low-Confidence' for downstream sensor fusion, rather than dropped. */
            id = "IGW-REQ-003";
            text = "DENM messages shall be evaluated against standardized ETSI confidence values (e.g., PositionConfidenceEllipse). Messages exceeding the maximum uncertainty radius (e.g., > 5 meters) shall be flagged as 'Low-Confidence' for downstream sensor fusion, rather than dropped.";
            attribute denmPositionConfidence : Real; // 0-100
            attribute denmSpeedConfidence : Real;
            attribute minConfidenceThreshold : Real; // 50.0
            attribute denmAccepted : Boolean;
            require constraint {
                denmPositionConfidence >= minConfidenceThreshold and
                denmSpeedConfidence >= minConfidenceThreshold implies denmAccepted
            }
        }

        // ---- Requisiti di integrità del segnale ----
        requirement def SignalLossDetection {
            doc /* V2V signal loss shall be detected when no valid CAM is received from a previously tracked vehicle for > 1500 ms, or global channel loss if no V2V energy is detected for > 3000 ms. */
            id = "IGW-REQ-004";
            text = "V2V signal loss shall be detected when no valid CAM is received from a previously tracked vehicle for > 1500 ms, or global channel loss if no V2V energy is detected for > 3000 ms.";
            attribute lastValidCamTimestamp : Real; // ms
            attribute now : Real;
            attribute lossTimeout : Real; // 500.0
            attribute v2vLost : Boolean;
            require constraint { (now - lastValidCamTimestamp) > lossTimeout implies v2vLost }
        }

        requirement def FragmentationMonitoring {
            doc /* The gateway shall monitor the Packet Error Rate (PER) and Channel Busy Ratio (CBR). If CBR exceeds the Decentralized Congestion Control (DCC) threshold (e.g., 60%), packet generation shall be restricted according to ETSI TS 103 141. */
            id = "IGW-REQ-005";
            text = "The gateway shall monitor the Packet Error Rate (PER) and Channel Busy Ratio (CBR). If CBR exceeds the Decentralized Congestion Control (DCC) threshold (e.g., 60%), packet generation shall be restricted according to ETSI TS 103 141.";
            attribute fragmentationRate : Real; // %
            attribute fragmentationThreshold : Real; // 15.0
            attribute reconstructionActive : Boolean;
            attribute persistenceDuration : Real; // s
            attribute persistenceLimit : Real = 3.0;
            attribute fallbackRequested : Boolean;
            require constraint {
                fragmentationRate > fragmentationThreshold implies reconstructionActive;
                (reconstructionActive and persistenceDuration > persistenceLimit) implies fallbackRequested
            }
        }

        // ---- Requisito di performance ----
        requirement def ValidationLatency {
            doc /* The entire validation process (reception → validated data available) must be completed within 20 ms for V2V messages and 50 ms for V2I messages. */
            id = "IGW-REQ-006";
            text = "Validation latency shall not exceed 20 ms for V2V and 50 ms for V2I.";
            attribute actualV2VLatency : Real;
            attribute actualV2ILatency : Real;
            attribute maxV2VLatency : Real = 20.0;
            attribute maxV2ILatency : Real = 50.0;
            require constraint {
                actualV2VLatency <= maxV2VLatency and actualV2ILatency <= maxV2ILatency
            }
        }
        }

        package CAMComposerRequirements {
            // ---- Requisiti del CAM Composer ----

            requirement def EgoStateReception {
                doc /* The CAM Composer shall continuously receive and validate the ego vehicle state (position, speed, heading, acceleration) from the internal bus. */
                id = "CAM-REQ-001";
                text = "The CAM Composer shall receive valid ego vehicle state data.";
                attribute egoStateReceived : Boolean;
                attribute dataIntegrityOk : Boolean;
                
                require constraint { 
                    // L'accettazione dello stato dipende dall'effettiva ricezione e dall'integrità
                    egoStateReceived and dataIntegrityOk 
                }
            }

            requirement def TriggerOnStateChange {
                doc /* A trigger shall be generated according to ETSI EN 302 637-2 rules: distance > 4m, speed variation > 0.5 m/s, or heading > 4°. */
                id = "CAM-REQ-002";
                text = "A CAM trigger shall be generated strictly on standardized dynamic ego state changes.";
                attribute deltaDistance : Real;     // m
                attribute deltaSpeed : Real;        // m/s
                attribute deltaHeading : Real;      // gradi
                attribute triggerGenerated : Boolean;
                
                require constraint {
                    // L'operatore == assicura che il trigger avvenga SE E SOLO SE si supera almeno una soglia
                    triggerGenerated == (deltaDistance > 4.0 or abs(deltaSpeed) > 0.5 or abs(deltaHeading) > 4.0)
                }
            }

            requirement def CAM_Composition {
                doc /* A valid CAM shall be composed upon trigger, containing the Basic Container and High Frequency Container (stationID, lat, lon, speed, heading, acceleration, timestamp). */
                id = "CAM-REQ-003";
                text = "A valid CAM shall be composed synchronously upon receiving a trigger.";
                attribute triggerReceived : Boolean;
                attribute camComposed : Boolean;
                attribute mandatoryFieldsPopulated : Boolean;
                
                require constraint { 
                    // La composizione è strettamente legata alla presenza del trigger e alla validità dei campi
                    camComposed == (triggerReceived and mandatoryFieldsPopulated)
                }
            }

            requirement def CAM_TransmissionRate {
                doc /* The CAM generation rate shall be dynamic, adhering to ETSI standards: bounded between 1 Hz (T_GenCamMax) and 10 Hz (T_GenCamMin), subject to DCC limits. */
                id = "CAM-REQ-004";
                text = "CAM dynamic transmission rate shall remain strictly between 1 Hz and 10 Hz.";
                attribute actualTransmissionRate : Real; // Hz
                attribute minRate : Real = 1.0;          // Veicolo in marcia lineare/fermo
                attribute maxRate : Real = 10.0;         // Veicolo in forte dinamica
                
                require constraint { 
                    actualTransmissionRate >= minRate and actualTransmissionRate <= maxRate
                }
            }

            requirement def SampleHoldBehavior {
                doc /* On the software interface layer, the output buffer shall hold the last valid CAM structure until overwritten by a newly composed CAM. */
                id = "CAM-REQ-005";
                text = "The output interface shall hold the last valid CAM data between triggers.";
                attribute newCamComposed : Boolean;
                attribute bufferUpdated : Boolean;
                attribute previousCamRetained : Boolean;
                
                require constraint {
                    // Vincolo che definisce un comportamento mutually exclusive
                    (newCamComposed implies bufferUpdated) and 
                    (not newCamComposed implies previousCamRetained)
                }
            }
        }

        package ElaborationRequirements {
            // ---- Requisiti dell'Elaboration ----

            requirement def ValidatedDataReception {
                doc /* The Elaboration shall receive validated V2X data on its input ports. */
                id = "ELB-REQ-001";
                text = "The Elaboration shall receive validated V2X data on its input ports.";
                attribute v2vDataPresent : Boolean;
                attribute v2iDataPresent : Boolean;
                require constraint { v2vDataPresent or v2iDataPresent }
            }

            requirement def FollowingParametersComputation {
                doc /* From the validated V2X data, the car‑following parameters shall be computed using the selected model, respecting the leader vehicle profile and string‑stability constraints. */
                id = "ELB-REQ-002";
                text = "Car‑following parameters shall be computed from V2X data.";
                attribute followingParamsReady : Boolean;
                attribute leaderProfileUsed : Boolean;
                attribute stringStabilityConsidered : Boolean;
                require constraint { followingParamsReady and leaderProfileUsed and stringStabilityConsidered }
            }

            requirement def InfrastructureBasedAdaptation {
                doc /* When valid V2I data is available, the system shall adapt its working (GLOSA, cut-in request, emergency vehicle, wrong-way, ecc). */
                id = "ELB-REQ-003";
                text = "The elaboration shall adapt its functioning based on Infrastructure's messages.";
                attribute v2iAvailable : Boolean;
                attribute glosaApplied : Boolean;
                attribute speedLimitEnforced : Boolean;
                require constraint { v2iAvailable implies (glosaApplied and speedLimitEnforced) }
            }

            requirement def ManeuverPrioritization {
                doc /* In the presence of multiple simultaneous events (cut‑in, wrong‑way vehicle, pedestrian alert, etc.) the highest‑priority safety‑critical action shall be selected and translated into control parameters. */
                id = "ELB-REQ-004";
                text = "In the presense of multiple simultaneous events, the system need to prioritize the most critical/satefy related.";
                attribute conflictingEvents : Boolean;
                attribute selectedManeuver : String; // "emergencyBrake" | "evasion" | "caution" | "normal"
                attribute controlParametersGenerated : Boolean;
                require constraint { conflictingEvents implies (selectedManeuver != "normal" and controlParametersGenerated) }
            }

            requirement def MonitoringOutput {
                doc /* Current status, selected maneuver, and critical parameters shall be exposed on the monitoring output for HMI and safety‑case logging. */
                id = "ELB-REQ-005";
                text = "The system shall produce monitoring data continuously.";
                attribute monitoringStreamActive : Boolean;
                require constraint { monitoringStreamActive == true }
            }

            requirement def ComputationLatency {
                doc /* The whole elaboration cycle shall complete in less than 20 ms. */
                id = "ELB-REQ-006";
                text = "Elaboration cycle time < 20 ms.";
                attribute cycleTime : Real; // ms
                attribute maxCycleTime : Real = 20.0;
                require constraint { cycleTime <= maxCycleTime }
            }
        }

        package OutputGatewayRequirements {
            // ---- Requisiti dell'OutputGateway ----

            requirement def ControlParametersForwarding {
                doc /* The OutputGateway shall forward the control parameters received from the Elaboration to the vehicle bus without modification. */
                id = "OGW-REQ-001";
                text = "Control parameters shall be forwarded to the output vehicle bus without modification.";
                attribute controlReceived : Boolean;
                attribute controlForwarded : Boolean;
                require constraint { controlReceived implies controlForwarded }
            }

            requirement def CAM_Forwarding {
                doc /* The CAM received from the CAM Composer shall be forwarded to the V2V communication port without modification. */
                id = "OGW-REQ-002";
                text = "CAM shall be forwarded to the V2V port without modification.";
                attribute camReceived : Boolean;
                attribute camForwarded : Boolean;
                require constraint { camReceived implies camForwarded }
            }

            requirement def MonitoringForwarding {
                doc /* The monitoring data received from the Elaboration shall be forwarded to the HMI port. */
                id = "OGW-REQ-003";
                text = "Monitoring data shall be forwarded to HMI port.";
                attribute monitoringReceived : Boolean;
                attribute monitoringForwarded : Boolean;
                require constraint { monitoringReceived implies monitoringForwarded }
            }

            requirement def PlatooningInfoForwarding {
                doc /* Platooning information received on the input port shall be forwarded unchanged to the output port. */
                id = "OGW-REQ-004";
                text = "Platooning info shall be forwarded unchanged.";
                attribute platooningReceived : Boolean;
                attribute platooningForwarded : Boolean;
                require constraint { platooningReceived implies platooningForwarded }
            }

            requirement def PlatooningInfoControl{
                doc /* The platooning information received on the input port shall control the other output based on its value (0 = no platooning (no CAM and no model parameters), 1 = platooning active (CAM and model parameters present)). */
                id = "OGW-REQ-005";
                text = "Platooning info shall control the other output based on its value (0 = no platooning (no CAM and no model parameters), 1 = platooning active (CAM and model parameters present)).";
            }

            requirement def ForwardingLatency {
                doc /* The forwarding latency for each data stream shall not exceed 5 ms. */
                id = "OGW-REQ-006";
                text = "Forwarding latency shall be ≤ 5 ms for all streams.";
                attribute actualControlLatency : Real;   // ms
                attribute actualCAM_Latency : Real;
                attribute actualMonitoringLatency : Real;
                attribute maxLatency : Real = 5.0;
                require constraint {
                    actualControlLatency <= maxLatency and
                    actualCAM_Latency <= maxLatency and
                    actualMonitoringLatency <= maxLatency
                }
            }
        }
    }

    


    library package Use_Case_Definitions{
        doc /* This package defines the use cases for car-following project. */
        
        part def Interactor{
            doc /* The interactor is a general actor that represents any entity that interacts with the system, such as vehicles, pedestrians, or infrastructure. */
            
            action sendData;
        }

        part def Vehicle:> Interactor{
            doc /* The vehicle actor represents any type of vehicle that interacts with the system, including both the ego vehicle and other vehicles on the road. */
        }

        part def Infrastructure:> Interactor{
            doc /* The infrastructure actor represents any roadside infrastructure that interacts with the system, such as traffic lights, road signs, or V2X communication units. */
        }

        part def Person:> Interactor{
            doc /* The person actor represents any individual technology that interacts with the system, such as smartphone, smarwatch or GPS devices. */
        }

        part def CloudService:> Interactor{
            doc /* The cloud service actor represents any remote service that interacts with the system, such as a traffic management system or a data analytics platform. */
        }

        part def CarFollowingModel{
            doc /* The car-following model represents the internal logic of the system that determines how the vehicle should adjust its speed and trajectory based on the received data and the behavior of surrounding vehicles. */
        }

        part def CarFollowingModel{
            doc /* The car-following model represents the internal logic of the system that determines how the vehicle should adjust its speed and trajectory based on the received data and the behavior of surrounding vehicles. */
        }

        item def Signals{
            doc /* The signals represent the various types of data that the system receives and processes, including V2X data, sensor data, and environmental data. */
        }

        item def V2VSignals:> Signals{
            doc /* The V2V signals represent the data received from other vehicles, which may include information about their speed, position, and behavior. */
        }

        item def V2ISignals:> Signals{
            doc /* The V2I signals represent the data received from the infrastructure, which may include information about traffic light status, road conditions, and other relevant factors. */
        }
        

        /* ===================================================================
            * USE CASE DEFINITIONS
        * =================================================================== */
        use case def UC0_SystemUseCases{
            objective{
                doc /* This use case represents the overall system use cases, which include various interactions with other vehicles, infrastructure, and external services. */
            }
        }


        use case def UC1_CACC_Synchronization{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor leader_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor leader_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for synchronizing the vehicle's trend with the following vehicle, based on the received V2V data. */
            }                   
        }

        use case def UC2_AbruptCutIn{
            subject System : Parts::Part{
                action inMex;
                action outMex;
            }
            actor car_following_model{
                action inMex;
                action outMex;
            }
            actor infrastructure{
                action inMex;
                action outMex;
            }
            subject System : Parts::Part{
                action inMex;
                action outMex;
            }
            actor car_following_model{
                action inMex;
                action outMex;
            }
            actor infrastructure{
                action inMex;
                action outMex;
            }
            objective{
                doc /* Use case for managing abrupt cut-in maneuvers from other vehicles, by adjusting the speed and trajectory of the vehicle to maintain safety. */
            }    
        }

        use case def UC3_CalledCutIn{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor lateral_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor lateral_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for managing called cut-in maneuvers from other vehicles, by adjusting the speed and trajectory of the vehicle to maintain safety. */
            }
        }

        use case def UC4_Shockwave_Mitigation{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor leader_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for mitigating shockwaves in traffic flow, by adjusting the speed of the vehicle based on the behavior of the following vehicle and the received V2V data. */
            }
        }

        use case def UC5_AdaptingFollowing{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor leader_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor leader_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for adapting the vehicle's following behavior based on the classification of the following vehicle, to enhance safety and comfort. */
            }
        }

        use case def UC6_CrossroadAdaptation{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for adapting the vehicle's trend at crossroads, considering the behavior of surrounding vehicles and traffic conditions (taken from V2V and V2I signals (SPaT)). */
            }
        }

        use case def UC7_SpeedLimitsAdaptation{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for adjusting the vehicle's speed based on speed limits received from V2I communication, to enhance safety and comply with traffic regulations. */
            }
        }

        use case def UC8_RoadHazardWarning{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for responding to road hazard warnings received from V2I communication, by adjusting the speed and trajectory of the vehicle to maintain safety. */
            }
        }

        use case def UC9_RoadConditionWarning{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for responding to road condition warnings received from V2I communication, by adjusting the speed and trajectory of the vehicle to maintain safety. */
            }
        }

        use case def UC10_SignalViolationProtection{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor criminal_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor criminal_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for protecting against signal violations at intersections, by adjusting the speed and trajectory of the vehicle based on traffic light status received from V2I communication. */
            }
        }

        use case def UC11_WrongWayDriverProtection{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for protecting against wrong-way drivers, by adjusting the speed and trajectory of the vehicle based on warnings received from V2I communication. */
            }
        }

        use case def UC12_SpecialVehicle{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor special_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor special_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for responding to special vehicle warnings received from V2I communication, by adjusting the speed and trajectory of the vehicle to maintain safety. */
            }
        }

        use case def UC13_PedestrianProtection{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor infrastructure{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for protecting pedestrians, by adjusting the speed and trajectory of the vehicle based on warnings received from V2I communication or detected by the vehicle's sensors. */
            }
        }

        use case def UC14_DegradedSignalManagement{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor follower_vehicle{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for managing degraded V2X signal quality, by pass the controll to the local sensor system. */
            }
        }

        use case def UC15_FragmentedSignalManagement{
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor interactor{
                event occurrence inMex;
                event occurrence outMex;
            }
            subject System : Parts::Part{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor car_following_model{
                event occurrence inMex;
                event occurrence outMex;
            }
            actor interactor{
                event occurrence inMex;
                event occurrence outMex;
            }
            objective{
                doc /* Use case for managing fragmented V2X signal quality, by implementing strategies to maintain safe operation even when data are fragmenteted. */
            }
        }

    }


    // QUI SOTTO è SBAGLIATO (CORREGGERE)
    library package Interfaces {
        item def V2X_Payload {
            doc /* The payload structure for V2X communication, which includes relevant information about the leader vehicle. */
            attribute leader_velocity : ScalarValues::Real;
            attribute leader_position : ScalarValues::Real;
        }
        
        port def V2X_ReceiverPort {
            doc /* A port for receiving V2X data from the leader vehicle, which will be used for decision-making in the system. */
            in item payload : V2X_Payload;
        }
    }


    library package Stakeholders_Definitions {
        doc /* Stakeholder and team member definitions for StakeholderView. */
        item def Stakeholder {
            doc /* The Stakeholder item represents an individual or organization with an interest in the project, including their contact information and role. */
            attribute fullName     : ScalarValues::String;
            attribute role         : ScalarValues::String;
            attribute email        : ScalarValues::String;
            attribute organization : ScalarValues::String;
            attribute phone        : ScalarValues::String;
            attribute linkedinUrl  : ScalarValues::String;
            attribute teamsUrl     : ScalarValues::String;
        }
        item def TeamMember {
            doc /* The TeamMember item represents an individual team member working on the project, including their contact information and role. */
            attribute fullName    : ScalarValues::String;
            attribute role        : ScalarValues::String;
            attribute email       : ScalarValues::String;
            attribute team        : ScalarValues::String;
            attribute phone       : ScalarValues::String;
            attribute linkedinUrl : ScalarValues::String;
            attribute teamsUrl    : ScalarValues::String;
        }
    }


    library package Tool_Definitions {
        doc /* SoftwareTool definition for ToolView. */
        item def SoftwareTool {
            doc /* The SoftwareTool item represents a software tool used in the project, including its name, version, and vendor information. */
            attribute toolName    : ScalarValues::String;
            attribute version     : ScalarValues::String;
            attribute vendor      : ScalarValues::String;
            attribute toolType    : ScalarValues::String;
            attribute scope       : ScalarValues::String;
            attribute license     : ScalarValues::String;
            attribute description : ScalarValues::String;
        }
    }

    library package Viewpoint_Definitions{
        viewpoint def EngineerViewpoint {
            doc /* Viewpoint for engineer visualization.
                * Shows view usefull for specific engineer. Usefull for comprension and implementation (behaviour, use-case, actionflow, stateTransition). */
        }

        viewpoint def StakeholderViewpoint{
            doc /* Viewpoint for stakeholder visualization.
                * Shows information important for the stakeholders. */
        }

        viewpoint def SystemViewpoint :> EngineerViewpoint{
            doc /* Viewpoint for system engineer.
                * Suitable for full understanding:
                * - The overall system architecture and its main components
                * - The interactions between components and how they realize the use cases
                * - The allocation of requirements to system components
                * - The model structure and status. */
        }

        
    }

    library package ViewDefinitions {

        private import ScalarValues::*;

        

        // ══════════════════════════════════════════════════════════════════════
        //  VIEWPOINT DEFINITIONS
        // ══════════════════════════════════════════════════════════════════════

        viewpoint def HardwareViewpoint {
            doc /* Viewpoint for hardware architecture visualization.
                * Filters: Emphasize hardware components and their usage.
                * Suitable for understanding:
                * - The overall hardware architecture weight of the system
                * - The main hardware components and their own resource needs
                * - Performance and reliability characteristics */
        }

        viewpoint def SignalFlowViewpoint {
            doc /* Viewpoint for signal and data flow visualization.
                * Filters: Emphasize ports, interfaces, and data movement.
                * Suitable for understanding:
                * - How signals flow through the system
                * - Port-to-port connections
                * - External interfaces
                * - Latency and throughput characteristics */
        }

        viewpoint def EngineerViewpoint {
            doc /* Viewpoint for system engineering visualization.
                * Shows actors, subject system, use cases and behavioural diagrams
                * with semantic links. */
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VIEW DEFINITIONS
        // ══════════════════════════════════════════════════════════════════════

        view def ResourceUsageView {
            doc /* View for visualizing the resource usage of hardware,
                * showing how components and subsystems utilise available resources. */
        }

        view def UseCaseView {
            doc /* View for actor / use-case visualization.
                * Shows actors, subject system, and use cases with semantic links. */
        }

        view def SequenceView {
            doc /* View for sequence diagram visualization.
                * Renders interaction flows between lifelines. */
        }

        view def RequirementView {
            doc /* View for requirement satisfaction visualization.
                * Shows satisfy-requirement blocks with nested requirements
                * and actual vs required values. */
        }

        view def StakeholderView {
            doc /* Grid view of project stakeholders with contact info and roles. */
        }

        view def NeedView {
            doc /* Bipartite graph: stakeholder needs on the left,
                * satisfying requirements on the right. */
        }

        view def ToolView {
            doc /* Grid view of software tools used in the project. */
        }

        view def VariantView {
            doc /* Tree view of variation definitions and their variant alternatives. */
        }

        view def SequenceGroupView {
            doc /* Aggregator view: gallery of all SequenceView diagrams in a file. */
        }

        view def PackageView {
            doc /* Nested-box treemap of package hierarchy with element counts by type. */
        }

        view def AnalysisView {
            doc /* Aggregator view: groups views by analysis domain for structured review. */
        }

        view def TeamView {
            doc /* Org-chart view of project teams and their members. */
        }

        view def LifecycleView {
            doc /* Timeline view of project lifecycle phases and transitions. */
        }

    }


    
    

    

    
    
    }
}