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

    /* ===================================================================
         * ATTRIBUTE DEFINITIONS
     * =================================================================== */
    attribute def ScalarValue :> Real {
        doc /* A generic scalar value, used for various measurements. */
    }
    attribute def Quantity :> Real {
        doc /* A physical quantity with units, such as length or mass. */
    }
    attribute def MeasurementReference :> String {
        doc /* A reference to the measurement context or standard. */
    }
    attribute def ISQUnit :> String {
        doc /* An International System of Quantities (ISQ) unit, like "m" for meters. */
    }
    attribute def SIUnit :> String {
        doc /* A unit from the International System of Units (SI), like "kg" for kilograms. */
    }


    /* ===================================================================
		 * PORT DEFINITIONS — Energy and Signal Flows
	 * =================================================================== */
	port def DataPort {
        doc /* A generic port for data transfer between components. */
        in dataIn :> ScalarValue;
        out dataOut :> ScalarValue;
    }

    port def SupplyPort {
        doc /* A port for supplying power or resources to components. */
        in supplyIn :> Quantity;
        out supplyOut :> Quantity;
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
		 * TOP-LEVEL SYSTEM — Car (Composition)
	 * =================================================================== */
	
    part def topLevelSystem {
        doc /* The top-level system representing the entire S.L.O.W. architecture. */
        part conditioner : conditioning_unit::conditioning_unit;
        part elaborator : elaboration_unit::elaboration_unit;
        part balancer : balancing_unit::balancing_unit;
        
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
		
		filter signal_flows {
			doc /* Highlight all signal transfer paths */
		}
		filter external_interfaces {
			doc /* Show input/output ports at system boundary */
		}
		filter dataflow {
			doc /* Display data movement between subsystems */
		}
	}

}