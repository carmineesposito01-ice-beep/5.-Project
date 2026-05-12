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
                /* ===================================================================
                     * ATTRIBUTES (Top-Use Case)
                 * =================================================================== */
                // Car-Following Attributes
                attribute :>> carFollowingModel = CarFollowingModelKind::IDM_2D;
                attribute :>> followingParameters;
                attribute :>> headwayIncrementPercentage =10.0;

                // ---------- Soglie di sicurezza ----------
                attribute :>> emergencyBrakingMaxReactionTime = 200.0 [milli*s];
                attribute :>> signalViolationEmergencyDistance;
                attribute :>> signalViolationAttentionDistance;
                attribute :>> pedestrianTTAAttentionThreshold;
                attribute :>> pedestrianTTADangerThreshold;
                attribute :>> pedestrianLateralSafetyBuffer = 1.0 [m];
                attribute :>> maxOvershootSpeed;
                attribute :>> jamRateInstabilityThreshold;
                attribute :>> stabilityValidationVehicleCount = 10;

                // ---------- Soglie SOTIF ----------
                attribute :>> leaderProfileConfidenceThresholdLow = 60.0;
                attribute :>> glosaUnreachableDecelerationProfile;
                attribute :>> denmConfidenceValidationRequired = true;
                attribute :>> pedestrianSensorValidationTimeout = 3.0 [s];

                // ---------- Performance ----------
                attribute :>> maxV2VEndToEndLatency = 100.0 [milli*s];
                attribute :>> maxV2IEndToEndLatency = 200.0 [milli*s];
                attribute :>> camUpdateRateMin = 10.0 [Hz];
                attribute :>> safetyDistanceAccuracyLowSpeed = 3.0 [m];
                attribute :>> safetyDistanceAccuracyHighSpeedPercent = 2.0;
                attribute :>> glosaComputationTimeMax = 50.0 [milli*s];

                // ---------- Degradazione e fault tolerance ----------
                attribute :>> v2vSignalLossTimeout = 500.0 [milli*s];
                attribute :>> transitionSmoothTime = 2.0 [s];
                attribute :>> messageFragmentationThresholdPercent = 15.0;
                attribute :>> fragmentationPersistenceTime = 3.0 [s];
                attribute :>> internalHeartbeatTimeout = 200.0 [milli*s];
                attribute :>> failOperationalArchitecture = false;

                // ---------- Variabili di stato runtime ----------
                attribute :>> carFollowingMode = CarFollowingModeKind::Disabled;
                attribute :>> v2vCommunicationStatus = CommStatusKind::Lost;
                attribute :>> v2iCommunicationStatus = CommStatusKind::Lost;
                attribute :>> leaderProfileConfidence;
                attribute :>> currentJamRate;
                attribute :>> glosaActive = false;
                attribute :>> emergencyManeuverInProgress  = false;
                
                part inputGateway : InputGateway_Unit{
                    doc /* The InputGateway unit, responsible for receiving and validating all incoming data. */
                    
                    part conditioning : Conditioning_Unit;
                    part validation : SignalValidation_Unit;

                    // Connessioni interne InputGateway
                    connection v2v_flow_IN : V2VCommPort connect inputGateway.v2vIn to conditioning.v2vIn;
                    connection v2i_flow_IN : V2ICommPort connect inputGateway.v2iIn to conditioning.v2iIn;
                    connection egoVehicle_flow_IN : VehicleBusPort connect inputGateway.egoSignalsIn  to conditioning.egoSignalsIn;
                    connection ego_val_OUT : VehicleBusPort connect validation.egoSignalsOut to inputGateway.egoSignalsOut;
                    connection status_flag_OUT : PlatooningInfoPort connect validation.platooningInfoOut to inputGateway.platooningInfoOut;
                    connection v2v_flow_OUT : V2VCommPort connect validation.validatedDataOut to inputGateway.v2vOut;
                    connection v2i_flow_OUT : V2ICommPort connect validation.validatedDataOut to inputGateway.v2iOut;

                    connection v2v_to_val : V2VCommPort connect conditioning.v2vOut to validation.v2vIn;
                    connection v2i_to_val : V2ICommPort connect conditioning.v2iOut to validation.v2iIn;
                    connection ego_to_val : VehicleBusPort connect conditioning.egoSignalsOut to validation.egoSignalsIn;
                    
                }
                part camComposer : CAMComposer_Unit{
                    doc /* The CAM Composer unit, responsible for composing CAM messages based on the ego vehicle state and other relevant data. */
                
                    part allineator : Allineator_Unit;
                    part trigger_cam : TriggerCAM_Unit;
                    part camMessageComposer : CAMMessageComposer_Unit;
                    part sample_hold : SampleANDHold;

                    connection ego_flow_IN : VehicleBusPort connect camComposer.egoIn to allineator.egoIn;
                    connection ego_flow_IN2 : VehicleBusPort connect camComposer.egoIn to trigger_cam.egoIn;
                    connection cam_flow_OUT : CAM_Flow connect sample_hold.camOut to camComposer.camOut;

                    connection ego_aligned : VehicleBusPort connect allineator.egoOut to camMessageComposer.egoIn;
                    connection trigger_flow : Boolean connect trigger_cam.triggerOut to camMessageComposer.triggerIn;
                    connection cam_message : CAM_Flow connect camMessageComposer.camOut to sample_hold.camIn;

                
                
                }
                part elaboration : Elaboration_Unit{
                    doc /* The Elaboration unit, responsible for processing validated data and generating control parameters. */

                    part evaluation : Evaluation_Unit;
                    part parameterGenerator : ParameterGenerator_Unit;
                    part monitoringComposer : MonitoringComposer_Unit;

                    connection v2v_IN : V2VInterface connect elaboration.v2vIn to evaluation.v2vIn;
                    connection v2i_IN : V2IInterface connect elaboration.v2iIn to evaluation.v2iIn;
                    connection v2v_IN2 : V2VInterface connect elaboration.v2vIn to parameterGenerator.v2vIn;
                    connection v2i_IN2 : V2IInterface connect elaboration.v2iIn to parameterGenerator.v2iIn;
                    connection parameter_OUT : ControlFlow connect parameterGenerator.modelParametersOut to elaboration.modelParametersOut;
                    connection monitoring_OUT : Monitoring_Flow connect monitoringComposer.monitoringOut to elaboration.monitoringOut;

                    connection eval_to_gen : ConditioningVariables connect evaluation.conditioningVariablesOut to parameterGenerator.conditioningVariablesIn;
                    connection eval_to_hmi : ConditioningVariables connect evaluation.conditioningVariablesOut to monitoringComposer.conditioningVariablesIn;
                    connection gen_to_hmi : ConditioningVariables connect parameterGenerator.modelParametersOut to monitoringComposer.modelParametersIn;
                }
                part outputGateway : OutputGateway_Unit{
                    doc /* The OutputGateway unit, responsible for sending generated control parameters to the vehicle and outputting monitoring information. */

                    part modelParametersOuting : ModelParametersOuting_Unit;
                    part camMessageOuting : CAMMessageOuting_Unit;
                    part monitoringOuting : MonitoringOuting_Unit;

                    connection modelParameters_IN : ControlFlow connect outputGateway.modelParametersIn to modelParametersOuting.modelParametersIn;
                    connection cam_IN : CAM_Flow connect outputGateway.camIn to camMessageOuting.camIn;
                    connection platooningInfo_IN : PlatooningInfo_Flow connect outputGateway.platooningInfoIn to modelParametersOuting.platooningInfoIn;
                    connection platooningInfo_IN2 : PlatooningInfo_Flow connect outputGateway.platooningInfoIn to camMessageOuting.platooningInfoIn;
                    connection platooningInfo_IN3 : PlatooningInfo_Flow connect outputGateway.platooningInfoIn to monitoringOuting.platooningInfoIn;
                    connection monitoring_IN : Monitoring_Flow connect outputGateway.monitoringIn to monitoringOuting.monitoringIn;
                    connection modelParameters_OUT : ControlFlow connect modelParametersOuting.modelParametersOut to outputGateway.modelParametersOut;
                    connection cam_OUT : CAM_Flow connect camMessageOuting.camOut to outputGateway.camOut;
                    connection monitoring_OUT : MonitoringPort connect monitoringOuting.monitoringOut to outputGateway.monitoringOut;
                    connection platooningInfo_OUT : PlatooningInfo_Flow connect outputGateway.platooningInfoIn to outputGateway.platooningInfoOut;
                
                }
            
                // Connessioni Top_Level                
                connection v2v_IN : V2VCommPort connect top_system.v2vIn to inputGateway.v2vIn;
                connection v2i_IN : V2ICommPort connect top_system.v2iIn to inputGateway.v2iIn;
                connection vehicle_bus_IN : VehicleBusPort connect top_system.egoVehicleInfoIn to inputGateway.egoSignalsIn;
                        
                connection monitoring_OUT : MonitoringPort connect  outputGateway.monitoringOut to top_system.monitoringOut;
                connection parameter_OUT : ControlFlow connect outputGateway.modelParametersOut to top_system.modelParametersOut;
                connection platooning_info_OUT : PlatooningInfo_Flow connect outputGateway.platooningInfoOut to top_system.platooningInfoOut;
                connection cam_OUT : CAM_Flow connect outputGateway.camOut to top_system.camOut;


                connection v2v_to_elaboration : V2VCommPort connect inputGateway.v2vOut to elaboration.v2vIn;
                connection v2i_to_elaboration : V2ICommPort connect inputGateway.v2iOut to elaboration.v2iIn;
                connection ego_to_camComp : EgoVehicleData_Flow connect inputGateway.egoSignalsOut to camComposer.egoIn;
                connection cacc_state_info : PlatooningInfo_Flow connect inputGateway.platooningInfoOut to outputGateway.platooningInfoIn;
                connection parameter_flow : ControlFlow connect elaboration.modelParametersOut to outputGateway.modelParametersIn;                
                connection monitoring_flow : MonitoringPort connect elaboration.monitoringOut to outputGateway.monitoringIn;
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
                
                action def InputGateway_ActionFlow {
                    doc /* Riceve messaggi V2V/V2I e dati bordo, li valida, gestisce frammentazione e ricostruzione, produce flusso dati validati e stato ego‑veicolo. */
                    merge acquisitionLoop;

                    action receiveV2V {
                        doc /* Acquisisce in parallelo CAM e MCM. */
                        action getCAM;
                        action getMCM;
                        fork rcvV2VFork;
                        join rcvV2VJoin;
                        first start then rcvV2VFork;
                        first rcvV2VFork then getCAM;
                        first rcvV2VFork then getMCM;
                        first getCAM then rcvV2VJoin;
                        first getMCM then rcvV2VJoin;
                        first rcvV2VJoin then done;
                    }

                    action receiveV2I {
                        doc /* Acquisisce in parallelo SPaT, MAP, DENM, IVS, EVA, VRU, CPM. */
                        action getSPaT;
                        action getMAP;
                        action getDENM;
                        action getIVS;
                        action getEVA;
                        action getVRU;
                        action getCPM;
                        fork rcvV2IFork;
                        join rcvV2IJoin;
                        first start then rcvV2IFork;
                        first rcvV2IFork then getSPaT;
                        first rcvV2IFork then getMAP;
                        first rcvV2IFork then getDENM;
                        first rcvV2IFork then getIVS;
                        first rcvV2IFork then getEVA;
                        first rcvV2IFork then getVRU;
                        first rcvV2IFork then getCPM;
                        first getSPaT then rcvV2IJoin;
                        first getMAP then rcvV2IJoin;
                        first getDENM then rcvV2IJoin;
                        first getIVS then rcvV2IJoin;
                        first getEVA then rcvV2IJoin;
                        first getVRU then rcvV2IJoin;
                        first getCPM then rcvV2IJoin;
                        first rcvV2IJoin then done;
                    }

                    action readOnboardSensors {
                        doc /* Legge GNSS, IMU e odometria dal bus veicolo. */
                        action getGNSS;
                        action getIMU;
                        fork onbFork;
                        join onbJoin;
                        first start then onbFork;
                        first onbFork then getGNSS;
                        first onbFork then getIMU;
                        first getGNSS then onbJoin;
                        first getIMU then onbJoin;
                        first onbJoin then done;
                    }

                    action validateMessages {
                        doc /* Applica controlli di freschezza, coerenza spaziale e confidence level. Scarta messaggi non validi. */
                        action checkDataAge;
                        action checkSpatialCoherenceWithGNSS;
                        action checkConfidenceIfDENM;
                        merge validatedSet;
                        merge discardedSet;
                        decide globalPass;
                        first start then checkDataAge;
                        first checkDataAge then checkSpatialCoherenceWithGNSS;
                        first checkSpatialCoherenceWithGNSS then globalPass;
                        first globalPass then validatedSet;    // valido
                        first globalPass then discardedSet;    // scartato (log opzionale)
                        first validatedSet then done;
                        first discardedSet then done;
                    }

                    action monitorChannelHealth {
                        doc /* Valuta perdita segnale e frammentazione; attiva ricostruzione se necessario; richiede fallback se persistente. */
                        action computeFragmentationRate;
                        action evaluateLossTimer;
                        decide channelOk;
                        decide needReconstruction;
                        decide needFallback;
                        first start then computeFragmentationRate;
                        first computeFragmentationRate then evaluateLossTimer;
                        first evaluateLossTimer then channelOk;
                        first channelOk then done;               // tutto nella norma
                        first channelOk then needReconstruction; // frammentazione elevata
                        first needReconstruction then done;      // avvia ricostruzione
                        first needReconstruction then needFallback; // persistenza eccessiva
                        first needFallback then done;            // segnala fallback al sistema
                    }

                    action buildEgoState {
                        doc /* Assembla lo stato dell'ego‑veicolo dai sensori di bordo. */
                        action combineGNSS_IMU_Odometry;
                        first start then combineGNSS_IMU_Odometry;
                        first combineGNSS_IMU_Odometry then done;
                    }

                    action outputValidatedData {
                        doc /* Prepara e invia il flusso di dati validati e lo stato ego verso le porte di uscita. */
                        action packValidatedData;
                        action sendToElaboration;
                        action sendEgoToCamComposer;
                        fork outFork;
                        join outJoin;
                        first start then outFork;
                        first outFork then packValidatedData;
                        first packValidatedData then sendToElaboration;
                        first outFork then sendEgoToCamComposer;
                        first sendToElaboration then outJoin;
                        first sendEgoToCamComposer then outJoin;
                        first outJoin then done;
                    }

                    // Flusso principale ciclico
                    first start then acquisitionLoop;
                    first acquisitionLoop then receiveV2V;
                    first acquisitionLoop then receiveV2I;
                    first acquisitionLoop then readOnboardSensors;
                    first receiveV2V then validateMessages;
                    first receiveV2I then validateMessages;
                    first readOnboardSensors then buildEgoState;
                    first validateMessages then monitorChannelHealth;
                    first monitorChannelHealth then outputValidatedData;
                    first buildEgoState then outputValidatedData;
                    first outputValidatedData then acquisitionLoop;
                }

                action def CAMComposer_ActionFlow {
                    doc /* Receives ego vehicle state, generates a trigger on significant changes, composes the CAM and holds it on the output via sample‑and‑hold. */
                    merge mainLoop;

                    action receiveEgoState {
                        doc /* Acquires ego vehicle data from the egoIn port. */
                        action getPosition;
                        action getSpeed;
                        action getHeading;
                        action getAcceleration;
                        action getTimestamp;
                        fork egoFork;
                        join egoJoin;
                        first start then egoFork;
                        first egoFork then getPosition;
                        first egoFork then getSpeed;
                        first egoFork then getHeading;
                        first egoFork then getAcceleration;
                        first egoFork then getTimestamp;
                        first getPosition then egoJoin;
                        first getSpeed then egoJoin;
                        first getHeading then egoJoin;
                        first getAcceleration then egoJoin;
                        first getTimestamp then egoJoin;
                        first egoJoin then done;
                    }

                    action evaluateTrigger {
                        doc /* Compares current state with previous state and decides whether to generate a trigger. */
                        action computeDeltaSpeed;
                        action computeDeltaHeading;
                        decide significantChange;
                        first start then computeDeltaSpeed;
                        first computeDeltaSpeed then computeDeltaHeading;
                        first computeDeltaHeading then significantChange;
                        first significantChange then done;   // trigger generated
                        first significantChange then done;   // no trigger (minimal variations)
                    }

                    action composeCAM {
                        doc /* Assembles the CAM message with all mandatory fields. */
                        action fillMandatoryFields;
                        action computeTimestamp;
                        action signMessage;
                        first start then fillMandatoryFields;
                        first fillMandatoryFields then computeTimestamp;
                        first computeTimestamp then signMessage;
                        first signMessage then done;
                    }

                    action sampleAndHold {
                        doc /* Updates the output with the new CAM if available, otherwise keeps the previous value. */
                        decide newCamAvailable;
                        action presentNewCam;
                        action keepPreviousCam;
                        first start then newCamAvailable;
                        first newCamAvailable then presentNewCam;
                        first newCamAvailable then keepPreviousCam;
                        first presentNewCam then done;
                        first keepPreviousCam then done;
                    }

                    // Main cyclic flow
                    first start then mainLoop;
                    first mainLoop then receiveEgoState;
                    first receiveEgoState then evaluateTrigger;
                    first evaluateTrigger then composeCAM;
                    first composeCAM then sampleAndHold;
                    first sampleAndHold then mainLoop;
                }

                action def OutputGateway_ActionFlow {
                    doc /* Receives control parameters, CAM, monitoring and platooning data, and forwards them to the appropriate external ports. */
                    merge mainLoop;

                    action receiveControlParameters {
                        doc /* Acquires control parameters from the modelParametersIn port. */
                        action getControlData;
                        first start then getControlData;
                        first getControlData then done;
                    }

                    action receiveCAM {
                        doc /* Acquires the composed CAM from the camIn port. */
                        action getCAM;
                        first start then getCAM;
                        first getCAM then done;
                    }

                    action receiveMonitoring {
                        doc /* Acquires monitoring data from the monitoringIn port. */
                        action getMonitoringData;
                        first start then getMonitoringData;
                        first getMonitoringData then done;
                    }

                    action receivePlatooningInfo {
                        doc /* Acquires platooning info from the platooningInfoIn port. */
                        action getPlatooningData;
                        first start then getPlatooningData;
                        first getPlatooningData then done;
                    }

                    action forwardToOutputs {
                        doc /* Forwards all received data to the corresponding output ports. */
                        action forwardControlToBus;
                        action forwardCAM_ToV2V;
                        action forwardMonitoringToHMI;
                        action forwardPlatooningInfo;
                        fork fwdFork;
                        join fwdJoin;
                        first start then fwdFork;
                        first fwdFork then forwardControlToBus;
                        first fwdFork then forwardCAM_ToV2V;
                        first fwdFork then forwardMonitoringToHMI;
                        first fwdFork then forwardPlatooningInfo;
                        first forwardControlToBus then fwdJoin;
                        first forwardCAM_ToV2V then fwdJoin;
                        first forwardMonitoringToHMI then fwdJoin;
                        first forwardPlatooningInfo then fwdJoin;
                        first fwdJoin then done;
                    }

                    // Flusso principale ciclico
                    first start then mainLoop;
                    first mainLoop then receiveControlParameters;
                    first mainLoop then receiveCAM;
                    first mainLoop then receiveMonitoring;
                    first mainLoop then receivePlatooningInfo;
                    first receiveControlParameters then forwardToOutputs;
                    first receiveCAM then forwardToOutputs;
                    first receiveMonitoring then forwardToOutputs;
                    first receivePlatooningInfo then forwardToOutputs;
                    first forwardToOutputs then mainLoop;
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
        package System_Requirements{
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
        

        // L2 REQUIREMENTS
        package InputGatewayRequirementUsage {
            requirement msgReceptionReq : MessageReception {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "IGW-REQ";
                }
            }
            satisfy msgReceptionReq by Structure::V2X_CACC_System::top_system::inputGateway;

            // Istanziamo un vincolo per ogni tipologia di messaggio, ma per snellire mostriamo solo un esempio di collegamento.
            // Nella pratica si può avere un requisito parametrico che il blocco soddisfa per ogni messaggio.
            requirement camValidationReq : TemporalSpatialValidation {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "IGW-REQ";
                }
            }
            satisfy camValidationReq by Structure::V2X_CACC_System::top_system::inputGateway;

            requirement denmConfReq : ConfidenceLevelFilter {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "IGW-REQ";
                }
            }
            satisfy denmConfReq by Structure::V2X_CACC_System::top_system::inputGateway;

            requirement signalLossReq : SignalLossDetection {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "IGW-REQ";
                }
            }
            satisfy signalLossReq by Structure::V2X_CACC_System::top_system::inputGateway;

            requirement fragmentationReq : FragmentationMonitoring {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "IGW-REQ";
                }
            }
            satisfy fragmentationReq by Structure::V2X_CACC_System::top_system::inputGateway;
                

            requirement validationLatencyReq : ValidationLatency {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "IGW-REQ";
                }                    
            }
            satisfy validationLatencyReq by Structure::V2X_CACC_System::top_system::inputGateway;
        }
        package CAMComposerRequirementUsage{
            requirement egoStateReceptionReq : EgoStateReception {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONAL REQ"; 
            }
            
        }
        satisfy egoStateReceptionReq by Structure::V2X_CACC_System::top_system::camComposer;

        requirement triggerReq : TriggerOnStateChange {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONAL REQ"; 
            }
            
        }
        satisfy triggerReq by Structure::V2X_CACC_System::top_system::camComposer;

        requirement camCompositionReq : CAM_Composition {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONAL REQ"; 
            }
            
        }
        satisfy camCompositionReq by Structure::V2X_CACC_System::top_system::camComposer;

        requirement camTransmissionRateReq : CAM_TransmissionRate {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONAL REQ"; 
            }
            
        }
        satisfy camTransmissionRateReq by Structure::V2X_CACC_System::top_system::camComposer;

        requirement sampleHoldReq : SampleHoldBehavior {
            @RequirementStatus { 
                status = "Draft"; 
                approver = ""; 
                date = "";
                group = "FUNCTIONAL REQ"; 
            }
            
        }
        satisfy sampleHoldReq by Structure::V2X_CACC_System::top_system::camComposer;
        }
        package ElaborationRequirementUsage {
            requirement validatedDataReceptionReq : ValidatedDataReception {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> v2vDataPresent = elab.v2vInputValid;
                attribute :>> v2iDataPresent = elab.v2iInputValid;
            }
            satisfy validatedDataReceptionReq by Structure::V2X_CACC_System::top_system::elaboration;

            requirement followingParamsReq : FollowingParametersComputation {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> followingParamsReady = elab.followingParamsReady;
                attribute :>> leaderProfileUsed = elab.leaderProfileUsed;
                attribute :>> stringStabilityConsidered = elab.stringStabilityConsidered;
            }
            satisfy followingParamsReq by Structure::V2X_CACC_System::top_system::elaboration;

            requirement infrastructureAdaptReq : InfrastructureBasedAdaptation {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> v2iAvailable = elab.v2iInputValid;
                attribute :>> glosaApplied = elab.glosaActive;
                attribute :>> speedLimitEnforced = elab.speedLimitEnforced;
            }
            satisfy infrastructureAdaptReq by Structure::V2X_CACC_System::top_system::elaboration;

            requirement maneuverPriorityReq : ManeuverPrioritization {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "SAFETY REQ"; 
                }
                attribute :>> conflictingEvents = elab.conflictingEventsDetected;
                attribute :>> selectedManeuver = elab.selectedManeuver;
                attribute :>> controlParametersGenerated = elab.controlParametersReady;
            }
            satisfy maneuverPriorityReq by Structure::V2X_CACC_System::top_system::elaboration;

            requirement monitoringOutputReq : MonitoringOutput {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> monitoringStreamActive = elab.monitoringStreamActive;
            }
            satisfy monitoringOutputReq by Structure::V2X_CACC_System::top_system::elaboration;

            requirement computationLatencyReq : ComputationLatency {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "PERFORMANCE REQ"; 
                }
                attribute :>> cycleTime = elab.currentCycleTime;
                attribute :>> maxCycleTime = 20.0;
            }
            satisfy computationLatencyReq by Structure::V2X_CACC_System::top_system::elaboration;
        }
        package OutputGatewayRequirementUsage {
            requirement controlForwardingReq : ControlParametersForwarding {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> controlReceived = ogw.controlInputValid;
                attribute :>> controlForwarded = ogw.controlOutputValid;
            }
            satisfy controlForwardingReq by Structure::V2X_CACC_System::top_system::outputGateway;

            requirement camForwardingReq : CAM_Forwarding {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> camReceived = ogw.camInputValid;
                attribute :>> camForwarded = ogw.camOutputValid;
            }
            satisfy camForwardingReq by Structure::V2X_CACC_System::top_system::outputGateway;

            requirement monitoringForwardingReq : MonitoringForwarding {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> monitoringReceived = ogw.monitoringInputValid;
                attribute :>> monitoringForwarded = ogw.monitoringOutputValid;
            }
            satisfy monitoringForwardingReq by Structure::V2X_CACC_System::top_system::outputGateway;

            requirement platooningForwardingReq : PlatooningInfoForwarding {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
                attribute :>> platooningReceived = ogw.platooningInputValid;
                attribute :>> platooningForwarded = ogw.platooningOutputValid;
            }
            satisfy platooningForwardingReq by Structure::V2X_CACC_System::top_system::outputGateway;

            requirement platooningInfoControl : PlatooningInfoControl {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "FUNCTIONAL REQ"; 
                }
            }
            satisfy platooningInfoControl by Structure::V2X_CACC_System::top_system::outputGateway;

            requirement forwardingLatencyReq : ForwardingLatency {
                @RequirementStatus { 
                    status = "Draft"; 
                    approver = ""; 
                    date = "";
                    group = "PERFORMANCE REQ"; 
                }
                attribute :>> actualControlLatency = ogw.controlLatency;
                attribute :>> actualCAM_Latency = ogw.camLatency;
                attribute :>> actualMonitoringLatency = ogw.monitoringLatency;
                attribute :>> maxLatency = 5.0;
            }
            satisfy forwardingLatencyReq by Structure::V2X_CACC_System::top_system::outputGateway;
        }


        
        
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

        view actionflow_IGW : StandardViewDefinitions::ActionFlowView{
            doc /* View representing the action flow of the Input Gateway component, showing the sequence of actions and interactions that occur within the Input Gateway in response to events or use case scenarios. */
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
            filter @SysML::PartUsage;
            @ViewRendering { fileName = "ActionFlow-View (IGW)"; }
            @AnalysisInfo {
                label       = "Action Flow";
                groupName   = "L3 — Component Black-Box";
                domain      = "Behavioral";
                icon        = "⚡";
                level       = "L3";
                kind        = "BlackBox";
                component   = "InputGateway";
                parentGroup = "B_W";
            }
            expose Behaviour::systemUseCase::InputGateway_ActionFlow::**;
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

        view requirementView_IGW : RequirementView {
            doc /* View representing the requirements of the Input Gateway component, showing how the requirements are structured, categorized, and satisfied by the Input Gateway. */
            satisfy systemEngineerViewpoint;
            satisfy stakeholderViewpoint;
            @ViewRendering { fileName = "Requirement-View (IGW)"; }
            @AnalysisInfo {
                label       = "Requirement View (IGW)";
                groupName   = "L3 — Component Black-Box";
                domain      = "Requirements";
                icon        = "📋";
                level       = "L3";
                kind        = "BlackBox";
                component   = "InputGateway";
                parentGroup = "B_W";
            }
            expose Structure::V2X_CACC_System::top_system::inputGateway;
        }

        view requirementView_CC : RequirementView {
            doc /* View representing the requirements of the Input Gateway component, showing how the requirements are structured, categorized, and satisfied by the Input Gateway. */
            satisfy systemEngineerViewpoint;
            satisfy stakeholderViewpoint;
            @ViewRendering { fileName = "Requirement-View (CC)"; }
            @AnalysisInfo {
                label       = "Requirement View (CC)";
                groupName   = "L3 — Component Black-Box";
                domain      = "Requirements";
                icon        = "📋";
                level       = "L3";
                kind        = "BlackBox";
                component   = "CAMComposer";
                parentGroup = "B_W";
            }
            expose Structure::V2X_CACC_System::top_system::camComposer;
        }

        view requirementView_E : RequirementView {
            doc /* View representing the requirements of the Input Gateway component, showing how the requirements are structured, categorized, and satisfied by the Input Gateway. */
            satisfy systemEngineerViewpoint;
            satisfy stakeholderViewpoint;
            @ViewRendering { fileName = "Requirement-View (E)"; }
            @AnalysisInfo {
                label       = "Requirement View (E)";
                groupName   = "L3 — Component Black-Box";
                domain      = "Requirements";
                icon        = "📋";
                level       = "L3";
                kind        = "BlackBox";
                component   = "Elaboration";
                parentGroup = "B_W";
            }
            expose Structure::V2X_CACC_System::top_system::elaboration;
        }

        view requirementView_OGW : RequirementView {
            doc /* View representing the requirements of the Input Gateway component, showing how the requirements are structured, categorized, and satisfied by the Input Gateway. */
            satisfy systemEngineerViewpoint;
            satisfy stakeholderViewpoint;
            @ViewRendering { fileName = "Requirement-View (OGW)"; }
            @AnalysisInfo {
                label       = "Requirement View (OGW)";
                groupName   = "L3 — Component Black-Box";
                domain      = "Requirements";
                icon        = "📋";
                level       = "L3";
                kind        = "BlackBox";
                component   = "OutputGateway";
                parentGroup = "B_W";
            }
            expose Structure::V2X_CACC_System::top_system::outputGateway;
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

        view interconnection_IGW : StandardViewDefinitions::InterconnectionView {
            doc /* View definition for interconnection visualization. */
            satisfy systemEngineerViewpoint;
            satisfy softwareEngineerViewpoint;
            @ViewRendering { fileName = "Interconnection-View (IGW)"; }
            @AnalysisInfo {
                label       = "Interconnection View";
                groupName   = "L4 — Component White-Box";
                domain      = "Physical";
                icon        = "🔗";
                level       = "L4";
                kind        = "WhiteBox";
                component   = "InputGateway";
                parentGroup = "B_W";
            }
            expose Structure::V2X_CACC_System::top_system::inputGateway;
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
            doc /* Project lifecycle timeline. */

            item phaseA : Phase {
                doc /* Definizione iniziale dei Bisogni degli stakeholder, idee per realizzarli e analisi di queste. */
                attribute phaseName = "Concept";
                attribute owner     = "Ing. Esposito";
                attribute notes     = "Feasibility study of needs and project ideas.";

                item gate_conceptExit : Gate {
                    attribute condition = "Feasibility Review Approvata";
                    attribute gateType  = "exit";
                }
            }

            item phaseB : Phase {
                doc /* Formalizza i Bisogni degli Stakeholder in Requisiti di sistema. */
                attribute phaseName = "Requirements";
                attribute owner     = "Ing. Esposito";
                attribute notes     = "Elicit, analyze and formalize stakeholder needs into system requirements.";

                item gate_reqEntry : Gate {
                    attribute condition = "Concept Review Passed";
                    attribute gateType  = "entry";
                }
                item gate_reqExit : Gate {
                    attribute condition = "Requirements Baseline Fixed";
                    attribute gateType  = "exit";
                }
            }

            item phaseC : Phase {
                doc /* Tradurre i Requisiti in funzioni (action), ignorando i componenti fisici. */
                attribute phaseName = "Functional";
                attribute owner     = "Ing. Esposito";
                attribute notes     = "Define system functions and their interactions, without committing to physical components.";

                item gate_designEntry : Gate {
                    attribute condition = "Requirements Review Passed";
                    attribute gateType  = "entry";
                }
                item gate_designExit : Gate {
                    attribute condition = "Functional Design Review Passed";
                    attribute gateType  = "exit";
                }
            }

            item phaseD : Phase {
                doc /* Associazione delle funzioni ai blocchi dell'architettura. */
                attribute phaseName = "Logical";
                attribute owner     = "Ing. Esposito";
                attribute notes     = "Associate function to architecture blocks and define ports and interfaces.";

                item gate_implEntry : Gate {
                    attribute condition = "Functional Design Completed";
                    attribute gateType  = "entry";
                }
                item gate_implExit : Gate {
                    attribute condition = "System Architecture Review Passed.";
                    attribute gateType  = "exit";
                }
            }

            item phaseE : Phase {
                doc /* Progettazione nel dettaglio dei blocchi funzionali dell'Architettura. */
                attribute phaseName = "Physical";
                attribute owner     = "Ing. Esposito";
                attribute notes     = "Detail design of functional blocks in the architecture.";

                item gate_implEntry : Gate {
                    attribute condition = "Architecture Level Completed";
                    attribute gateType  = "entry";
                }
                item gate_implExit : Gate {
                    attribute condition = "Design Review Passed.";
                    attribute gateType  = "exit";
                }
            }

            item phaseF : Phase {
                doc /* Test di integrazione, simulazione HIL e verifica dei requisiti. */
                attribute phaseName = "Verification";
                attribute owner     = "Ing. Esposito";
                attribute notes     = "Integration, simulation and verification of Requirements.";

                item gate_vvEntry : Gate {
                    attribute condition = "Architecture Design Passed";
                    attribute gateType  = "entry";
                }
                item gate_vvExit : Gate {
                    attribute condition = "Verification Review Approved";
                    attribute gateType  = "exit";
                }
            }

            item phaseG : Phase {
                doc /* Verifica che il sistema soddisfi i bisogni degli stakeholder. */
                attribute phaseName = "Validation";
                attribute owner     = "Ing. Esposito";
                attribute notes     = "Validation with stakeholders to ensure needs are met.";

                item gate_vvEntry : Gate {
                    attribute condition = "Verification Review Approved";
                    attribute gateType  = "entry";
                }
                item gate_vvExit : Gate {
                    attribute condition = "Validation Review Approved";
                    attribute gateType  = "exit";
                }
            }


            item phaseH : Phase {
                doc /* Rilascio e messa in produzione del sistema. */
                attribute phaseName = "Deployment";
                attribute owner     = "Unknown";
                attribute notes     = "Release and deployment of the system.";

                item gate_deployEntry : Gate {
                    attribute condition = "Validation Review Approved";
                    attribute gateType  = "entry";
                }

                item gate_depExit : Gate {
                    attribute condition = "System deployed and operational.";
                    attribute gateType  = "exit";
                }
            }

            // ────── OCCURRENCE ──────
            occurrence occ_A1 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Define Objective: Design a modular cacc system that use V2X signals (V2V, V2I, ecc) to generate a batch of parameters to controll a car following model, using Deep Learning tecnique. Final implementation on FPGA hardware (PYNQ-Z1).";
                attribute date    = "2026-03-15";
            }

            occurrence occ_A2 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Platooning Study";
                attribute date    = "2026-03-16";
            }

            occurrence occ_A3 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Neural Network Study";
                attribute date    = "2026-03-20";
            }

            occurrence occ_A4 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "SysML v2 Study";
                attribute date    = "2026-03-28";
            }

            occurrence occ_A5 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Car Following Model Study";
                attribute date    = "2026-04-15";
            }

            occurrence occ_A6 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Define Project Needs";
                attribute date    = "2026-04-21";
            }

            occurrence occ_A7 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Inizialize Sysml v2 project (.sysml)";
                attribute date    = "2026-04-22";
            }

            occurrence occ_A8 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Produce Use-Case View";
                attribute date    = "2026-04-23";
            }

            occurrence occ_A9 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Produce Stakeholder View";
                attribute date    = "2026-04-23";
            }

            occurrence occ_A10 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Produce Member View";
                attribute date    = "2026-04-23";
            }

            occurrence occ_A11 : InternalOccurrence {
                attribute inPhase = "Concept";
                attribute content = "Produce Tool View";
                attribute date    = "2026-04-23";
            }

            occurrence pass_A_B : PassageEvent {
                attribute fromPhase    = "Concept";
                attribute toPhase      = "Requirements";
                attribute fromProgress = 100;
                attribute date         = "2026-04-25";
                attribute content      = "Concept Approved";
            }

            occurrence occ_B0 : InternalOccurrence {
                attribute inPhase = "Requirements";
                attribute content = "Start 1° Black-Box Analysis";
                attribute date    = "2026-04-26";
            }

            occurrence occ_B1 : InternalOccurrence {
                attribute inPhase = "Requirements";
                attribute content = "Convert Needs in Requirements (System)";
                attribute date    = "2026-04-26";
            }

            occurrence occ_B2 : InternalOccurrence {
                attribute inPhase = "Requirements";
                attribute content = "Produce Requirement View";
                attribute date    = "2026-04-26";
            }

            occurrence pass_B_C : PassageEvent {
                attribute fromPhase    = "Requirements";
                attribute toPhase      = "Functional";
                attribute fromProgress = 30;
                attribute date         = "2026-04-30";
                attribute content      = "Requirements To Approve";
            }

            occurrence occ_C1 : InternalOccurrence {
                attribute inPhase = "Functional";
                attribute content = "Define Actions (functions)";
                attribute date    = "2026-04-30";
            }

            occurrence occ_C2 : InternalOccurrence {
                attribute inPhase = "Functional";
                attribute content = "Produce ActionFlow View";
                attribute date    = "2026-04-30";
            }

            occurrence occ_C3 : InternalOccurrence {
                attribute inPhase = "Functional";
                attribute content = "Produce StateTransition View";
                attribute date    = "2026-04-30";
            }

            occurrence occ_C4 : InternalOccurrence {
                attribute inPhase = "Functional";
                attribute content = "Produce Sequence Views";
                attribute date    = "2026-04-30";
            }

            occurrence occ_C5 : InternalOccurrence {
                attribute inPhase = "Functional";
                attribute content = "Produce General View";
                attribute date    = "2026-04-30";
            }

            occurrence occ_C6 : InternalOccurrence {
                attribute inPhase = "Functional";
                attribute content = "Produce Grid View";
                attribute date    = "2026-04-30";
            }

            occurrence occ_C7 : InternalOccurrence {
                attribute inPhase = "Functional";
                attribute content = "Produce Browser View";
                attribute date    = "2026-04-30";
            }

            occurrence pass_C_D : PassageEvent {
                attribute fromPhase    = "Functional";
                attribute toPhase      = "Logical";
                attribute fromProgress = 30;
                attribute date         = "2026-05-04";
                attribute content      = "Functional Design Approved";
            }
            
            occurrence occ_D0 : InternalOccurrence {
                attribute inPhase = "Logical";
                attribute content = "Start 1° White-Box Analysis";
                attribute date    = "2026-05-04";
            }

            occurrence occ_D1 : InternalOccurrence {
                attribute inPhase = "Logical";
                attribute content = "Define internal Structure";
                attribute date    = "2026-05-04";
            }

            occurrence occ_D2 : InternalOccurrence {
                attribute inPhase = "Logical";
                attribute content = "Produce Internconnection View";
                attribute date    = "2026-05-04";
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
            attribute :>> role         = "Company Supervisor";
            attribute :>> email        = "emanuele.carella@kineton.it";
            attribute :>> organization = "Kineton";
            attribute :>> phone        = "+39 xxx xxx xxxx";
            doc /* Oversees project methodology, validates MBSE approach,
                 * and approves system architecture decisions. */
        }
        }
        
        package ProjectTools {
            doc /* Software tools used in the FPGA car-following MBSE project. */


            item vivado : SoftwareTool {
                attribute toolName    = "Xilinx Vivado";
                attribute version     = "2025.2";
                attribute vendor      = "AMD (ex Xilinx)";
                attribute toolType    = "EDA / FPGA Design Suite";
                attribute scope       = "Hardware Engineering";
                attribute license     = "WebPACK (Free)";
                attribute description = "FPGA design suite for synthesis, implementation and bitstream generation on PYNQ-Z1.";

                attribute descPurpose = "Primary tool for FPGA firmware development (HW/SW), including RTL design, synthesis, implementation, and bitstream generation.";
                attribute descRole    = "Hardware design, simulation, and deployment.";
                attribute descOutput  = "Bitstream (.bit), Timing/Power Reports, hardware/software configuration files (.xsa).";
                attribute descModules = "Vivado Simulator (XSim); IP Integrator; Logic Analyzer; High-Level Synthesis (HLS).";
                attribute descWiki    = "https://docs.xilinx.com";
            }

            item matlab : SoftwareTool {
                attribute toolName    = "MATLAB Toolchain";
                attribute version     = "2026a";
                attribute vendor      = "MathWorks";
                attribute toolType    = "Model-Based Design";
                attribute scope       = "System Modeling & Simulation";
                attribute license     = "Academic";
                attribute description = "Technical computing environment used for system-level modeling and simulation.";

                attribute descPurpose = "Define the logical and functional architecture of the system and run dynamic simulations to validate design choices.";
                attribute descRole    = "Implement the system architecture and execute the verification of system requirements.";
                attribute descOutput  = "Architecture models, simulation data (.mat), requirement verification reports.";
                attribute descModules = "System Composer; Simulink.";
                attribute descWiki    = "https://www.mathworks.com/help/";
            }

            item python : SoftwareTool {
                attribute toolName    = "Python";
                attribute version     = "3.13";
                attribute vendor      = "Python Software Foundation";
                attribute toolType    = "Scripting / Automation";
                attribute scope       = "Software Design";
                attribute license     = "PSF License (Open Source)";
                attribute description = "High-level interpreted language used as the primary ecosystem for artificial intelligence development.";

                attribute descPurpose = "Provide the computational framework and libraries required for machine learning development.";
                attribute descRole    = "Design the neural network architecture and execute its training phase.";
                attribute descOutput  = "Trained neural network models (e.g., .onnx, .pt, .h5), training logs, evaluation metrics.";
                attribute descModules = "Deep Learning Frameworks (e.g., TensorFlow/PyTorch, snntorch); Data Processing Libraries.";
                attribute descWiki    = "https://docs.python.org/3.13/";
            }

            item vscode_sysml : SoftwareTool {
                attribute toolName    = "Visual Studio Code (SysIde)";
                attribute version     = "1.90";
                attribute vendor      = "Sensmetry";
                attribute toolType    = "IDE / Textual Modeling Editor";
                attribute scope       = "Systems Engineering";
                attribute license     = "MIT (IDE) / Academic (SysIde)";
                attribute description = "Source code editor equipped with the SysIde extension by Sensmetry for text-based MBSE.";

                attribute descPurpose = "Enable text-based authoring of system models with real-time syntax validation and rendering.";
                attribute descRole    = "Write the SysML v2 model as code and visualize it through the extension's integrated visualizer.";
                attribute descOutput  = "SysML v2 source files (.sysml), interactive local visualizations.";
                attribute descModules = "SysIde Extension (0.8); Language Server Protocol (LSP).";
                attribute descWiki    = "https://sensmetry.com/syside";
            }
            
            item sysmlTool : SoftwareTool {
                attribute :>> toolName    = "SysML v2 CLI / Eclipse SysML v2 Extension";
                attribute :>> version     = "2025.12";
                attribute :>> vendor      = "OMG / Eclipse Foundation";
                attribute :>> toolType    = "MBSE Authoring";
                attribute :>> scope       = "Systems Engineering";
                attribute :>> license     = "Open Source";
                attribute :>> description = "Text-based SysML v2 modelling environment used to author and validate the system model / PlantUML extension for Eclipse IDE.";
            
                attribute descPurpose = "Enable text-based authoring of system models with real-time syntax validation and rendering.";
                attribute descRole    = "Write the SysML v2 model as code and visualize it through the extension's integrated visualizer.";
                attribute descOutput  = "SysML v2 source files (.sysml), interactive local visualizations.";
                attribute descModules = "SysML v2 CLI; Eclipse SysML Extension.";
                attribute descWiki    = "https://www.omg.org/spec/SysML/2.0/";
            }

            item eclipse_syson : SoftwareTool {
                attribute toolName    = "Eclipse SysON";
                attribute version     = "2026.03";
                attribute vendor      = "Eclipse Foundation";
                attribute toolType    = "MBSE Model Database & Visualizer";
                attribute scope       = "Systems Engineering";
                attribute license     = "Open Source";
                attribute description = "Open-source SysML v2 platform acting as the central authoritative repository for system models.";

                attribute descPurpose = "Centralize the MBSE data and enable automated data exchange across the engineering toolchain.";
                attribute descRole    = "Store the model in its database and manage REST API calls from other software to provide or receive data.";
                attribute descOutput  = "Centralized SysML v2 database records, REST API payloads (JSON).";
                attribute descModules = "SysON Database; REST API Gateway; Model Server.";
                attribute descWiki    = "https://syson.org/";
            }

            item custom_visualizer : SoftwareTool {
                attribute toolName    = "SysML v2 Visualizer";
                attribute version     = "0.5";
                attribute vendor      = "In-house Tool";
                attribute toolType    = "Visualization Utility";
                attribute scope       = "Systems Engineering";
                attribute license     = "Proprietary (In-house)";
                attribute description = "Dedicated in-house rendering engine for SysML v2 models.";

                attribute descPurpose = "Translate complex SysML v2 code into consumable graphical representations tailored for specific stakeholders.";
                attribute descRole    = "Provide a way to visualize the model's views and manage custom viewpoints.";
                attribute descOutput  = "Graphical views, interactive dashboards, rendered viewpoint exports.";
                attribute descModules = "Viewpoint Manager; Rendering Engine.";
                attribute descWiki    = "Internal Project Wiki";
            }

            item gitlab : SoftwareTool {
                attribute toolName    = "GitLab";
                attribute version     = "3.17";
                attribute vendor      = "Git Project";
                attribute toolType    = "Version Control";
                attribute scope       = "DevOps";
                attribute license     = "Open Source";
                attribute description = "Integrated platform for distributed version control and CI/CD automation.";

                attribute descPurpose = "Guarantee version history, branching, and collaboration for all project source files, including text-based models.";
                attribute descRole    = "Primary DevOps platform: Git repository hosting, code review via Merge Requests, and pipeline orchestration.";
                attribute descOutput  = "Commit history, branches, tags, CI/CD artifacts.";
                attribute descModules = "Version Control; CI/CD Pipelines; Issue Tracker; Merge Requests.";
                attribute descWiki    = "https://docs.gitlab.com";
            }
            
        }
    }

}