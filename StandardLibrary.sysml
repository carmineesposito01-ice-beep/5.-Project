library package Attribute_Definitions{
    doc /* FPGA System Definition:
         * This package defines the overall structure where the system will be allocated, with all the main components and their interactions.
         * It serves as the central point for integrating the various subsystem. 
         * */
    private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;

    

    /* ===================================================================
        * ATTRIBUTE DEFINITIONS
     * =================================================================== */
    attribute def ClockFrequency:> QuantityValue{
        doc /* The operating clock frequency of the FPGA system, in megahertz (MHz). */
    }
    attribute def LogicElements:> Integer {
        doc /* The number of logic elements available in the FPGA, which determines the complexity of the designs that can be implemented. */
    }
    attribute def DSPBlocks:> Integer {
        doc /* The number of digital signal processing (DSP) blocks available in the FPGA, which are specialized for high-speed arithmetic operations. */
    }
    attribute def BlockRAM:> QuantityValue{
        doc /* The amount of block RAM available in the FPGA, which is used for storing data and instructions. */
    }
    attribute def IOPins:> Integer {
        doc /* The number of input/output pins available on the FPGA, which determines how many external connections can be made. */
    }
    attribute def Power:> PowerValue{
        doc /* The power consumption of the FPGA system, typically measured in watts (W). */
        attribute maxPower: PowerValue;
    }
    attribute def VoltageCore:> ElectricPotentialValue {
        doc /* The core voltage of the FPGA, which is the voltage level at which the internal logic operates. */
    }
    attribute def Temperature:> TemperatureValue{
        doc /* The operating temperature range of the FPGA, which is important for ensuring reliable performance. */
        attribute tempMin: TemperatureValue;
        attribute tempMax: TemperatureValue;
        
        assert constraint {
            tempMin <= tempMax
        }
    }
    attribute def Performance:> QuantityValue{
        doc /* The performance characteristics of the FPGA system, including maximum throughput and latency. */
        attribute maxThroughput: QuantityValue;
        attribute latency: TimeValue;
    }
    attribute def ReconfigurationTime:> TimeValue{
        doc /* The time required to reconfigure the FPGA, which is important for applications that require dynamic changes to the hardware configuration. */
    }
    attribute def SecurityFeatures:> Boolean {
        doc /* The security features implemented in the FPGA system, which may include secure boot, bitstream encryption, and tamper detection. */
        attribute SecureBoot: Boolean;
        attribute BitstreamEncryption: Boolean;
        attribute TamperDetection: Boolean;
    }
    attribute def MaxAllowedTime:> TimeValue{
        doc /* The maximum allowed time to identify safety fault. */
    }    
    attribute def MTBF:> TimeValue{
        doc /* The mean time between failures (MTBF) of the FPGA system, which is a measure of its reliability. */
    }
}

// TODO: Put package of use case and other here, so you have a centralized file


// QUI SOTTO è SBAGLIATO (CORREGGERE)
library package Interfaces {
    item def V2X_Payload {
        doc /* The payload structure for V2X communication, which includes relevant information about the leader vehicle. */
        attribute leader_velocity : ScalarValues::Real;
        attribute leader_position : ScalarValues::Real;
    }
    
    port def V2X_ReceiverPort {
        doc /* A port for receiving V2X data from the leader vehicle, which will be used for decision-making in the system. */
        in item payload : V2X_Payload;
    }
}