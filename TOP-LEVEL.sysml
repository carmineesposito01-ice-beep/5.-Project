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


    /* ===================================================================
        * REQUIREMENT DEFINITIONS
     * =================================================================== */
    package Requirements {
        requirement def FPGA_ResourceRequirements {
            doc /* Resource requirements for the FPGA system, including logic elements, DSP blocks, block RAM, and I/O pins. */
            id = "RES-001";
            requirement LogicElementsRequirement {
                id = "RES-001-LE";
                doc /* Constraint to ensure that the number of logic elements used in the design does not exceed the available logic elements on the FPGA. */
                attribute actual : LogicElements;
                attribute required : LogicElements;

                require constraint {actual <= required}
            }
            requirement DSPBlocksRequirement {
                id = "RES-001-DSP";
                doc /* Constraint to ensure that the number of DSP blocks used in the design does not exceed the available DSP blocks on the FPGA. */
                attribute actual : DSPBlocks;
                attribute required : DSPBlocks;

                require constraint {actual <= required}
            }
            requirement BlockRAMRequirement {
                id = "RES-001-BRAM";
                doc /* Constraint to ensure that the amount of block RAM used in the design does not exceed the available block RAM on the FPGA. */
                attribute actual : BlockRAM;
                attribute required : BlockRAM;

                require constraint {actual <= required}
            }
            requirement IOPinsRequirement {
                id = "RES-001-IO";
                doc /* Constraint to ensure that the number of I/O pins used in the design does not exceed the available I/O pins on the FPGA. */
                attribute actual : IOPins;
                attribute required : IOPins;

                require constraint {actual <= required}
            }

            text = "Il sistema FPGA deve rispettare i limiti di risorse hardware, inclusi logic elements, DSP blocks, block RAM e I/O pins.";
        }

        requirement def FPGA_PerformanceRequirements {
            doc /* Performance requirements for the FPGA system, including throughput and latency. */
            id = "PERF-001";
            text = "Il sistema FPGA deve garantire una throughput minimo e latenza massima.";
        
            attribute actual : Performance;
            attribute required : Performance;

            require constraint {
                actual.maxThroughput >= required.maxThroughput and
                actual.latency <= required.latency
            }
            
        }

        requirement def FPGA_SafetyRequirement{
            doc /* Safety requirements for the FPGA system, including fault detection and safe-state transition. */
            id = "SAFE-001";
            text = "Il sistema FPGA deve rilevare e gestire i fault hardware entro un certo tempo, passando in safe‑state.";
            
            attribute actualDetectionTime : TimeValue;
            attribute actualRecoveryTime : TimeValue;
            attribute requiredTime : TimeValue;

            require constraint {
                (actualDetectionTime + actualRecoveryTime) <= requiredTime
            }
        }

        requirement def FPGA_SecurityRequirement{
            doc /* Security requirements for the FPGA system, including secure boot and bitstream encryption. */
            id = "SEC-001";
            text = "Il sistema FPGA deve implementare SecureBoot e BitstreamEncryption per proteggere contro accessi non autorizzati.";
            
            attribute actualFeatures : SecurityFeatures;
    
            require constraint {
                actualFeatures.SecureBoot == true and 
                actualFeatures.BitstreamEncryption == true and
                actualFeatures.TamperDetection ==true
            }
        }

        requirement def FPGA_ReliabilityRequirement{
            doc /* Reliability requirements for the FPGA system, including mean time between failures (MTBF). */
            id = "REL-001";
            text = "Il sistema FPGA deve avere un MTBF ≥ 10.000 h in condizioni operative (‑40 °C … +85 °C).";
            
            attribute actual_MTBF : TimeValue;
            attribute required_MTBF : TimeValue;
            attribute actual_temperature : TemperatureValue;
            attribute required_temperature : Temperature;

            assume constraint{required_temperature.tempMin <= actual_temperature <= required_temperature.tempMax}
            require constraint{
                actual_MTBF >= required_MTBF
            }

        }

        requirement def FPGA_PowerRequirement{
            doc /* Constraint to ensure that the power consumption of the design does not exceed the maximum power limit of the FPGA. */
            id = "POWER-001";
            text = "Il sistema FPGA deve consumare ≤ potenza massima in condizioni operative.";
        
            attribute actual : PowerValue;
            attribute required : PowerValue;

            require constraint {actual <= required}        
        }

        requirement def FPGA_ThermalRequirement{
            doc /* Constraint to ensure that the operating temperature of the FPGA does not exceed the specified limits. */
            id = "THERMAL-001";
            text = "Il sistema FPGA deve operare entro i limiti di temperatura specificati.";
        
            attribute actual : TemperatureValue;
            attribute required : Temperature;

            require constraint {required.tempMin <= actual <= required.tempMax}        
        }
    
    }






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
            satisfy requirement resourceReq : Requirements::FPGA_ResourceRequirements by this{
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

            satisfy requirement PerformanceReq : Requirements::FPGA_PerformanceRequirements by this{
                attribute :>> actual = system.performance;
                attribute :>> required = performance;
            }
            satisfy requirement SafetyReq : Requirements::FPGA_SafetyRequirement by this{
                attribute :>> actualDetectionTime = system.safetyDetectionTime;
                attribute :>> actualRecoveryTime = system.safetyRecoveryTime;
                attribute :>> requiredTime = 100 [milli*s];
            }
            satisfy requirement SecuriyReq : Requirements::FPGA_SecurityRequirement by this {
                attribute :>> actualFeatures = securityFeatures;
            }
            satisfy requirement ReliabilityReq : Requirements::FPGA_ReliabilityRequirement by this{
                attribute :>> actual_MTBF = mtbf;
                attribute :>> required_MTBF = 10000 [hour];
                attribute :>> actual_temperature = system.temperature;
                attribute :>> required_temperature = temperature;
            }


            satisfy requirement PowerReq : Requirements::FPGA_PowerRequirement by this{
                attribute :>> actual = system.used_power;
                attribute :>> required = power.maxPower;
            }

            satisfy requirement ThermalReq : Requirements::FPGA_ThermalRequirement by this{
                attribute :>> actual = system.temperature; 
                attribute :>> required = temperature;
            }
        }
    }

  
}

    
