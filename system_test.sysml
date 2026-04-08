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
    public import Attribute::*;

    enum def AsilLevel {        
        doc /*
                 * Automotive Safety Integrity Level (ASIL) classification for the conditioning unit, indicating the required safety level for its operation.
        */
        enum QM;
        enum A;
        enum B;
        enum C;
        enum D;
    }

    /* ===================================================================
         * ATTRIBUTE DEFINITIONS
    * =================================================================== */
    attribute def systemClockFrequency_MHz :> Real {
        doc /* The operating clock frequency of the conditioning unit, in megahertz (MHz). */
    }
    attribute def asilRequirement :> AsilLevel {
        doc /* The Automotive Safety Integrity Level (ASIL) requirement for the conditioning unit, indicating the safety level it must meet. */
    }
    attribute def totalLatencyBudget_ms :> Real {
        doc /* The total latency budget for the conditioning unit, in milliseconds (ms), indicating the maximum allowed time for processing input signals. */
    }
    attribute def thermalPowerLimit_W :> Real {
        doc /* The thermal power limit for the conditioning unit, in watts (W), indicating the maximum power dissipation allowed to prevent overheating. */
    }
    

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

        attribute systemClockFrequency_MHz : Real = 200.0;
        attribute asilRequirement : AsilLevel = AsilLevel::B;
        attribute totalLatencyBudget_ms : Real = 5.0;
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