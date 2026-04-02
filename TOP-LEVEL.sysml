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


    private import system_test::*;
    

    /* ===================================================================
        * ATTRIBUTE USAGE
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
        attribute typicalPower: PowerValue;
        attribute maxPower: PowerValue;
    }
    attribute def VoltageCore:> ElectricPotentialValue {
        doc /* The core voltage of the FPGA, which is the voltage level at which the internal logic operates. */
    }
    attribute def Temperature:> TemperatureValue{
        doc /* The operating temperature range of the FPGA, which is important for ensuring reliable performance. */
        attribute tempMin: TemperatureValue;
        attribute tempMax: TemperatureValue;
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


    /* ===================================================================
        * PART USAGE
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
            attribute :>> typicalPower = 5 [W];
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

        part system : topLevelSystem {
            doc /* The top-level system allocated on the PYNQ-Z1 FPGA board, which integrates the various subsystems. */
            
            /* ===================================================================
		     * PART ALLOCATION
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
    }
    
    /* ===================================================================
        * PART USAGE
     * =================================================================== */
    part pynqZ1 : PYNQZ1 {
        doc /* The instance of the PYNQ-Z1 FPGA board used in the system. */
        
    }
        
        
}

    
        

        
        
}