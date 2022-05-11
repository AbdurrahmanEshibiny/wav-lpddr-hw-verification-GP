interface wav_DFI_if(input clock, input reset);

    // Update
    logic                     ctrlupd_ack;
    logic                     ctrlupd_req;
    logic                     phyupd_ack;
    logic                     phyupd_req;
    logic [1:0]               phyupd_type;

    // PHY Master
    logic                      phymstr_ack;
    logic [1:0]                phymstr_cs_state;
    logic                      phymstr_req;
    logic                      phymstr_state_sel;
    logic [1:0]                phymstr_type;

    // Low Power Control
    logic                      lp_ctrl_ack;
    logic                      lp_ctrl_req;
    logic [5:0]                lp_ctrl_wakeup;
    logic                      lp_data_ack;
    logic                      lp_data_req;
    logic [5:0]                lp_data_wakeup;

	//command

	//write 

	//wck

	//read

	//status

    clocking cb_drv @(posedge clock);
        default input #2ns output #2ns;
        output ctrlupd_req, 
                phymstr_ack, 
                phyupd_ack,
                lp_ctrl_req, lp_ctrl_wakeup, 
                lp_data_req, lp_data_wakeup;
		//define the remaining interface singnals
        input lp_data_ack, lp_ctrl_ack, ctrlupd_ack, phyupd_req, phyupd_type,
            phymstr_cs_state, phymstr_req, phymstr_state_sel, phymstr_type;
		//define the remaining interface singnals
    endclocking // cb_drv

    clocking cb_mon @(posedge clock);
        default input #2ns;
        input ctrlupd_req, ctrlupd_ack,
        phyupd_ack, phyupd_req, phyupd_type,
        phymstr_ack, phymstr_cs_state, phymstr_req, phymstr_state_sel, phymstr_type,
        lp_ctrl_req, lp_ctrl_wakeup, lp_ctrl_ack,
        lp_data_req, lp_data_wakeup, lp_data_ack;
	//define the remaining interface singnals
    endclocking // cb_mon

    modport mp_drv (input reset, clocking cb_drv);

    modport mp_mon(input reset, clocking cb_mon);
endinterface