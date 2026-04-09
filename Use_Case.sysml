library package Use_Case{
    doc /* This package defines the use cases for car-following project. */

    /* ===================================================================
         * IMPORTS [PARTS]
     * =================================================================== */
    public import FPGA_Hardware::*;
    public import system_test::*;



    use case def MaintainSecurityDistance {
        doc /* Use case for maintaining a secure distance between the vehicle and following vehicle, which involves managing the speed accordingly. */
        subject system : topLevelSystem;
        first start;
        then action acquireV2XData;
        then action computeSafeDistance;
        then action changeSpeed;
        then done;
    }
}
