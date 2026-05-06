part :>> inputGateway : InputGateway_Unit{
                    doc /* The InputGateway unit, responsible for receiving and validating all incoming data. */

                    part :>> conditioning : Conditioning_Unit{
                        in port v2vIn : V2VCommPort;
                        in port v2iIn : V2ICommPort;
                        in port egoVehicleInfoIn : VehicleBusPort;

                        out port v2vOut : V2VCommPort;
                        out port v2iOut : V2ICommPort;
                        out port egoVehicleOut : VehicleBusPort;

                    }
                    part :>> validation : SignalValidation_Unit{
                        in port v2vIn : V2VCommPort;
                        in port v2iIn : V2ICommPort;
                        in port egoVehicleInfoIn : VehicleBusPort;

                        out port validatedDataOut : ValidatedDataOutPort;
                        out port stateFlagOut : PlatooningInfoOutPort;
                        out port egoVehicleOut : VehicleBusPort;
                    }

                    connection v2v_flow : V2VCommPort connect inputGateway.v2v to conditioning.v2vIn;
                    connection v2i_flow : V2ICommPort connect inputGateway.v2i to conditioning.v2iIn;
                    connection egoVehicle_flow : VehicleBusPort connect inputGateway.egovehicleInfoIn  to conditioning.egoVehicleInfoIn;
                    connection ego_val : VehicleBusPort connect validation.egoVehicleOut to inputGateway.validatedSignal;
                    connection status_flag : PlatooningInfoOutPort connect validation.stateFlagOut to inputGateway.egoSignals;
                    connection signal_val : ValidatedDataOutPort connect validation.egoVehicleOut to inputGateway.validatedSignal;

                    connection v2v_int : V2VCommPort connect conditioning.v2vOut to validation.v2vIn;
                    connection v2i_int : V2ICommPort connect conditioning.v2iOut to validation.v2iIn;
                    connection ego_int : VehicleBusPort connect conditioning.egoVehicleOut to validation.egoVehicleInfoIn;
                    
                    

                }