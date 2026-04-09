package V2xProcessingSystem {
	doc /* V2X Signal Processing System for FPGA (Xilinx Pynq)
		 * Main package containing the system-level architecture:
		 * - Conditioning Unit: Processes raw V2X signals
		 * - Elaboration Unit: Performs signal elaboration and computation
		 * - Balancing Unit: Weights computed parameters with external model outputs
		 * 
		 * Modeled following SysML v2 pattern-based approach with separate
		 * component definitions and hierarchical composition. */
	
	private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;
	
	/* ===================================================================
		 * ATTRIBUTE DEFINITIONS — Signal and Parameter Types
	 * =================================================================== */
	
	attribute def V2xSignal :> Real {
		doc /* Raw Vehicle-to-Everything signal from external sources. */
	}
	
	attribute def ConditionedSignal :> Real {
		doc /* Processed V2X signal after conditioning (filtering, normalization). */
	}
	
	attribute def ComputedParameter :> Real {
		doc /* Output parameter from the elaboration unit. */
	}
	
	attribute def BalancedParameter :> Real {
		doc /* Final weighted parameter after balancing with external model output. */
	}
	
	attribute def ControlSignal :> String {
		doc /* Control signal for reset and enable commands. */
	}
	
	attribute def StatusSignal :> String {
		doc /* Status signal for system/subsystem status reporting. */
	}
	
	/* ===================================================================
		 * PORT DEFINITIONS — Generic Data Flows
		 * =================================================================== */
	
	port def V2xInputPort {
		doc /* Input port for raw V2X signals. */
		in v2xIn :> V2xSignal;
	}
	
	port def V2xOutputPort {
		doc /* Output port for V2X-derived signals. */
		out v2xOut :> V2xSignal;
	}
	
	port def ConditionedSignalPort {
		doc /* Port for conditioned signals between units. */
		in conditionedIn :> ConditionedSignal;
		out conditionedOut :> ConditionedSignal;
	}
	
	port def ParameterPort {
		doc /* Port for computed/balanced parameters. */
		in parameterIn :> ComputedParameter;
		in parameterIn_1 :> ComputedParameter;
		in parameterIn_2 :> ComputedParameter;
		out parameterOut :> ComputedParameter;
		out parameterOut_1 :> ComputedParameter;
		out parameterOut_2 :> ComputedParameter;
	}
	
	port def BalancedParameterPort {
		doc /* Port for balanced (weighted) parameters. */
		in balancedIn :> BalancedParameter;
		in balancedIn_1 :> BalancedParameter;
		in balancedIn_2 :> BalancedParameter;
		out balancedOut :> BalancedParameter;
		out balancedOut_1 :> BalancedParameter;
		out balancedOut_2 :> BalancedParameter;
	}
	
	port def ControlPort {
		doc /* Control port for system management. */
		in control :> ControlSignal;
		out status :> StatusSignal;
	}
	
	/* ===================================================================
		 * INTERFACE DEFINITIONS — Data Flow Connections
		 * =================================================================== */
	
	interface def V2xSignalFlow {
		doc /* V2X signal flow between units. */
		end source : V2xOutputPort;
		end sink : ~V2xInputPort;
		flow from source.v2xOut to sink.v2xIn;
	}
	
	interface def ConditionedSignalFlow {
		doc /* Conditioned signal flow between Conditioning and Elaboration units. */
		end source : ConditionedSignalPort;
		end sink : ~ConditionedSignalPort;
		flow from source.conditionedOut to sink.conditionedIn;
	}
	
	interface def ParameterFlow {
		doc /* Parameter flow from Elaboration to Balancing unit. */
		end source : ParameterPort;
		end sink : ~ParameterPort;
		flow from source.parameterOut to sink.parameterIn;
		flow from source.parameterOut_1 to sink.parameterIn_1;
		flow from source.parameterOut_2 to sink.parameterIn_2;
	}
	
	interface def BalancedParameterFlow {
		doc /* Balanced parameter flow from Balancing unit to system output. */
		end source : BalancedParameterPort;
		end sink : ~BalancedParameterPort;
		flow from source.balancedOut to sink.balancedIn;
		flow from source.balancedOut_1 to sink.balancedIn_1;
		flow from source.balancedOut_2 to sink.balancedIn_2;
	}
	
	/* ===================================================================
		 * PART DEFINITIONS — Subsystem Components
		 * =================================================================== */
	
	part def ConditioningUnit {
		doc /* Conditioning Unit subsystem:
			 * Receives raw V2X signals and performs:
			 * - Filtering (noise reduction)
			 * - Normalization
			 * - Validation
			 * - Signal conditioning for downstream processing */
		
		attribute signalFilterType : String = "Kalman";
		attribute normalizationRange : Real = 1.0;
		attribute processingLatency : String = "< 1ms";
	}
	
	part def ElaborationUnit {
		doc /* Elaboration Unit subsystem:
			 * Receives conditioned signals and performs:
			 * - Signal processing and computation
			 * - Feature extraction
			 * - Algorithm execution (adaptive/machine learning)
			 * - Generation of output parameters (3 values) */
		
		attribute algorithmType : String = "Adaptive Signal Processing";
		attribute computationMethod : String = "Dedicated FPGA Kernels";
		attribute outputCardinality : Integer = 3;
		attribute processingLatency : String = "< 2ms";
	}
	
	part def BalancingUnit {
		doc /* Balancing Unit subsystem:
			 * Receives parameters from Elaboration Unit and external model,
			 * then performs:
			 * - Parameter fusion using weighting functions
			 * - Validation and consistency checks
			 * - Output generation of balanced parameters
			 * 
			 * Purpose: Weight computed parameters with equivalent parameters
			 * generated by an external, independent model to achieve
			 * robustness and reliability. */
		
		attribute weighting_strategy : String = "Adaptive Weighted Fusion";
		attribute externalModelIntegration : String = "Loose Coupling";
		attribute consistencyCheckEnabled : Boolean = true;
		attribute processingLatency : String = "< 1ms";
	}
	
	/* ===================================================================
		 * SYSTEM COMPOSITION — V2X Processing System
		 * =================================================================== */
	
	part def V2xProcessingSystem {
		doc /* Main system composition combining all three subsystems:
			 * 1. Conditioning Unit
			 * 2. Elaboration Unit
			 * 3. Balancing Unit
			 * 
			 * Implemented on Xilinx Pynq FPGA platform.
			 * 
			 * Signal flow:
			 * V2X Input -> Conditioning Unit -> Elaboration Unit -> 
			 * Balancing Unit (with external model) -> Balanced Output */
		
		attribute platform : String = "Xilinx Pynq";
		attribute implementationTechnology : String = "FPGA";
		attribute targetArchitecture : String = "V2X Signal Processing";
		
		/* Instantiate the three subsystems */
		part conditioningUnit : ConditioningUnit;
		part elaborationUnit : ElaborationUnit;
		part balancingUnit : BalancingUnit;
		
		/* System-level ports for external connectivity */
		port systemV2xInput : V2xInputPort;
		port systemConditionedOutput : ConditionedSignalPort;
		port systemComputedParameters : ParameterPort;
		port systemExternalModel : ParameterPort;
		port systemFinalOutput : BalancedParameterPort;
		port systemControl : ControlPort;
		
		/* Internal connections via interface usages */
		connection v2xFlow : V2xSignalFlow 
			connect systemV2xInput to systemConditionedOutput;
		
		connection conditioningToElaboration : ConditionedSignalFlow 
			connect systemConditionedOutput to systemComputedParameters;
		
		connection elaborationToBalancing : ParameterFlow 
			connect systemComputedParameters to systemFinalOutput;
		
		connection externalModelToBalancing : ParameterFlow 
			connect systemExternalModel to systemFinalOutput;
	}
	
	/* ===================================================================
		 * SYSTEM INSTANCE — Configured V2X Processing System
		 * =================================================================== */
	
	part V2xProcessor : V2xProcessingSystem {
		doc /* An instance of the V2X Processing System deployed on Xilinx Pynq FPGA. */
		
		part :>> conditioningUnit {
			doc /* Conditioning Unit instance - Kalman filtering enabled. */
		}
		
		part :>> elaborationUnit {
			doc /* Elaboration Unit instance - generating 3 output parameters. */
		}
		
		part :>> balancingUnit {
			doc /* Balancing Unit instance - weighted fusion with external model. */
		}
	}
	
	/* ===================================================================
		 * VIEWPOINT DEFINITIONS — Filtered Views on the System
		 * =================================================================== */
	
	viewpoint def SignalFlowViewpoint {
		doc /* Viewpoint for signal and data flow visualization.
			 * Filters: Emphasize ports, interfaces, and data movement.
			 * Suitable for understanding:
			 * - How signals flow through the system
			 * - Port-to-port connections
			 * - External interfaces
			 * - Latency and throughput characteristics */
		
		filter signal_flows {
			doc /* Highlight all signal transfer paths */
		}
		filter external_interfaces {
			doc /* Show input/output ports at system boundary */
		}
		filter dataflow {
			doc /* Display data movement between subsystems */
		}
	}
	
	viewpoint def ArchitecturalViewpoint {
		doc /* Viewpoint for system architecture and subsystem decomposition.
			 * Filters: Show part composition and hierarchical structure.
			 * Suitable for understanding:
			 * - System architecture
			 * - Subsystem relationships
			 * - Hierarchical decomposition
			 * - Component responsibilities */
		
		filter subsystems {
			doc /* Show all subsystem parts (Conditioning, Elaboration, Balancing) */
		}
		filter composition {
			doc /* Display part composition and hierarchy */
		}
		filter interfaces {
			doc /* Show port definitions and interface contracts */
		}
	}
	
	viewpoint def FunctionalViewpoint {
		doc /* Viewpoint for functional behavior and responsibilities.
			 * Filters: Emphasize functional aspects of each unit.
			 * Suitable for understanding:
			 * - What each subsystem does
			 * - Processing algorithms
			 * - Functional requirements
			 * - Output generation */
		
		filter conditioning_functions {
			doc /* Filtering, normalization, validation */
		}
		filter elaboration_functions {
			doc /* Signal processing, feature extraction, computation */
		}
		filter balancing_functions {
			doc /* Parameter fusion, weighting, consistency checking */
		}
	}
	
	viewpoint def ImplementationViewpoint {
		doc /* Viewpoint for implementation details on FPGA.
			 * Filters: Show platform, technology, performance attributes.
			 * Suitable for understanding:
			 * - FPGA target platform (Xilinx Pynq)
			 * - Processing latencies
			 * - Implementation strategies
			 * - Hardware constraints */
		
		filter platform_details {
			doc /* Xilinx Pynq FPGA platform specifications */
		}
		filter performance_attributes {
			doc /* Latency, throughput, resource utilization */
		}
		filter implementation_strategy {
			doc /* Algorithm implementations, kernel types */
		}
	}
	
	/* ===================================================================
		 * VIEW DEFINITIONS — Concrete Views Using Viewpoints
		 * =================================================================== */
	
	view SignalFlowView using SignalFlowViewpoint {
		doc /* Concrete signal flow view showing how V2X signals
			 * traverse through the three subsystems. */
	}
	
	view ArchitecturalDecompositionView using ArchitecturalViewpoint {
		doc /* Concrete architectural view showing system decomposition
			 * into Conditioning, Elaboration, and Balancing units. */
	}
	
	view FunctionalResponsibilitiesView using FunctionalViewpoint {
		doc /* Concrete view describing what each subsystem functionally does. */
	}
	
	view FPGAImplementationView using ImplementationViewpoint {
		doc /* Concrete view showing FPGA implementation strategy on Xilinx Pynq. */
	}
	
}

