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
		 * PORT DEFINITIONS — Energy and Signal Flows
	 * =================================================================== */
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


        part conditioner : conditioning_unit::conditioning_unit_v1;
        part elaborator : elaboration_unit::elaboration_unit_v1;
        part balancer : balancing_unit::balancing_unit_v1;
        
        /* Internal Connections via Interface Usages */
        connection conditioned_signals : DataFlow connect conditioner to elaborator;
        connection generated_parameters : DataFlow connect elaborator to balancer;

        /* ===================================================================
             * USE CASE ALLOCATION
         * =================================================================== */
        use case maintainSecurityDistance : N1_MaintainSecurityDistance{
            doc /* Allocation of the Maintain Security Distance use case to the system. */
            subject :>> system = system;
        }
        use case emergencyBraking : N3_EmergencyBraking{
            doc /* Allocation of the Emergency Braking use case to the system. */
            subject :>> system = system;
        }
        use case cutInDetection : N5_CutInDetection{
            doc /* Allocation of the Cut-In Detection use case to the system. */
            subject :>> system = system;
        }
        use case stopAndGoMitigation: N6_StopAndGoMitigation{
            doc /* Allocation of the Stop-and-Go Mitigation use case to the system. */
            subject :>> system = system;
        }
        use case packetLossResilience : N7_PacketLossResilience{
            doc /* Allocation of the Packet Loss Resilience use case to the system. */
            subject :>> system = system;
        }
        use case crossroadAdaptiveDriving : N8_CrossroadAdaptiveDriving{
            doc /* Allocation of the Crossroad Adaptive Driving use case to the system. */
            subject :>> system = system;
        }
        use case followingVehicleClassification : N9_FollowingVehicleClassification{
            doc /* Allocation of the Following Vehicle Classification use case to the system. */
            subject :>> system = system;
        }
        /* ===================================================================
		     * REQUIREMENT USAGE (WIP)
	     * =================================================================== */
        satisfy requirement safeDistanceMaintenance: SafeDistanceMaintenance by this{
            doc /* Allocation of the requirement for maintaining a safe distance to the system. */
            
        }
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

    part system : topLevelSystem {
        doc /* The system instance that will be used for requirement and use case allocation. */
    }


    /* ===================================================================
		 * VIEWPOINT DEFINITIONS — Filtered Views on the System
	 * =================================================================== */
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

}