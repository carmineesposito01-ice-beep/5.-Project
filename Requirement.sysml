library package Requirement_Definitions {
    private import ScalarValues::*;
    private import Quantities::*;
    private import MeasurementReferences::*;
    private import ISQ::*;
    private import SI::*;
    private import Attribute_Definitions::*;

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

    /* ===================================================================
		 * SYSTEM REQUIREMENTS (WIP)
	 * =================================================================== */
    requirement def SafeDistanceMaintenance{
        doc /* The system must maintain a safe distance from the following vehicle by adjusting the speed accordingly. */
        id = "SYS-001";
        text = "Il sistema deve mantenere una distanza di sicurezza dal veicolo che segue, regolando la velocità di conseguenza.";
        
        attribute actualDistance : QuantityValue;
        attribute requiredDistance : QuantityValue;

        require constraint {actualDistance >= requiredDistance}
    }

    requirement def RapidAdjustmentSpeed{
        doc /* The system must rapidly adjust the speed of the vehicle in response to changes in the following vehicle's behavior. */
        id = "SYS-002";
        text = "Il sistema deve regolare rapidamente la velocità del veicolo in risposta ai cambiamenti nel comportamento del veicolo che segue.";
        
        attribute actualAdjustmentTime : TimeValue;
        attribute requiredAdjustmentTime : TimeValue;

        require constraint {actualAdjustmentTime <= requiredAdjustmentTime}        
    }

    requirement def EmergencyBrakeing{
        doc /* The system must apply emergency braking when receive an emergency flag (DENM message). */
        id = "SYS-003";
        text = "Il sistema deve applicare la frenata di emergenza quando viene ricevuto un messaggio d'emergenza.";
        
        attribute max_processing_time : TimeValue;
        attribute min_deceleration : Real; 
        attribute response_latency : TimeValue;
        attribute commanded_accel : Real;
        
        
        require constraint {
            doc /* Verifica del tempo di elaborazione per l'emergenza */
            response_latency <= max_processing_time
        }        
        require constraint {
            doc /* Verifica dell'applicazione della forza frenante massima */
            commanded_accel <= min_deceleration
        }
    }

    requirement def V2V_Anticipation{
        doc /* The system must anticipate the behavior of the following vehicle based on historical data and current conditions. */
        id = "SYS-004";
        text = "Il sistema deve anticipare il comportamento del veicolo che segue basandosi su dati storici e condizioni attuali.";

        attribute min_anticipation_time : TimeValue;
        attribute max_jerk : Real;        
        attribute action_start_time : TimeValue;
        attribute leader_maneuver_start_time : TimeValue;
        
        require constraint {
            doc /* Verifica che l'azione inizi prima dell'effettiva variazione cinematica */
            action_start_time <= (leader_maneuver_start_time - min_anticipation_time)
        }
    }

    requirement def CutInManagement{
        doc /* The system must detect cut-in maneuvers from other vehicle and respond accordingly. */
        id = "SYS-005";
        text = "Il sistema deve rilevare le manovre di taglio di altri veicoli e rispondere di conseguenza.";
        
        attribute max_lateral_detection_time : TimeValue;
        attribute comfort_decel_limit : Real;
        attribute detection_delay : TimeValue;
        attribute commanded_accel : Real;
        

        require constraint {
            doc /* Verifica che il rilevamento avvenga rapidamente */
            detection_delay <= max_lateral_detection_time
        }    
        require constraint {
            doc /* Verifica che non si usi una frenata d'emergenza per un cut-in sicuro */
            commanded_accel >= comfort_decel_limit
        }
    }





}

    
    