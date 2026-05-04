package ComponentDefinition{
    doc /* 
        /* This package contains the definitions of the components used in the system. 
        /* Each component is defined with its properties, behaviors, and interactions with 
        /* other sub-components. The components are organized on system hierarchy based."
        */ 
    
    private import ScalarValues::*;
	private import Quantities::*;
	private import MeasurementReferences::*;
	private import ISQ::*;
	private import SI::*;

    public import Attribute_Definitions::*;
    public import PortandInterfaceDefinitions::*;


    part def InputGateway_Unit{
        doc /* Part representing the input gateway of the system, responsible for receiving data 
            /* from external sources (V2X signals). */
            
        port v2v : V2VCommPort;          // riceve CAM, MCM
        port v2i : V2ICommPort;          // riceve SPaT, MAP, DENM, IVS, EVA, VRU, CPM
        port vehicleBus : VehicleBusPort; // riceve GNSS, IMU, odometry
        port secMonOut : SecurityAlertsOutPort;  // alert di sicurezza verso OutputGateway
        port validatedOut : ValidatedDataOutPort; // dati validati verso Elaboration
        port egoOut : EgoVehicleStateOutPort;     // stato ego veicolo verso CAM composer

        part conditioner : Conditioning_Unit;
        part signalValidation : SignalValidation_Unit;
        
    }

    part def Elaboration_Unit{
        doc /* Part representing the elaboration unit of the system, responsible for processing 
            /* the received data and generate the model's parameters. */
        
        port validatedIn : ValidatedDataInPort;       // da InputGateway
        port controlOut : ControlParametersOutPort;   // verso OutputGateway
        
        part analyzer : Analyzer_Unit;
        part v2v_own_message : V2V_OwnMessage_Unit;
        part parameter_generator : ParameterGenerator_Unit;
        part output_gateway : OutputGateway_Unit;
    }

    part def OutputGateway_Unit{
        doc /* Part representing the output gateway of the system, responsible for sending the generated data (parameters, CAM message). */
    
        port controlIn : ControlParametersInPort; // da Elaboration
        port camIn : CAM_InPort;                  // da CAM composer
        port secMonIn : SecurityAlertsInPort;     // alert di sicurezza da InputGateway

        // Porte esterne (verso i canali reali)
        port v2v : V2VCommPort;          // invia CAM
        port vehicleBus : VehicleBusPort; // invia comandi attuatori
        port hmi : HMIPort;              // notifiche HMI

        part send_v2v_message : Send_V2VMessage_Unit;
        part send_parameters : Send_Parameters_Unit;
        part send_platooning_info : Send_Platooning_Info_Unit;
    }

    part def CAMComposer_Unit{
        doc /* Part representing the CAM composer unit of the system, responsible for composing the CAM messages based on the ego vehicle state and other relevant data. */
    
        port egoIn : EgoVehicleStateInPort;   // da InputGateway
        port camOut : CAM_OutPort;            // CAM da inviare
    }


    part def Conditioning_Unit{
        doc /* Part representing the conditioning unit of the system, responsible for filtering operations,
            /* and refining operations for the input signals. */
        
    }

    part def SignalValidation_Unit{
        doc /* Part representing the signal validation unit of the system, responsible for validating the 
            /* received signals and ensuring their integrity and reliability. */



        part check_degradation :CheckDegradation_Unit;
        part signal_reconstruction : SignalRecostruction_Unit;
    }

    part def CheckDegradation_Unit{
        doc /* Part representing the check degradation unit of the system, responsible for checking the degradation of the received signals and ensuring their reliability. */

    }

    part def SignalRecostruction_Unit{
        doc /* Part representing the signal reconstruction unit of the system, responsible for reconstructing the received signals in case of degradation or loss. */

    }



    

    part def Analyzer_Unit{
        doc /* Part representing the analyzer unit of the system, responsible for analyzing the validated signals data and generating data for following parameter generation insights. */
        


        part v2v_analyzer : V2V_Analyzer_Unit;
        part v2i_analyzer : V2I_Analyzer_Unit;
    }

    part def V2V_Analyzer_Unit{
        doc /* Part representing the V2V analyzer unit of the system, responsible for analyzing the validated signals data and generating data for following parameter generation insights. */
        
    }

    part def V2I_Analyzer_Unit{
        doc /* Part representing the V2I analyzer unit of the system, responsible for analyzing the validated signals data and generating data for following parameter generation insights. */
        
    }

    part def ParameterGenerator_Unit{
        doc /* Part representing the parameter generator unit of the system, responsible for generating the parameters for the following model based on the analyzed data. */
    }

    part def V2V_OwnMessage_Unit{
        doc /* Part representing the V2V own message unit of the system, responsible for generating the V2V own message from own actual data (speed, position, ecc). */
        
    }

    

    part def Send_V2VMessage_Unit{
        doc /* Part representing the send V2V message unit of the system, responsible for sending the generated V2V own message to other vehicles. */
    }

    part def Send_Parameters_Unit{
        doc /* Part representing the send parameters unit of the system, responsible for sending the generated parameters to the vehicle's control system. */
    }

    part def Send_Platooning_Info_Unit{
        doc /* Part representing the send platooning info unit of the system, responsible for sending the generated platooning information to other vehicles. */
    }






}