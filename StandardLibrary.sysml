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
    /* ===================================================================
         * ATTRIBUTE DEFINITIONS (da cambiare con quelli definiti in Attribute_Definitions)
    * =================================================================== */
    attribute def ClockFrequency:> QuantityValue{
        doc /* The operating clock frequency of the FPGA system, in megahertz (MHz). */
    }
    attribute def LogicElements:> ScalarValue {
        doc /* The number of logic elements available in the FPGA, which determines the complexity of the designs that can be implemented. */
    }
    attribute def DSPBlocks:> ScalarValue {
        doc /* The number of digital signal processing (DSP) blocks available in the FPGA, which are specialized for high-speed arithmetic operations. */
    }
    attribute def BlockRAM:> QuantityValue{
        doc /* The amount of block RAM available in the FPGA, which is used for storing data and instructions. */
    }
    attribute def IOPins:> ScalarValue {
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

    attribute def CarFollowingParams {
        doc /* Parameters for car-following behavior, used in car-following algorithms. */
        attribute headwayTime : Real;  // s
        attribute maxAcceleration : Real; // m/s^2
        attribute maxDeceleration : Real; // m/s^2
    }

    attribute def DecelerationProfile {
        doc /* Profile for deceleration behavior, used in car-following algorithms. */
        attribute maxDeceleration : Real; // m/s^2
        attribute jerk : Real; // m/s^3
    }
}

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
        id = "FR-S-001";
        text = "Il sistema deve mantenere una distanza di sicurezza dal veicolo che segue, regolando la velocità di conseguenza.";
        
        attribute actualDistance : QuantityValue;
        attribute requiredDistance : QuantityValue;

        require constraint {actualDistance >= requiredDistance}
    }

    requirement def EmergencyBraking{
        doc /* The system must apply emergency braking when receive an emergency flag (DENM message). */
        id = "FR-S-002";
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

    requirement def CutInManagement{
        doc /* The system must detect cut-in maneuvers from other vehicle and respond accordingly. */
        id = "FR-S-003";
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

    requirement def WavesDetection{
        doc /* The system must detect stop-and-go waves in the traffic flow, observing following vehicles situation. */
        id = "FR-S-004";
        text = "Il sistema deve controllare lo stato dei veicoli che lo precedono, per rilevare in anticipo onde 'stop-and-go'.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di accelerazione/decelerazione dei veicoli che precedono.
    }

    requirement def WavesMitigation{
        doc /* The system must mitigate stop-and-go waves by adjusting the speed of the vehicle based on the waves intensity. */
        id = "FR-S-005";
        text = "Il sistema deve mitigare le onde 'stop-and-go' regolando la velocità del veicolo in base all'entità dell'onda.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di accelerazione/decelerazione dei veicoli che precedono e sulla capacità del sistema di assorbire queste variazioni senza causare disagio ai passeggeri.
    }

    requirement def AdjustToDegradedSignals{
        doc /* The system must adjust its behavior in case of degraded V2X signal quality, for example by increasing the safety distance or reducing the speed. */
        id = "FR-S-006";
        text = "Il sistema deve adattare il proprio comportamento in caso di degrado della qualità del segnale V2X, ad esempio aumentando la distanza di sicurezza o riducendo la velocità.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di degradazione del segnale e sulla capacità del sistema di adattarsi a queste condizioni per mantenere la sicurezza.
    }

    requirement def ContinuousSignals{
        doc /* The system must ensure continuous and reliable V2X signals, to avoid ghost braking and maintain smooth driving. */
        id = "FR-S-007";
        text = "Il sistema deve garantire segnali V2X continui e affidabili, allo scopo di evitare frenate fantasma e mantenere una guida fluida.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di elaborazione dei segnali e sulla capacità del sistema di mantenere una risposta coerente e affidabile anche in presenza di variazioni nei dati ricevuti.
    }
    requirement def InteractionV2I{
        doc /* The system must interact with the infrastructure (V2I) and extract from SPaT messages the necessary information for its operation (e.g., traffic light color, remaining time, etc.). */
        id = "FR-S-008";
        text = "Il sistema deve interagire con l'infrastruttura (V2I) ed estrarre dai messaggi SPaT le informazioni necessarie al funzionamento (ex. colore semaforo, tempo residuo, ecc).";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di comunicazione V2I e sulla capacità del sistema di integrare queste informazioni nel processo decisionale per migliorare la sicurezza e l'efficienza della guida.
    }

    requirement def CrossroadAdaptation{
        doc /* The system must adapt its trend at crossroads, considering the behavior of surrounding vehicles and traffic conditions (taken from V2V and V2I signals (SPaT)). */
        id = "FR-S-009";
        text = "Il sistema deve adattare il proprio andamento agli incroci, considerando il comportamento dei veicoli circostanti e le condizioni del traffico (sulla base dei segnali V2V e V2I (SPaT)).";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di comportamento degli incroci e sulla capacità del sistema di adattarsi a queste condizioni per garantire una guida sicura ed efficiente.
    }

    requirement def TrafficLightFlowOptimization{
        doc /* The system must optimize the traffic flow at intersections by adjusting the speed of the vehicle to catch green lights, based on V2I communication and SPaT messages. */
        id = "FR-S-010";
        text = "Il sistema deve ottimizzare il flusso del traffico agli incroci regolando la velocità del veicolo per prendere i semafori verdi, sulla base della comunicazione V2I e dei messaggi SPaT.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di ottimizzazione del flusso del traffico e sulla capacità del sistema di regolare la velocità in modo da massimizzare l'efficienza della guida e ridurre i tempi di attesa agli incroci.
    }

    requirement def FollowingsUnderstanding{
        doc /* The system must understand the behavior of the following vehicle, classifying it (e.g., aggressive, cautious) based on its behavior and characteristics. */
        id = "FR-S-011";
        text = "Il sistema deve comprendere il comportamento del veicolo che segue, classificandolo (es. aggressivo, prudente) sulla base del suo comportamento e delle sue caratteristiche.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di comportamento dei veicoli che seguono e sulla capacità del sistema di classificare questi comportamenti per adattare la propria strategia di guida in modo più efficace.
    }

    requirement def FollowingAdaptation{
        doc /* The system must adapt its behavior based on the classification of the following vehicle, to enhance safety and comfort. */
        id = "FR-S-012";
        text = "Il sistema deve adattare il proprio comportamento in base alla classificazione del veicolo che segue, per migliorare la sicurezza e il comfort.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di adattamento del comportamento e sulla capacità del sistema di regolare la propria strategia di guida in modo da garantire una maggiore sicurezza e comfort per i passeggeri.
    }

    requirement def JerkMinimization{
        doc /* The system must minimize jerk (the rate of change of acceleration) to enhance passenger comfort, especially during stop-and-go waves or cut-in maneuvers. */
        id = "CR-S-01";
        text = "Il sistema deve minimizzare il jerk (la variazione di accelerazione) per migliorare il comfort dei passeggeri, specialmente durante le onde di stop-and-go o le manovre di inserimento.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di minimizzazione del jerk e sulla capacità del sistema di regolare la propria strategia di guida in modo da garantire una maggiore comodità per i passeggeri.
    }

    requirement def ReactionTimeMinimize{
        doc /* The system must minimize is own reaction time to the enviroment change, to enhance safety. */
        id = "CR-S-2";
        text = "Il sistema deve minimizzare il proprio tempo di reazione ai cambiamenti dell'ambiente, per migliorare la sicurezza.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di minimizzazione del tempo di reazione e sulla capacità del sistema di regolare la propria strategia di guida in modo da garantire una maggiore sicurezza.
    }

    requirement def EnergyEfficiency{
        doc /* The system must optimize energy efficiency to minimize battery usage and power dissipation. */
        id = "NFR-S-1";
        text = "Il sistema deve ottimizzare l'efficienza energetica per minimizzare il consumo della batteria e la dissipazione di potenza.";

        // Riempire poi con la logica di validazione di questo requisito, ad esempio basata su pattern di ottimizzazione dell'efficienza energetica e sulla capacità del sistema di regolare la propria strategia di guida in modo da garantire una maggiore efficienza energetica.
    }





}



library package Use_Case_Definitions{
    doc /* This package defines the use cases for car-following project. */
    
    part def Interactor{
        doc /* The interactor is a general actor that represents any entity that interacts with the system, such as vehicles, pedestrians, or infrastructure. */
        
        action sendData;
    }

    part def Vehicle:> Interactor{
        doc /* The vehicle actor represents any type of vehicle that interacts with the system, including both the ego vehicle and other vehicles on the road. */
    }

    part def Infrastructure:> Interactor{
        doc /* The infrastructure actor represents any roadside infrastructure that interacts with the system, such as traffic lights, road signs, or V2X communication units. */
    }

    part def Person:> Interactor{
        doc /* The person actor represents any individual technology that interacts with the system, such as smartphone, smarwatch or GPS devices. */
    }

    part def CloudService:> Interactor{
        doc /* The cloud service actor represents any remote service that interacts with the system, such as a traffic management system or a data analytics platform. */
    }

    part def CarFollowingModel{
        doc /* The car-following model represents the internal logic of the system that determines how the vehicle should adjust its speed and trajectory based on the received data and the behavior of surrounding vehicles. */
    }

    part def CarFollowingModel{
        doc /* The car-following model represents the internal logic of the system that determines how the vehicle should adjust its speed and trajectory based on the received data and the behavior of surrounding vehicles. */
    }

    item def Signals{
        doc /* The signals represent the various types of data that the system receives and processes, including V2X data, sensor data, and environmental data. */
    }

    item def V2VSignals:> Signals{
        doc /* The V2V signals represent the data received from other vehicles, which may include information about their speed, position, and behavior. */
    }

    item def V2ISignals:> Signals{
        doc /* The V2I signals represent the data received from the infrastructure, which may include information about traffic light status, road conditions, and other relevant factors. */
    }
    

    /* ===================================================================
         * USE CASE DEFINITIONS
     * =================================================================== */
    use case def UC0_SystemUseCases{
        objective{
            doc /* This use case represents the overall system use cases, which include various interactions with other vehicles, infrastructure, and external services. */
        }
    }


    use case def UC1_CACC_Synchronization{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor leader_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor leader_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for synchronizing the vehicle's trend with the following vehicle, based on the received V2V data. */
        }                   
    }

    use case def UC2_AbruptCutIn{
        subject System : Parts::Part{
            action inMex;
            action outMex;
        }
        actor car_following_model{
            action inMex;
            action outMex;
        }
        actor infrastructure{
            action inMex;
            action outMex;
        }
        subject System : Parts::Part{
            action inMex;
            action outMex;
        }
        actor car_following_model{
            action inMex;
            action outMex;
        }
        actor infrastructure{
            action inMex;
            action outMex;
        }
        objective{
            doc /* Use case for managing abrupt cut-in maneuvers from other vehicles, by adjusting the speed and trajectory of the vehicle to maintain safety. */
        }    
    }

    use case def UC3_CalledCutIn{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor lateral_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor lateral_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for managing called cut-in maneuvers from other vehicles, by adjusting the speed and trajectory of the vehicle to maintain safety. */
        }
    }

    use case def UC4_Shockwave_Mitigation{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor leader_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for mitigating shockwaves in traffic flow, by adjusting the speed of the vehicle based on the behavior of the following vehicle and the received V2V data. */
        }
    }

    use case def UC5_AdaptingFollowing{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor leader_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor leader_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for adapting the vehicle's following behavior based on the classification of the following vehicle, to enhance safety and comfort. */
        }
    }

    use case def UC6_CrossroadAdaptation{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for adapting the vehicle's trend at crossroads, considering the behavior of surrounding vehicles and traffic conditions (taken from V2V and V2I signals (SPaT)). */
        }
    }

    use case def UC7_SpeedLimitsAdaptation{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for adjusting the vehicle's speed based on speed limits received from V2I communication, to enhance safety and comply with traffic regulations. */
        }
    }

    use case def UC8_RoadHazardWarning{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for responding to road hazard warnings received from V2I communication, by adjusting the speed and trajectory of the vehicle to maintain safety. */
        }
    }

    use case def UC9_RoadConditionWarning{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for responding to road condition warnings received from V2I communication, by adjusting the speed and trajectory of the vehicle to maintain safety. */
        }
    }

    use case def UC10_SignalViolationProtection{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor criminal_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor criminal_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for protecting against signal violations at intersections, by adjusting the speed and trajectory of the vehicle based on traffic light status received from V2I communication. */
        }
    }

    use case def UC11_WrongWayDriverProtection{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for protecting against wrong-way drivers, by adjusting the speed and trajectory of the vehicle based on warnings received from V2I communication. */
        }
    }

    use case def UC12_SpecialVehicle{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor special_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor special_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for responding to special vehicle warnings received from V2I communication, by adjusting the speed and trajectory of the vehicle to maintain safety. */
        }
    }

    use case def UC13_PedestrianProtection{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor infrastructure{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for protecting pedestrians, by adjusting the speed and trajectory of the vehicle based on warnings received from V2I communication or detected by the vehicle's sensors. */
        }
    }

    use case def UC14_DegradedSignalManagement{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor follower_vehicle{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for managing degraded V2X signal quality, by pass the controll to the local sensor system. */
        }
    }

    use case def UC15_FragmentedSignalManagement{
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor interactor{
            event occurrence inMex;
            event occurrence outMex;
        }
        subject System : Parts::Part{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor car_following_model{
            event occurrence inMex;
            event occurrence outMex;
        }
        actor interactor{
            event occurrence inMex;
            event occurrence outMex;
        }
        objective{
            doc /* Use case for managing fragmented V2X signal quality, by implementing strategies to maintain safe operation even when data are fragmenteted. */
        }
    }




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



library package State {
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