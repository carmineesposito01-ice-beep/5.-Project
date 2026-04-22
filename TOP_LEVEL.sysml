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
                }

                use case adaptingFollowing : UC5_AdaptingFollowing{
                subject :>> System = system;
                actor :>> car_following_model = cfm;
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

    
            

            
          
            

            /* ===================================================================
		         * REQUIREMENT USAGE (WIP)
	         * =================================================================== */
            
            satisfy requirement emergencyBraking: EmergencyBraking by this{
                doc /* Allocation of the requirement for emergency braking to the system. */
            }
            satisfy requirement cutInManagement: CutInManagement by this{
                doc /* Allocation of the requirement for cut-in management to the system. */
            }
            satisfy requirement wavesDetection : WavesDetection by this{
                doc /* Allocation of the requirement for stop-and-go wave detection to the system. */
            }
            satisfy requirement wavesMitigation : WavesMitigation by this{
                doc /* Allocation of the requirement for stop-and-go wave mitigation to the system. */
            }
            satisfy requirement adjustToDegradedSignals : AdjustToDegradedSignals by this{
                doc /* Allocation of the requirement for adjusting to degraded signals to the system. */
            }
            satisfy requirement continuousSignals : ContinuousSignals by this{
                doc /* Allocation of the requirement for handling continuous signals to the system. */
            }
            satisfy requirement interactionV2I : InteractionV2I by this{
                doc /* Allocation of the requirement for V2I interaction to the system. */
            }
            satisfy requirement crossroadAdaptation : CrossroadAdaptation by this{
                doc /* Allocation of the requirement for crossroad adaptation to the system. */
            }
            satisfy requirement trafficLightFlowOptimization : TrafficLightFlowOptimization by this{
                doc /* Allocation of the requirement for traffic light flow optimization to the system. */
            }
            satisfy requirement followingsUnderstanding : FollowingsUnderstanding by this{
                doc /* Allocation of the requirement for understanding following vehicles to the system. */
            }
            satisfy requirement followingAdaptation : FollowingAdaptation by this{
                doc /* Allocation of the requirement for adapting to following vehicles to the system. */
            }
            satisfy requirement jerkMinimization : JerkMinimization by this{
                doc /* Allocation of the requirement for jerk minimization to the system. */
            }
            satisfy requirement reactionTimeMinimize : ReactionTimeMinimize by this{
                doc /* Allocation of the requirement for minimizing reaction time to the system. */
            }
            satisfy requirement energyEfficiency : EnergyEfficiency by this{
                doc /* Allocation of the requirement for energy efficiency to the system. */
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
    viewpoint def EngineerViewpoint {
        doc /* Viewpoint for use case visualization.
            * Shows actors, subject system, and use cases with semantic links. */
    }
    viewpoint systemEngineerViewpoint : EngineerViewpoint;
    viewpoint systemEngineerViewpoint : EngineerViewpoint;

    view def UseCaseView {
    view def UseCaseView {
        doc /* View definition for actor/use-case visualization. */
        satisfy systemEngineerViewpoint;
    }

    view def SequenceView {
        doc /* View definition for sequence diagram visualization. */
        satisfy systemEngineerViewpoint;
        satisfy systemEngineerViewpoint;
    }

    view def SequenceView {
        doc /* View definition for sequence diagram visualization. */
        satisfy systemEngineerViewpoint;
    }

    view useCaseView : UseCaseView {
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

    
