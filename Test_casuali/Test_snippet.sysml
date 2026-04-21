package SwimLanes {
    part def Part0;
    part def Part1;
    part def Part2;
    part part0 : Part0{
        perform action0;
        part part1 : Part1 {
            perform action0.action1;
            perform action0.action4;
        }
        part part2 : Part2 {
            perform action0.action2;
            perform action0.action3;
        }
    }

    action action0 {
        action action1;
        action action2;
        action action3;
        action action4;
        first start then action1;
        first action1 then action2;
        first action2 then action3;
        first action3 then action4;
        first action4 then done;
    }
}


package SwimLanesFixed {
    part def Part1;
    part def Part2;

    action action0 {
        
        // 1. Definiamo le azioni DIRETTAMENTE come proprietà delle parti.
        // Queste diventeranno le tue "corsie" (i box grandi).
        part part1 : Part1 {
            action action1;
            action action4;
        }
        
        part part2 : Part2 {
            action action2;
            action action3;
        }

        // 2. Usiamo la Dot Notation (Parte.Azione) per il flusso temporale.
        // Questo costringe il visualizzatore a tracciare le frecce
        // DIRETTAMENTE tra i nodi dentro ai box delle parti.
        first start;
        then part1.action1;
        then part2.action2;
        then part2.action3;
        then part1.action4;
        then done;
    }
}




package SwimLanes_v3 {
    part def Part0;
    part def Part1;
    part def Part2;
    part part0 : Part0{
        perform action0;
        part part1 : Part1 {
            perform action0.action1;
            perform action0.action4;
        }
        part part2 : Part2 {
            perform action0.action2;
            perform action0.action3;
        }
        first start then part0.action0.action1;
        first part0.action0.action1 then part0.action0.action2;
        first part0.action0.action2 then part0.action0.action3;
        first part0.action0.action3 then part0.action0.action4;

    }
    

    action action0 {
        action action1;
        action action2;
        action action3;
        action action4;
        first start then action1;
        first action1 then action2;
        first action2 then action3;
        first action3 then action4;
        first action4 then done;
    }
}



package 'Tom Sawyer Sequence View' {
    
    part def Cliente;
    part def Server;

    // 1. Il nodo radice DEVE essere un "occurrence" (o "occurrence def")
    occurrence SequenceInterazione {
        
        // 2. Le Lifeline (le parti che comunicano)
        part client : Cliente {
            // 3. I "punti di ancoraggio" del tempo sulla lifeline
            event occurrence inviaRichiesta;
            then event occurrence riceviRisposta;
        }
        
        part server : Server {
            event occurrence riceviRichiesta;
            then event occurrence elaboraDati;
            then event occurrence inviaRisposta;
        }

        // 4. I Messaggi DEVONO collegare gli EVENTI, non le parti intere
        message 'test' from client.inviaRichiesta to server.riceviRichiesta;
        
        then message from server.inviaRisposta to client.riceviRisposta;
    }
}








occurrence test_suo{
                        ref part local_system = system;
                        ref part local_follower = follower;
                        ref part local_following = following;
                        message 'test' from local_system.controlCarFollowing to local_follower.sendV2V;
                        then message 'test2' from local_system.controlCarFollowing to local_following.sendV2V;
                    }
                
                

                    //message sendV2V from leader_vehicle to system;
                    occurrence test_sequence{
                        ref part follower_vehicle: Vehicle;
                        part follower1 : Vehicle{
                        event occurrence sendV2V;
                    }
                        part following1 : Vehicle{
                        event occurrence sendV2V;
                    }
                        part system1{
                        event occurrence receiveV2V;
                        then event occurrence processV2V;
                        then event occurrence controlCarFollowing;
                        }
                
                    message 'V2V data' from following1.sendV2V to system1.receiveV2V;
                    then message 'V2V_data' from follower1.sendV2V to system1.receiveV2V;
                    then message 'Elaboration' from system1.processV2V to system1.controlCarFollowing;




                message 'Send_V2V_data' from following.sendV2V to system.receiveV2V;
                then message 'Send_V2V_data2' from system.processV2V to system.receiveV2V;
                then message 'Elaborate' from system.processV2V to system.controlCarFollowing;
                }