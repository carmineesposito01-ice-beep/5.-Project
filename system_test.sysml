package system_test{
    doc /* This is the top-level system that will intagrate all subsystem for the application. */

    /* ===================================================================
         * IMPORTS [PARTS]
     * =================================================================== */
    private import conditioning_unit::*;
    private import elaboration_unit::*;
    private import balancing_unit::*;
    
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
        part conditioner : conditioning_unit;
        part elaborator : elaboration_unit;
        part balancer : balancing_unit;
        
        /* Internal Connections via Interface Usages */
        connection dataFlow : DataFlow connect conditioner to elaborator;
        connection dataFlow : DataFlow connect elaborator to balancer;

    }


}