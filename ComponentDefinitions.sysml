package 'Order Processing Example' {

    // 1. Definizione dei tipi (chi partecipa al sistema)
    part def Customer;
    part def OrderService;
    part def PaymentGateway;

    // 2. Azione Principale
    action 'Process Order' {
        
        // Istanze delle parti (queste diventano le Lifelines nel rendering)
        part customer : Customer;
        part service : OrderService;
        part gateway : PaymentGateway;

        // 3. Prima Sub-Action: Fase di Checkout
        first action 'Checkout' {
            first message 'Submit Cart' from customer to service;
            then message 'Request Payment Details' from service to customer;
            then message 'Provide Details' from customer to service;
        }

        // 4. Seconda Sub-Action: Fase di Pagamento
        then action 'Process Payment' {
            first message 'Authorize Payment' from service to gateway;
            
            // Un messaggio interno alla sub-action
            then message 'Payment Confirmed' from gateway to service;
        }

        // 5. Conclusione nell'azione principale
        then message 'Order Complete' from service to customer;
    }
}