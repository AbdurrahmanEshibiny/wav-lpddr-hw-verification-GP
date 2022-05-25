`include "DFI/DFI_agent/wav_DFI_defines.svh"

interface wav_DFI_if(input clock, input reset);
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
    logic                      reset_n [0:3] = '{default:1'b0};
    logic [13:0]               address [0:3] = '{default:14'b0};
    logic [1:0]                cke [0:3] = '{default:0};
    logic [1:0]                cs [0:3] = '{default:0};
    logic                      dram_clk_disable [0:3] = '{default:0};
    logic                      parity_in [0:3] = '{default:0};
    

	//write 
    logic [63:0]               wrdata [0:3] = '{default:0};
    logic [1:0]                wrdata_cs [0:3] = '{default:0};
    logic [7:0]                wrdata_mask [0:3] = '{default:0};
    logic                      wrdata_en [0:3] = '{default:0};
    

	//wck
    logic [1:0]                wck_cs [0:3] = '{default:0};
    logic                      wck_en [0:3] = '{default:0};
    logic [1:0]                wck_toggle [0:3] = '{default:0};
    
    // read
    logic [63:0]               rddata [0:3] = '{default:0};
    logic [1:0]                rddata_cs [0:3] = '{default:0};
    logic [7:0]                rddata_dbi [0:3] = '{default:0};
    logic                      rddata_en [0:3] = '{default:0};
    logic                      rddata_valid [0:3] = '{default:0};

	// status
    logic                      init_complete = 0;
    logic                      init_start = 0;
    logic [1:0]                freq_fsp = 0;
    logic [1:0]                freq_ratio = 0;
    logic [4:0]                frequency = 0;

    clocking cb_drv @(posedge clock);
        default input #2ns output #2ns;
                // update
        output  ctrlupd_req,
                // phy master
                phymstr_ack, 
                phyupd_ack,
                // low power
                lp_ctrl_req, lp_ctrl_wakeup, 
                lp_data_req, lp_data_wakeup,
                // command
                reset_n,
                address,
                cke,
                cs,
                dram_clk_disable,
                parity_in,
                // write
                wrdata,
                wrdata_cs,
                wrdata_mask,
                wrdata_en,
                // write clk
                wck_cs,
                wck_en,
                wck_toggle,
                // read
                rddata_cs,
                rddata_en,
                // status
                init_start,
                freq_fsp,
                freq_ratio,
                frequency;

                // low power
        input   lp_data_ack, lp_ctrl_ack,
                // update
                ctrlupd_ack, phyupd_req, phyupd_type,
                // phy master
                phymstr_cs_state, phymstr_req,
                phymstr_state_sel, phymstr_type,
                // read
                rddata,
                rddata_dbi,
                rddata_valid,
                // status
                init_complete;
    endclocking // cb_drv

    clocking cb_mon @(posedge clock);
        default input #2ns;
                // update
        input   ctrlupd_req, ctrlupd_ack,
                phyupd_ack, phyupd_req, phyupd_type,
                // phy master
                phymstr_ack, phymstr_cs_state, phymstr_req, phymstr_state_sel, phymstr_type,
                // low power
                lp_ctrl_req, lp_ctrl_wakeup, lp_ctrl_ack,
                lp_data_req, lp_data_wakeup, lp_data_ack,
                // command
                reset_n,
                address,
                cke,
                cs,
                dram_clk_disable,
                parity_in,
                // write
                wrdata,
                wrdata_cs,
                wrdata_mask,
                wrdata_en,
                // write clock
                wck_cs,
                wck_en,
                wck_toggle,
                // read
                rddata,
                rddata_cs,
                rddata_dbi,
                rddata_en,
                rddata_valid,
                // status
                init_complete,
                init_start,
                freq_fsp,
                freq_ratio,
                frequency;
    endclocking // cb_mon

    modport mp_drv(input reset, clocking cb_drv);
    modport mp_mon(input reset, clocking cb_mon);


    // DFI control Assertions
    lp_ctrl_is_defined: assert property (@(posedge clock) $isunknown({lp_ctrl_req, lp_ctrl_wakeup, lp_ctrl_ack}) == 0);
    lp_data_is_defined: assert property (@(posedge clock) $isunknown({lp_data_req, lp_data_wakeup, lp_data_ack}) == 0);
    ctrlupd_is_defined: assert property (@(posedge clock) $isunknown({ctrlupd_ack, ctrlupd_req}) == 0);
    phyupd_is_defined:  assert property (@(posedge clock) $isunknown({phyupd_req, phyupd_type, phyupd_ack}) == 0);
    phymstr_is_defined: assert property (@(posedge clock) $isunknown({phymstr_req, phymstr_cs_state, phymstr_ack, phymstr_state_sel, phymstr_type}) == 0);

    // item_26: assert property (@(posedge clock) $fell(lp_ctrl_ack)[*1:$] |=> ($fell(lp_ctrl_ack) && ~lp_ctrl_req));    // ack should be de-asserted after req
    item_26: assert property (@(posedge clock) lp_ctrl_ack |->##[1:$] ($fell(lp_ctrl_ack) && ~lp_ctrl_req));    // ack should be de-asserted after req
    // item_34: assert property (@(posedge clock) lp_data_ack[*1:$] |=> ($fell(lp_data_ack) && ~lp_data_req));    // ack should be de-asserted after req
    item_34: assert property (@(posedge clock) lp_data_ack |->##[1:$] ($fell(lp_data_ack) && ~lp_data_req));    // ack should be de-asserted after req

    item_42: assert property (@(posedge clock) (lp_ctrl_req & ~lp_ctrl_ack) [*(`tlp_resp)] |=> ~lp_ctrl_req);    // if ack didn't show up after tlp_resp, req should go low
    item_43: assert property (@(posedge clock) (lp_data_req & ~lp_data_ack) [*(`tlp_resp)] |=> ~lp_data_req);    // if ack didn't show up after tlp_resp, req should go low

    item_92: assert property (@(posedge clock) (ctrlupd_ack |-> ctrlupd_req));  //req is HIGH as long as ack is HIGH
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

    `define address_is_idle (address[0] == 14'b0 && address[1] == 14'b0 && address[2] == 14'b0 && address[3] == 14'b0)

    // while phyupd_req is accepted, ensure that no other commands are sent and that the DFI is idle
    item_95: assert property(@(posedge clock) phyupd_ack |-> (~lp_ctrl_req & ~lp_data_req & ~phymstr_req & ~ctrlupd_req & `address_is_idle));
    item_96: assert property(@(posedge clock) ctrlupd_ack |-> (~lp_ctrl_req & ~lp_data_req & ~phymstr_req & ~phyupd_req & `address_is_idle)); 
    item_97: assert property(@(posedge clock) $rose(ctrlupd_req) |->##[0:$] ctrlupd_ack); 

    // no read or write transactions at lp mode    
    item_30: assert property(@(posedge clock) ~(lp_data_req & ~(!(4'({>>{wrdata_en}})))) && ~(lp_data_req & ~(!(4'({>>{rddata_en}})))));
    item_27: assert property(@(posedge clock) ~(lp_ctrl_req & ~(!(56'({>>{address}})))));
endinterface