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
    // SYS-F-001: ricezione CAM >= 10 Hz
    requirement def CAM_ReceptionRate {
        doc /* SYS-F-001: The system shall receive CAM messages at a minimum frequency of 10 Hz. */
        id = "SYS-F-001";
        text = "The system shall receive CAM messages at a minimum frequency of 10 Hz.";
        attribute actualReceiveRate : Real;   // Hz
        attribute requiredRate : Real = 10.0; // Hz
        require constraint { actualReceiveRate >= requiredRate }
    }

    // SYS-F-002: calcolo parametri following da CAM
    requirement def CAM_BasedFollowingComputation {
        doc /* SYS-F-002: The system shall compute car‑following parameters based on received CAM signals. */
        id = "SYS-F-002";
        text = "The system shall compute car‑following parameters based on received CAM signals.";
        attribute camDataAvailable : Boolean;
        attribute followingParamsValid : Boolean;
        require constraint { camDataAvailable implies followingParamsValid }
    }

    // SYS-F-003: invio CAM aggiornati
    requirement def CAM_Transmission {
        doc /* SYS-F-003: The system shall send its own updated CAM to the following vehicle. */
        id = "SYS-F-003";
        text = "The system shall send its own updated CAM to the following vehicle.";
        attribute actualCamSendRate : Real; // Hz
        attribute requiredCamSendRate : Real = 10.0;
        require constraint { actualCamSendRate >= requiredCamSendRate }
    }

    // SYS-F-004: riconoscimento cut‑in improvviso via V2V
    requirement def CutInDetection {
        doc /* SYS-F-004: The system shall detect a sudden cut‑in event based on V2V information. */
        id = "SYS-F-004";
        text = "The system shall detect a sudden cut‑in event based on V2V information.";
        attribute cutInScenarioOnV2V : Boolean;
        attribute cutInDetected : Boolean;
        require constraint { cutInScenarioOnV2V implies cutInDetected }
    }

    // SYS-F-005: frenata immediata dopo cut‑in
    requirement def CutInEmergencyBraking {
        doc /* SYS-F-005: If a sudden cut‑in occurs, the system shall command an immediate brake to avoid collision. */
        id = "SYS-F-005";
        text = "If a sudden cut‑in occurs, the system shall command an immediate brake to avoid collision.";
        attribute cutInDetected : Boolean;
        attribute emergencyBrakeCommand : Boolean;
        attribute timeToBrakeActuation : Real; // ms
        attribute maxReactionTime : Real = 200.0; // ms (from SYS‑SAF‑TR‑002)
        require constraint { cutInDetected implies (emergencyBrakeCommand and timeToBrakeActuation <= maxReactionTime) }
    }

    // SYS-F-006a: ricezione richiesta cut‑in e verifica fattibilità
    requirement def CutInRequestFeasibilityCheck {
        doc /* SYS-F-006a: The system shall receive a cut‑in request from a side vehicle and verify its feasibility. */
        id = "SYS-F-006a";
        text = "The system shall receive a cut‑in request from a side vehicle and verify its feasibility.";
        attribute cutInRequestReceived : Boolean;
        attribute feasibilityCheckPerformed : Boolean;
        require constraint { cutInRequestReceived implies feasibilityCheckPerformed }
    }

    // SYS-F-006b: trasmissione accettazione se fattibile
    requirement def CutInAccept {
        doc /* SYS-F-006b: If the request is feasible, the system shall transmit acceptance via maneuver coordination protocols. */
        id = "SYS-F-006b";
        text = "If the request is feasible, the system shall transmit acceptance via maneuver coordination protocols.";
        attribute feasibilityResult : ResponseKind;
        attribute mcmAcceptSent : Boolean;
        require constraint { feasibilityResult == ResponseKind::accept implies mcmAcceptSent }
    }

    // SYS-F-006c: trasmissione rifiuto se non fattibile
    requirement def CutInReject {
        doc /* SYS-F-006c: If the request is not feasible, the system shall transmit rejection. */
        id = "SYS-F-006c";
        text = "If the request is not feasible, the system shall transmit rejection.";
        attribute feasibilityResult : ResponseKind;
        attribute mcmRejectSent : Boolean;
        require constraint { feasibilityResult == ResponseKind::reject implies mcmRejectSent }
    }

    // SYS-F-007a: ripristino car‑following dopo cut‑in
    requirement def CutInCompletionRevert {
        doc /* SYS-F-007a: After the cut‑in is completed or cancelled, the system shall revert to standard car‑following logic. */
        id = "SYS-F-007a";
        text = "After the cut‑in is completed or cancelled, the system shall revert to standard car‑following logic.";
        attribute cutInActive : Boolean;
        attribute carFollowingMode : CarFollowingModeKind;
        require constraint { not cutInActive implies carFollowingMode == CarFollowingModeKind::CACC }
    }

    // SYS-F-007b: calcolo Jam Rate da CAM follower
    requirement def JamRateCalculation {
        doc /* SYS-F-007b: The system shall receive CAM from multiple following vehicles and compute the string instability probability (Jam Rate). */
        id = "SYS-F-007b";
        text = "The system shall receive CAM from multiple following vehicles and compute the string instability probability (Jam Rate).";
        attribute multipleFollowerCAMs : Boolean;
        attribute jamRateCalculated : Boolean;
        require constraint { multipleFollowerCAMs implies jamRateCalculated }
    }

    // SYS-F-008a: aumento headway quando instabilità supera soglia
    requirement def JamMitigationHeadwayIncrease {
        doc /* SYS-F-008a: If instability exceeds a defined threshold, the system shall increase headway by 10% (default) while staying within safe ranges. */
        id = "SYS-F-008a";
        text = "If instability exceeds a defined threshold, the system shall increase headway by 10% (default) while staying within safe ranges.";
        attribute currentJamRate : Real;
        attribute jamThreshold : Real;
        attribute headwayTime : Real;
        attribute nominalHeadway : Real;
        attribute incrementPercent : Real = 10.0;
        require constraint {
            currentJamRate > jamThreshold implies
            headwayTime == nominalHeadway * (1.0 + incrementPercent/100.0)
        }
    }

    // SYS-F-009a: determinazione profilo comportamentale leader
    requirement def LeaderProfileClassification {
        doc /* SYS-F-009a: The system shall determine the behavioral profile of the leading vehicle by analyzing historical CAM data. */
        id = "SYS-F-009a";
        text = "The system shall determine the behavioral profile of the leading vehicle by analyzing historical CAM data.";
        attribute camHistoryAvailable : Boolean;
        attribute leaderProfileDetermined : Boolean;
        attribute leaderProfileConfidence : Real; // %
        require constraint { camHistoryAvailable implies (leaderProfileDetermined and leaderProfileConfidence >= 0.0) }
    }

    // SYS-F-008b: applicazione modificatori parametri in base al profilo
    requirement def ProfileBasedParameterModifiers {
        doc /* SYS-F-008b: Based on the identified profile, the system shall apply modifiers to car‑following parameters. */
        id = "SYS-F-008b";
        text = "Based on the identified profile, the system shall apply modifiers to car‑following parameters.";
        attribute leaderProfile : LeaderProfileKind;
        attribute headwayTime : Real;
        attribute baseHeadway : Real;
        // mapping semplificato: profilo aggressivo -> headway ridotto, timido -> aumentato
        require constraint {
            (leaderProfile == LeaderProfileKind::aggressive implies headwayTime <= baseHeadway * 0.9) and
            (leaderProfile == LeaderProfileKind::timid implies headwayTime >= baseHeadway * 1.1)
        }
    }

    // SYS-F-009: ricezione informazioni ciclo semaforico (SPaT/MAP)
    requirement def SPAT_MAP_Reception {
        doc /* SYS-F-009: The system shall receive traffic light information (SPaT/MAP) from the V2I infrastructure. */
        id = "SYS-F-009";
        text = "The system shall receive traffic light information (SPaT/MAP) from the V2I infrastructure.";
        attribute spatMapDataAvailable : Boolean;
        require constraint { spatMapDataAvailable == true }
    }

    // SYS-F-010a: calcolabilità onda verde (GLOSA)
    requirement def GLOSAFeasibilityCalculation {
        doc /* SYS-F-010a: The system shall compute whether a green wave (GLOSA) is achievable. */
        id = "SYS-F-010a";
        text = "The system shall compute whether a green wave (GLOSA) is achievable.";
        attribute spatMapDataAvailable : Boolean;
        attribute glosaFeasible : Boolean;
        require constraint { spatMapDataAvailable implies glosaFeasible != null }
    }

    // SYS-F-010b: adattamento velocità se onda verde raggiungibile
    requirement def GLOSASpeedAdaptation {
        doc /* SYS-F-010b: If the green wave is attainable, the system shall adapt the speed within longitudinal comfort limits. */
        id = "SYS-F-010b";
        text = "If the green wave is attainable, the system shall adapt the speed within longitudinal comfort limits.";
        attribute glosaFeasible : Boolean;
        attribute speedAdaptationActive : Boolean;
        attribute speed : Real;
        attribute maxComfortAccel : Real;
        attribute minComfortDecel : Real;
        require constraint {
            glosaFeasible implies
            speedAdaptationActive and
            (speed' - speed) <= maxComfortAccel * deltaT and
            (speed - speed') <= abs(minComfortDecel) * deltaT   // esemplificativo
        }
    }

    // SYS-F-010c: decelerazione progressiva se onda verde non raggiungibile
    requirement def GLOSANonGreenDeceleration {
        doc /* SYS-F-010c: If the green wave is not attainable, the system shall perform a progressive and comfortable deceleration. */
        id = "SYS-F-010c";
        text = "If the green wave is not attainable, the system shall perform a progressive and comfortable deceleration.";
        attribute glosaFeasible : Boolean;
        attribute decelerationActive : Boolean;
        attribute decelerationProfile : DecelerationProfile;
        attribute comfortProfile : DecelerationProfile; // quello definito come confortevole
        require constraint {
            (not glosaFeasible) implies
            decelerationActive and
            decelerationProfile.maxDeceleration <= comfortProfile.maxDeceleration and
            decelerationProfile.jerk <= comfortProfile.jerk
        }
    }

    // SYS-F-011: applicazione limiti di velocità da infrastruttura
    requirement def SpeedLimitEnforcement {
        doc /* SYS-F-011: The system shall receive current speed limits from the infrastructure and enforce them as a maximum speed constraint. */
        id = "SYS-F-011";
        text = "The system shall receive current speed limits from the infrastructure and enforce them as a maximum speed constraint.";
        attribute receivedSpeedLimit : Real; // km/h
        attribute maxSpeed : Real;
        require constraint { maxSpeed <= receivedSpeedLimit }
    }

    // SYS-F-012: riduzione velocità per lavori stradali (DENM)
    requirement def RoadHazardWarningResponse {
        doc /* SYS-F-012: The system shall receive road work warnings and progressively reduce cruise speed. */
        id = "SYS-F-012";
        text = "The system shall receive road work warnings and progressively reduce cruise speed.";
        attribute roadWorksWarningActive : Boolean;
        attribute speed : Real;
        attribute nominalSpeed : Real;
        require constraint { roadWorksWarningActive implies speed <= nominalSpeed and decelerationComfortable }
    }

    // SYS-F-013: ricezione notifica infrazione semaforica (Signal Violation Warning)
    requirement def SignalViolationWarningReception {
        doc /* SYS-F-013: The system shall receive a Signal Violation Warning (SVW) from the infrastructure. */
        id = "SYS-F-013";
        text = "The system shall receive a Signal Violation Warning (SVW) from the infrastructure.";
        attribute svwReceived : Boolean;
        require constraint { svwReceived == true }
    }

    // SYS-F-014a: (già coperto da SYS-F-013) ma tabella lo distingue; lo teniamo come requisito distinto di ricezione
    requirement def SVW_ReceptionForAction {
        doc /* SYS-F-014a: The system shall be capable of receiving a Signal Violation Warning from the infrastructure. */
        id = "SYS-F-014a";
        text = "The system shall be capable of receiving a Signal Violation Warning from the infrastructure.";
        attribute svwReceived : Boolean;
        require constraint { svwReceived == true }
    }

    // SYS-F-014b: frenata di emergenza se distanza < soglia_emergenza
    requirement def SVW_EmergencyBrake {
        doc /* SYS-F-014b: If the distance to the violation point is less than the emergency threshold, the system shall perform an emergency brake. */
        id = "SYS-F-014b";
        text = "If the distance to the violation point is less than the emergency threshold, the system shall perform an emergency brake.";
        attribute distanceToViolation : Real; // m
        attribute emergencyThreshold : Real;
        attribute emergencyBrakeActive : Boolean;
        require constraint { distanceToViolation < emergencyThreshold implies emergencyBrakeActive == true }
    }

    // SYS-F-014c: decelerazione moderata se distanza tra soglia_emergenza e soglia_attenzione
    requirement def SVW_ModerateDeceleration {
        doc /* SYS-F-014c: If the distance is between the emergency and attention thresholds, the system shall perform a moderate deceleration. */
        id = "SYS-F-014c";
        text = "If the distance is between the emergency and attention thresholds, the system shall perform a moderate deceleration.";
        attribute distanceToViolation : Real;
        attribute emergencyThreshold : Real;
        attribute attentionThreshold : Real;
        attribute moderateDecelActive : Boolean;
        require constraint {
            (distanceToViolation >= emergencyThreshold and distanceToViolation <= attentionThreshold) implies
            moderateDecelActive == true
        }
    }

    // SYS-F-015a: aumento headway laterale per veicolo contromano
    requirement def WrongWayVehicle_LateralHeadwayIncrease {
        doc /* SYS-F-015a: In case of a wrong‑way vehicle, the system shall progressively increase lateral headway to the maximum available. */
        id = "SYS-F-015a";
        text = "In case of a wrong‑way vehicle, the system shall progressively increase lateral headway to the maximum available.";
        attribute wrongWayVehicleDetected : Boolean;
        attribute lateralHeadway : Real; // m
        attribute maxAvailableLateralHeadway : Real; // m
        require constraint { wrongWayVehicleDetected implies lateralHeadway == maxAvailableLateralHeadway }
    }

    // SYS-F-015b: manovra di evitamento se veicolo contromano entro soglia critica
    requirement def WrongWayVehicle_EvasionManeuver {
        doc /* SYS-F-015b: If the wrong‑way vehicle comes within a critical threshold, the system shall perform an evasive maneuver. */
        id = "SYS-F-015b";
        text = "If the wrong‑way vehicle comes within a critical threshold, the system shall perform an evasive maneuver.";
        attribute distanceToWrongWayVehicle : Real;
        attribute criticalThreshold : Real;
        attribute evasionManeuverActive : Boolean;
        require constraint { distanceToWrongWayVehicle <= criticalThreshold implies evasionManeuverActive == true }
    }

    // SYS-F-015c: ripristino headway laterale dopo evento
    requirement def WrongWayVehicle_RestoreLateralHeadway {
        doc /* SYS-F-015c: After the event is over, the system shall restore the original lateral headway. */
        id = "SYS-F-015c";
        text = "After the event is over, the system shall restore the original lateral headway.";
        attribute wrongWayEventActive : Boolean;
        attribute lateralHeadway : Real;
        attribute nominalLateralHeadway : Real;
        require constraint { not wrongWayEventActive implies lateralHeadway == nominalLateralHeadway }
    }

    // SYS-F-016a: aumento headway laterale per veicolo di emergenza (EVA)
    requirement def EmergencyVehicle_LateralHeadwayIncrease {
        doc /* SYS-F-016a: Upon receiving an Emergency Vehicle Alert (EVA), the system shall progressively increase lateral headway. */
        id = "SYS-F-016a";
        text = "Upon receiving an Emergency Vehicle Alert (EVA), the system shall progressively increase lateral headway.";
        attribute evaReceived : Boolean;
        attribute lateralHeadway : Real;
        attribute increasedLateralHeadway : Real;
        require constraint { evaReceived implies lateralHeadway >= increasedLateralHeadway }
    }

    // SYS-F-016b: ripristino headway laterale dopo passaggio veicolo emergenza
    requirement def EmergencyVehicle_RestoreLateralHeadway {
        doc /* SYS-F-016b: After the emergency vehicle has passed, the system shall restore the original lateral headway. */
        id = "SYS-F-016b";
        text = "After the emergency vehicle has passed, the system shall restore the original lateral headway.";
        attribute emergencyPassageOver : Boolean;
        attribute lateralHeadway : Real;
        attribute nominalLateralHeadway : Real;
        require constraint { emergencyPassageOver implies lateralHeadway == nominalLateralHeadway }
    }

    // SYS-F-017a: calcolo TTA per pedone (da avviso VRU/CPM)
    requirement def Pedestrian_TTACalculation {
        doc /* SYS-F-017a: Upon receiving a pedestrian alert (VRU/CPM), the system shall compute the Time‑To‑Arrival (TTA). */
        id = "SYS-F-017a";
        text = "Upon receiving a pedestrian alert (VRU/CPM), the system shall compute the Time‑To‑Arrival (TTA).";
        attribute pedestrianAlertReceived : Boolean;
        attribute ttaCalculated : Boolean;
        require constraint { pedestrianAlertReceived implies ttaCalculated == true }
    }

    // SYS-F-017b: procedere normalmente se TTA > soglia attenzione
    requirement def Pedestrian_ProceedIfTTAHigh {
        doc /* SYS-F-017b: If the TTA is above the attention threshold, the system shall proceed normally. */
        id = "SYS-F-017b";
        text = "If the TTA is above the attention threshold, the system shall proceed normally.";
        attribute tta : Real; // s
        attribute attentionThreshold : Real;
        attribute carFollowingMode : CarFollowingModeKind;
        require constraint { tta > attentionThreshold implies carFollowingMode == CarFollowingModeKind::CACC }
    }

    // SYS-F-017c: rallentare per mantenere TTA entro limiti sicurezza
    requirement def Pedestrian_SlowDownForTTA {
        doc /* SYS-F-017c: If the TTA is below the attention threshold, the system shall slow down to keep TTA within safe limits. */
        id = "SYS-F-017c";
        text = "If the TTA is below the attention threshold, the system shall slow down to keep TTA within safe limits.";
        attribute tta : Real;
        attribute attentionThreshold : Real;
        attribute dangerThreshold : Real;
        attribute decelerationActive : Boolean;
        require constraint {
            (tta <= attentionThreshold and tta > dangerThreshold) implies
            decelerationActive == true
        }
    }

    // SYS-F-017d: frenata fino all'arresto se TTA < soglia pericolo
    requirement def Pedestrian_EmergencyBrakeForTTA {
        doc /* SYS-F-017d: If the TTA is below the danger threshold, the system shall brake to a full stop. */
        id = "SYS-F-017d";
        text = "If the TTA is below the danger threshold, the system shall brake to a full stop.";
        attribute tta : Real;
        attribute dangerThreshold : Real;
        attribute emergencyBrakeFullStop : Boolean;
        require constraint { tta < dangerThreshold implies emergencyBrakeFullStop == true }
    }

    // SYS-F-017e: riprendere car‑following standard al cessare allarme
    requirement def Pedestrian_ResumeAfterAlarm {
        doc /* SYS-F-017e: When the alarm ceases, the system shall resume standard car‑following. */
        id = "SYS-F-017e";
        text = "When the alarm ceases, the system shall resume standard car‑following.";
        attribute pedestrianAlarmActive : Boolean;
        attribute carFollowingMode : CarFollowingModeKind;
        require constraint { not pedestrianAlarmActive implies carFollowingMode == CarFollowingModeKind::CACC }
    }

    // ==================== 2.1 Safety Goal & Integrity Requirements (ISO 26262) ====================

    requirement def NoRearEndCollision_V2VError {
        doc /* SYS-SAF-001: The system shall not cause a rear‑end collision due to incorrect or missing V2V communication information. */
        id = "SYS-SAF-001";
        text = "The system shall not cause a rear‑end collision because of erroneous or missing V2V data.";
        attribute rearEndCollisionDueToV2VError : Boolean;
        require constraint { rearEndCollisionDueToV2VError == false }
    }

    requirement def NoCollisionDuringAssistedCutIn {
        doc /* SYS-SAF-002: The system shall not cause a collision during an assisted cut‑in maneuver. */
        id = "SYS-SAF-002";
        text = "The system shall not cause a collision during an assisted cut‑in.";
        attribute cutInCollisionOccurred : Boolean;
        require constraint { cutInCollisionOccurred == false }
    }

    requirement def NoIntersectionCollision_V2IError {
        doc /* SYS-SAF-003: The system shall not cause a collision at a signalized intersection due to incorrect or missing V2I information. */
        id = "SYS-SAF-003";
        text = "The system shall not cause an intersection collision because of faulty V2I data.";
        attribute intersectionCollisionDueToV2IError : Boolean;
        require constraint { intersectionCollisionDueToV2IError == false }
    }

    requirement def NoPedestrianIncident {
        doc /* SYS-SAF-004: The system shall not cause an accident with a pedestrian due to a missed reaction to a warning. */
        id = "SYS-SAF-004";
        text = "The system shall not cause a pedestrian accident because of a missed warning reaction.";
        attribute pedestrianAccidentOccurred : Boolean;
        require constraint { pedestrianAccidentOccurred == false }
    }

    requirement def NoEmergencyVehicleCollision {
        doc /* SYS-SAF-005: The system shall not cause a collision with an emergency vehicle due to an incorrect maneuver. */
        id = "SYS-SAF-005";
        text = "The system shall not cause a collision with an emergency vehicle because of an erroneous maneuver.";
        attribute emergencyVehicleCollisionOccurred : Boolean;
        require constraint { emergencyVehicleCollisionOccurred == false }
    }

    requirement def NoWrongWayVehicleCollision {
        doc /* SYS-SAF-006: The system shall not cause a collision with a wrong‑way vehicle due to an incorrect evasive maneuver. */
        id = "SYS-SAF-006";
        text = "The system shall not cause a collision with a wrong‑way vehicle because of an erroneous evasive maneuver.";
        attribute wrongWayCollisionOccurred : Boolean;
        require constraint { wrongWayCollisionOccurred == false }
    }

    requirement def NoStringInstabilityAmplification {
        doc /* SYS-SAF-007: The system shall not cause longitudinal instability (shockwave) by amplifying speed oscillations. */
        id = "SYS-SAF-007";
        text = "The system shall not cause longitudinal instability by amplifying speed oscillations.";
        attribute instabilityAmplificationOccurred : Boolean;
        require constraint { instabilityAmplificationOccurred == false }
    }

    requirement def LegalSpeedLimitCompliance {
        doc /* SYS-SAF-008: The system shall not violate legal speed limits. */
        id = "SYS-SAF-008";
        text = "The system shall not exceed legal speed limits.";
        attribute speedLimitViolation : Boolean;
        require constraint { speedLimitViolation == false }
    }

    requirement def NoUnnecessaryOrExcessiveEmergencyBrake {
        doc /* SYS-SAF-009: The system shall not cause a collision due to an unnecessary or excessive emergency braking. */
        id = "SYS-SAF-009";
        text = "The system shall not cause a collision because of an unnecessary/excessive emergency brake.";
        attribute unnecessaryEmergencyBrakeCollision : Boolean;
        require constraint { unnecessaryEmergencyBrakeCollision == false }
    }

    requirement def NoUnstableOrExcessiveEvasionManeuver {
        doc /* SYS-SAF-010: The system shall not cause an accident due to an unstable or excessive evasive maneuver. */
        id = "SYS-SAF-010";
        text = "The system shall not cause an accident because of an unstable/excessive evasive maneuver.";
        attribute unstableEvasionAccident : Boolean;
        require constraint { unstableEvasionAccident == false }
    }

    // ==================== 2.2 Technical Safety Requirements (TSR) ====================

    requirement def CACC_DataCoherenceCheck {
        doc /* SYS-SAF-TR-001: The CACC synchronization function shall include a redundancy check that verifies the consistency of received CAM data (e.g., plausible speed/position change) before computing following parameters. */
        id = "SYS-SAF-TR-001";
        text = "CACC shall perform a coherence check on received CAM data before computing following parameters.";
        attribute camDataReceived : Boolean;
        attribute coherenceCheckPerformed : Boolean;
        attribute dataCoherent : Boolean;
        attribute followingParamsComputed : Boolean;
        require constraint {
            camDataReceived implies (coherenceCheckPerformed and
            (followingParamsComputed implies dataCoherent))
        }
    }

    requirement def CutIn_EmergencyBrakeReactionTime {
        doc /* SYS-SAF-TR-002: The emergency brake for a sudden cut‑in shall activate within 200 ms from message reception to actuator command. */
        id = "SYS-SAF-TR-002";
        text = "Cut‑in emergency brake shall activate within 200 ms.";
        attribute cutInDetected : Boolean;
        attribute brakeCommandTime : Real; // ms
        attribute msgReceptionTime : Real; // ms
        require constraint {
            cutInDetected implies (brakeCommandTime - msgReceptionTime <= 200.0)
        }
    }

    requirement def CutIn_FeasibilityVerificationOnCamData {
        doc /* SYS-SAF-TR-003: The cut‑in feasibility decision shall be verified based on CAM data (position, heading, speed) to confirm the trajectory before acceptance/rejection. */
        id = "SYS-SAF-TR-003";
        text = "Cut‑in feasibility shall be verified using CAM data before responding.";
        attribute cutInRequestReceived : Boolean;
        attribute camDataForFeasibilityValid : Boolean;
        attribute feasibilityDecisionMade : Boolean;
        require constraint {
            cutInRequestReceived implies (camDataForFeasibilityValid and feasibilityDecisionMade)
        }
    }

    requirement def V2I_MessageValidation {
        doc /* SYS-SAF-TR-004: The system shall validate V2I messages (SPaT/EVA) by evaluating Data Age, spatial consistency via GNSS, and security certificate authenticity (PKI) before activating longitudinal adaptation. */
        id = "SYS-SAF-TR-004";
        text = "V2I messages shall be validated (Data Age, GNSS, PKI) before longitudinal adaptation.";
        attribute v2iMessageReceived : Boolean;
        attribute dataAgeValid : Boolean;
        attribute gnssConsistencyValid : Boolean;
        attribute pkiCertificateValid : Boolean;
        attribute longitudinalAdaptationActive : Boolean;
        require constraint {
            v2iMessageReceived implies (dataAgeValid and gnssConsistencyValid and pkiCertificateValid);
            longitudinalAdaptationActive implies (dataAgeValid and gnssConsistencyValid and pkiCertificateValid)
        }
    }

    requirement def SignalViolation_OnboardSensorValidation {
        doc /* SYS-SAF-TR-005: The Signal Violation Protection function shall validate the computed distance and trajectory with onboard sensor data (GNSS + IMU/Odometry/HD Maps) before activating braking. */
        id = "SYS-SAF-TR-005";
        text = "Signal violation distance/trajectory shall be validated with onboard sensors before braking.";
        attribute svwReceived : Boolean;
        attribute distanceValidatedByOnboardSensors : Boolean;
        attribute svwBrakeActivated : Boolean;
        require constraint {
            svwBrakeActivated implies distanceValidatedByOnboardSensors
        }
    }

    requirement def Pedestrian_LateralSafetyBuffer {
        doc /* SYS-SAF-TR-006: The pedestrian protection function shall maintain a lateral safety buffer of at least 1.0 m from the pedestrian crossing. */
        id = "SYS-SAF-TR-006";
        text = "Lateral buffer ≥ 1.0 m shall be maintained when a pedestrian crossing alarm is active.";
        attribute pedestrianAlarmActive : Boolean;
        attribute lateralDistanceToCrossing : Real; // m
        attribute requiredBuffer : Real = 1.0;
        require constraint {
            pedestrianAlarmActive implies lateralDistanceToCrossing >= requiredBuffer
        }
    }

    requirement def EmergencyVehicle_TrajectoryCrossCheck {
        doc /* SYS-SAF-TR-007: The emergency vehicle handling function shall yield only after verifying the actual trajectory of the emergency vehicle by cross‑checking V2I data with onboard sensors. */
        id = "SYS-SAF-TR-007";
        text = "Emergency vehicle trajectory shall be cross‑checked with onboard sensors before yielding.";
        attribute evaReceived : Boolean;
        attribute trajectoryCrossChecked : Boolean;
        attribute yieldManeuverInitiated : Boolean;
        require constraint {
            yieldManeuverInitiated implies (evaReceived and trajectoryCrossChecked)
        }
    }

    requirement def EvasiveManeuver_LateralAccelerationLimit {
        doc /* SYS-SAF-TR-008: The wrong‑way vehicle evasive maneuver shall respect a dynamic lateral acceleration limit computed from estimated road friction, with an absolute maximum of 4.0 m/s², to maintain vehicle stability. */
        id = "SYS-SAF-TR-008";
        text = "Evasive lateral acceleration ≤ 4.0 m/s² dynamically limited by road friction.";
        attribute evasionActive : Boolean;
        attribute actualLateralAccel : Real;
        attribute frictionLimitedMaxAccel : Real;
        attribute absoluteMaxAccel : Real = 4.0;
        require constraint {
            evasionActive implies (actualLateralAccel <= min(frictionLimitedMaxAccel, absoluteMaxAccel))
        }
    }

    requirement def ShockwaveDamping_StringStabilityValidation {
        doc /* SYS-SAF-TR-009: The shockwave mitigation algorithm shall be validated to ensure asymptotic string stability for at least 10 consecutive vehicles in mixed traffic conditions. */
        id = "SYS-SAF-TR-009";
        text = "String stability shall be validated for ≥ 10 vehicles in mixed traffic.";
        attribute stringStabilityValidated : Boolean;
        attribute testVehicleCount : Integer;
        require constraint { stringStabilityValidated and testVehicleCount >= 10 }
    }

    requirement def SpeedLimit_OvershootControl {
        doc /* SYS-SAF-TR-010: The control logic shall guarantee, considering actuator tolerances and road slopes, a maximum transient overshoot of X km/h over the detected legal limit, converging to the exact limit. */
        id = "SYS-SAF-TR-010";
        text = "Speed overshoot ≤ X km/h over the legal limit during transient, then convergence.";
        attribute actualSpeed : Real; // km/h
        attribute legalLimit : Real;
        attribute maxOvershoot : Real; // X km/h
        require constraint {
            actualSpeed <= legalLimit + maxOvershoot
        }
    }

    // ==================== 2.3 SOTIF Requirements (ISO 21448) integrated with ISO 34502 ====================

    requirement def LeaderProfile_ConservativeFallback {
        doc /* SYS-SOTIF-001: If classifier confidence drops below 60%, the following parameters shall revert to the conservative default set. */
        id = "SYS-SOTIF-001";
        text = "When leader profile confidence < 60%, revert to conservative default parameters.";
        attribute leaderProfileConfidence : Real;
        attribute confidenceThresholdLow : Real = 60.0;
        attribute usingConservativeParams : Boolean;
        require constraint {
            leaderProfileConfidence < confidenceThresholdLow implies usingConservativeParams == true
        }
    }

    requirement def JamRate_FalsePositiveHandling {
        doc /* SYS-SOTIF-002: The shockwave damping function shall identify and handle false positives in the jam rate indicator caused by temporary events (e.g., a vehicle leaving the highway). */
        id = "SYS-SOTIF-002";
        text = "False positive jam rate indicators shall be filtered out.";
        attribute jamRateAlarmTriggered : Boolean;
        attribute transientEventDetected : Boolean;
        attribute falsePositiveHandled : Boolean;
        require constraint {
            (jamRateAlarmTriggered and transientEventDetected) implies falsePositiveHandled
        }
    }

    requirement def GLOSA_UnreachableGreenWaveHandling {
        doc /* SYS-SOTIF-003: If the green wave is computed but not reachable (e.g., due to non‑communicating traffic), the system shall execute a comfortable deceleration. */
        id = "SYS-SOTIF-003";
        text = "When GLOSA green wave is unattainable, execute a comfortable deceleration.";
        attribute glosaGreenWaveAttainable : Boolean;
        attribute comfortableDecelActive : Boolean;
        require constraint {
            not glosaGreenWaveAttainable implies comfortableDecelActive == true
        }
    }

    requirement def DENM_ConfidenceLevelValidation {
        doc /* SYS-SOTIF-004: The road hazard warning function shall validate the hazard existence by analyzing Confidence Level fields (Position Confidence, Speed Confidence) in ETSI messages. */
        id = "SYS-SOTIF-004";
        text = "DENM hazard shall be validated using message confidence fields.";
        attribute denmReceived : Boolean;
        attribute positionConfidenceValid : Boolean;
        attribute speedConfidenceValid : Boolean;
        attribute hazardResponseActivated : Boolean;
        require constraint {
            hazardResponseActivated implies (positionConfidenceValid and speedConfidenceValid)
        }
    }

    requirement def Pedestrian_OnboardVerification {
        doc /* SYS-SOTIF-005: The system shall verify the presence of a pedestrian on the crossing using onboard sensors (e.g., camera) within 3 s after receiving the V2I alert (false negative mitigation). */
        id = "SYS-SOTIF-005";
        text = "Verify pedestrian presence with onboard sensors within 3 s of V2I alert.";
        attribute pedestrianAlertReceived : Boolean;
        attribute onboardVerificationPerformed : Boolean;
        attribute verificationTime : Real; // s
        attribute maxVerificationTime : Real = 3.0;
        require constraint {
            pedestrianAlertReceived implies (onboardVerificationPerformed and verificationTime <= maxVerificationTime)
        }
    }

    requirement def EmergencyManeuver_ODDRestrictions {
        doc /* SYS-SOTIF-006: The system shall define and document the validation conditions and safety limits for all emergency maneuvers, specifying the ODDs where they are guaranteed (UL 4600). */
        id = "SYS-SOTIF-006";
        text = "Emergency maneuver validation conditions and ODD limits must be documented.";
        attribute emergencyManeuversDefined : Boolean;
        attribute oddDocumented : Boolean;
        require constraint { emergencyManeuversDefined and oddDocumented }
    }

    // ==================== 2.4 Safety Requirements from ISO 34502 (Scenario-Based Safety Evaluation) ====================

    requirement def ScenarioCatalogGeneration {
        doc /* SYS-SCEN-001: For each safety goal, the system shall generate a test scenario catalog including nominal, edge, and failure scenarios following ISO 34502 guidelines. */
        id = "SYS-SCEN-001";
        text = "A scenario catalog (nominal, edge, failure) shall be generated for every safety goal.";
        attribute scenarioCatalogGenerated : Boolean;
        attribute safetyGoals : Boolean[*]; // list of safety goals; simplification: a boolean for each required
        require constraint { scenarioCatalogGenerated == true }
    }

    requirement def ScenarioBasedSafetyIntegration {
        doc /* SYS-SCEN-002: The scenario‑based safety evaluation process shall be integrated into the development flow starting from the concept phase. */
        id = "SYS-SCEN-002";
        text = "Scenario‑based safety evaluation shall be integrated from the concept phase.";
        attribute scenarioProcessIntegrated : Boolean;
        require constraint { scenarioProcessIntegrated == true }
    }

    requirement def ScenarioResultsAgainstAcceptanceCriteria {
        doc /* SYS-SCEN-003: Simulation results shall be compared with the acceptance criteria defined in the Safety Case for each scenario. */
        id = "SYS-SCEN-003";
        text = "Simulation results must meet acceptance criteria per scenario.";
        attribute simulationResults : Boolean; // simplified: true if all meet criteria
        require constraint { simulationResults == true }
    }

    requirement def ODD_ScenarioCoverageDocumentation {
        doc /* SYS-SCEN-004: Scenario coverage shall be documented and justified, demonstrating that the selected set of scenarios is representative of the intended ODD. */
        id = "SYS-SCEN-004";
        text = "Scenario coverage must be documented and ODD‑representative.";
        attribute oddCoverageDocumented : Boolean;
        attribute oddCoverageJustified : Boolean;
        require constraint { oddCoverageDocumented and oddCoverageJustified }
    }

    requirement def V2X_DegradedChannelScenarios {
        doc /* SYS-SCEN-005a: For V2X‑dependent functions, the catalog shall include edge scenarios of channel degradation (e.g., latency > 500 ms, packet loss > 30%, signal shadow zones, radio channel congestion). */
        id = "SYS-SCEN-005a";
        text = "V2X degradation scenarios (latency, packet loss, shadow zones) must be included.";
        attribute v2xDegradationScenariosIncluded : Boolean;
        require constraint { v2xDegradationScenariosIncluded == true }
    }

    requirement def V2X_CybersecurityTestScenarios {
        doc /* SYS-SCEN-005b: The system shall be subjected to cybersecurity test scenarios to verify resilience against data spoofing and network flooding (jamming/DoS), in accordance with ISO/SAE 21434. */
        id = "SYS-SCEN-005b";
        text = "Cybersecurity test scenarios (spoofing, jamming) shall be executed.";
        attribute cybersecurityScenariosExecuted : Boolean;
        require constraint { cybersecurityScenariosExecuted == true }
    }

    // SYS-CYB-001: V2X message authentication (ETSI ITS 103 097)
    requirement def V2xMessageAuthentication {
        doc /* SYS-CYB-001: All V2X messages (V2V and V2I) must be authenticated using a digital signature mechanism compliant with ETSI ITS 103 097 to ensure data integrity and authenticity. */
        id = "SYS-CYB-001";
        text = "All V2X messages shall be authenticated via ETSI ITS 103 097 digital signatures.";
        attribute allV2xMessagesAuthenticated : Boolean;
        require constraint { allV2xMessagesAuthenticated == true }
    }

    // SYS-CYB-002: Sender certificate validation
    requirement def CertificateValidation {
        doc /* SYS-CYB-002: The system must verify the validity of the sender's digital certificate for each received message, discarding messages with expired or revoked certificates. */
        id = "SYS-CYB-002";
        text = "Every received message shall have its sender certificate validated; expired/revoked ones rejected.";
        attribute invalidCertMessagesAccepted : Boolean;
        require constraint { invalidCertMessagesAccepted == false }
    }

    // SYS-CYB-003: Sensitive data encryption (AES-256)
    requirement def SensitiveDataEncryption {
        doc /* SYS-CYB-003: The system must encrypt sensitive data (future position, planned trajectory) in CAM and DENM using AES-256. */
        id = "SYS-CYB-003";
        text = "Sensitive payload fields shall be AES-256 encrypted.";
        attribute sensitiveDataEncrypted : Boolean;
        require constraint { sensitiveDataEncrypted == true }
    }

    // SYS-CYB-004: Intrusion detection, logging, tamper-proof log
    requirement def IntrusionDetectionAndLogging {
        doc /* SYS-CYB-004: The system must detect and log any intrusion, replay attack, or manipulation of V2X messages within 10 ms. The security log must be tamper-proof. */
        id = "SYS-CYB-004";
        text = "Intrusions shall be detected and logged within 10 ms; log must be tamper-proof.";
        attribute intrusionEventOccurred : Boolean;
        attribute detectionAndLogLatency : Real; // ms
        attribute maxLogLatency : Real = 10.0; // ms
        attribute logTampered : Boolean;
        require constraint {
            intrusionEventOccurred implies (detectionAndLogLatency <= maxLogLatency);
            not logTampered
        }
    }

    // SYS-CYB-005: Security monitor for message frequency
    requirement def MessageFrequencyMonitoring {
        doc /* SYS-CYB-005: The system must implement a Security Monitor that verifies the message arrival frequency and raises an alarm if the deviation exceeds 20% of the nominal value. */
        id = "SYS-CYB-005";
        text = "Security monitor shall raise alarm if message frequency deviates >20%.";
        attribute messageFrequencyDeviationPercent : Real;
        attribute alarmThresholdPercent : Real = 20.0;
        attribute securityAlarmRaised : Boolean;
        require constraint {
            (messageFrequencyDeviationPercent > alarmThresholdPercent) implies securityAlarmRaised
        }
    }

    // SYS-CYB-006: Software updates via SUMS (UNECE R156)
    requirement def SoftwareUpdateManagement {
        doc /* SYS-CYB-006: Every software update must be distributed and authenticated via a SUMS compliant with UNECE R156. Updates allowed only stationary with parking brake, except critical security patches which need explicit driver confirmation. */
        id = "SYS-CYB-006";
        text = "Updates shall be managed via SUMS; installation conditions enforced.";
        attribute updateProcessSUMSCompliant : Boolean;
        attribute updateInstallationConditionsSatisfied : Boolean;
        require constraint {
            updateProcessSUMSCompliant and updateInstallationConditionsSatisfied
        }
    }

    // SYS-CYB-007: Defense in depth (≥2 layers)
    requirement def DefenseInDepth {
        doc /* SYS-CYB-007: The system must support a defense in depth approach with at least two independent layers of protection for V2X communications. */
        id = "SYS-CYB-007";
        text = "At least two independent protection layers shall be active.";
        attribute independentProtectionLayers : Integer;
        require constraint { independentProtectionLayers >= 2 }
    }

    // SYS-CYB-008: Personal data privacy (no clear transmission, pseudonymization)
    requirement def PersonalDataProtection {
        doc /* SYS-CYB-008: User personal data must not be transmitted in clear and must be pseudonymized when used for third-party services. */
        id = "SYS-CYB-008";
        text = "Personal data shall not be transmitted in clear; shall be pseudonymized.";
        attribute personalDataTransmittedInClear : Boolean;
        attribute personalDataPseudonymized : Boolean;
        require constraint {
            personalDataTransmittedInClear == false and personalDataPseudonymized == true
        }
    }

    // SYS-CYB-009: Automatic fallback to onboard sensors on confirmed cyber-attack
    requirement def CyberAttackFallback {
        doc /* SYS-CYB-009: A confirmed cyber-attack compromising V2V communication must automatically trigger fallback to onboard sensor mode (Fail-Degraded) within 500 ms. */
        id = "SYS-CYB-009";
        text = "Confirmed cyber-attack shall trigger fallback to onboard sensors within 500 ms.";
        attribute cyberAttackConfirmed : Boolean;
        attribute fallbackTime : Real; // ms
        attribute maxFallbackTime : Real = 500.0; // ms
        attribute fallbackToOnboardSensorsActivated : Boolean;
        require constraint {
            cyberAttackConfirmed implies (fallbackTime <= maxFallbackTime and fallbackToOnboardSensorsActivated)
        }
    }

    // SYS-OPR-001: V2V signal loss for > 500 ms → disable CACC, inform driver, transition to passive within 100 ms
    requirement def V2vSignalLossFallback {
        doc /* SYS-OPR-001: If the V2V signal is lost for more than 500 ms, the system shall disable CACC control, notify the driver (or higher‑level Vehicle Control), and transition to a passive state (yield control to onboard sensors) within 100 ms. */
        id = "SYS-OPR-001";
        text = "On V2V signal loss > 500 ms, disable CACC and transition to passive within 100 ms.";
        attribute v2vSignalLostDuration : Real; // ms
        attribute lossTimeout : Real = 500.0; // ms
        attribute caccDisabled : Boolean;
        attribute driverNotified : Boolean;
        attribute transitionToPassiveTime : Real; // ms from loss detection
        attribute maxTransitionTime : Real = 100.0; // ms
        require constraint {
            (v2vSignalLostDuration > lossTimeout) implies
            (caccDisabled and driverNotified and transitionToPassiveTime <= maxTransitionTime)
        }
    }

    // SYS-OPR-002: V2V signal restored within 5 s + data validation → CACC re‑enabled with 2 s smooth transition
    requirement def V2vSignalRestoreAndReactivation {
        doc /* SYS-OPR-002: If the V2V signal is restored within 5 s and data validation is positive, the system may re‑enable CACC mode with a gradual 2‑second transition. */
        id = "SYS-OPR-002";
        text = "If V2V signal recovered within 5 s and data valid, reactivate CACC with 2 s smooth transition.";
        attribute v2vSignalRecovered : Boolean;
        attribute recoveryWindow : Real = 5.0; // s
        attribute dataValidationPositive : Boolean;
        attribute caccReactivationAllowed : Boolean;
        attribute reactivationSmoothTime : Real; // s
        attribute requiredSmoothTime : Real = 2.0; // s
        require constraint {
            (v2vSignalRecovered and dataValidationPositive) implies
            (caccReactivationAllowed and reactivationSmoothTime >= requiredSmoothTime)
        }
    }

    // SYS-OPR-003: Message fragmentation > 15% in 1 s → activate signal reconstruction; if persists > 3 s → trigger SYS-OPR-001
    requirement def MessageFragmentationHandling {
        doc /* SYS-OPR-003: When message fragmentation exceeds 15% within a 1‑second window, the system shall activate a signal reconstruction algorithm. If fragmentation persists for more than 3 s, apply SYS-OPR-001. */
        id = "SYS-OPR-003";
        text = "Fragmentation > 15% in 1 s → reconstruct; if persistent > 3 s → fallback as OPR-001.";
        attribute fragmentationRate : Real; // % in last 1 s window
        attribute fragmentationThreshold : Real = 15.0; // %
        attribute reconstructionActive : Boolean;
        attribute fragmentationPersistentDuration : Real; // s
        attribute persistenceLimit : Real = 3.0; // s
        attribute fallbackToOPR001Triggered : Boolean;
        require constraint {
            fragmentationRate > fragmentationThreshold implies reconstructionActive;
            (reconstructionActive and fragmentationPersistentDuration > persistenceLimit) implies fallbackToOPR001Triggered
        }
    }

    // SYS-OPR-004: V2I communication failure → disable V2I functions, use map data for speed limits, proceed with car‑following
    requirement def V2iFailureFallback {
        doc /* SYS-OPR-004: Upon a V2I communication failure, all V2I functions shall be safely disabled. The system shall rely on map data to retrieve necessary information (e.g., speed limits) and continue with car‑following. */
        id = "SYS-OPR-004";
        text = "On V2I failure, disable V2I functions and use map data for speed limits.";
        attribute v2iCommunicationFailed : Boolean;
        attribute v2iFunctionsDisabledSafely : Boolean;
        attribute mapBasedDataUsed : Boolean;
        attribute carFollowingActive : Boolean;
        require constraint {
            v2iCommunicationFailed implies (v2iFunctionsDisabledSafely and mapBasedDataUsed and carFollowingActive)
        }
    }

    // SYS-OPR-005: GLOSA failure or missing traffic light signal → revert to standard car‑following within safety constraints
    requirement def GLOSAFailureRecovery {
        doc /* SYS-OPR-005: In case of GLOSA failure or missing traffic light signal, the system shall revert to standard car‑following while respecting safety constraints. */
        id = "SYS-OPR-005";
        text = "On GLOSA failure, revert to standard car‑following within safety constraints.";
        attribute glosaFailure : Boolean;
        attribute standardCarFollowingResumed : Boolean;
        attribute safetyConstraintsSatisfied : Boolean;
        require constraint {
            glosaFailure implies (standardCarFollowingResumed and safetyConstraintsSatisfied)
        }
    }

    // SYS-OPR-006: Internal heartbeat monitoring → detect failure of critical modules, activate fail‑safe mode within 200 ms
    requirement def HeartbeatMonitoring {
        doc /* SYS-OPR-006: The system shall implement an internal heartbeat mechanism to monitor the health of all critical software modules. A detected failure shall activate the appropriate fail‑safe mode within 200 ms. */
        id = "SYS-OPR-006";
        text = "Heartbeat monitoring: on critical module failure, fail‑safe within 200 ms.";
        attribute heartbeatFailureDetected : Boolean;
        attribute failSafeActivationTime : Real; // ms
        attribute maxFailSafeTime : Real = 200.0; // ms
        attribute failSafeModeActivated : Boolean;
        require constraint {
            heartbeatFailureDetected implies (failSafeModeActivated and failSafeActivationTime <= maxFailSafeTime)
        }
    }

    // SYS-OPR-007: Fail‑safe architecture; on internal critical fault, stop sending parameters to actuation model within FTTI
    requirement def FailSafeArchitecture {
        doc /* SYS-OPR-007: The V2X system shall operate under a Fail‑Safe architecture. Upon a critical internal fault, it shall stop sending actuation parameters within the Fault Tolerant Time Interval (FTTI), ensuring a safe disengagement. */
        id = "SYS-OPR-007";
        text = "Fail‑Safe architecture: cease actuation commands within FTTI on critical fault.";
        attribute criticalInternalFault : Boolean;
        attribute ftti : Real; // ms, Fault Tolerant Time Interval (attribute of system)
        attribute actuationCommandStopped : Boolean;
        attribute commandStopTime : Real; // ms from fault
        require constraint {
            criticalInternalFault implies (actuationCommandStopped and commandStopTime <= ftti)
        }
    }

    // ==================== Performance Requirements ====================
    requirement def V2V_SafetyEndToEndLatency {
        doc /* SYS-PERF-001: End-to-end latency for safety V2V communication (CAM) must be less than 100 ms. */
        id = "SYS-PERF-001";
        text = "V2V safety end-to-end latency shall be < 100 ms.";
        attribute actualV2vLatency : Real; // ms
        attribute maxAllowedLatency : Real = 100.0; // ms
        require constraint { actualV2vLatency <= maxAllowedLatency }
    }

    requirement def V2I_SafetyEndToEndLatency {
        doc /* SYS-PERF-002: End-to-end latency for safety V2I communication (SPaT, DENM) must be less than 200 ms. */
        id = "SYS-PERF-002";
        text = "V2I safety end-to-end latency shall be < 200 ms.";
        attribute actualV2iLatency : Real; // ms
        attribute maxAllowedLatency : Real = 200.0; // ms
        require constraint { actualV2iLatency <= maxAllowedLatency }
    }

    requirement def CAM_MinimumUpdateRate {
        doc /* SYS-PERF-003: The guaranteed minimum update rate for CAM messages must be 10 Hz. */
        id = "SYS-PERF-003";
        text = "CAM update rate shall be ≥ 10 Hz.";
        attribute actualUpdateRate : Real; // Hz
        attribute minRequiredRate : Real = 10.0; // Hz
        require constraint { actualUpdateRate >= minRequiredRate }
    }

    requirement def SafetyDistanceEstimationAccuracy {
        doc /* SYS-PERF-004: The safety distance estimation accuracy shall be ±3 m for speeds below 50 km/h and ±2 % for speeds above 50 km/h. */
        id = "SYS-PERF-004";
        text = "Distance estimation error ≤ 3 m (speed <50 km/h) or ≤ 2% (speed ≥ 50 km/h).";
        attribute speed : Real; // km/h
        attribute absoluteErrorLowSpeed : Real; // m (absolute value)
        attribute relativeErrorHighSpeedPercent : Real; // % (absolute relative error)
        require constraint {
            if speed < 50.0 then
                abs(absoluteErrorLowSpeed) <= 3.0
            else
                relativeErrorHighSpeedPercent <= 2.0
        }
    }

    requirement def GLOSA_ComputationTime {
        doc /* SYS-PERF-005: The GLOSA computation time must be less than 50 ms. */
        id = "SYS-PERF-005";
        text = "GLOSA computation shall complete in < 50 ms.";
        attribute actualGlosaComputationTime : Real; // ms
        attribute maxAllowedTime : Real = 50.0; // ms
        require constraint { actualGlosaComputationTime <= maxAllowedTime }
    }

    // ==================== Process Requirements (ASPICE v4.0) ====================
    requirement def RequirementsTraceability {
        doc /* SYS-PROC-001: Requirements shall be traced to original stakeholder needs (SYS.2.BP6) and linked to verification criteria and test cases (SYS.2.BP5, SYS.4.BP5). */
        id = "SYS-PROC-001";
        text = "Requirements shall be fully traced to stakeholder needs and test cases.";
        attribute traceabilityEstablished : Boolean;
        require constraint { traceabilityEstablished == true }
    }

    requirement def RequirementsReview {
        doc /* SYS-PROC-002: Requirements shall be reviewed to ensure completeness, unambiguity, and testability (SYS.2.BP3, SUP.4). */
        id = "SYS-PROC-002";
        text = "Each requirement shall be reviewed for completeness, unambiguity, and testability.";
        attribute allRequirementsReviewed : Boolean;
        require constraint { allRequirementsReviewed == true }
    }

    requirement def ExternalInterfaceSpecification {
        doc /* SYS-PROC-003: External system interfaces (V2V/V2I communication bus, HMI, GNSS/IMU) must be formally specified, including safety and cybersecurity properties. */
        id = "SYS-PROC-003";
        text = "External interfaces shall be formally specified with safety and cybersecurity attributes.";
        attribute interfacesFormallySpecified : Boolean;
        require constraint { interfacesFormallySpecified == true }
    }

    requirement def SafetyCaseDevelopment {
        doc /* SYS-PROC-004: A Safety Case according to UL 4600 shall be developed, including risk analysis, SOTIF validation, and demonstration of robust degraded operations. */
        id = "SYS-PROC-004";
        text = "A UL 4600 Safety Case shall be developed, covering risk, SOTIF, and degraded ops.";
        attribute safetyCaseDeveloped : Boolean;
        require constraint { safetyCaseDeveloped == true }
    }

    requirement def TARA_Conduction {
        doc /* SYS-PROC-005: A TARA (Threat Analysis and Risk Assessment) shall be conducted for all V2X interfaces, producing traceable cybersecurity requirements (ISO/SAE 21434 §15). */
        id = "SYS-PROC-005";
        text = "A TARA shall be performed for all V2X interfaces, yielding traceable cybersecurity requirements.";
        attribute taraConducted : Boolean;
        attribute cyberReqsTraceable : Boolean;
        require constraint { taraConducted and cyberReqsTraceable }
    }

    requirement def ScenarioCatalogDefinition {
        doc /* SYS-PROC-006: The development process shall include definition and validation of a safety scenario catalog conforming to ISO 34502, with documented ODD coverage. */
        id = "SYS-PROC-006";
        text = "A validated scenario catalog per ISO 34502 with documented ODD coverage shall be established.";
        attribute scenarioCatalogValidated : Boolean;
        attribute oddCoverageDocumented : Boolean;
        require constraint { scenarioCatalogValidated and oddCoverageDocumented }
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