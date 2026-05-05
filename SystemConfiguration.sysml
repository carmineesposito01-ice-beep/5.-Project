package V2X_CACC_Model{
    doc /* Top-Level system of the cacc model, to generate parameter for a platooning model (microscopic) */

    private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;

    private import StandardLibrary::**;
    private import ComponentDefinition::*;

    //private import system_test::*;  //TODO: Da togliere quando l'avremo spostato in ComponentDefinitions con gli altri

    package Structure{
        /* ===================================================================
             * PART USAGE
         * =================================================================== */
        part def V2X_CACC_System {
            doc /* The main system part representing the entire V2X CACC system. */
            
            part top_system : topLevelSystem {
                doc /* The top-level system (allocated on the PYNQ-Z1 FPGA board), which integrates the various subsystems. */
                
                    
                // Connessioni con la sintassi corretta
                connection validated_data_flow : ValidatedData connect inputGateway.validatedSignal to elaboration.validatedSignal;
                connection ego_vehicle_data_flow : EgoVehicleData connect inputGateway.egoSignals to camComposer.egoIn;
                connection state_flag : PlatooningInfoOutPort connect inputGateway.state_flag to outputGateway.state_flag;
                connection control_flow : ControlFlow connect elaboration.modelParameters to outputGateway.modelParameters;
                connection cam_flow : CAM_Flow connect camComposer.camOut to outputGateway.camIn;

            }
        }
    }

    package Behaviour{
        /* ===================================================================
             * ACTOR ALLOCATION
         * =================================================================== */
        part follower : Vehicle;
        part following : Vehicle;
        part extraneous : Vehicle;
        part infrastructure : Infrastructure;
        part cloud : CloudService;
        part person : Person;
        part general_interactor : Interactor;
        part cfm : CarFollowingModel;
        
        /* ===================================================================
             * USE CASE USAGE (Top-Use Case)
         * =================================================================== */
        use case systemUseCase : UC0_SystemUseCases{
                doc /* Allocation of the overall system use cases to the system. */
                subject System = Structure::V2X_CACC_System::top_system;
                actor  follower_vehicle = follower;
                actor  leader_vehicle = following;
                actor  lateral_vehicle = extraneous;
                actor  infrastructure = infrastructure;
                actor  cloud_service = cloud;
                actor  person_actor = person;
                actor  general_interactor_actor = general_interactor;
                
                // CONNECTIONS TODO: Rimuovere e realizzare la logica automatica degli use case (senza l'innesto in un use case totale come adesso)
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

                /* ===================================================================
                     * ACTION FLOW FOR V2X CAR-FOLLOWING SYSTEM
                 * =================================================================== */
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

                /* ===================================================================
                     * STATE MACHINE FOR V2X CAR-FOLLOWING SYSTEM
                 * =================================================================== */
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
    

   
                
                
                /* ===================================================================
                     * USE CASE USAGE (Top-Use Case)
                 * =================================================================== */
                use case cacc_synchronization : UC1_CACC_Synchronization{
                    doc /* Allocation of the CACC Synchronization use case to the system. */
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                    subject :>> System = System;
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
                
            
                       
            }    


    }

    package Requirements{
        /* ===================================================================
		     * SYSTEM REQUIREMENTS (WIP)
	     * =================================================================== */
    
        requirement cam_receptionRate : CAM_ReceptionRate {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONALE REQ"; 
            }
                    
            attribute :>> requiredRate = 10 [Hz];
        }
        satisfy cam_receptionRate by Structure::V2X_CACC_System::top_system;

        requirement cam_basedFollowingComputation : CAM_BasedFollowingComputation {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ"; 
            }
                    
            
        }
        satisfy cam_basedFollowingComputation by Structure::V2X_CACC_System::top_system;

        requirement cam_transmission : CAM_Transmission{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
        }
        satisfy cam_transmission by Structure::V2X_CACC_System::top_system;

        requirement cutInDetection : CutInDetection{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONALE REQ";  
            }
        }
        satisfy cutInDetection by Structure::V2X_CACC_System::top_system;

        requirement cutInEmergencyBraking : CutInEmergencyBraking{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
        }
        satisfy cutInEmergencyBraking by Structure::V2X_CACC_System::top_system;

        requirement cutInRequest{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
            requirement cutInRequestFeasibilityCheck : CutInRequestFeasibilityCheck{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = ""; 
                    group = "FUNCTIONALE REQ"; 
                }

            }

            requirement cutInAccept : CutInAccept{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = ""; 
                    group = "FUNCTIONALE REQ"; 
                }
            } 

            requirement cutInReject : CutInReject{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = ""; 
                    group = "FUNCTIONALE REQ"; 
                }
            }



        }
        satisfy cutInRequest by Structure::V2X_CACC_System::top_system;

        
        requirement cutInCompletionRevert : CutInCompletionRevert{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ"; 
            }
        }
        satisfy cutInCompletionRevert by Structure::V2X_CACC_System::top_system;

        requirement shockwaveMitigazion{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
            requirement jamRateCalculation : JamRateCalculation{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = ""; 
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement jamMitigationHeadwayIncrease : JamMitigationHeadwayIncrease{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }
        }
        satisfy shockwaveMitigazion by Structure::V2X_CACC_System::top_system;


        requirement leaderClassification{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
            requirement leaderProfileClassification : LeaderProfileClassification{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement profileBasedParameterModifiers : ProfileBasedParameterModifiers{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            } 
        }
        satisfy leaderClassification by Structure::V2X_CACC_System::top_system;

        requirement crossroadAdaptation{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
            requirement spat_map_Reception: SPAT_MAP_Reception{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement glosaFeasibilityCalculation : GLOSAFeasibilityCalculation{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement glosaSpeedAdaptation : GLOSASpeedAdaptation{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement GLOSANonGreenDeceleration : GLOSANonGreenDeceleration{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }
        }
        satisfy crossroadAdaptation by Structure::V2X_CACC_System::top_system;

        requirement speedLimitEnforcement : SpeedLimitEnforcement{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONALE REQ"; 
            }
        }

        requirement roadHazardWarningResponse : RoadHazardWarningResponse{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONALE REQ"; 
            }
        }
        satisfy roadHazardWarningResponse by Structure::V2X_CACC_System::top_system;

        requirement signalViolationWarningReception : SignalViolationWarningReception{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONALE REQ"; 
            }
        }
        satisfy signalViolationWarningReception by Structure::V2X_CACC_System::top_system;

        requirement swm{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONALE REQ"; 
            }
            requirement swm_ReceptionForAction : SVW_ReceptionForAction{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement swm_EmergencyBrake : SVW_EmergencyBrake{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement swm_ModerateDeceleration : SVW_ModerateDeceleration{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }
        }
        satisfy swm by Structure::V2X_CACC_System::top_system;

        requirement wrongWay_Adaptation{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
            requirement WrongWayVehicle_LateralHeadwayIncrease : WrongWayVehicle_LateralHeadwayIncrease{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
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
                    group = "FUNCTIONALE REQ"; 
                }
            }
        }
        satisfy wrongWay_Adaptation by Structure::V2X_CACC_System::top_system;

        requirement emergencyVehicle{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
            requirement emergencyVehicle_LateralHeadwayIncrease : EmergencyVehicle_LateralHeadwayIncrease{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement emergencyVehicle_RestoreLateralHeadway : EmergencyVehicle_RestoreLateralHeadway{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }
        }
        satisfy emergencyVehicle by Structure::V2X_CACC_System::top_system;

        requirement pedestrian{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = ""; 
                group = "FUNCTIONALE REQ";
            }
            requirement pedestrian_TTACalculation : Pedestrian_TTACalculation{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement pedestrian_ProceedIfTTAHigh : Pedestrian_ProceedIfTTAHigh{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement pedestrian_SlowDownForTTA : Pedestrian_SlowDownForTTA{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement pedestrian_EmergencyBrakeForTTA : Pedestrian_EmergencyBrakeForTTA{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }

            requirement pedestrian_ResumeAfterAlarm : Pedestrian_ResumeAfterAlarm{
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONALE REQ"; 
                }
            }
        }
        satisfy pedestrian by Structure::V2X_CACC_System::top_system;

        requirement state_Comunication : State_Comunications{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONALE REQ"; 
            }
        }
        satisfy state_Comunication by Structure::V2X_CACC_System::top_system;
        
        
        /* ===================================================================
            * SAFETY REQUIREMENTS
        * =================================================================== */
        
        requirement noRearEndCollision_V2VError : NoRearEndCollision_V2VError {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noRearEndCollision_V2VError by FPGA_Hardware::PYNQZ1::system;

        requirement noCollisionDuringAssistedCutIn : NoCollisionDuringAssistedCutIn {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noCollisionDuringAssistedCutIn by FPGA_Hardware::PYNQZ1::system;

        requirement noIntersectionCollision_V2IError : NoIntersectionCollision_V2IError {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noIntersectionCollision_V2IError by FPGA_Hardware::PYNQZ1::system;
        
        requirement noPedestrianIncident : NoPedestrianIncident {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noPedestrianIncident by Structure::V2X_CACC_System::top_system;
        
        requirement noEmergencyVehicleCollision : NoEmergencyVehicleCollision {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noEmergencyVehicleCollision by Structure::V2X_CACC_System::top_system;
        
        requirement noWrongWayVehicleCollision : NoWrongWayVehicleCollision {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noWrongWayVehicleCollision by Structure::V2X_CACC_System::top_system;
        
        requirement noStringInstabilityAmplification : NoStringInstabilityAmplification {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noStringInstabilityAmplification by Structure::V2X_CACC_System::top_system;
        
        requirement legalSpeedLimitCompliance : LegalSpeedLimitCompliance {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy legalSpeedLimitCompliance by Structure::V2X_CACC_System::top_system;
        
        requirement noUnnecessaryOrExcessiveEmergencyBrake : NoUnnecessaryOrExcessiveEmergencyBrake {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noUnnecessaryOrExcessiveEmergencyBrake by Structure::V2X_CACC_System::top_system;
        
        requirement noUnstableOrExcessiveEvasionManeuver : NoUnstableOrExcessiveEvasionManeuver {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SAFETY REQ"; 
            }
        }
        satisfy noUnstableOrExcessiveEvasionManeuver by Structure::V2X_CACC_System::top_system;




        /* ===================================================================
            * SOTIF REQUIREMENTS
        * =================================================================== */

        requirement leaderProfile_ConservativeFallback : LeaderProfile_ConservativeFallback {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }
        satisfy leaderProfile_ConservativeFallback by Structure::V2X_CACC_System::top_system;

        requirement jamRate_FalsePositiveHandling : JamRate_FalsePositiveHandling {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }
        satisfy jamRate_FalsePositiveHandling by Structure::V2X_CACC_System::top_system;

        requirement jamRate_FalsePositiveHandling : JamRate_FalsePositiveHandling {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }

        requirement glosa_UnreachableGreenWaveHandling : GLOSA_UnreachableGreenWaveHandling {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }
        satisfy glosa_UnreachableGreenWaveHandling by Structure::V2X_CACC_System::top_system;

        requirement denm_ConfidenceLevelValidation : DENM_ConfidenceLevelValidation {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }
        satisfy denm_ConfidenceLevelValidation by Structure::V2X_CACC_System::top_system;

        requirement denm_ConfidenceLevelValidation : DENM_ConfidenceLevelValidation{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }
        satisfy denm_ConfidenceLevelValidation by Structure::V2X_CACC_System::top_system;

        requirement pedestrian_OnboardVerification : Pedestrian_OnboardVerification {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }
        satisfy pedestrian_OnboardVerification by Structure::V2X_CACC_System::top_system;
        

        requirement emergencyManeuver_ODDRestrictions : EmergencyManeuver_ODDRestrictions {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SOTIF REQ";
            }
        }
        satisfy emergencyManeuver_ODDRestrictions by Structure::V2X_CACC_System::top_system;

        /* ===================================================================
            * SAFETY-SCENARIO REQUIREMENTS
        * =================================================================== */

        requirement scenarioCatalogGeneration : ScenarioCatalogGeneration{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SCENARIO REQ";
            }
        }
        satisfy scenarioCatalogGeneration by Structure::V2X_CACC_System::top_system;

        requirement scenarioBasedSafetyIntegration : ScenarioBasedSafetyIntegration {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SCENARIO REQ";
            }
        }
        satisfy scenarioBasedSafetyIntegration by Structure::V2X_CACC_System::top_system;

        requirement scenarioResultsAgainstAcceptanceCriteria : ScenarioResultsAgainstAcceptanceCriteria {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SCENARIO REQ";
            }
        }
        satisfy scenarioResultsAgainstAcceptanceCriteria by Structure::V2X_CACC_System::top_system;
        

        requirement odd_ScenarioCoverageDocumentation : ODD_ScenarioCoverageDocumentation {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SCENARIO REQ";
            }
        }
        satisfy odd_ScenarioCoverageDocumentation by Structure::V2X_CACC_System::top_system;

        requirement v2x_DegradedChannelScenarios : V2X_DegradedChannelScenarios {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "SCENARIO REQ";
            }
        }
        satisfy v2x_DegradedChannelScenarios by Structure::V2X_CACC_System::top_system;

        requirement v2x_CybersecurityTestScenarios : V2X_CybersecurityTestScenarios {
            @RequirementStatus { 
                status = "Rejected"; 
                approver = ""; 
                date = "";
                group = "SCENARIO REQ";
            }
        }
        satisfy v2x_CybersecurityTestScenarios by Structure::V2X_CACC_System::top_system;
    
        /* ===================================================================
            * OPERATIONAL REQUIREMENTS
        * =================================================================== */

        requirement v2vSignalLossFallback : V2vSignalLossFallback {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "OPERATIONAL REQ";
            }
        }
        satisfy v2vSignalLossFallback by Structure::V2X_CACC_System::top_system;

        requirement v2vSignalRestoreAndReactivation : V2vSignalRestoreAndReactivation {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "OPERATIONAL REQ";
            }
        }
        satisfy v2vSignalRestoreAndReactivation by Structure::V2X_CACC_System::top_system;

        requirement messageFragmentationHandling : MessageFragmentationHandling {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "OPERATIONAL REQ";
            }
        }
        satisfy messageFragmentationHandling by Structure::V2X_CACC_System::top_system;

        requirement v2iFailureFallback : V2iFailureFallback {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "OPERATIONAL REQ";
            }
        }
        satisfy v2iFailureFallback by Structure::V2X_CACC_System::top_system;

        requirement glosaFailureRecovery : GLOSAFailureRecovery {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "OPERATIONAL REQ";
            }
        }
        satisfy glosaFailureRecovery by Structure::V2X_CACC_System::top_system;

        requirement heartbeatMonitoring : HeartbeatMonitoring {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "OPERATIONAL REQ";
            }
        }
        satisfy heartbeatMonitoring by Structure::V2X_CACC_System::top_system;

        requirement failSafeArchitecture : FailSafeArchitecture {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "OPERATIONAL REQ";
            }
        }
        satisfy failSafeArchitecture by Structure::V2X_CACC_System::top_system;

        /* ===================================================================
            * PERFORMANCE REQUIREMENTS
        * =================================================================== */
        requirement v2v_SafetyEndToEndLatency : V2V_SafetyEndToEndLatency {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PERFORMANCE REQ";
            }
        }
        satisfy v2v_SafetyEndToEndLatency by Structure::V2X_CACC_System::top_system;

        requirement v2i_SafetyEndToEndLatency : V2I_SafetyEndToEndLatency {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PERFORMANCE REQ";
            }
        }
        satisfy v2i_SafetyEndToEndLatency by Structure::V2X_CACC_System::top_system;

        requirement cam_MinimumUpdateRate : CAM_MinimumUpdateRate {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PERFORMANCE REQ";
            }
        }
        satisfy cam_MinimumUpdateRate by Structure::V2X_CACC_System::top_system;
        
        requirement safetyDistance_EstimationAccuracy : SafetyDistanceEstimationAccuracy {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PERFORMANCE REQ";
            }
        }
        satisfy safetyDistance_EstimationAccuracy by Structure::V2X_CACC_System::top_system;

        requirement glosa_ComputationTime : GLOSA_ComputationTime {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PERFORMANCE REQ";
            }
        }
        satisfy glosa_ComputationTime by Structure::V2X_CACC_System::top_system;


        /* ===================================================================
            * PROCESS REQUIREMENTS
        * =================================================================== */
        requirement requirementsTraceability : RequirementsTraceability {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PROCESS REQ";
            }
        }
        satisfy requirementsTraceability by Structure::V2X_CACC_System::top_system;

        requirement requirementsReview : RequirementsReview{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PROCESS REQ";
            }
        }
        satisfy requirementsReview by Structure::V2X_CACC_System::top_system;

        requirement externalInterfaceSpecification : ExternalInterfaceSpecification{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PROCESS REQ";
            }
        }
        satisfy externalInterfaceSpecification by Structure::V2X_CACC_System::top_system;

        requirement safetyCaseDevelopment : SafetyCaseDevelopment{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PROCESS REQ";
            }
        }
        satisfy safetyCaseDevelopment by Structure::V2X_CACC_System::top_system;

        requirement tara_Conduction : TARA_Conduction{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PROCESS REQ";
            }
        }
        satisfy tara_Conduction by Structure::V2X_CACC_System::top_system;

        requirement scenarioCatalogogDefinition : ScenarioCatalogDefinition{
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "PROCESS REQ";
            }
        }
        satisfy scenarioCatalogogDefinition by Structure::V2X_CACC_System::top_system;    

    
    }

    package Analysis{


    }

    package Verification{


    }

    package View_Viewpoint{
        viewpoint hardwareEngineerViewpoint : EngineerViewpoint{
            doc /* Viewpoint for the hardware engineer, focusing on the hardware architecture, components, and interfaces. */
        }
        viewpoint systemEngineerViewpoint : SystemViewpoint{
            doc /* Viewpoint for the system engineer, focusing on the overall system architecture, component interactions, and requirement satisfaction. */
        }
        viewpoint stakeholderViewpoint : StakeholderViewpoint{
            doc /* Viewpoint for stakeholders, focusing on the high-level system goals, use cases, and requirement fulfillment. */
        }
        viewpoint softwareEngineerViewpoint : EngineerViewpoint{
            doc /* Viewpoint for the software engineer, focusing on the software architecture, components, and interfaces. */
        }

        
        view analysisView : AnalysisView {
            doc /* Analysis dashboard — discovers views via attribute level/kind/parentGroup. */
            satisfy systemEngineerViewpoint;
            @ViewRendering { fileName = "Analysis-View"; }
            @AnalysisInfo { 
                label = "Analysis Dashboard"; 
                icon = "📊"; 
            }
            expose View_Viewpoint;
        }

        view gridView : StandardViewDefinitions::GridView {
            doc /* Grid view: presents a grid of key system attributes, such as requirements, functions, components, and interfaces, with information on their status, importance, and their relationship with other elements of the system. */
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
            @ViewRendering { fileName = "Grid-View"; }
            @AnalysisInfo {
                label       = "Attribute Grid";
                groupName   = "L1 — System Black-Box";
                domain      = "Attributes";
                icon        = "▦";
                level       = "L1";
                kind        = "BlackBox";
                component   = "";
                parentGroup = "B_W";
            }
            expose Structure::V2X_CACC_System::top_system;
        }

        view browserView : StandardViewDefinitions::BrowserView {
            doc /* Browser view: provides a hierarchical tree-like structure that allows users to navigate through the different elements of the system, such as requirements, functions, components, and interfaces, and explore their relationships and dependencies. */
            satisfy systemEngineerViewpoint;
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
            expose V2X_CACC_Model;
        }


        view generalView : StandardViewDefinitions::GeneralView{
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
            filter @SysML::PortUsage;
            @ViewRendering { fileName = "General-View"; }
            @AnalysisInfo {
                label = "General View";
                groupName = "L1 — System Black-Box";
                domain = "Structural";
                icon  = "🔍";
                level = "L1";
                kind  = "BlackBox";
                component = "";
                parentGroup = "B_W";
            }
            expose Structure::V2X_CACC_System::top_system;
        }

        view useCaseView : UseCaseView {
            doc /* View representing the use cases of the system, showing the interactions between the system and its actors, and how the system fulfills its requirements. */
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
            satisfy stakeholderViewpoint;
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
            expose Behaviour::systemUseCase;
        }

        view actionflow : StandardViewDefinitions::ActionFlowView{
            doc /* View representing the action flow of the system, showing the sequence of actions and interactions that occur in response to events or use case scenarios. */
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
            filter @SysML::PartUsage;
            @ViewRendering { fileName = "ActionFlow-View"; }
            @AnalysisInfo {
                label       = "Action Flow";
                groupName   = "L1 — System Black-Box";
                domain      = "Behavioral";
                icon        = "⚡";
                level       = "L1";
                kind        = "BlackBox";
                component   = "";
                parentGroup = "B_W";
            }
            expose Behaviour::systemUseCase::V2X_CarFollowing_System::**;
        }

        view stateTransitionFlow : StandardViewDefinitions::StateTransitionView {
            doc /* View representing the state transition flow of the system, showing the different states of the system and how it transitions between them in response to events or conditions. */
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
            @ViewRendering { fileName = "StateTransition-View"; }
            @AnalysisInfo {
                label       = "State Transitions";
                groupName   = "L1 — System Behavioral";
                domain      = "Behavioral";
                icon        = "🔄";
                level       = "L1";
                kind        = "BlackBox";
                component   = "";
                parentGroup = "B_W";
            }
            expose Behaviour::systemUseCase::V2XCarFollowingSystem;
        }

        view requirementView : RequirementView {
            doc /* View representing the requirements of the system, showing how the requirements are structured, categorized, and satisfied by the system components. */
            satisfy systemEngineerViewpoint;
            satisfy stakeholderViewpoint;
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
            expose Structure::V2X_CACC_System::top_system;
        }

        view uc1_SequenceView : StandardViewDefinitions::SequenceView {
            @AnalysisInfo { label = "CACC Sync — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::cacc_synchronization::sequence;
        }

        view uc2_SequenceView : SequenceView {
            @AnalysisInfo { label = "Abrupt Cut-In — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::abruptCutIn::sequence;
        }

        view uc3_SequenceView : SequenceView {
            @AnalysisInfo { label = "Called Cut-In — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::calledCutIn::sequence;
        }

        view uc4_SequenceView : SequenceView {
            @AnalysisInfo { label = "Shockwaves Mitigation — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::shockwavesMitigation::sequence;
        }

        view uc5_SequenceView : SequenceView {
            @AnalysisInfo { label = "Adapting Following — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::adaptingFollowing::sequence;
        }

        view uc6_SequenceView : SequenceView {
            @AnalysisInfo { label = "Cross-Road Adaptation — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::crossRoadAdaptation::sequence;
        }

        view uc7_SequenceView : SequenceView {
            @AnalysisInfo { label = "Speed Limits Adaptation — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::speedLimitsAdaptation::sequence;
        }

        view uc8_SequenceView : SequenceView {
            @AnalysisInfo { label = "Road Hazard Warning — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::roadHazardWarning::sequence;
        }

        view uc9_SequenceView : SequenceView {
            @AnalysisInfo { label = "Road Condition Warning — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::roadConditionWarning::sequence;
        }

        view uc10_SequenceView : SequenceView {
            @AnalysisInfo { label = "Signal Violation Protection — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::signalViolationProtection::sequence;
        }

        view uc11_SequenceView : SequenceView {
            @AnalysisInfo { label = "Wrong-Way Driver Protection — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::wrongWayDriverProtection::sequence;
        }

        view uc12_SequenceView : SequenceView {
            @AnalysisInfo { label = "Special Vehicle — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::specialVehicle::sequence;
        }

        view uc13_SequenceView : SequenceView {
            @AnalysisInfo { label = "Pedestrian Protection — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::pedestrianProtection::sequence;
        }

        view uc14_SequenceView : SequenceView {
            @AnalysisInfo { label = "Degraded Signal Management — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::degradedSignalManagement::sequence;
        }

        view uc15_SequenceView : SequenceView {
            @AnalysisInfo { label = "Fragmented Signal Management — Sequence"; icon = "🎬"; }
            expose Behaviour::systemUseCase::fragmentedSignalManagement::sequence;
        }

        view sequenceGroupView : SequenceGroupView {
            doc /* Aggregator that collects all sequence diagrams for navigation. */
            @ViewRendering { fileName = "Sequence-Views"; }
            @AnalysisInfo {
                label       = "Sequence Gallery";
                groupName   = "L1 — System Black-Box";
                domain      = "Behavioral";
                icon        = "🗂️";
                level       = "L1";
                kind        = "BlackBox";
                component   = "";
                parentGroup = "B_W";
            }
            expose View_Viewpoint;
        }

        view interconnectionView : StandardViewDefinitions::InterconnectionView {
            doc /* View definition for interconnection visualization. */
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
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
            expose Structure::V2X_CACC_System::top_system;
        }

        view stakeholderView : StakeholderView {
            doc /* Stakeholder view: mostra il team e le parti interessate del progetto FPGA. */
            satisfy systemEngineerViewpoint;
            @AnalysisInfo {
                label       = "Stakeholders";
                groupName   = "Team & Organization";
                domain      = "Stakeholders";
                icon        = "👥";
                level       = "L1";
                kind        = "";
                component   = "";
                parentGroup = "";
            }
            expose ProjectInfo::ProjectStakeHolders;
        }

        view teamView : TeamView {
            doc /* Project team structure. */
            satisfy systemEngineerViewpoint;
            satisfy stakeholderViewpoint;
            @AnalysisInfo {
                label       = "Team Member";
                groupName   = "Team & Organization";
                domain      = "Organizational";
                icon        = "🏢";
                level       = "L1";
                kind        = "";
                component   = "";
                parentGroup = "";
            }
            expose ProjectInfo::ProjectTeamMembers;
        }

        view toolView : ToolView {
            doc /* Tool view: mostra gli strumenti software del progetto FPGA. */
            satisfy systemEngineerViewpoint;
            @AnalysisInfo {
                label       = "Software Tools";
                groupName   = "Tools & Infrastructure";
                domain      = "Toolchain";
                icon        = "🔧";
                level       = "L1";
                kind        = "";
                component   = "";
                parentGroup = "";
            }
            expose ProjectInfo::ProjectTools;
        }

        view lifecycleView : LifecycleView {
            doc /* Project lifecycle phases. */
            satisfy systemEngineerViewpoint;
            @AnalysisInfo {
                label       = "Lifecycle Timeline";
                groupName   = "Process & Lifecycle";
                domain      = "Temporal";
                icon        = "📅";
                level       = "L1";
                kind        = "";
                component   = "";
                parentGroup = "";
            }
            expose ProjectInfo::ProjectLifecycle;
        }



    }

    package ProjectInfo{
        package ProjectLifecycle {  //TODO: Da correggere l'hard-coding
        private import ScalarValues::*;

        // ─── Type definitions ────────────────────────────────────────────────
        occurrence def PassageEvent {
            doc /* A forward transition from one phase to the next. */
            attribute fromPhase : ScalarValues::String;
            attribute toPhase   : ScalarValues::String;
            attribute content   : ScalarValues::String;
            attribute date      : ScalarValues::String;
        }

        occurrence def IterationEvent {
            doc /* A backward iteration to a previously completed phase. */
            attribute fromPhase : ScalarValues::String;
            attribute toPhase   : ScalarValues::String;
            attribute reason    : ScalarValues::String;
            attribute content   : ScalarValues::String;
            attribute date      : ScalarValues::String;
        }

        item def Gate {
            doc /* A review gate (entry or exit condition) for a lifecycle phase. */
            attribute condition : ScalarValues::String;
            attribute gateType  : ScalarValues::String;
        }

        item def Phase {
            doc /* A lifecycle phase containing attributes and review gates. */
            attribute phaseName : ScalarValues::String;
            attribute status    : ScalarValues::String;
            attribute startDate : ScalarValues::String;
            attribute endDate   : ScalarValues::String;
            attribute owner     : ScalarValues::String;
            attribute progress  : ScalarValues::Integer;
            attribute notes     : ScalarValues::String;
        }

        item def Lifecycle {
            doc /* Top-level container for lifecycle phases and transition events. */
        }

        // ─── Instance ────────────────────────────────────────────────────────
        item projectLifecycle : Lifecycle {
            doc /* FPGA project lifecycle timeline. */

            item reqPhase : Phase {
                attribute phaseName = "Requirements";
                attribute status    = "completed";
                attribute startDate = "2025-01-10";
                attribute endDate   = "2025-02-28";
                attribute owner     = "devCarmine";
                attribute progress  = 100;
                attribute notes     = "Stakeholder requirements elicited and approved.";
                item entryGate : Gate {
                    attribute gateType  = "entry";
                    attribute condition = "Project kickoff approved by steering committee.";
                }
                item exitGate : Gate {
                    attribute gateType  = "exit";
                    attribute condition = "Requirements baseline signed off by all stakeholders.";
                }
            }

            item designPhase : Phase {
                attribute phaseName = "Design";
                attribute status    = "completed";
                attribute startDate = "2025-03-01";
                attribute endDate   = "2025-04-15";
                attribute owner     = "devLuca";
                attribute progress  = 100;
                attribute notes     = "Architecture and interface definitions finalized.";
                item entryGate : Gate {
                    attribute gateType  = "entry";
                    attribute condition = "Requirements baseline approved.";
                }
                item exitGate : Gate {
                    attribute gateType  = "exit";
                    attribute condition = "Critical Design Review (CDR) passed.";
                }
            }

            item implementationPhase : Phase {
                attribute phaseName = "Implementation";
                attribute status    = "active";
                attribute startDate = "2025-04-16";
                attribute endDate   = "2025-07-31";
                attribute owner     = "devSofia";
                attribute progress  = 60;
                attribute notes     = "FPGA firmware and signal processing modules in progress.";
                item entryGate : Gate {
                    attribute gateType  = "entry";
                    attribute condition = "CDR passed; implementation backlog groomed.";
                }
                item exitGate : Gate {
                    attribute gateType  = "exit";
                    attribute condition = "Feature freeze; all unit tests passing.";
                }
            }

            item testingPhase : Phase {
                attribute phaseName = "Testing";
                attribute status    = "planned";
                attribute startDate = "2025-08-01";
                attribute endDate   = "2025-09-30";
                attribute owner     = "devCarmine";
                attribute progress  = 0;
                attribute notes     = "Hardware-in-the-loop and system integration tests.";
                item entryGate : Gate {
                    attribute gateType  = "entry";
                    attribute condition = "Feature freeze confirmed; test plan approved.";
                }
                item exitGate : Gate {
                    attribute gateType  = "exit";
                    attribute condition = "All critical defects resolved; qualification test passed.";
                }
            }

            item deploymentPhase : Phase {
                attribute phaseName = "Deployment";
                attribute status    = "planned";
                attribute startDate = "2025-10-01";
                attribute endDate   = "2025-11-15";
                attribute owner     = "devLuca";
                attribute progress  = 0;
                attribute notes     = "Field deployment and customer acceptance.";
                item entryGate : Gate {
                    attribute gateType  = "entry";
                    attribute condition = "Qualification test report signed off.";
                }
                item exitGate : Gate {
                    attribute gateType  = "exit";
                    attribute condition = "Customer acceptance test passed.";
                }
            }

            // Passage events (forward transitions — first run)
            occurrence req2design : PassageEvent {
                attribute fromPhase = "Requirements";
                attribute toPhase   = "Design";
                attribute content   = "Requirements baseline signed off. All 47 requirements approved.";
                attribute date      = "2025-02-28";
            }
            occurrence design2impl : PassageEvent {
                attribute fromPhase = "Design";
                attribute toPhase   = "Implementation";
                attribute content   = "CDR passed. Architecture approved, implementation starts.";
                attribute date      = "2025-04-15";
            }
            occurrence impl2test : PassageEvent {
                attribute fromPhase = "Implementation";
                attribute toPhase   = "Testing";
                attribute content   = "Feature freeze declared. Hand-off to test team.";
                attribute date      = "2025-07-31";
            }

            // Iteration event (backward — testing reveals a critical defect)
            occurrence test2design_iter : IterationEvent {
                attribute fromPhase = "Testing";
                attribute toPhase   = "Design";
                attribute reason    = "Critical architecture defect found during HIL testing.";
                attribute content   = "Revisit DSP-FPGA interface design. Restart from Design.";
                attribute date      = "2025-09-05";
            }

            // Passage events — second run (after iteration)
            occurrence design2impl_r2 : PassageEvent {
                attribute fromPhase = "Design";
                attribute toPhase   = "Implementation";
                attribute content   = "Revised interface design approved. Implementation restarts.";
                attribute date      = "2025-09-20";
            }
            occurrence impl2test_r2 : PassageEvent {
                attribute fromPhase = "Implementation";
                attribute toPhase   = "Testing";
                attribute content   = "Hotfix implemented and verified. Re-entering test phase.";
                attribute date      = "2025-10-10";
            }
            occurrence test2deploy : PassageEvent {
                attribute fromPhase = "Testing";
                attribute toPhase   = "Deployment";
                attribute content   = "All qualification tests passed. Cleared for deployment.";
                attribute date      = "2025-10-25";
            }
        }
        }
    
        package ProjectTeamMembers {
            doc /* Project team and stakeholders for the car-following system. */

            item member_1 : Stakeholders_Definitions::TeamMember {
                attribute :>> fullName = "Carmine Esposito";   
                attribute :>> role = "System Engineer / SW-HW Engineer";       
                attribute :>> email = "carmine.esposito01.ce@gmail.com";      
                attribute :>> team = "--";       
                attribute :>> phone = "+39 xxx xxx xxxx";    
                attribute :>> linkedinUrl = "https://www.linkedin.com/in/carmine-esposito-970302224/";
                attribute :>> teamsUrl = "https://teams.microsoft.com/l/chat/0/0?users=carmine.esposito17@studenti.unina.it";  
                
                doc /* Responsible for SysML v2 model design:
                    - Structure;
                    - Behaviour;
                    - Requirement;
                    - Analysis;
                    - Verification;
                    - Views.
                    * Also responsible for Visualizer tool development, architecture design, Simulink implementation and FPGA integration. */
            }
        }

        package ProjectStakeHolders {
        item supervisor_1 : Stakeholders_Definitions::Stakeholder {
            attribute :>> fullName     = "Emanuele Carella";
            attribute :>> role         = "Academic Supervisor";
            attribute :>> email        = "mario.rossi@unina.it";
            attribute :>> organization = "Kineton";
            attribute :>> phone        = "+39 xxx xxx xxxx";
            doc /* Oversees project methodology, validates MBSE approach,
                 * and approves system architecture decisions. */
        }
        }
        
        package ProjectTools {
            doc /* Software tools used in the FPGA car-following MBSE project. */

            item vivado : Tool_Definitions::SoftwareTool {
                attribute :>> toolName    = "Xilinx Vivado";
                attribute :>> version     = "2023.2";
                attribute :>> vendor      = "AMD / Xilinx";
                attribute :>> toolType    = "FPGA Synthesis & Implementation";
                attribute :>> scope       = "Hardware";
                attribute :>> license     = "WebPACK (Free)";
                attribute :>> description = "FPGA design suite for synthesis, implementation and bitstream generation on PYNQ-Z1.";
            }

            item matlab : Tool_Definitions::SoftwareTool {
                attribute :>> toolName    = "MATLAB / Simulink";
                attribute :>> version     = "R2023b";
                attribute :>> vendor      = "MathWorks";
                attribute :>> toolType    = "Model-Based Design";
                attribute :>> scope       = "System Modeling";
                attribute :>> license     = "Academic";
                attribute :>> description = "Used for algorithm prototyping, signal processing simulation, and HDL code generation.";
            }

            item python : Tool_Definitions::SoftwareTool {
                attribute :>> toolName    = "Python";
                attribute :>> version     = "3.13";
                attribute :>> vendor      = "Python Software Foundation";
                attribute :>> toolType    = "Scripting / Automation";
                attribute :>> scope       = "Software Design";
                attribute :>> license     = "Open Source (PSF)";
                attribute :>> description = "Used for Neural Network design, training and pruning.";
            }

            item sysmlTool : Tool_Definitions::SoftwareTool {
                attribute :>> toolName    = "SysML v2 CLI / VS Code Extension";
                attribute :>> version     = "2024.12";
                attribute :>> vendor      = "OMG / Community";
                attribute :>> toolType    = "MBSE Authoring";
                attribute :>> scope       = "Systems Engineering";
                attribute :>> license     = "Open Source";
                attribute :>> description = "Text-based SysML v2 modelling environment used to author and validate the system model.";
            }

            item sysmlValidator : Tool_Definitions::SoftwareTool{
                attribute :>> toolName    = "Eclipse SysON";
                attribute :>> version     = "2025-03";
                attribute :>> vendor      = "Eclipse";
                attribute :>> toolType    = "Model Validation";
                attribute :>> scope       = "Systems Engineering";
                attribute :>> license     = "Open Source";
                attribute :>> description = "Automated validation tool for checking model consistency, correctness, and requirement satisfaction.";
            }

            item visualizer : Tool_Definitions::SoftwareTool{
                attribute :>> toolName    = "SysML v2 Model-Visualizer";
                attribute :>> version     = "0.5";
                attribute :>> vendor      = "In-house";
                attribute :>> toolType    = "Custom Views Visualization";
                attribute :>> scope       = "Systems Engineering";
                attribute :>> license     = "Open Source";
                attribute :>> description = "Custom-built visualization tool for visualize SysML model views&viewpoint.";
            }

            item git : Tool_Definitions::SoftwareTool {
                attribute :>> toolName    = "Git";
                attribute :>> version     = "2.43";
                attribute :>> vendor      = "Git Project";
                attribute :>> toolType    = "Version Control";
                attribute :>> scope       = "DevOps";
                attribute :>> license     = "Open Source (GPL-2.0)";
                attribute :>> description = "Source control for SysML model files, firmware, and Visualizer source code.";
            }

            item vscode : Tool_Definitions::SoftwareTool {
                attribute :>> toolName    = "Visual Studio Code";
                attribute :>> version     = "1.90";
                attribute :>> vendor      = "Microsoft";
                attribute :>> toolType    = "IDE";
                attribute :>> scope       = "Development";
                attribute :>> license     = "Free";
                attribute :>> description = "Primary development environment for SysML authoring, Python scripting, and Visualizer development.";
            }
        }
    }

}