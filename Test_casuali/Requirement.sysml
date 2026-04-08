library package Requirements {
    private import Attribute::*;

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