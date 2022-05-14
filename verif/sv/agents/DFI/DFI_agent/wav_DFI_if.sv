`include "DFI/DFI_agent/wav_DFI_defines.svh"

interface wav_DFI_if(input clock, input reset);

    //status, not entirely implemented 
    logic                     init_start = 0;

    // Update
    logic                     ctrlupd_ack = 0;
    logic                     ctrlupd_req = 0;
    logic                     phyupd_ack = 0;
    logic                     phyupd_req = 0;
    logic [1:0]               phyupd_type = 0;

    // PHY Master
    logic                      phymstr_ack = 0;
    logic [1:0]                phymstr_cs_state = 0;
    logic                      phymstr_req = 0;
    logic                      phymstr_state_sel = 0;
    logic [1:0]                phymstr_type = 0;

    // Low Power Control
    logic                      lp_ctrl_ack = 0;
    logic                      lp_ctrl_req = 0;
    logic [5:0]                lp_ctrl_wakeup = 0;
    logic                      lp_data_ack = 0;
    logic                      lp_data_req = 0;
    logic [5:0]                lp_data_wakeup = 0;


	//command
    logic                      reset_n_p0=0,
    logic                      reset_n_p1=0,
    logic                      reset_n_p2=0,
    logic                      reset_n_p3=0,
    logic [13:0]               address_p0=0,
    logic [13:0]               address_p1=0,
    logic [13:0]               address_p2=0,
    logic [13:0]               address_p3=0,
    logic [1:0]                cke_p0=0,
    logic [1:0]                cke_p1=0,
    logic [1:0]                cke_p2=0,
    logic [1:0]                cke_p3=0,
    logic [1:0]                cs_p0=0,
    logic [1:0]                cs_p1=0,
    logic [1:0]                cs_p2=0,
    logic [1:0]                cs_p3=0,
    logic                      dram_clk_disable_p0=0,
    logic                      dram_clk_disable_p1=0,
    logic                      dram_clk_disable_p2=0,
    logic                      dram_clk_disable_p3=0,


	//write 
    logic [63:0]               wrdata_p0=0,
    logic [63:0]               wrdata_p1=0,
    logic [63:0]               wrdata_p2=0,
    logic [63:0]               wrdata_p3=0,
    logic                      parity_in_p0=0,
    logic                      parity_in_p1=0,
    logic                      parity_in_p2=0,
    logic                      parity_in_p3=0,
    logic [1:0]                wrdata_cs_p0=0,
    logic [1:0]                wrdata_cs_p1=0,
    logic [1:0]                wrdata_cs_p2=0,
    logic [1:0]                wrdata_cs_p3=0,
    logic [7:0]                wrdata_mask_p0=0,
    logic [7:0]                wrdata_mask_p1=0,
    logic [7:0]                wrdata_mask_p2=0,
    logic [7:0]                wrdata_mask_p3=0,
    logic                      wrdata_en_p0=0,
    logic                      wrdata_en_p1=0,
    logic                      wrdata_en_p2=0,
    logic                      wrdata_en_p3=0,
    
	//wck
    logic [1:0]                wck_cs_p0=0,
    logic [1:0]                wck_cs_p1=0,
    logic [1:0]                wck_cs_p2=0,
    logic [1:0]                wck_cs_p3=0,
    logic                      wck_en_p0=0,
    logic                      wck_en_p1=0,
    logic                      wck_en_p2=0,
    logic                      wck_en_p3=0,
    logic [1:0]                wck_toggle_p0=0,
    logic [1:0]                wck_toggle_p1=0,
    logic [1:0]                wck_toggle_p2=0,
    logic [1:0]                wck_toggle_p3=0,
	
    
    //read

	//status

    clocking cb_drv @(posedge clock);
        default input #2ns output #2ns;
        output ctrlupd_req, 
                phymstr_ack, 
                phyupd_ack,
                lp_ctrl_req, lp_ctrl_wakeup, 
                lp_data_req, lp_data_wakeup,
                reset_n_p0,reset_n_p1,reset_n_p2,reset_n_p3,
                address_p0,address_p1,address_p2,address_p3,
                cke_p0,cke_p1,cke_p2,cke_p3,
                cs_p0,cs_p1,cs_p2,cs_p3,
                dram_clk_disable_p0,dram_clk_disable_p1,dram_clk_disable_p2,dram_clk_disable_p3,
                wrdata_p0,wrdata_p1,wrdata_p2,wrdata_p3,
                parity_in_p0,parity_in_p1,parity_in_p2,parity_in_p3,
                wrdata_cs_p0,wrdata_cs_p1,wrdata_cs_p2,wrdata_cs_p3,
                wrdata_mask_p0,wrdata_mask_p1,wrdata_mask_p2,wrdata_mask_p3,
                wrdata_en_p0,wrdata_en_p1,wrdata_en_p2,wrdata_en_p3,
                wck_cs_p0,wck_cs_p1,wck_cs_p2,wck_cs_p3,
                wck_en_p0,wck_en_p1,wck_en_p2,wck_en_p3,
                wck_toggle_p0,wck_toggle_p1,wck_toggle_p2,wck_toggle_p3;
                /*read*/
                /*status*/
        input lp_data_ack, lp_ctrl_ack, ctrlupd_ack, phyupd_req, phyupd_type,
            phymstr_cs_state, phymstr_req, phymstr_state_sel, phymstr_type;
                /*read*/
                /*status*/
    endclocking // cb_drv

    clocking cb_mon @(posedge clock);
        default input #2ns;
        input ctrlupd_req, ctrlupd_ack,
        phyupd_ack, phyupd_req, phyupd_type,
        phymstr_ack, phymstr_cs_state, phymstr_req, phymstr_state_sel, phymstr_type,
        lp_ctrl_req, lp_ctrl_wakeup, lp_ctrl_ack,
        lp_data_req, lp_data_wakeup, lp_data_ack,
        reset_n_p0,reset_n_p1,reset_n_p2,reset_n_p3,
        address_p0,address_p1,address_p2,address_p3,
        cke_p0,cke_p1,cke_p2,cke_p3,
        cs_p0,cs_p1,cs_p2,cs_p3,
        dram_clk_disable_p0,dram_clk_disable_p1,dram_clk_disable_p2,dram_clk_disable_p3,
        wrdata_p0,wrdata_p1,wrdata_p2,wrdata_p3,
        parity_in_p0,parity_in_p1,parity_in_p2,parity_in_p3,
        wrdata_cs_p0,wrdata_cs_p1,wrdata_cs_p2,wrdata_cs_p3,
        wrdata_mask_p0,wrdata_mask_p1,wrdata_mask_p2,wrdata_mask_p3,
        wrdata_en_p0,wrdata_en_p1,wrdata_en_p2,wrdata_en_p3,
        wck_cs_p0,wck_cs_p1,wck_cs_p2,wck_cs_p3,
        wck_en_p0,wck_en_p1,wck_en_p2,wck_en_p3,
        wck_toggle_p0,wck_toggle_p1,wck_toggle_p2,wck_toggle_p3;
        /*read*/
        /*status*/
    endclocking // cb_mon

    modport mp_drv (input reset, clocking cb_drv);

    modport mp_mon(input reset, clocking cb_mon);




    // DFI control Assertions
    lp_ctrl_is_defined: assert property (@(posedge clock) $isunknown({lp_ctrl_req, lp_ctrl_wakeup, lp_ctrl_ack}) == 0);
    lp_data_is_defined: assert property (@(posedge clock) $isunknown({lp_data_req, lp_data_wakeup, lp_data_ack}) == 0);
    ctrlupd_is_defined: assert property (@(posedge clock) $isunknown({ctrlupd_ack, ctrlupd_req}) == 0);
    phyupd_is_defined:  assert property (@(posedge clock) $isunknown({phyupd_req, phyupd_type, phyupd_ack}) == 0);
    phymstr_is_defined: assert property (@(posedge clock) $isunknown({phymstr_req, phymstr_cs_state, phymstr_ack, phymstr_state_sel, phymstr_type}) == 0);

    item_26: assert property (@(posedge clock) lp_ctrl_ack[*1:$] |=> ($fell(lp_ctrl_ack) && ~lp_ctrl_req));    // ack should be de-asserted after req
    item_34: assert property (@(posedge clock) lp_data_ack[*1:$] |=> ($fell(lp_data_ack) && ~lp_data_req));    // ack should be de-asserted after req

    item_42: assert property (@(posedge clock) (lp_ctrl_req & ~lp_ctrl_ack) [*(`tlp_resp)] |=> ~lp_ctrl_req);    // if ack didn't show up after tlp_resp, req should go low
    item_43: assert property (@(posedge clock) (lp_data_req & ~lp_data_ack) [*(`tlp_resp)] |=> ~lp_data_req);    // if ack didn't show up after tlp_resp, req should go low

    item_92: assert property (@(posedge clock) (ctrlupd_ack |-> ctrlupd_req));  //req is HIGH as long as req is HIGH
    item_100: assert property (@(posedge clock) phyupd_req |->##[0:`tphyupd_resp] phyupd_ack);  // ack should come within tphyupd_resp cycles from the req
    item_101: assert property (@(posedge clock) $rose(phyupd_req) |-> ~phyupd_ack); //req cannot be re-asserted before de-assertion of ack
    item_102: assert property (@(posedge clock) ~phyupd_req |=> ~phyupd_ack); // ack should de-assert upon detection of de-asserton of req

    item_104: assert property (@(posedge clock) phyupd_req |->##[0:$] phyupd_ack);  // upon req, ack is high eventually

    // forbidden states
    item_106: assert property (@(posedge clock) ~(phyupd_ack & phymstr_ack)); 
    item_107: assert property (@(posedge clock) ~(init_start & phyupd_ack));
    item_108: assert property (@(posedge clock) ~(ctrlupd_req & phyupd_ack));
    item_109: assert property (@(posedge clock) ~(init_start & phymstr_ack));
    item_110: assert property (@(posedge clock) ~(init_start & ctrlupd_req));
    item_111: assert property (@(posedge clock) ~(init_start & lp_ctrl_req));
    item_112: assert property (@(posedge clock) ~(init_start & lp_data_req));
endinterface