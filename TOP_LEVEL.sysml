package FPGA_Hardware{
    doc /* FPGA System Definition:
         * This package defines the overall structure where the system will be allocated, with all the main components and their interactions.
         * It serves as the central point for integrating the various subsystem. 
         * */
    private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;
    private import Requirement_Definitions::*;
    private import Attribute_Definitions::*;
    private import Use_Case_Definitions::*;


    private import system_test::*;
    
    /* ===================================================================
        * PART DEFINITIONS
     * =================================================================== */

    interface def SupplyEnergy {
        doc /* Interface for energy supply connections. */
        end supplier : SupplyPort;
        end consumer : ~SupplyPort;
        flow from supplier.supplyOut to consumer.supplyIn;
    }

    interface def DataFlow {
        doc /* Interface for data flow connections. */
        end source : DataPort;
        end sink : ~DataPort;
        flow from source.dataOut to sink.dataIn;
    }

    /* ===================================================================
        * PART DEFINITIONS
     * =================================================================== */
    part def PYNQZ1{
        doc /* The PYNQ-Z1 FPGA board, which serves as the hardware platform for the system. */
        
        /* ===================================================================
            * ATTRIBUTE USAGE
         * =================================================================== */
        attribute clockFrequency: ClockFrequency = 100 [mega*Hz];
        attribute logicElements: LogicElements = 28800;
        attribute dspBlocks: DSPBlocks = 220;
        attribute blockRAM: BlockRAM = 4.9 [mega*B];
        attribute ioPins: IOPins = 100;

        attribute power: Power {
            attribute :>> maxPower = 10 [W];
        }

        attribute voltageCore: VoltageCore = 1.0 [V];

        attribute temperature: Temperature {
            attribute :>> tempMin = -40 [C];
            attribute :>> tempMax = 85 [C];
        }

        attribute performance: Performance {
            attribute :>> maxThroughput = 6 [giga*bit/s];
            attribute :>> latency = 10 [nano*s];
        }

        attribute reconfigurationTime: ReconfigurationTime = 0.5 [s];
        attribute securityFeatures: SecurityFeatures {
            attribute :>> SecureBoot = true;
            attribute :>> BitstreamEncryption = true;
            attribute :>> TamperDetection = true;
        }
        attribute maxAllowedTime : MaxAllowedTime = 1 [milli*s];
        attribute mtbf : MTBF = 300000 [hour];



        part follower : Vehicle{
            event occurrence sendV2V;
        }
        part following : Vehicle{
            event occurrence sendV2V;
        }


        part extraneous : Vehicle;
        part infrastructure : Infrastructure;
        part cloud : CloudService;
        part person : Person;
        part general_interactor : Interactor;
        part cfm : CarFollowingModel;
            

    


        /* ===================================================================
            * PARTE USAGE
         * =================================================================== */
        
        part system : topLevelSystem {
            doc /* The top-level system allocated on the PYNQ-Z1 FPGA board, which integrates the various subsystems. */
            
            /* ===================================================================
		     * PART ALLOCATION (Che non servirebbe, perchè sarà tutto allocato all'interno del blocco)
	         * =================================================================== */        
            part :>> conditioner {
                doc /* Configuration for the Condition Unit */
            }
            part :>> elaborator {
                doc /* Configuration for the Elaboration Unit */
            }
            part :>> balancer {
                doc /* Configuration for the Balancing Unit */
            }
    

            /* ===================================================================
                 * USE CASE USAGE
             * =================================================================== */
            event occurrence receiveV2V;
            then event occurrence processV2V;
            then event occurrence controlCarFollowing;
            
            use case systemUseCase : UC0_SystemUseCases{
                doc /* Allocation of the overall system use cases to the system. */
                subject System = system;
                actor  follower_vehicle = follower;
                actor  leader_vehicle = following;
                actor  lateral_vehicle = extraneous;
                actor  infrastructure = infrastructure;
                actor  cloud_service = cloud;
                actor  person_actor = person;
                actor  general_interactor_actor = general_interactor;
                
                // CONNECTIONS
                connect follower_vehicle  to cacc_synchronization;
                connect leader_vehicle to cacc_synchronization;
                connect follower_vehicle to abruptCutIn;
                connect lateral_vehicle to calledCutIn;
                connect follower_vehicle to calledCutIn;
                connect follower_vehicle to shockwavesMitigation;
                connect leader_vehicle to adaptingFollowing;
                connect infrastructure to crossRoadAdaptation;
                connect infrastructure to speedLimitsAdaptation;
                connect follower_vehicle to speedLimitsAdaptation;
                connect infrastructure to roadHazardWarning;
                connect infrastructure to roadConditionWarning;
                connect infrastructure to signalViolationProtection;
                connect follower_vehicle to signalViolationProtection;
                connect extraneous to signalViolationProtection;
                connect infrastructure to wrongWayDriverProtection;
                connect follower_vehicle to specialVehicle;
                connect infrastructure to specialVehicle;
                connect person_actor to pedestrianProtection;
                connect infrastructure to pedestrianProtection;
                connect follower_vehicle to degradedSignalManagement;
                connect general_interactor_actor to fragmentedSignalManagement;

                action def general_Action_Flow{
                    merge node1;
                    action inputAcquisition{
                        doc /* Action for acquiring input data from various sources (V2V, V2I, sensors). */
                        action inputGateway{
                            doc /* Action for routing input data to the appropriate processing units. */
                            action receiveV2V{
                                doc /* Action for receiving V2V messages. */
                                action receiveCAM;
                                action receiveSPaT;
                                action receiveCutInRequest;
                                fork rV2Vfork1;
                                join rV2Vjoin1;

                                first start then rV2Vfork1;
                                first rV2Vfork1 then receiveCAM;
                                first rV2Vfork1 then receiveSPaT;
                                first rV2Vfork1 then receiveCutInRequest;
                                first receiveCAM then rV2Vjoin1;
                                first receiveSPaT then rV2Vjoin1;
                                first receiveCutInRequest then rV2Vjoin1;
                                first rV2Vjoin1 then done;
                            }
                            action receiveV2I{
                                doc /* Action for receiving V2I messages. */
                                action receiveSPaT;
                                action receiveCrossroadInfo;
                                action receiveSpeedLimitInfo;
                                action receiveHazardInfo;
                                action receiveConditionInfo;
                                action receiveViolationInfo;
                                fork rV2Ifork1;
                                join rV2Ijoin1;

                                first start then rV2Ifork1;
                                first rV2Ifork1 then receiveSPaT;
                                first rV2Ifork1 then receiveCrossroadInfo;
                                first rV2Ifork1 then receiveSpeedLimitInfo;
                                first rV2Ifork1 then receiveHazardInfo;
                                first rV2Ifork1 then receiveConditionInfo;
                                first rV2Ifork1 then receiveViolationInfo;
                                first receiveSPaT then rV2Ijoin1;
                                first receiveCrossroadInfo then rV2Ijoin1;
                                first receiveSpeedLimitInfo then rV2Ijoin1;
                                first receiveHazardInfo then rV2Ijoin1;
                                first receiveConditionInfo then rV2Ijoin1;
                                first receiveViolationInfo then rV2Ijoin1;
                                first rV2Ijoin1 then done;
                            }
                        }
                        action signalValidation{
                            doc /* Action for validating received signals and messages. */
                            action controlLastSignal;
                            action controlQualitySignal;
                            action repairSignal;
                            merge sVnode1;
                            decide sVdecide1;
                            decide sVdecide2;

                            first start then sVnode1;
                            first sVnode1 then controlLastSignal;
                            first controlLastSignal then sVdecide1;
                            first sVdecide1 then sVnode1;
                            first sVdecide1 then controlQualitySignal;
                            first controlQualitySignal then sVdecide2;
                            first sVdecide2 then done;
                            first sVdecide2 then repairSignal;
                            first repairSignal then done;
                        }

                        first start then inputGateway;
                        first inputGateway then signalValidation;
                        first signalValidation then done;
                    }
                    action dataProcessing{
                        doc /* Action for analyze data and produce output parameters. */
                        action dataAnalysis{
                            doc /* Action for analyzing the acquired data to extract relevant information. */
                            action analyzeV2VData{
                                doc /* Action for analyzing V2V data to determine the state of surrounding vehicles. */
                                action analyzeCAM;
                                action analyzeSPaT;
                                action analyzeCutInRequest;
                                fork aV2Vfork1;
                                join aV2Vjoin1;

                                first start then aV2Vfork1;
                                first aV2Vfork1 then analyzeCAM;
                                first aV2Vfork1 then analyzeSPaT;
                                first aV2Vfork1 then analyzeCutInRequest;
                                first analyzeCAM then aV2Vjoin1;
                                first aV2Vjoin1 then done;
                            }
                            action analyzeV2IData{
                                doc /* Action for analyzing V2I data to understand the current traffic situation and infrastructure status. */
                                action analyzeSPaT;
                                action analyzeCrossroadInfo;
                                action analyzeSpeedLimitInfo;
                                action analyzeHazardInfo;
                                action analyzeConditionInfo;
                                action analyzeViolationInfo;
                                fork aV2Ifork1;
                                join aV2Ijoin1;

                                first start then aV2Ifork1;
                                first aV2Ifork1 then analyzeSPaT;
                                first aV2Ifork1 then analyzeCrossroadInfo;
                                first aV2Ifork1 then analyzeSpeedLimitInfo;
                                first aV2Ifork1 then analyzeHazardInfo;
                                first aV2Ifork1 then analyzeConditionInfo;
                                first aV2Ifork1 then analyzeViolationInfo;
                                first analyzeSPaT then aV2Ijoin1;
                                first analyzeCrossroadInfo then aV2Ijoin1;
                                first analyzeSpeedLimitInfo then aV2Ijoin1;
                                first analyzeHazardInfo then aV2Ijoin1;
                                first analyzeConditionInfo then aV2Ijoin1;
                                first analyzeViolationInfo then aV2Ijoin1;
                                first aV2Ijoin1 then done;
                            }
                            fork dAfork1;
                            join dAjoin1;

                            first start then dAfork1;
                            first dAfork1 then analyzeV2VData;
                            first dAfork1 then analyzeV2IData;
                            first analyzeV2VData then dAjoin1;
                            first analyzeV2IData then dAjoin1;
                            first dAjoin1 then done;
                        }
                        fork dPfork1;
                        action sendV2V;
                        action generateParameters;
                        join dPjoin1;

                        first start then dataAnalysis;
                        first dataAnalysis then dPfork1;
                        first dPfork1 then sendV2V;
                        first dPfork1 then generateParameters;
                        first sendV2V then dPjoin1;
                        first generateParameters then dPjoin1;
                        first dPjoin1 then done;
                    }

                    first start then node1;
                    first node1 then inputAcquisition;
                    first inputAcquisition then dataProcessing;
                    first dataProcessing then node1;

                    
                }



                // ==========================================
                    // ACTION FLOW FOR V2X CAR-FOLLOWING SYSTEM
                // ==========================================
                action def V2X_CarFollowing_System {
    doc /* Main action flow of the V2X-only car-following system. Covers input acquisition, signal validation, data processing, and output generation, including degraded operation handling. */
    merge loopStart;
    
    action inputAcquisition {
        doc /* Acquires all raw data from V2V, V2I, and onboard sensors (GNSS/IMU). */
        action inputGateway {
            doc /* Parallel reception of V2V and V2I messages. */
            action receiveV2V {
                doc /* Handles all V2V communication. */
                action receiveCAM;
                action receiveMCM;
                action receiveCutInRequest;
                fork v2vFork;
                join v2vJoin;
                first start then v2vFork;
                first v2vFork then receiveCAM;
                first v2vFork then receiveMCM;
                first v2vFork then receiveCutInRequest;
                first receiveCAM then v2vJoin;
                first receiveMCM then v2vJoin;
                first receiveCutInRequest then v2vJoin;
                first v2vJoin then done;
            }
            action receiveV2I {
                doc /* Handles all V2I communication. */
                action receiveSPaT;
                action receiveMAP;
                action receiveIVS;
                action receiveDENM;
                action receiveEVA;
                action receiveVRU;
                action receiveCPM;
                action receiveSVW;
                fork v2iFork;
                join v2iJoin;
                first start then v2iFork;
                first v2iFork then receiveSPaT;
                first v2iFork then receiveMAP;
                first v2iFork then receiveIVS;
                first v2iFork then receiveDENM;
                first v2iFork then receiveEVA;
                first v2iFork then receiveVRU;
                first v2iFork then receiveCPM;
                first v2iFork then receiveSVW;
                first receiveSPaT then v2iJoin;
                first receiveMAP then v2iJoin;
                first receiveIVS then v2iJoin;
                first receiveDENM then v2iJoin;
                first receiveEVA then v2iJoin;
                first receiveVRU then v2iJoin;
                first receiveCPM then v2iJoin;
                first receiveSVW then v2iJoin;
                first v2iJoin then done;
            }
            first start then receiveV2V;
            first start then receiveV2I;
            first receiveV2V then done;
            first receiveV2I then done;
        }

        action signalValidation {
            doc /* Validates freshness, consistency, authenticity, and cybersecurity of every received message. */
            action validateCAM;
            action validateMCM;
            action validateSPaT;
            action validateMAP;
            action validateIVS;
            action validateDENM;
            action validateEVA;
            action validateVRU;
            action validateCPM;
            action validateSVW;
            action cybersecurityChecks {
                doc /* Checks for intrusions, replay attacks, and message frequency anomalies. */
                action detectIntrusion;
                action detectReplayAttack;
                action monitorFrequency;
                action logSecurityEvents;
                fork secFork;
                join secJoin;
                first start then secFork;
                first secFork then detectIntrusion;
                first secFork then detectReplayAttack;
                first secFork then monitorFrequency;
                first secFork then logSecurityEvents;
                first detectIntrusion then secJoin;
                first detectReplayAttack then secJoin;
                first monitorFrequency then secJoin;
                first logSecurityEvents then secJoin;
                first secJoin then done;
            }
            merge allValidated;
            decide globalValidity;
            first start then validateCAM;
            first start then validateMCM;
            first start then validateSPaT;
            first start then validateMAP;
            first start then validateIVS;
            first start then validateDENM;
            first start then validateEVA;
            first start then validateVRU;
            first start then validateCPM;
            first start then validateSVW;
            first start then cybersecurityChecks;
            first validateCAM then allValidated;
            first validateMCM then allValidated;
            first validateSPaT then allValidated;
            first validateMAP then allValidated;
            first validateIVS then allValidated;
            first validateDENM then allValidated;
            first validateEVA then allValidated;
            first validateVRU then allValidated;
            first validateCPM then allValidated;
            first validateSVW then allValidated;
            first cybersecurityChecks then allValidated;
            first allValidated then globalValidity;
            first globalValidity then done;         // all valid: proceed to data processing
            first globalValidity then done;         // some invalid: message discarded (handled inside validation actions)
        }

        first start then inputGateway;
        first inputGateway then signalValidation;
        first signalValidation then done;
    }

    decide communicationStatus {
        doc /* Evaluates if V2V and V2I are sufficiently reliable to continue CACC operation. */
    }
    
    action degradedOperation {
        doc /* If communication is lost or severely degraded, disable CACC and fall back to passive mode. */
        action disableCACC;
        action notifyDriverOrSupervisor;
        action transitionToPassive;
        first start then disableCACC;
        first disableCACC then notifyDriverOrSupervisor;
        first notifyDriverOrSupervisor then transitionToPassive;
        first transitionToPassive then done;
    }

    action dataProcessing {
        doc /* Analyzes validated data and determines the vehicle control strategy. */
        action analyzeV2VData {
            doc /* Extracts surrounding vehicle states and intentions. */
            action analyzeCAM;
            action analyzeMCM;
            action analyzeCutInRequest;
            fork aV2vFork;
            join aV2vJoin;
            first start then aV2vFork;
            first aV2vFork then analyzeCAM;
            first aV2vFork then analyzeMCM;
            first aV2vFork then analyzeCutInRequest;
            first analyzeCAM then aV2vJoin;
            first analyzeMCM then aV2vJoin;
            first analyzeCutInRequest then aV2vJoin;
            first aV2vJoin then done;
        }
        action analyzeV2IData {
            doc /* Interprets infrastructure data (traffic lights, hazards, limits, etc.). */
            action analyzeSPaT;
            action analyzeMAP;
            action analyzeIVS;
            action analyzeDENM;
            action analyzeEVA;
            action analyzeVRU;
            action analyzeCPM;
            action analyzeSVW;
            fork aV2iFork;
            join aV2iJoin;
            first start then aV2iFork;
            first aV2iFork then analyzeSPaT;
            first aV2iFork then analyzeMAP;
            first aV2iFork then analyzeIVS;
            first aV2iFork then analyzeDENM;
            first aV2iFork then analyzeEVA;
            first aV2iFork then analyzeVRU;
            first aV2iFork then analyzeCPM;
            first aV2iFork then analyzeSVW;
            first analyzeSPaT then aV2iJoin;
            first analyzeMAP then aV2iJoin;
            first analyzeIVS then aV2iJoin;
            first analyzeDENM then aV2iJoin;
            first analyzeEVA then aV2iJoin;
            first analyzeVRU then aV2iJoin;
            first analyzeCPM then aV2iJoin;
            first analyzeSVW then aV2iJoin;
            first aV2iJoin then done;
        }
        action decisionMaking {
            doc /* Combines all analyses and chooses the highest priority maneuver. */
            action determineLeaderProfile;
            action computeFollowingParameters;
            action evaluateGLOSA;
            action evaluateCutInManuever;
            action evaluateWrongWayVehicle;
            action evaluateEmergencyVehicle;
            action evaluatePedestrianRisk;
            action evaluateSignalViolation;
            action evaluateStringStability;
            merge priorityMerge;
            decide highestPriorityAction;
            first start then determineLeaderProfile;
            first determineLeaderProfile then computeFollowingParameters;
            first computeFollowingParameters then priorityMerge;
            first start then evaluateGLOSA;
            first evaluateGLOSA then priorityMerge;
            first start then evaluateCutInManuever;
            first evaluateCutInManuever then priorityMerge;
            first start then evaluateWrongWayVehicle;
            first evaluateWrongWayVehicle then priorityMerge;
            first start then evaluateEmergencyVehicle;
            first evaluateEmergencyVehicle then priorityMerge;
            first start then evaluatePedestrianRisk;
            first evaluatePedestrianRisk then priorityMerge;
            first start then evaluateSignalViolation;
            first evaluateSignalViolation then priorityMerge;
            first start then evaluateStringStability;
            first evaluateStringStability then priorityMerge;
            first priorityMerge then highestPriorityAction;
            first highestPriorityAction then done;    // selected maneuver (e.g., emergency brake, evasion, normal following)
            first highestPriorityAction then done;    // if no special event, default to standard car-following
        }
        fork dataFork;
        join dataJoin;
        first start then dataFork;
        first dataFork then analyzeV2VData;
        first dataFork then analyzeV2IData;
        first analyzeV2VData then dataJoin;
        first analyzeV2IData then dataJoin;
        first dataJoin then decisionMaking;
        first decisionMaking then done;
    }

    action outputGeneration {
        doc /* Produces vehicle control commands and sends updated CAM. */
        action generateControlCommands {
            doc /* Computes acceleration, braking, and steering commands. */
            action computeLongitudinalCommand;
            action computeLateralCommand;
            fork cmdFork;
            join cmdJoin;
            first start then cmdFork;
            first cmdFork then computeLongitudinalCommand;
            first cmdFork then computeLateralCommand;
            first computeLongitudinalCommand then cmdJoin;
            first computeLateralCommand then cmdJoin;
            first cmdJoin then done;
        }
        action sendUpdatedCAM;
        action updateHMIDisplay;
        fork outFork;
        join outJoin;
        first start then outFork;
        first outFork then generateControlCommands;
        first outFork then sendUpdatedCAM;
        first outFork then updateHMIDisplay;
        first generateControlCommands then outJoin;
        first sendUpdatedCAM then outJoin;
        first updateHMIDisplay then outJoin;
        first outJoin then done;
    }

    first start then loopStart;
    first loopStart then inputAcquisition;
    first inputAcquisition then communicationStatus;
    first communicationStatus then degradedOperation;
    first communicationStatus then dataProcessing;
    first degradedOperation then loopStart;
    first dataProcessing then outputGeneration;
    first outputGeneration then loopStart;
}


                // ==========================================
                    // STATE MACHINE FOR V2X CAR-FOLLOWING SYSTEM
                // ==========================================
                state def V2XCarFollowingSystem {
                    doc /* State machine for the V2X car-following system, managing operational states, communication status, and fault handling. */
                    // Segnali per notifiche HMI
                    item def StatusUpdate {
                        doc /* A message structure for sending status updates to the HMI. */
                        attribute messageS : String;
                    }
    
                    // Attributi del sistema (rilevanti per lo stato)
                    attribute v2vStatus : CommStatusKind;
                    attribute v2iStatus : CommStatusKind;
                    attribute v2vSignalLostDuration : Real;       // [ms]
                    attribute v2vSignalLossTimeout : Real = 500.0; // [ms]
                    attribute fragmentationRate : Real;            // [%]
                    attribute fragmentationThreshold : Real = 15.0;// [%]
                    attribute fragmentationPersistentDuration : Real; // [s]
                    attribute fragmentationPersistenceLimit : Real = 3.0; // [s]
                    attribute cyberAttackConfirmed : Boolean;
                    attribute heartbeatFailureDetected : Boolean;
                    attribute criticalInternalFault : Boolean;
                    attribute v2vSignalRestored : Boolean;
                    attribute dataValidationPositive : Boolean;
                    attribute initComplete : Boolean;
                    attribute shutdownCommand : Boolean;

                    // Porte
                    ref port v2v : V2VCommPort;
                    ref port v2i : V2ICommPort;
                    ref port vehicleBus : VehicleBusPort;
                    ref port hmi : HMIPort;
                    ref port securityMonitor : SecurityMonitorPort;

                    // ===== INGRESSO INIZIALE =====
                    entry;
                        then disabled;

                    // ===== SUPER-STATO: DISABLED =====
                    state disabled {
                        entry action {
                            send new StatusUpdate(messageS = "System disabled") via hmi;
                        }

                        transition disabled2active
                            first disabled
                            accept when (initComplete) and (not shutdownCommand)
                            do action {
                                send new StatusUpdate(messageS = "System enabling") via hmi;
                            }
                            then active;

                        transition disabledStay
                            first disabled
                            accept when (shutdownCommand)
                            then disabled;
    
                    }
                    // ===== SUPER-STATO: ACTIVE =====
                    state active {
                        entry action {
                            send new StatusUpdate(messageS = "System active") via hmi;
                        } 
                        then activeInitial;

                        state activeInitial;

                        // RISOLUZIONE ERRORE 3: Aggiunte parentesi per evitare la concatenazione dei token (es. OKandv2iStatus)
                        transition init2normal
                            first activeInitial
                            accept when ((v2vStatus == CommStatusKind::OK) and (v2iStatus == CommStatusKind::OK))
                            then normalOperation;

                        transition init2partialV2I
                            first activeInitial
                            accept when ((v2vStatus == CommStatusKind::OK) and (v2iStatus != CommStatusKind::OK))
                            then partialV2IFailure;
                        

                        // ----- Sotto-stato: NormalOperation -----
                        state normalOperation {
                            transition normal2partialV2I
                                first normalOperation
                                accept when (v2iStatus != CommStatusKind::OK)
                                then partialV2IFailure;            
                        }

                        // ----- Sotto-stato: PartialV2IFailure -----
                        state partialV2IFailure {
                            transition partialV2I2normal
                                first partialV2IFailure
                                accept when (v2iStatus == CommStatusKind::OK)
                                then normalOperation;

                            transition partialV2I2partialV2V
                                first partialV2IFailure
                                accept when ((v2vStatus != CommStatusKind::OK) or (fragmentationRate > fragmentationThreshold))
                                then partialV2VFailure;

                            transition partialV2I2passive_cyber
                                first partialV2IFailure
                                accept when (cyberAttackConfirmed)
                                do action { send new StatusUpdate(messageS = "Cyber attack – fallback") via hmi; }
                                then passive;

                            transition partialV2I2passive_hb
                                first partialV2IFailure
                                accept when ((heartbeatFailureDetected) or (criticalInternalFault))
                                do action { send new StatusUpdate(messageS = "Critical fault – fallback") via hmi; }
                                then passive;        
                        }

                        // ----- Sotto-stato: PartialV2VFailure -----
                        state partialV2VFailure {
                            entry action startSignalReconstruction;

                            transition partialV2VBack2normal
                                first partialV2VFailure
                                accept when ((v2vStatus == CommStatusKind::OK) and not ((v2vSignalLostDuration > v2vSignalLossTimeout) or (fragmentationPersistentDuration > fragmentationPersistenceLimit)))
                                then normalOperation;

                            transition partialV2V2passive_timeout
                                first partialV2VFailure
                                accept when (v2vSignalLostDuration > v2vSignalLossTimeout)
                                do action { send new StatusUpdate(messageS = "V2V lost – fallback") via hmi; }
                                then passive;

                            transition partialV2V2passive_frag
                                first partialV2VFailure
                                accept when (fragmentationPersistentDuration > fragmentationPersistenceLimit)
                                do action { send new StatusUpdate(messageS = "V2V fragmentation – fallback") via hmi; }
                                then passive;

                            transition partialV2V2passive_cyber
                                first partialV2VFailure
                                accept when (cyberAttackConfirmed)
                                do action { send new StatusUpdate(messageS = "Cyber attack – fallback") via hmi; }
                                then passive;

                            transition partialV2V2passive_hb
                                first partialV2VFailure
                                accept when ((heartbeatFailureDetected) or (criticalInternalFault))
                                do action { send new StatusUpdate(messageS = "Critical fault – fallback") via hmi; }
                                then passive;
                        }

                        // ----- Sotto-stato: CyberAttackDegraded -----
                        state cyberAttackDegraded;

                        transition cyber2passive
                            first cyberAttackDegraded
                            then passive;
    
                    }
                    // ===== SUPER-STATO: PASSIVE =====
                    state passive {
                        entry action {
                            send new StatusUpdate(messageS = "CACC disabled – passive mode") via hmi;
                        }

                        transition passive2active
                            first passive
                            accept when ((v2vSignalRestored) and (dataValidationPositive))
                            do action {
                                send new StatusUpdate(messageS = "V2V restored – reactivating") via hmi;
                            }
                            then active;

                        transition passive2disabled
                            first passive
                            accept when (shutdownCommand)
                            do action { send new StatusUpdate(messageS = "System shutdown") via hmi; }
                            then disabled;
                    }

                    // ==========================================
                        // TRANSIZIONI GLOBALI DI FALLBACK
                    // ==========================================
    
                    transition activeDirect2passive_hb
                        first active
                        accept when ((heartbeatFailureDetected) or (criticalInternalFault))
                        do action { send new StatusUpdate(messageS = "Critical fault – fallback") via hmi; }
                        then passive;

                    transition activeDirect2passive_cyber
                        first active
                        accept when (cyberAttackConfirmed)
                        do action { send new StatusUpdate(messageS = "Cyber attack – fallback") via hmi; }
                        then passive;
                }          
    

   
                
                

                use case cacc_synchronization : UC1_CACC_Synchronization{
                    doc /* Allocation of the CACC Synchronization use case to the system. */
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> follower_vehicle = follower;
                    actor :>> leader_vehicle = following;
                    
                    
                    occurrence sequence{
                        ref part uc1_leader = leader_vehicle;
                        ref part uc1_follower = follower_vehicle;
                        ref part uc1_system = System;
                        ref part uc1_cfm = car_following_model;
                        

                        message '1.1: V2V data' from uc1_leader.outMex to uc1_system.inMex;
                        then message '1.2: V2V data' from uc1_follower.outMex to uc1_system.inMex;
                        then message '2: Control' from uc1_system.outMex to uc1_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2V;
                        action generateParameter;
                        fork fork1;
                        action sendV2V;
                        action controll_CFM;


                        first start then receiveV2V;
                        first receiveV2V then generateParameter;
                        first generateParameter then fork1;
                        first fork1 then sendV2V;
                        first sendV2V then receiveV2V;
                        first fork1 then controll_CFM;
                        first controll_CFM then receiveV2V;
                    }                    
                }
                

                use case abruptCutIn : UC2_AbruptCutIn{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;

                    occurrence sequence{
                        ref part uc2_system = System;
                        ref part uc2_infrastructure = infrastructure;
                        ref part uc2_cfm = car_following_model;
                        
                        message '1: Cut-In' from uc2_infrastructure.outMex to uc2_system.inMex;
                        then message '2: EmergencyBrake' from uc2_system.outMex to uc2_cfm.inMex;
                    }

                action def action_flow{
                        action receiveV2V;
                        action controllDistance;
                        decide distance;
                        action emergencyBrake;
                        merge merge1;
                        action sendEmergencyBrakeAlert;

                        first start then receiveV2V;
                        first receiveV2V then controllDistance;
                        first controllDistance then distance;
                        first distance then sendEmergencyBrakeAlert;
                        first sendEmergencyBrakeAlert then emergencyBrake;
                        first distance then merge1;
                        first emergencyBrake then merge1;
                        first merge1 then done;
                    }
                }
                
               
                use case calledCutIn : UC3_CalledCutIn{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> lateral_vehicle = extraneous;

                    occurrence sequence{
                        ref part uc3_system = System;
                        ref part uc3_lateral = lateral_vehicle;
                        ref part uc3_cfm = car_following_model;

                        message '1: Cut-In Intent' from uc3_lateral.outMex to uc3_system.inMex;
                        then message '2: Response' from uc3_system.outMex to uc3_lateral.inMex;
                        then message '3: Control (based on Response)' from uc3_system.outMex to uc3_cfm.inMex;

                    }

                    action def action_flow{
                        action receiveCutInRequest;
                        action evaluateRequest;
                        action sendAnswer;
                        action increaseHeadway;
                        action waitCutIn;
                        action reduceHeadway;

                        decide verifyAnswer;
                                         
                        
                        first start then receiveCutInRequest;
                        first receiveCutInRequest then evaluateRequest;
                        first evaluateRequest then sendAnswer;
                        first sendAnswer then verifyAnswer;
                        first verifyAnswer then increaseHeadway;
                          first increaseHeadway then waitCutIn;
                          first waitCutIn then reduceHeadway;
                          first reduceHeadway then done;
                        first verifyAnswer then done;
                        
                    }

                }


                use case shockwavesMitigation : UC4_Shockwave_Mitigation{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> leader_vehicle = following;

                    occurrence sequence{
                        ref part uc4_system = System;                        
                        ref part uc4_cfm = car_following_model;
                        ref part uc4_leader_vehicle = leader_vehicle;

                        message '1: Send V2V' from uc4_leader_vehicle.outMex to uc4_system.inMex;
                        then message '2: Correct Headway' from uc4_system.outMex to uc4_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2V;
                        merge node;
                        action stringInstabilityDetermination;
                        decide verifySI;
                        action shockwaveMitigation;
                        merge merge1;
                        action normalControl;



                        first start then receiveV2V;
                        first receiveV2V then node;
                        first node then stringInstabilityDetermination;
                        first stringInstabilityDetermination then verifySI;
                        first verifySI then shockwaveMitigation;
                          first shockwaveMitigation then merge1;
                        first verifySI then normalControl;
                          first normalControl then merge1;
                        first merge1 then node;

                    }

                }
            

                use case adaptingFollowing : UC5_AdaptingFollowing{
                subject :>> System = system;
                actor :>> car_following_model = cfm;
                actor :>> leader_vehicle = following;

                occurrence sequence{
                    ref part uc5_system = System;                        
                    ref part uc5_cfm = car_following_model;
                    ref part uc5_leader_vehicle = leader_vehicle;

                    message '1: Send V2V' from uc5_leader_vehicle.outMex to uc5_system.inMex;
                    then message '2: Adapt to Following' from uc5_system.outMex to uc5_cfm.inMex;
                }

                action def actionflow{
                    action receiveV2V;
                    merge node;
                    action analyzeData;
                    action defineLeaderType;
                    decide verifyType;
                    action determineBehaviour;
                    action determineALevel;
                    merge merge1;
                    action modifyVariables;

                    first start then receiveV2V;
                    first receiveV2V then node;
                    first node then analyzeData;
                    first analyzeData then defineLeaderType;
                    first defineLeaderType then verifyType;
                    first verifyType then determineBehaviour;
                      first determineBehaviour then merge1;
                    first verifyType then determineALevel;
                      first determineALevel then merge1;
                    first merge1 then modifyVariables;
                    first modifyVariables then node;
                }
            }


                use case crossRoadAdaptation : UC6_CrossroadAdaptation{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;

                    occurrence sequence{
                        ref part uc6_system = System;                        
                        ref part uc6_cfm = car_following_model;
                        ref part uc6_infrastructure = infrastructure;

                        message '1: Crossroad Info' from uc6_infrastructure.outMex to uc6_system.inMex;
                        then message '2: Adapt to Crossroad' from uc6_system.outMex to uc6_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        action analyzeCrossroadInfo;
                        action greenWaveFeasibility;
                        decide verifyGreenWave;
                        action defineAdvantage;
                        decide verifyAdvantage;
                        merge merge1;
                        action greenWaveMitigation;
                        merge merge2;
                        action stopProcedure;
                        

                        first start then receiveV2I;
                        first receiveV2I then analyzeCrossroadInfo;
                        first analyzeCrossroadInfo then greenWaveFeasibility;
                        first greenWaveFeasibility then verifyGreenWave;
                        first verifyGreenWave then merge1;
                        first verifyGreenWave then defineAdvantage;
                        first defineAdvantage then verifyAdvantage;
                        first verifyAdvantage then merge1;
                        first verifyAdvantage then greenWaveMitigation;
                        first merge1 then stopProcedure;
                        first greenWaveMitigation then merge2;
                        first stopProcedure then merge2;
                        first merge2 then done;
                    }
                }


                use case speedLimitsAdaptation : UC7_SpeedLimitsAdaptation{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                    actor :>> follower_vehicle = follower;
                
                    occurrence sequence{
                        ref part uc7_system = System;                        
                        ref part uc7_cfm = car_following_model;
                        ref part uc7_infrastructure = infrastructure;
                        ref part uc7_follower_vehicle = follower_vehicle;

                        message '1: Speed Limit Info' from uc7_infrastructure.outMex to uc7_system.inMex;
                        then message '2: Adapt to Speed Limit' from uc7_system.outMex to uc7_cfm.inMex;
                        then message '3: Notify Follower' from uc7_system.outMex to uc7_follower_vehicle.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        merge node;
                        action analyzeSpeedLimitInfo;
                        action modifyMaxSpeed;

                        first start then node;
                        first node then receiveV2I;
                        first receiveV2I then analyzeSpeedLimitInfo;
                        first analyzeSpeedLimitInfo then modifyMaxSpeed;
                        first modifyMaxSpeed then node;
                    }
                }


                use case roadHazardWarning : UC8_RoadHazardWarning{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                
                    occurrence sequence{
                        ref part uc8_system = System;                        
                        ref part uc8_cfm = car_following_model;
                        ref part uc8_infrastructure = infrastructure;

                        message '1: Road Hazard Info' from uc8_infrastructure.outMex to uc8_system.inMex;
                        then message '2: Adapt Following' from uc8_system.outMex to uc8_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        action analyzeHazardInfo;
                        action modifyFollowing;

                        first start then receiveV2I;
                        first receiveV2I then analyzeHazardInfo;
                        first analyzeHazardInfo then modifyFollowing;
                        first modifyFollowing then done;
                    }
                }


                use case roadConditionWarning : UC9_RoadConditionWarning{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                
                    occurrence sequence{
                        ref part uc9_system = System;                        
                        ref part uc9_cfm = car_following_model;
                        ref part uc9_infrastructure = infrastructure;

                        message '1: Road Condition Info' from uc9_infrastructure.outMex to uc9_system.inMex;
                        then message '2: Adapt Following' from uc9_system.outMex to uc9_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        action analyzeConditionInfo;
                        action modifyFollowing;
                        merge node;

                        first start then node;
                        first node then receiveV2I;
                        first receiveV2I then analyzeConditionInfo;
                        first analyzeConditionInfo then modifyFollowing;
                        first modifyFollowing then node;
                    }
                }


                use case signalViolationProtection : UC10_SignalViolationProtection{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                    actor :>> follower_vehicle = follower;
                    actor :>> criminal_vehicle = extraneous;
                
                    occurrence sequence{
                        ref part uc10_system = System;                        
                        ref part uc10_cfm = car_following_model;
                        ref part uc10_infrastructure = infrastructure;
                        ref part uc10_follower_vehicle = follower_vehicle;
                        ref part uc10_criminal_vehicle = criminal_vehicle;

                        message '1: Signal Violation Info' from uc10_infrastructure.outMex to uc10_system.inMex;
                        then message '2: Protect from Violation' from uc10_system.outMex to uc10_cfm.inMex;
                        then message '3: Notify Follower' from uc10_system.outMex to uc10_follower_vehicle.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        action analyzeViolationInfo;
                        decide verifyDistance;
                        action emergencyBrake;
                        action reduceSpeed;
                        merge merge1;

                        first start then receiveV2I;
                        first receiveV2I then analyzeViolationInfo;
                        first analyzeViolationInfo then verifyDistance;
                        first verifyDistance then emergencyBrake;
                        first verifyDistance then reduceSpeed;
                        first emergencyBrake then merge1;
                        first reduceSpeed then merge1;
                        first merge1 then done;
                    }
                }


                use case wrongWayDriverProtection : UC11_WrongWayDriverProtection{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                
                    occurrence sequence{
                        ref part uc11_system = System;                        
                        ref part uc11_cfm = car_following_model;
                        ref part uc11_infrastructure = infrastructure;

                        message '1: Wrong-Way Driver Info' from uc11_infrastructure.outMex to uc11_system.inMex;
                        then message '2.1: Increase lateral headway' from uc11_system.outMex to uc11_cfm.inMex;
                        then message '2.2: Avoid procedure' from uc11_system.outMex to uc11_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        merge node;
                        action analyzeWarningInfo;
                        action calculateDistance;
                        action increaseLateralHeadway;
                        action waitAvoidment;
                        decide verifyAvoidment;
                        action reduceLateralHeadway;
                        fork fork1;
                        join join1;


                        first start then receiveV2I;
                        first receiveV2I then node;
                        first node then analyzeWarningInfo;
                        first analyzeWarningInfo then fork1;
                        first fork1 then calculateDistance;
                          first calculateDistance then join1;
                        first fork1 then increaseLateralHeadway;
                          first increaseLateralHeadway then join1;
                        first join1 then waitAvoidment;
                        first waitAvoidment then verifyAvoidment;
                        first verifyAvoidment then node;
                        first verifyAvoidment then reduceLateralHeadway;
                        first reduceLateralHeadway then done; 
                    }
                }


                use case specialVehicle : UC12_SpecialVehicle{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> special_vehicle = extraneous;
                    actor :>> infrastructure = infrastructure;
                
                    occurrence sequence{
                        ref part uc12_system = System;                        
                        ref part uc12_cfm = car_following_model;
                        ref part uc12_special_vehicle = special_vehicle;
                        ref part uc12_infrastructure = infrastructure;

                        message '1: Special Vehicle Info' from uc12_infrastructure.outMex to uc12_system.inMex;
                        then message '2.1: Increase lateral headway' from uc12_system.outMex to uc12_cfm.inMex;
                        then message '2.2: Pull Over' from uc12_system.outMex to uc12_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        merge node;
                        action analyzeWarningInfo;
                        action calculateDistance;
                        action increaseLateralHeadway;
                        action waitAvoidment;
                        decide verifyAvoidment;
                        action reduceLateralHeadway;
                        fork fork1;
                        join join1;
                        

                        first start then receiveV2I;
                        first receiveV2I then node;
                        first node then analyzeWarningInfo;
                        first analyzeWarningInfo then fork1;
                        first fork1 then calculateDistance;
                          first calculateDistance then join1;
                        first fork1 then increaseLateralHeadway;
                          first increaseLateralHeadway then join1;
                        first join1 then waitAvoidment;
                        first waitAvoidment then verifyAvoidment;
                        first verifyAvoidment then node;
                        first verifyAvoidment then reduceLateralHeadway;
                        first reduceLateralHeadway then done; 
                    }
                }


                use case pedestrianProtection : UC13_PedestrianProtection{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                
                    occurrence sequence{
                        ref part uc13_system = System;                        
                        ref part uc13_cfm = car_following_model;
                        ref part uc13_infrastructure = infrastructure;

                        message '1: Pedestrian Info' from uc13_infrastructure.outMex to uc13_system.inMex;
                        then message '2.1: Increase headway' from uc13_system.outMex to uc13_cfm.inMex;
                        then message '2.2: Stop' from uc13_system.outMex to uc13_cfm.inMex;
                    }

                    action def action_flow{
                        action receiveV2I;
                        merge node;
                        action extractInfo;
                        action calculateArrivingTime;
                        decide verifyTime;
                        action reduceSpeed;
                        action brake;
                        action emergencyBrake;
                        merge merge1;


                        first start then receiveV2I;
                        first receiveV2I then extractInfo;
                        first extractInfo then calculateArrivingTime;
                        first calculateArrivingTime then verifyTime;
                        first verifyTime then merge1;
                        first verifyTime then reduceSpeed;
                          first reduceSpeed then merge1;
                        first verifyTime then brake;
                          first brake then merge1;
                        first verifyTime then emergencyBrake;
                          first emergencyBrake then merge1;
                        first merge1 then done;
                    }
                }


                use case degradedSignalManagement : UC14_DegradedSignalManagement{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> follower_vehicle = follower;
                
                    occurrence sequence{
                        ref part uc14_system = System;                        
                        ref part uc14_cfm = car_following_model;
                        ref part uc14_follower_vehicle = follower_vehicle;

                        message '1: No Signal' from uc14_follower_vehicle.outMex to uc14_system.inMex;
                        then message '2: Shut down' from uc14_system.outMex to uc14_cfm.inMex;
                    }

                    action def action_flow{
                        decide node;
                        action controlLastSignal;
                        action verifyTime;
                        action shutdown;

                        first start then node;
                        first node then controlLastSignal;
                        first controlLastSignal then verifyTime;
                        first verifyTime then shutdown;
                          first shutdown then node;
                        first verifyTime then node;
                    }
                }   


                use case fragmentedSignalManagement: UC15_FragmentedSignalManagement{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> interactor = general_interactor;
                
                    occurrence sequence{
                        ref part uc15_system = System;                        
                        ref part uc15_cfm = car_following_model;
                        ref part uc15_interactor = interactor;

                        message '1: Fragmented Signal' from uc15_interactor.outMex to uc15_system.inMex;
                        then message '2: Mitigation' from uc15_system.outMex to uc15_system.inMex;
                        then message '3: Control' from uc15_system.outMex to uc15_cfm.inMex;
                    }

                    action def action_flow{
                        decide node;
                        action controlQualitySignal;
                        action verifyQuality;
                        action repairSignal;
                        merge merge1;
                        action passSignal;


                        first start then node;
                        first node then controlQualitySignal;
                        first controlQualitySignal then verifyQuality;
                        first verifyQuality then merge1;
                        first verifyQuality then repairSignal;
                          first repairSignal then merge1;
                        first merge1 then passSignal;
                        first passSignal then node;
                    }
                }                
                
            
                       
            

            /* ===================================================================
		         * REQUIREMENT USAGE (WIP)
	         * =================================================================== */
            }    
        }
        
    }
    
    


    package Usage{
        /* ===================================================================
        * PART USAGE
         * =================================================================== */
        part pynqZ1 : PYNQZ1 {
            doc /* The instance of the PYNQ-Z1 FPGA board used in the system. */        
        
            /* ===================================================================
                * REQUIREMENT ALLOCATION
             * =================================================================== */
            satisfy requirement resourceReq : FPGA_ResourceRequirements by this{
                requirement LogicElements:>> LogicElementsRequirement{
                    attribute :>> actual = system.logicElements;
                    attribute :>> required = logicElements;
                }
                requirement DSPBlocks:>> DSPBlocksRequirement{
                    attribute :>> actual = system.dspBlocks;
                    attribute :>> required = dspBlocks;
                }
                requirement BlockRAM:>> BlockRAMRequirement{
                    attribute :>> actual = system.blockRAM;
                    attribute :>> required = blockRAM;
                }
                requirement IOPins:>> IOPinsRequirement{
                    attribute :>> actual = system.ioPins;
                    attribute :>> required = ioPins;
                }
            }

            satisfy requirement PerformanceReq : FPGA_PerformanceRequirements by this{
                attribute :>> actual = system.performance;
                attribute :>> required = performance;
            }
            satisfy requirement SafetyReq : FPGA_SafetyRequirement by this{
                attribute :>> actualDetectionTime = system.safetyDetectionTime;
                attribute :>> actualRecoveryTime = system.safetyRecoveryTime;
                attribute :>> requiredTime = 100 [milli*s];
            }
            satisfy requirement SecuriyReq : FPGA_SecurityRequirement by this {
                attribute :>> actualFeatures = securityFeatures;
            }
            satisfy requirement ReliabilityReq : FPGA_ReliabilityRequirement by this{
                attribute :>> actual_MTBF = mtbf;
                attribute :>> required_MTBF = 10000 [hour];
                attribute :>> actual_temperature = system.temperature;
                attribute :>> required_temperature = temperature;
            }


            satisfy requirement PowerReq : FPGA_PowerRequirement by this{
                attribute :>> actual = system.used_power;
                attribute :>> required = power.maxPower;
            }

            satisfy requirement ThermalReq : FPGA_ThermalRequirement by this{
                attribute :>> actual = system.temperature; 
                attribute :>> required = temperature;
            }

            
        }
    }




    


package Views{




    viewpoint def HardwareViewpoint {
        doc /* Viewpoint for hardware architecture visualization.
             * Filters: Emphasize hardware components and their usage.
             * Suitable for understanding:
             * - The overall hardware architecture weight of the system
             * - The main hardware components and their own resource needs
             * - Performance and reliability characteristics */
    
    }

    viewpoint fpgaEngineerViewpoint : HardwareViewpoint;


    viewpoint def SignalFlowViewpoint {
		doc /* Viewpoint for signal and data flow visualization.
			 * Filters: Emphasize ports, interfaces, and data movement.
			 * Suitable for understanding:
			 * - How signals flow through the system
			 * - Port-to-port connections
			 * - External interfaces
			 * - Latency and throughput characteristics */
	}

     /* ===================================================================
        * PARTE USAGE
      * =================================================================== */
    view def ResourceUsageView{
        doc /* View for visualizing the resource usage of the FPGA hardware, showing how the various components and subsystems utilize the available resources. */
        satisfy fpgaEngineerViewpoint;
    }



    view resourceUsageView : ResourceUsageView{
        // EXPOSE ELEMENTS
        expose FPGA_Hardware::PYNQZ1;
        
        // FILTERS
        filter @SysML::AttributeUsage;

        // VISUALIZATION
        render viewRendering;
    }


    viewpoint def EngineerViewpoint {
        doc /* Viewpoint for use case visualization.
            * Shows actors, subject system, and use cases with semantic links. */
    }
    viewpoint systemEngineerViewpoint : EngineerViewpoint;
    
    view def UseCaseView {
        doc /* View definition for actor/use-case visualization. */
        satisfy systemEngineerViewpoint;
    }

    view def SequenceView {
        doc /* View definition for sequence diagram visualization. */
        satisfy systemEngineerViewpoint;
    }


    view useCaseView : UseCaseView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase;
        
        attribute depth = 1;
        attribute fileName = "UseCaseView";
        attribute fileType = "png";
        render viewRendering;
    }

    view useCaseView_V2 : StandardViewDefinitions::GeneralView {
        attribute depth = 1;
        attribute fileName = "UseCaseView";
        attribute fileType = "png";
        
		expose PYNQZ1::system::systemUseCase::follower_vehicle;
		expose PYNQZ1::system::systemUseCase::leader_vehicle;
		expose PYNQZ1::system::systemUseCase::cloud_service;
		expose PYNQZ1::system::systemUseCase::person_actor;
		expose PYNQZ1::system::systemUseCase::general_interactor_actor;
		expose PYNQZ1::system::systemUseCase::cacc_synchronization;
		expose PYNQZ1::system::systemUseCase::abruptCutIn;
		expose PYNQZ1::system::systemUseCase::calledCutIn;
		expose PYNQZ1::system::systemUseCase::shockwavesMitigation;
		expose PYNQZ1::system::systemUseCase::crossRoadAdaptation;
		expose PYNQZ1::system::systemUseCase::fragmentedSignalManagement;
		expose PYNQZ1::system::systemUseCase::degradedSignalManagement;
		expose PYNQZ1::system::systemUseCase::pedestrianProtection;
		expose PYNQZ1::system::systemUseCase::specialVehicle;
		expose PYNQZ1::system::systemUseCase::wrongWayDriverProtection;
		expose PYNQZ1::system::systemUseCase::signalViolationProtection;
		expose PYNQZ1::system::systemUseCase::roadConditionWarning;
		expose PYNQZ1::system::systemUseCase::roadHazardWarning;
		expose PYNQZ1::system::systemUseCase::speedLimitsAdaptation;
		expose PYNQZ1::system::systemUseCase::adaptingFollowing;
		expose PYNQZ1::system::systemUseCase::cacc_synchronization::car_following_model;
		expose PYNQZ1::system::systemUseCase::infrastructure;
	}

    view actionflow : StandardViewDefinitions::ActionFlowView{
        attribute depth = 4;
        attribute fileName = "ActionFlowView";
        attribute fileType = "png";
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::V2X_CarFollowing_System::**;

        filter @SysML::PartUsage;
    }

    view stateTransitionFlow : StandardViewDefinitions::StateTransitionView {
        attribute depth = 4;
        attribute fileName = "StateTransitionFlow";
        attribute fileType = "png";
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::V2XCarFollowingSystem;
    }

    view generalView : StandardViewDefinitions::GeneralView{
        attribute depth = 4;
        attribute fileName = "GeneralView";
        attribute fileType = "png";
        expose FPGA_Hardware::PYNQZ1::system;
        filter @SysML::PortUsage;

    }

    view uc1_SequenceView : StandardViewDefinitions::SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::cacc_synchronization::sequence;
    }

    view uc2_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::abruptCutIn::sequence;
        
        render viewRendering;
    }

    view uc3_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::calledCutIn::sequence;
        
        render viewRendering;
    }

    view uc4_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::shockwavesMitigation::sequence;
        
        render viewRendering;
    }

    view uc5_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::adaptingFollowing::sequence;
        
        render viewRendering;
    }

    view uc6_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::crossRoadAdaptation::sequence;
        
        render viewRendering;
    }

    view uc7_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::speedLimitsAdaptation::sequence;
        
        render viewRendering;
    }

    view uc8_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::roadHazardWarning::sequence;
        
        render viewRendering;
    }

    view uc9_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::roadConditionWarning::sequence;
        
        render viewRendering;
    }

    view uc10_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::signalViolationProtection::sequence;
        
        render viewRendering;
    }

    view uc11_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::wrongWayDriverProtection::sequence;
        
        render viewRendering;
    }

    view uc12_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::specialVehicle::sequence;
        
        render viewRendering;
    }

    view uc13_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::pedestrianProtection::sequence;
        
        render viewRendering;
    }

    view uc14_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::degradedSignalManagement::sequence;
        
        render viewRendering;
    }

    view uc15_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::fragmentedSignalManagement::sequence;
    }
        
    view uc13_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::pedestrianProtection::sequence;
        
        render viewRendering;
    }

    view uc14_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::degradedSignalManagement::sequence;
        
        render viewRendering;
    }

    view uc15_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::fragmentedSignalManagement::sequence;
        
        render viewRendering;
    }


    
}

}
