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
                        then message '3: Control' from uc3_system.outMex to uc3_cfm.inMex;

                    }

                }

                use case shockwavesMitigation : UC4_Shockwave_Mitigation{
                subject :>> System = system;
                actor :>> car_following_model = cfm;
                actor :>> follower_vehicle = follower;

                }

                use case adaptingFollowing : UC5_AdaptingFollowing{
                subject :>> System = system;
                actor :>> car_following_model = cfm;
                actor :>> leader_vehicle = following;

                }

                use case crossRoadAdaptation : UC6_CrossroadAdaptation{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                }

                use case speedLimitsAdaptation : UC7_SpeedLimitsAdaptation{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                    actor :>> follower_vehicle = follower;
                }

                use case roadHazardWarning : UC8_RoadHazardWarning{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
            }

                use case roadConditionWarning : UC9_RoadConditionWarning{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                }

                use case signalViolationProtection : UC10_SignalViolationProtection{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                    actor :>> follower_vehicle = follower;
                    actor :>> criminal_vehicle = extraneous;
                }

                use case wrongWayDriverProtection : UC11_WrongWayDriverProtection{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                }

                use case specialVehicle : UC12_SpecialVehicle{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> special_vehicle = extraneous;
                    actor :>> infrastructure = infrastructure;
                }

                use case pedestrianProtection : UC13_PedestrianProtection{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> infrastructure = infrastructure;
                }

                use case degradedSignalManagement : UC14_DegradedSignalManagement{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> follower_vehicle = follower;
                }   

                use case fragmentedSignalManagement: UC15_FragmentedSignalManagement{
                    subject :>> System = system;
                    actor :>> car_following_model = cfm;
                    actor :>> interactor = general_interactor;
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

    view uc1_SequenceView : SequenceView {
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::cacc_synchronization::sequence;
        expose FPGA_Hardware::PYNQZ1::system::systemUseCase::cacc_synchronization::sequence::*;
        
        
        render viewRendering;
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
        
        render viewRendering;
    }
}

    
