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
            use case cacc_synchronization : UC1_CACC_Synchronization{
                doc /* Allocation of the CACC Synchronization use case to the system. */
                subject system;
                actor Vehicle = Vehicle;
            }

            use case emergency_braking : UC2_EmergencyBraking{
                doc /* Allocation of the Emergency Braking use case to the system. */
                subject system;
                actor Vehicle = Vehicle;
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
}

    
