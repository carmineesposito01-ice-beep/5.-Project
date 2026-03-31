package VehicleArchitecture {
	doc /* * Structural and functional model of a Passenger Vehicle (Car).
		 * Modeled following the official SysML v2 textual syntax. */
	private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;
	/* ===================================================================
		 * ATTRIBUTE DEFINITIONS
	 * =================================================================== */
	attribute def FuelLevelType :> Real {
		doc /* Fuel level as a ratio, 0.0 (empty) to 1.0 (full). */
	}
	/* ===================================================================
		 * PORT DEFINITIONS — Energy and Signal Flows
	 * =================================================================== */
	port def MechanicalEnergyPort {
		doc /* Port for mechanical energy transfer (e.g. torque). */
		out transferredTorque :> torque;
	}
	port def ElectricalSignalPort {
		doc /* Port for electrical control signals. */
		in controlSignal :> power;
	}
	port def BrakeCommandPort {
		doc /* Port for brake commands from ECU. */
		in brakeForce :> force;
	}
	port def SteerCommandPort {
		doc /* Port for steering commands from ECU. */
		in steeringAngle :> angularMeasure;
	}
	/* ===================================================================
		 * INTERFACE DEFINITIONS — How ports connect
		 * =================================================================== */
	interface def EnergyTransfer {
		doc /* Coupling between the powerplant output and drivetrain input. */
		end source : MechanicalEnergyPort;
		end sink : ~MechanicalEnergyPort;
		flow from source.transferredTorque to sink.transferredTorque;
	}
	interface def BrakeSignalTransfer {
		doc /* Signal transfer from ECU to the braking system. */
		end ecuPort : ~BrakeCommandPort;
		end brakePort : BrakeCommandPort;
		flow from ecuPort.brakeForce to brakePort.brakeForce;
	}
	interface def SteerSignalTransfer {
		doc /* Signal transfer from ECU to the steering system. */
		end ecuPort : ~SteerCommandPort;
		end steerPort : SteerCommandPort;
		flow from ecuPort.steeringAngle to steerPort.steeringAngle;
	}
	/* ===================================================================
		 * PART DEFINITIONS — Subsystem Definitions
		 * =================================================================== */
	part def Powerplant {
		doc /* Internal combustion engine or electric motor. */
		attribute enginePower :> power;
		attribute fuelLevel : FuelLevelType;
		port driveOutput : MechanicalEnergyPort;
	}
	part def Drivetrain {
		doc /* Transmits mechanical energy from the powerplant to the wheels. */
		port driveInput : ~MechanicalEnergyPort;
	}
	part def BrakingSystem {
		doc /* Hydraulic or electronic braking subsystem. */
		attribute brakingForce :> force;
		port brakeInput : BrakeCommandPort;
	}
	part def Steering {
		doc /* Power-assisted steering subsystem. */
		port steerInput : SteerCommandPort;
	}
	part def Chassis {
		doc /* Structural frame of the vehicle. */
		attribute chassisMass :> mass;
	}
	part def ECU {
		doc /* Electronic Control Unit — central vehicle controller. */
		attribute softwareVersion : String;
		port brakeCmd : ~BrakeCommandPort;
		port steerCmd : ~SteerCommandPort;
	}
	/* ===================================================================
		 * STATE DEFINITION — Ignition State Machine
		 * =================================================================== */
	action def IgnitionStates {
		doc /* * State machine for the vehicle ignition system.
				 * Transitions: Off -> Accessory -> On -> Start -> On.
				 *              On -> Off, Start -> Off (emergency shutdown). */
		/* In SysML v2 le transizioni usano obbligatoriamente first e then */
	}
	/* ===================================================================
		 * TOP-LEVEL SYSTEM — Car (Composition)
		 * =================================================================== */
	part def Car {
		doc /* Top-level definition of a Passenger Vehicle system. */
		attribute vehicleMass :> mass;
		/* Hierarchical Decomposition (Composition) */
		part powerplant : Powerplant;
		part drivetrain : Drivetrain;
		part braking : BrakingSystem;
		part steering : Steering;
		part chassis : Chassis;
		part ecu : ECU;
		/* Behavioral: Ignition State Machine */
		/* Internal Connections via Interface Usages */
		connection powerTransfer : EnergyTransfer connect powerplant to drivetrain;
		connection brakeControl : BrakeSignalTransfer connect ecu to braking;
		connection steerControl : SteerSignalTransfer connect ecu to steering;
		
		view view3 : StandardViewDefinitions::GeneralView {
			expose VehicleArchitecture::Car;
		}
		view view4 : StandardViewDefinitions::InterconnectionView {
			expose VehicleArchitecture::Car;
			expose powerplant;
			expose drivetrain;
			expose braking;
			expose steering;
			expose chassis;
			expose ecu;
		}
	}
	/* ===================================================================
		 * SYSTEM INSTANCE — Configured Vehicle
		 * =================================================================== */
	part myVehicle : Car {
		doc /* A specific vehicle configuration with assigned values. */
		attribute :>> vehicleMass = 1500 [kg];
		part :>> powerplant {
			attribute :>> enginePower = 110 [kW];
			attribute :>> fuelLevel = 0.85;
		}
		part :>> chassis {
			attribute :>> chassisMass = 800 [kg];
		}
		part :>> ecu {
			attribute :>> softwareVersion = "v2.3.1";
		}
	}
	view view1 {
		expose VehicleArchitecture;
		expose ElectricalSignalPort;
		expose BrakeSignalTransfer;
		expose Powerplant;
	}
	view view2 : StandardViewDefinitions::GeneralView;
}