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
    private import Metadata_Definitions::*;
    private import ViewDefinitions::*;


    private import system_test::*;
    
    

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
            
                   
            // Connessioni con la sintassi corretta
            connection validated_data_flow : ValidatedData connect inputGateway.validatedOut to elaboration.validatedIn;
            connection ego_vehicle_data_flow : EgoVehicleData connect inputGateway.egoOut to camComposer.egoIn;
            connection security_alerts_flow : SecurityAlertsFlow connect inputGateway.secMonOut to outputGateway.secMonIn;
            connection control_flow : ControlFlow connect elaboration.controlOut to outputGateway.controlIn;
            connection cam_flow : CAM_Flow connect camComposer.camOut to outputGateway.camIn;

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

                action def old_general_Action_Flow{
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

                            fork sVfork1;
                            join sVjoin1;                            
                            first start then sVfork1;
                            first sVfork1 then validateCAM;
                              first validateCAM then sVjoin1;
                            first sVfork1 then validateMCM;
                              first validateMCM then sVjoin1;
                            first sVfork1 then validateSPaT;
                              first validateSPaT then sVjoin1;
                            first sVfork1 then validateMAP;
                              first validateMAP then sVjoin1;
                            first sVfork1 then validateIVS;
                              first validateIVS then sVjoin1;
                            first sVfork1 then validateDENM;
                              first validateDENM then sVjoin1;
                            first sVfork1 then validateEVA;
                              first validateEVA then sVjoin1;
                            first sVfork1 then validateVRU;
                              first validateVRU then sVjoin1;
                            first sVfork1 then validateCPM;
                              first validateCPM then sVjoin1;
                            first sVfork1 then validateSVW;
                              first validateSVW then sVjoin1;
                            
                            first sVjoin1 then done;         // only valid signal will be taken in the next processing                        }
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
                            doc /* Execute all analysys to control parameters generation. */
                            action determineLeaderProfile;
                            action evaluateGLOSA;
                            action evaluateCutInManuever;
                            action evaluateWrongWayVehicle;
                            action evaluateEmergencyVehicle;
                            action evaluatePedestrianRisk;
                            action evaluateSignalViolation;
                            action evaluateStringStability;
                            action computeFollowingParameters;
                            fork dMfork1;
                            join dMjoin1;
                            

                            first start then dMfork1;
                            first dMfork1 then determineLeaderProfile;
                              first determineLeaderProfile then dMjoin1;
                            first dMfork1 then evaluateGLOSA;
                              first evaluateGLOSA then dMjoin1;
                            first dMfork1 then evaluateCutInManuever;
                              first evaluateCutInManuever then dMjoin1;
                            first dMfork1 then evaluateWrongWayVehicle;
                              first evaluateWrongWayVehicle then dMjoin1;
                            first dMfork1 then evaluateEmergencyVehicle;
                              first evaluateEmergencyVehicle then dMjoin1;
                            first dMfork1 then evaluatePedestrianRisk;
                              first evaluatePedestrianRisk then dMjoin1;
                            first dMfork1 then evaluateSignalViolation;
                              first evaluateSignalViolation then dMjoin1;
                            first dMfork1 then evaluateStringStability;
                              first evaluateStringStability then dMjoin1;
                            first dMjoin1 then computeFollowingParameters;
                            first computeFollowingParameters then done;
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
                        doc /* Produces vehicle output data (generated parameters, update for HMI display, CAM for following vehicle). */
                        action sendUpdatedCAM;
                        action sendUpdatedParameters;
                        action updateHMIDisplay;
                        fork outFork;
                        join outJoin;
                        first start then outFork;
                        first outFork then sendUpdatedParameters;
                        first outFork then sendUpdatedCAM;
                        first outFork then updateHMIDisplay;
                        first sendUpdatedParameters then outJoin;
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

    viewpoint def SystemViewpoint{
        doc /* Viewpoint for system architecture visualization.
             * Filters: Emphasize system components, their interactions, and use case realization.
             * Suitable for understanding:
             * - The overall system architecture and its main components
             * - The interactions between components and how they realize the use cases
             * - The allocation of requirements to system components */
    }

    viewpoint def EngineerViewpoint {
        doc /* Viewpoint for use case visualization.
            * Shows actors, subject system, and use cases with semantic links. */
    }

    viewpoint fpgaEngineerViewpoint : HardwareViewpoint;
    viewpoint systemEngineerViewpoint : SystemViewpoint;
    viewpoint systemEngineerViewpoint : EngineerViewpoint;
    



    
    /* ===================================================================
        * VIEWS USAGE
     * =================================================================== */    
    
    view resourceUsageView : ResourceUsageView{
        expose FPGA_Hardware::PYNQZ1;
        @ViewRendering { fileName = "ResourceUsage-View"; }
        @AnalysisInfo {
            label       = "Resource Usage";
            groupName   = "L3 — DSP Subsystem";
            domain      = "Resources";
            icon        = "📊";
            level       = "L3";
            kind        = "BlackBox";
            component   = "PYNQZ1_DSP";
            parentGroup = "B_W";
        }
    }

    view useCaseView : UseCaseView {
        satisfy systemEngineerViewpoint;
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase;
        @ViewRendering { fileName = "UseCase-View"; }
        @AnalysisInfo {
            label       = "Use Case View";
            groupName   = "L1 — System Black-Box";
            domain      = "Functional";
            icon        = "👤";
            level       = "L1";
            kind        = "BlackBox";
            component   = "";
            parentGroup = "B_W";
        }
    }

    view actionflow : StandardViewDefinitions::ActionFlowView{
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::V2X_CarFollowing_System::**;
        @ViewRendering { fileName = "ActionFlow-View"; }
        filter @SysML::PartUsage;
        @AnalysisInfo {
            label       = "Action Flow";
            groupName   = "L3 — System Behavioral";
            domain      = "Behavioral";
            icon        = "⚡";
            level       = "L3";
            kind        = "BlackBox";
            component   = "PYNQZ1_System";
            parentGroup = "B_W";
        }
    }

    view stateTransitionFlow : StandardViewDefinitions::StateTransitionView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::V2XCarFollowingSystem;
        @ViewRendering { fileName = "StateTransition-View"; }
        @AnalysisInfo {
            label       = "State Transitions";
            groupName   = "L3 — System Behavioral";
            domain      = "Behavioral";
            icon        = "🔄";
            level       = "L3";
            kind        = "BlackBox";
            component   = "PYNQZ1_System";
            parentGroup = "B_W";
        }
    }

    view generalView : StandardViewDefinitions::GeneralView{
        expose FPGA_Hardware::PYNQZ1::system;
        filter @SysML::PortUsage;
        @ViewRendering { fileName = "General-View"; }
        @AnalysisInfo {
            label = "General Structure";
            icon  = "🔍";
        }
    }

    view interconnectionView : StandardViewDefinitions::InterconnectionView {
        doc /* View definition for interconnection visualization. */
        expose FPGA_Hardware::PYNQZ1::system;
        @ViewRendering { fileName = "Interconnection-View"; }
        @AnalysisInfo {
            label       = "Interconnection View";
            groupName   = "L2 — System White-Box";
            domain      = "Physical";
            icon        = "🔗";
            level       = "L2";
            kind        = "WhiteBox";
            component   = "";
            parentGroup = "B_W";
        }
    }

    view uc1_SequenceView : StandardViewDefinitions::SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::cacc_synchronization::sequence;
        @AnalysisInfo { label = "CACC Sync — Sequence"; icon = "🎬"; }
    }

    view uc2_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::abruptCutIn::sequence;
        @AnalysisInfo { label = "Abrupt Cut-In — Sequence"; icon = "🎬"; }
    }

    view uc3_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::calledCutIn::sequence;
        @AnalysisInfo { label = "Called Cut-In — Sequence"; icon = "🎬"; }
    }

    view uc4_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::shockwavesMitigation::sequence;
        @AnalysisInfo { label = "Shockwaves Mitigation — Sequence"; icon = "🎬"; }
    }

    view uc5_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::adaptingFollowing::sequence;
        @AnalysisInfo { label = "Adapting Following — Sequence"; icon = "🎬"; }
    }

    view uc6_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::crossRoadAdaptation::sequence;
        @AnalysisInfo { label = "Cross-Road Adaptation — Sequence"; icon = "🎬"; }
    }

    view uc7_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::speedLimitsAdaptation::sequence;
        @AnalysisInfo { label = "Speed Limits Adaptation — Sequence"; icon = "🎬"; }
    }

    view uc8_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::roadHazardWarning::sequence;
        @AnalysisInfo { label = "Road Hazard Warning — Sequence"; icon = "🎬"; }
    }

    view uc9_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::roadConditionWarning::sequence;
        @AnalysisInfo { label = "Road Condition Warning — Sequence"; icon = "🎬"; }
    }

    view uc10_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::signalViolationProtection::sequence;
        @AnalysisInfo { label = "Signal Violation Protection — Sequence"; icon = "🎬"; }
    }

    view uc11_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::wrongWayDriverProtection::sequence;
        @AnalysisInfo { label = "Wrong-Way Driver Protection — Sequence"; icon = "🎬"; }
    }

    view uc12_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::specialVehicle::sequence;
        @AnalysisInfo { label = "Special Vehicle — Sequence"; icon = "🎬"; }
    }

    view uc13_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::pedestrianProtection::sequence;
        @AnalysisInfo { label = "Pedestrian Protection — Sequence"; icon = "🎬"; }
    }

    view uc14_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::degradedSignalManagement::sequence;
        @AnalysisInfo { label = "Degraded Signal Management — Sequence"; icon = "🎬"; }
    }

    view uc15_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::fragmentedSignalManagement::sequence;
        @AnalysisInfo { label = "Fragmented Signal Management — Sequence"; icon = "🎬"; }
    }



    view gridView : StandardViewDefinitions::GridView {
        doc /* Grid/tabular view: mostra tutti gli attributi del blocco PYNQZ1
             * con nome, tipo, valore e unità di misura. */
        expose FPGA_Hardware::PYNQZ1;
        filter @SysML::AttributeUsage;
        @ViewRendering { fileName = "Grid-View"; }
        @AnalysisInfo {
            label       = "Attribute Grid";
            groupName   = "L3 — DSP Subsystem";
            domain      = "Attributes";
            icon        = "▦";
            level       = "L3";
            kind        = "BlackBox";
            component   = "PYNQZ1_DSP";
            parentGroup = "B_W";
        }
    }

    view browserView : StandardViewDefinitions::BrowserView {
        doc /* Browser view: presenta la struttura gerarchica del package
             * FPGA_Hardware come albero espandibile. */
        expose FPGA_Hardware;
        @ViewRendering { fileName = "Browser-View"; }
        @AnalysisInfo {
            label       = "Model Browser";
            groupName   = "Tools & Infrastructure";
            domain      = "Navigation";
            icon        = "🌳";
            level       = "L1";
            kind        = "";
            component   = "";
            parentGroup = "";
        }
    }

    view requirementView : RequirementView {
        doc /* Requirement view: mostra i blocchi satisfy-requirement dell'istanza pynqZ1
             * con i requisiti annidati e i valori actual vs required. */
        expose FPGA_Hardware::PYNQZ1::system;
        @ViewRendering { fileName = "Requirement-View"; }
        @AnalysisInfo {
            label       = "Requirement View";
            groupName   = "L1 — System Black-Box";
            domain      = "Requirements";
            icon        = "📋";
            level       = "L1";
            kind        = "BlackBox";
            component   = "";
            parentGroup = "B_W";
        }
    }

    view analysisView : AnalysisView {
        doc /* Analysis dashboard — discovers views via attribute level/kind/parentGroup. */
        expose Views;
        @AnalysisInfo { label = "Analysis Dashboard"; icon = "📊"; }
    }

    
}

package Requirement{
    private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;


    /* ===================================================================
		 * SYSTEM REQUIREMENTS (WIP)
	 * =================================================================== */
    
    requirement cam_receptionRate : CAM_ReceptionRate {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = ""; 
        }
                
        attribute :>> requiredRate = 10 [Hz];
    }
    satisfy cam_receptionRate by FPGA_Hardware::PYNQZ1::system;

    requirement cam_basedFollowingComputation : CAM_BasedFollowingComputation {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = ""; 
        }
                
        
    }
    satisfy cam_basedFollowingComputation by FPGA_Hardware::PYNQZ1::system;

    requirement cam_transmission : CAM_Transmission{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = ""; 
        }
    }
    satisfy cam_trasmission by FPGA_Hardware::PYNQZ1::system;

    requirement cutInDetection : CutInDetection{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = ""; 
        }
    }
    satisfy cutInDetection by FPGA_Hardware::PYNQZ1::system;

    requirement cutInEmergencyBraking : CutInEmergencyBraking{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = ""; 
        }
    }
    satisfy cutInEmergencyBraking by FPGA_Hardware::PYNQZ1::system;

    requirement cutInRequest{
        requirement cutInRequestFeasibilityCheck : CutInRequestFeasibilityCheck{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
            }

        }

        requirement cutInAccept : CutInAccept{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
            }
        } 

        requirement cutInReject : CutInReject{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
            }
        }



    }
    satisfy cutInRequest by FPGA_Hardware::PYNQZ1::system;

    
    requirement cutInCompletionRevert : CutInCompletionRevert{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = ""; 
        }
    }
    satisfy cutInCompletionRevert by FPGA_Hardware::PYNQZ1::system;

    requirement shockwaveMitigazion{
        requirement jamRateCalculation : JamRateCalculation{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
            }
        }

        requirement jamMitigationHeadwayIncrease : JamMitigationHeadwayIncrease{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }
    }
    satisfy shockwaveMitigazion by FPGA_Hardware::PYNQZ1::system;


    requirement leaderClassification{
        requirement leaderProfileClassification : LeaderProfileClassification{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement profileBasedParameterModifiers : ProfileBasedParameterModifiers{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        } 
    }
    satisfy leaderClassification by FPGA_Hardware::PYNQZ1::system;

    requirement crossroadAdaptation{
        requirement spat_map_Reception: SPAT_MAP_Reception{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement glosaFeasibilityCalculation : GLOSAFeasibilityCalculation{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement glosaSpeedAdaptation : GLOSASpeedAdaptation{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement GLOSANonGreenDeceleration : GLOSANonGreenDeceleration{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }
    }
    satisfy crossroadAdaptation by FPGA_Hardware::PYNQZ1::system;

    requirement speedLimitEnforcement : SpeedLimitEnforcement{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }

    requirement roadHazardWarningResponse : RoadHazardWarningResponse{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy roadHazardWarningResponse by FPGA_Hardware::PYNQZ1::system;

    requirement signalViolationWarningReception : SignalViolationWarningReception{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy signalViolationWarningReception by FPGA_Hardware::PYNQZ1::system;

    requirement swm{
        requirement swm_ReceptionForAction : SVW_ReceptionForAction{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement swm_EmergencyBrake : SVW_EmergencyBrake{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement swm_ModerateDeceleration : SVW_ModerateDeceleration{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }
    }
    satisfy swm by FPGA_Hardware::PYNQZ1::system;

    requirement wrongWay_Adaptation{
        requirement WrongWayVehicle_LateralHeadwayIncrease : WrongWayVehicle_LateralHeadwayIncrease{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement wrongWayVehicle_EvasionManeuver : WrongWayVehicle_EvasionManeuver{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement wrongWayVehicle_RestoreLateralHeadway : WrongWayVehicle_RestoreLateralHeadway{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }
    }
    satisfy wrongWay_Adaptation by FPGA_Hardware::PYNQZ1::system;

    requirement emergencyVehicle{
        requirement emergencyVehicle_LateralHeadwayIncrease : EmergencyVehicle_LateralHeadwayIncrease{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement emergencyVehicle_RestoreLateralHeadway : EmergencyVehicle_RestoreLateralHeadway{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }
    }
    satisfy emergencyVehicle by FPGA_Hardware::PYNQZ1::system;

    requirement pedestrian{
        requirement pedestrian_TTACalculation : Pedestrian_TTACalculation{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement pedestrian_ProceedIfTTAHigh : Pedestrian_ProceedIfTTAHigh{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement pedestrian_SlowDownForTTA : Pedestrian_SlowDownForTTA{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement pedestrian_EmergencyBrakeForTTA : Pedestrian_EmergencyBrakeForTTA{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }

        requirement pedestrian_ResumeAfterAlarm : Pedestrian_ResumeAfterAlarm{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
            }
        }
    }
    satisfy pedestrian by FPGA_Hardware::PYNQZ1::system;

    requirement state_Comunication : State_Comunications{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy state_Comunication by FPGA_Hardware::PYNQZ1::system;
    
    
    /* ===================================================================
		 * SYSTEM REQUIREMENTS (WIP)
	 * =================================================================== */
    
    requirement noRearEndCollision_V2VError : NoRearEndCollision_V2VError {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noRearEndCollision_V2VError by FPGA_Hardware::PYNQZ1::system;

    requirement noCollisionDuringAssistedCutIn : NoCollisionDuringAssistedCutIn {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noCollisionDuringAssistedCutIn by FPGA_Hardware::PYNQZ1::system;

    requirement noIntersectionCollision_V2IError : NoIntersectionCollision_V2IError {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noIntersectionCollision_V2IError by FPGA_Hardware::PYNQZ1::system;
    
    requirement noPedestrianIncident : NoPedestrianIncident {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noPedestrianIncident by FPGA_Hardware::PYNQZ1::system;
    
    requirement noEmergencyVehicleCollision : NoEmergencyVehicleCollision {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noEmergencyVehicleCollision by FPGA_Hardware::PYNQZ1::system;
    
    requirement noWrongWayVehicleCollision : NoWrongWayVehicleCollision {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noWrongWayVehicleCollision by FPGA_Hardware::PYNQZ1::system;
    
    requirement noStringInstabilityAmplification : NoStringInstabilityAmplification {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noStringInstabilityAmplification by FPGA_Hardware::PYNQZ1::system;
    
    requirement legalSpeedLimitCompliance : LegalSpeedLimitCompliance {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy legalSpeedLimitCompliance by FPGA_Hardware::PYNQZ1::system;
    
    requirement noUnnecessaryOrExcessiveEmergencyBrake : NoUnnecessaryOrExcessiveEmergencyBrake {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noUnnecessaryOrExcessiveEmergencyBrake by FPGA_Hardware::PYNQZ1::system;
    
    requirement noUnstableOrExcessiveEvasionManeuver : NoUnstableOrExcessiveEvasionManeuver {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy noUnstableOrExcessiveEvasionManeuver by FPGA_Hardware::PYNQZ1::system;




    // ==================== 2.3 SOTIF Requirements (ISO 21448) integrated with ISO 34502 ====================

    requirement leaderProfile_ConservativeFallback : LeaderProfile_ConservativeFallback {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy leaderProfile_ConservativeFallback by FPGA_Hardware::PYNQZ1::system;

    requirement jamRate_FalsePositiveHandling : JamRate_FalsePositiveHandling {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy jamRate_FalsePositiveHandling by FPGA_Hardware::PYNQZ1::system;

    requirement jamRate_FalsePositiveHandling : JamRate_FalsePositiveHandling {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }

    requirement glosa_UnreachableGreenWaveHandling : GLOSA_UnreachableGreenWaveHandling {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy glosa_UnreachableGreenWaveHandling by FPGA_Hardware::PYNQZ1::system;

    requirement denm_ConfidenceLevelValidation : DENM_ConfidenceLevelValidation {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy denm_ConfidenceLevelValidation by FPGA_Hardware::PYNQZ1::system;

    requirement denm_ConfidenceLevelValidation : DENM_ConfidenceLevelValidation{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy denm_ConfidenceLevelValidation by FPGA_Hardware::PYNQZ1::system;

    requirement pedestrian_OnboardVerification : Pedestrian_OnboardVerification {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy pedestrian_OnboardVerification by FPGA_Hardware::PYNQZ1::system;
    

    requirement emergencyManeuver_ODDRestrictions : EmergencyManeuver_ODDRestrictions {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy emergencyManeuver_ODDRestrictions by FPGA_Hardware::PYNQZ1::system;

    // ==================== 2.4 Safety Requirements from ISO 34502 (Scenario-Based Safety Evaluation) ====================

    requirement scenarioCatalogGeneration : ScenarioCatalogGeneration{
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy scenarioCatalogGeneration by FPGA_Hardware::PYNQZ1::system;

    requirement scenarioBasedSafetyIntegration : ScenarioBasedSafetyIntegration {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy scenarioBasedSafetyIntegration by FPGA_Hardware::PYNQZ1::system;

    requirement scenarioResultsAgainstAcceptanceCriteria : ScenarioResultsAgainstAcceptanceCriteria {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy scenarioResultsAgainstAcceptanceCriteria by FPGA_Hardware::PYNQZ1::system;
    

    requirement odd_ScenarioCoverageDocumentation : ODD_ScenarioCoverageDocumentation {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy odd_ScenarioCoverageDocumentation by FPGA_Hardware::PYNQZ1::system;

    requirement v2x_DegradedChannelScenarios : V2X_DegradedChannelScenarios {
        @RequirementStatus { 
            status = "Draft"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy v2x_DegradedChannelScenarios by FPGA_Hardware::PYNQZ1::system;

    requirement v2x_CybersecurityTestScenarios : V2X_CybersecurityTestScenarios {
        @RequirementStatus { 
            status = "Rejected"; 
            approver = ""; 
            date = "";
        }
    }
    satisfy v2x_CybersecurityTestScenarios by FPGA_Hardware::PYNQZ1::system;
    
    //TODO: Terminare di allocare i Requirement
    

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

}
