package S_L_O_W {
    doc /* * S.L.O.W. (So Let Overthink Well) is a joke name, don't take that seriously. */
    
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
		 * PART DEFINITIONS — Subsystem Definitions
		 * =================================================================== */

    part def Condition_Unit {
        doc /* A unit to apply conditioning to input signals. */
    }

    part def Elaboration_Unit {
        doc /* A unit to perform elaboration on input signals. */
    }

    part def Balancing_Unit {
        doc /* Units to combine generated parameters with other from FAST Model. */
    }

    /* ===================================================================
		 * STATE DEFINITION — Ignition State Machine
		 * =================================================================== */
	


    /* ===================================================================
		 * TOP-LEVEL SYSTEM — Car (Composition)
		 * =================================================================== */
	

    part def SLOW_System {
        doc /* The top-level system representing the entire S.L.O.W. architecture. */
        part conditionUnit : Condition_Unit;
        part elaborationUnit : Elaboration_Unit;
        part balancingUnit : Balancing_Unit;

        /* Internal Connections via Interface Usages */
        connection dataFlow : DataFlow connect conditionUnit to elaborationUnit;
        connection dataFlow : DataFlow connect elaborationUnit to balancingUnit;

    }

    /* ===================================================================
		 * SYSTEM INSTANCE — Configured Vehicle
		 * =================================================================== */
	part Slow : SLOW_System {
        doc /* An instance of the S.L.O.W. system, representing a configured vehicle. */
    
        part :>> conditionUnit {
            /* Configuration for the Condition Unit */
        }
        part :>> elaborationUnit {
            /* Configuration for the Elaboration Unit */
        }
        part :>> balancingUnit {
            /* Configuration for the Balancing Unit */
        }
    }

}