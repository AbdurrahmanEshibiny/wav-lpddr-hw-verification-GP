// `include "DFI/DFI_agent/wav_DFI_transfer.sv"

task automatic set_dfi_phymstr_req;
    input wav_DFI_phymstr_transfer trans;
    begin        
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_CS_STATE, trans.cs_state);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_STATE_SEL, trans.state_sel);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_TYPE, trans._type);
		`CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_REQ_OVR, 1'b1);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_REQ_VAL, trans.req);
    end
endtask

task automatic get_dfi_phymstr_ack;
    output logic val;
    begin
        `CSR_RDF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_STA, ACK, val);
    end
endtask

task automatic get_dfi_phymstr_req;
    output logic val;
    begin
        `CSR_RDF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_STA, REQ, val);
    end
endtask

task automatic set_dfi_phyupd_req;
    input wav_DFI_update_transfer trans;
    begin
        trans.print();
        `CSR_WRF3(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, 
                    SW_TYPE, SW_REQ_OVR, SW_REQ_VAL,
                    trans._type, 1'b1, trans.req);
        // `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, SW_REQ_VAL, );
        // `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, SW_TYPE, );
    end
endtask

task automatic set_dfi_ctrlupd_req;
    input wav_DFI_update_transfer trans;
    static bit val = 1;
    begin
        `CSR_WRF4(DDR_DFI_OFFSET, DDR_DFI_CTRLUPD_IF_CFG, 
        SW_EVENT_0_OVR, SW_EVENT_0_VAL, SW_EVENT_1_OVR, SW_EVENT_1_VAL,
        1'b1, (val ? 1'b1 : 1'b0), 1'b1, (val ? 1'b1 : 1'b0));

        val = ~val;

        trans.print();
        `CSR_WRF4(DDR_DFI_OFFSET,DDR_DFI_CTRLUPD_IF_CFG, 
                    SW_REQ_OVR, SW_REQ_VAL, SW_ACK_OVR, SW_ACK_OVR,
                    1'b1, trans.req, 1'b1, trans.ack);
    end
endtask

task automatic set_dfi_lp_req;
    input wav_DFI_lp_transfer trans;
    static bit val = 1;
    begin
        trans.print();

        if (trans.is_ctrl) begin
            `CSR_WRF4(DDR_DFI_OFFSET, DDR_DFI_LP_CTRL_IF_CFG, 
            SW_EVENT_0_OVR, SW_EVENT_0_VAL, SW_EVENT_1_OVR, SW_EVENT_1_VAL,
            1'b1, (val ? 1'b1 : 1'b0), 1'b1, (val ? 1'b1 : 1'b0));

            val = ~val;

            `CSR_WRF4(DDR_DFI_OFFSET, DDR_DFI_LP_CTRL_IF_CFG, 
            SW_REQ_OVR, SW_REQ_VAL, SW_ACK_OVR, SW_ACK_OVR,
            1'b1, trans.req, 1'b1, trans.ack);
        end
        else begin
            `CSR_WRF4(DDR_DFI_OFFSET,  DDR_DFI_LP_DATA_IF_CFG, 
            SW_EVENT_0_OVR, SW_EVENT_0_VAL, SW_EVENT_1_OVR, SW_EVENT_1_VAL,
            1'b1, (val ? 1'b1 : 1'b0), 1'b1, (val ? 1'b1 : 1'b0));

            val = ~val;

            `CSR_WRF4(DDR_DFI_OFFSET, DDR_DFI_LP_DATA_IF_CFG, 
            SW_REQ_OVR, SW_REQ_VAL, SW_ACK_OVR, SW_ACK_OVR,
            1'b1, trans.req, 1'b1, trans.ack);
        end
    end
endtask

task automatic get_dfi_phyupd_ack;
    output logic val;
    begin
        `CSR_RDF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_STA, ACK, val);
    end
endtask

task automatic get_dfi_phyupd_req;
    output logic val;
    begin
        `CSR_RDF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_STA, REQ, val);
    end
endtask

task t_dfi_phyupd(output int err, input bit doInit = 1);
        logic ack = 0, req = 0;
        wav_DFI_update_transfer trans;
    begin
        `uvm_info(get_name(), "starting t_dfi_phyupd", UVM_MEDIUM);

        trans = new();
        err = 0;        
        if (doInit) begin
            #1us;
            `uvm_info(get_name(), "calling ddr_boot", UVM_MEDIUM);
            ddr_boot(err);
        end
        
        `uvm_info(get_name(), "starting t_dfi_phyupd main body", UVM_MEDIUM);
        assert(trans.randomize());
        `uvm_info(get_name(), "Randomized the phyupd trans HIGH", UVM_MEDIUM);
        trans.req = 1;
        trans.print();
        
        `uvm_info(get_name(), "driving the phyupd trans HIGH", UVM_MEDIUM);
        set_dfi_phyupd_req(trans);
        // do begin
        //     get_dfi_phyupd_ack(ack);
        // end while (!ack);
        // `uvm_info(get_name(), $psprintf("ack = %0d", ack), UVM_MEDIUM);     
        EventHandler::wait_for_event(EventHandler::phyupd_ack_pos);
        
        trans.req = 0;
        `uvm_info(get_name(), "driving the phyupd req to LOW", UVM_MEDIUM);
        set_dfi_phyupd_req(trans);

        `uvm_info(get_name(), "overriding phyupd event to HIGH", UVM_MEDIUM);
        `CSR_WRF2(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, 
                    SW_EVENT_OVR, SW_EVENT_VAL,
                    1'b1, 1'b1);
        // do begin
        //     get_dfi_phyupd_req(req);
        // end while (req);
        // `uvm_info(get_name(), $psprintf("req = %0d", req), UVM_MEDIUM);
        EventHandler::wait_for_event(EventHandler::phyupd_req_neg);

        `uvm_info(get_name(), "overriding phyupd event to LOW", UVM_MEDIUM);
        `CSR_WRF2(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, 
                    SW_EVENT_OVR, SW_EVENT_VAL,
                    1'b1, 1'b0);
        #10ns;

        `uvm_info(get_name(), "DFI phyupd test completed!!!!!!!!", UVM_MEDIUM);
    end
 endtask

task t_dfi_phymstr(output int err, input bit doInit = 1);
    logic ack = 0, req = 0;
    wav_DFI_phymstr_transfer trans;
    begin
        if (doInit) begin
            `uvm_info(get_name(), "starting t_dfi_phymstr", UVM_MEDIUM);
            #1us;

            `uvm_info(get_name(), "calling ddr_boot", UVM_MEDIUM);
            ddr_boot(err);  
        end
        
        `uvm_info(get_name(), "starting t_dfi_phymstr body", UVM_MEDIUM);     
        trans = new();
        assert(trans.randomize());
        trans.req = 1;
        trans.print();
		
        `uvm_info(get_name(), "driving the phymstr trans HIGH", UVM_MEDIUM);
        set_dfi_phymstr_req(trans);
        // do begin
        //     get_dfi_phymstr_ack(ack);
        // end while (!ack);
        EventHandler::wait_for_event(EventHandler::phymstr_ack_pos); 
        trans.req = 0;
        `uvm_info(get_name(), "driving the phymstr trans LOW", UVM_MEDIUM);
        set_dfi_phymstr_req(trans);
		
		
		`uvm_info(get_name(), "overriding phymstr event to HIGH", UVM_MEDIUM);
        `CSR_WRF2(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, 
                    SW_EVENT_OVR, SW_EVENT_VAL,
                    1'b1, 1'b1);
		
		// do begin
        //     get_dfi_phymstr_ack(req);
        // end while (req);
        // `uvm_info(get_name(), $psprintf("req = %0d", req), UVM_MEDIUM);
        EventHandler::wait_for_event(EventHandler::phymstr_req_neg);
		
		`uvm_info(get_name(), "overriding phymstr event to LOW", UVM_MEDIUM);
        `CSR_WRF2(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, 
                    SW_EVENT_OVR, SW_EVENT_VAL,
                    1'b1, 1'b0);

        #10ns;
    end
endtask

task t_dfi_lp(output int err, input bit doInit = 1, input bit is_ctrl=0);
    logic ack = 0, req = 0;
    wav_DFI_lp_transfer trans;
    begin
        if (doInit) begin
            `uvm_info(get_name(), "starting t_dfi_lp", UVM_MEDIUM);
            #1us;

            `uvm_info(get_name(), "calling ddr_boot", UVM_MEDIUM);
            ddr_boot(err);  
        end
        
        `uvm_info(get_name(), "starting t_dfi_lp body", UVM_MEDIUM);     
        trans = new();
        assert(trans.randomize());
        trans.req = 1;
        trans.ack = 1;
        trans.is_ctrl = is_ctrl;
        trans.print();
		
        `uvm_info(get_name(), "driving the lp trans HIGH", UVM_MEDIUM);
        set_dfi_lp_req(trans);
        
        // if (is_ctrl)
        //     EventHandler::wait_for_event(EventHandler::lp_ctrl_ack_pos); 
        // else
        //     EventHandler::wait_for_event(EventHandler::lp_data_ack_pos);

        trans.req = 0;
        trans.ack = 0;
        `uvm_info(get_name(), "driving the lp trans LOW", UVM_MEDIUM);
        set_dfi_lp_req(trans);
        
        // if (is_ctrl)
        //     EventHandler::wait_for_event(EventHandler::lp_ctrl_req_neg);
        // else
        //     EventHandler::wait_for_event(EventHandler::lp_data_req_neg);

        #10ns;
    end
endtask

task t_dfi_ctrlupd(output int err, input bit doInit = 1);
    logic ack = 0, req = 0;
    wav_DFI_update_transfer trans;
    begin
        if (doInit) begin
            `uvm_info(get_name(), "starting t_dfi_ctrlupd", UVM_MEDIUM);
            #1us;

            `uvm_info(get_name(), "calling ddr_boot", UVM_MEDIUM);
            ddr_boot(err);  
        end
        
        `uvm_info(get_name(), "starting t_dfi_ctrlupd body", UVM_MEDIUM);     
        trans = new();
        assert(trans.randomize());
        trans.req = 1;
        trans.ack = 1;
        trans.is_ctrl = 1'b1;
        trans.print();
		
        `uvm_info(get_name(), "driving the ctrlupd trans HIGH", UVM_MEDIUM);
        set_dfi_ctrlupd_req(trans);
        
        // EventHandler::wait_for_event(EventHandler::ctrlupd_ack_pos); 

        trans.req = 0;
        trans.ack = 0;
        `uvm_info(get_name(), "driving the ctrlupd trans LOW", UVM_MEDIUM);
        set_dfi_ctrlupd_req(trans);
        
        // EventHandler::wait_for_event(EventHandler::ctrlupd_req_neg);

        #10ns;
    end
endtask


virtual wav_DFI_if vif = null;

task automatic init_vif;
    if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif)) begin
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".DFI_vif"});
    end
endtask

task automatic wait_dfi_cycles(int count);
    repeat(count) @(posedge vif.clock);
endtask

task automatic handle_status_internally;
    if (vif == null) begin
        init_vif(); // obtain the virtual DFI interface
    end

    `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_STATUS_IF_CFG, 
            SW_ACK_OVR,
            1'b0);
    `CSR_WRF4(DDR_DFI_OFFSET,DDR_DFI_STATUS_IF_CFG, 
            SW_EVENT_1_OVR, SW_EVENT_1_VAL, SW_REQ_VAL, SW_REQ_OVR,
            1'b1, 1'b1, 1'b0, 1'b1);
    fork
        forever begin
            @(posedge vif.init_start);
            `uvm_info(get_name(), $psprintf("overriding status req val = $b", vif.init_start), UVM_MEDIUM);            
            `CSR_WRF1(DDR_DFI_OFFSET, DDR_DFI_STATUS_IF_CFG, 
                    SW_REQ_VAL, 1'b1);
            wait_dfi_cycles(10);
            `CSR_WRF1(DDR_DFI_OFFSET, DDR_DFI_STATUS_IF_CFG, 
                    SW_REQ_VAL, 1'b0);
        end
    join_none

    // delay to allow the previous values to be written in the registers
    wait_dfi_cycles(50);    
endtask

task automatic set_freq_ratio(int freq_ratio);
    // Case1: SDR 1:1 - egress DDR2to1
    if (freq_ratio == 1) begin
        set_txdq_sdr_fc_dly   (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
        set_txdq_sdr_pipe_en  (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdq_sdr_x_sel    (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3200) );
        set_txdqs_sdr_fc_dly  (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
        set_txdqs_sdr_pipe_en (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3200) );

        set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(8'd0),  .rank_sel(RANK_ALL), .x_sel    ('h7654_3210) );  //WCK
        set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(8'd1),  .rank_sel(RANK_ALL), .x_sel    ('h7654_3210) );  //DQS/Parity

        set_txdq_ddr_pipe_en  (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdq_ddr_x_sel    (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );
        set_txdqs_ddr_pipe_en (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdqs_ddr_x_sel   (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );

        //EGRESS_MODE 6:0 DEF=0x01 "Egress mode (one-hot) - 0: SDR, 1:DDR_2to1, 2:QDR_2to1, 3: ODR_2to1, 4:QDR_4to1, 5:ODR_4to1, 6: BSCAN ";
        set_dq_egress_mode    (.byte_sel(ALL),    .dq (8'd99), .mode('h02) );
        set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd99), .mode('h02) );
        set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd0),  .mode('h02) ); // WCK DDR2to1.
        set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd1),  .mode('h02) ); // DQS DDR2to1.

        // set_rx_gb             (.byte_sel(DQ_ALL), .rgb_mode(DGB_1TO1_HF), .fgb_mode(FGB_1TO1),    .wck_mode(1'b0)); // for DQ, lopback DQS clock
        // set_rx_gb             (.byte_sel(CA),     .rgb_mode(DGB_1TO1_HF), .fgb_mode(FGB_1TO1),    .wck_mode(1'b1)); // for CA, loop back CK clock
        // set_tx_gb             (.byte_sel(ALL),    .tgb_mode(DGB_1TO1_HF), .wgb_mode(WGB_1TO1));
        set_rx_gb             (.byte_sel(DQ_ALL),     .rgb_mode(DGB_2TO1_HF), .fgb_mode(FGB_2TO2),    .wck_mode(1'b0)); // DQS Loop back
        set_rx_gb             (.byte_sel(CA),         .rgb_mode(DGB_2TO1_HF), .fgb_mode(FGB_2TO2),    .wck_mode(1'b1)); // CK  Loop back
        set_tx_gb             (.byte_sel(ALL),        .tgb_mode(DGB_2TO1_HF), .wgb_mode(WGB_1TO1));


        //   bl = 32;
        //DFI Configuration
        set_dfiwrd_wdp_cfg     (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h0), .pre_gb_pipe_en(1'b0));
        set_dfiwrcctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
        set_dfickctrl_wdp_cfg  (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
        set_dfiwctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
        set_dfiwenctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
        //set_dfiwckctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
        set_dfirctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
        set_dfi_rdgb_mode      (DFIRGB_1TO1);
        set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h1),   .wck_oe_cycles(4'h1),   .ie_cycles(4'h2),       .re_cycles(4'h6), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0)); // RE extended to 6 cycles to confirm independent control on RE.
        set_dfi_clken_pext_cfg (.wr_clken_cycles(4'h7), .rd_clken_cycles(4'hF), .ca_clken_cycles(4'h3));
    end


    // Case2: DDR - DP 2to1 - egress DDR2to1 - freq ratio 1:1
    else if (freq_ratio == 2) begin
        set_txdq_sdr_fc_dly   (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
        set_txdq_sdr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdq_sdr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3210) );

        set_txdqs_sdr_fc_dly  (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
        set_txdqs_sdr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3210) );

        set_txdq_ddr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdq_ddr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );
        set_txdqs_ddr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdqs_ddr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );

        //EGRESS_MODE 6:0 DEF=0x01 "Egress mode (one-hot) - 0: SDR, 1:DDR_2to1, 2:QDR_2to1, 3: ODR_2to1, 4:QDR_4to1, 5:ODR_4to1, 6: BSCAN ";
        set_dq_egress_mode    (.byte_sel(ALL),    .dq (8'd99), .mode('h02) );
        set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd99), .mode('h02) );

        set_rx_gb             (.byte_sel(DQ_ALL),     .rgb_mode(DGB_2TO1_HF), .fgb_mode(FGB_2TO2),    .wck_mode(1'b0)); // DQS Loop back
        set_rx_gb             (.byte_sel(CA),         .rgb_mode(DGB_2TO1_HF), .fgb_mode(FGB_2TO2),    .wck_mode(1'b1)); // CK  Loop back
        set_tx_gb             (.byte_sel(ALL),        .tgb_mode(DGB_2TO1_HF), .wgb_mode(WGB_1TO1));

        //DFI Configuration
        set_dfiwrd_wdp_cfg     (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h0), .pre_gb_pipe_en(1'b0));
        set_dfiwrcctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfickctrl_wdp_cfg  (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfiwctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfiwenctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        //set_dfiwckctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfirctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfi_rdgb_mode      (DFIRGB_2TO2);
        // set_dfi_rdgb_mode      (DFIRGB_1TO1);
        //set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h3),   .wck_oe_cycles(4'h1),   .ie_cycles(4'h2),       .re_cycles(4'h2), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0));
        set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h3),   .wck_oe_cycles(4'h1),   .ie_cycles(4'h2),       .re_cycles(4'h6), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0));
        set_dfi_clken_pext_cfg (.wr_clken_cycles(4'h7), .rd_clken_cycles(4'hF), .ca_clken_cycles(4'h3));
    end







    // Case3: DDR - DP 4to1 - egress QDR2to1
    else begin
        set_txdq_sdr_fc_dly   (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
        set_txdq_sdr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdq_sdr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3120) );

        set_txdqs_sdr_fc_dly  (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
        set_txdqs_sdr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h7654_2020) );
        set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(0),  .rank_sel(RANK_ALL), .x_sel   ('h7654_3120) );// WCK
        set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(1),  .rank_sel(RANK_ALL), .x_sel   ('h7654_3120) );// DQS/Parity

        set_txdq_ddr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdq_ddr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );
        set_txdqs_ddr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
        set_txdqs_ddr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );

        //EGRESS_MODE 6:0 DEF=0x02 "Egress mode (one-hot) - 0:SDR, 1:DDR_2to1, 2:QDR_2to1, 3: ODR_2to1, 4:QDR_4to1, 5:ODR_4to1, 6:BSCAN";
        set_dq_egress_mode    (.byte_sel(ALL),    .dq (99), .mode('h04) );
        set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(99), .mode('h04) );

        set_rx_gb             (.byte_sel(DQ_ALL),     .rgb_mode (DGB_4TO1_HF), .fgb_mode(FGB_4TO4),  .wck_mode(1'b0)); // DQS Loop back
        set_rx_gb             (.byte_sel(CA),         .rgb_mode (DGB_4TO1_HF), .fgb_mode(FGB_4TO4),   .wck_mode(1'b1)); // CK  Loop back
        set_tx_gb             (.byte_sel(ALL),        .tgb_mode (DGB_4TO1_HF), .wgb_mode(WGB_1TO1));

        //DFI Configuration
        set_dfiwrd_wdp_cfg     (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h0), .pre_gb_pipe_en(1'b0));
        set_dfiwrcctrl_wdp_cfg (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfickctrl_wdp_cfg  (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfiwctrl_wdp_cfg   (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfiwenctrl_wdp_cfg (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        //set_dfiwckctrl_wdp_cfg (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfirctrl_wdp_cfg   (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
        set_dfi_rdgb_mode      (DFIRGB_4TO4);
        // set_dfi_rdgb_mode      (DFIRGB_1TO1);
        // set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h2),   .wck_oe_cycles(4'h1),      .ie_cycles(4'h2),       .re_cycles(4'h2), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0));
        set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h2),   .wck_oe_cycles(4'h1),      .ie_cycles(4'h2),       .re_cycles(4'h6), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0));
        set_dfi_clken_pext_cfg (.wr_clken_cycles(4'h7), .rd_clken_cycles(4'hF), .ca_clken_cycles(4'h3));
    end
endtask


// same as t_ddr_sanity but without the packet generation
// still not fully working ... data never stops randomizing!
// case 3 guarantees DFI 2:1
task genina_t_ddr_sanity;
    output int err;
    input int freq_setup;
    int err_temp;
    int err_cnt;
    int bl;
    begin
    err = 0;
    err_temp = 0;
    err_cnt  = 0;

    wait_hclk (1);
    ddr_boot(err) ;
    set_dfi_ca_rddata_en (.en(1'b1));  // Enable CA RDDATA en for CA loopback.

    // Set lpde delay
    // 90p delay through DQ TX LPDE, 98ps Delay through DQS TX LPDE
    set_wrdq_lpde_dly  (.byte_sel(ALL),    .rank_sel(RANK_ALL), .dq(99),  .gear(2'h2), .r0_dly(6'h01), .r1_dly(6'h01));
    set_wrdqs_lpde_dly (.byte_sel(DQ_ALL), .rank_sel(RANK_ALL), .dqs(99), .gear(2'h2), .r0_dly(6'h01), .r1_dly(6'h01));
    set_wrdqs_lpde_dly (.byte_sel(CA),     .rank_sel(RANK_ALL), .dqs(99), .gear(2'h2), .r0_dly(6'h21), .r1_dly(6'h21));
    set_rdsdr_lpde_dly (.byte_sel(DQ_ALL), .rank_sel(RANK_ALL),           .gear(2'h2), .r0_dly(6'h1A), .r1_dly(6'h1A));
    set_rdsdr_lpde_dly (.byte_sel(CA),     .rank_sel(RANK_ALL),           .gear(2'h2), .r0_dly(6'h1A), .r1_dly(6'h1A));
    // 20ps delay through DQS RX diff PAD. this is the skew between DQ and DQS to capture DQ in SA.
    set_dq_dqs_drvr_cfg   (.byte_sel(ALL), .dqs_freq_MHz(ddrfreq_MHz), .lb_mode(1), .wck_mode(1'b0), .se_mode(1'b0), .termination(1'b1) ) ;
    set_dq_dqs_rcvr_cfg   (.byte_sel(DQ_ALL), .rank_sel(RANK_ALL), .dqs_freq_MHz(ddrfreq_MHz), .dly_ps('d0));

    // Enable IO loopback
    set_tx_io_cmn_cfg_dt    (.byte_sel(ALL),    .rank_sel(RANK_ALL), .lpbk_en(1'b1), .ncal('d14), .pcal('d45));

    bl = 32;

    case (freq_setup)
        1 : begin
            //----------------------------------------------------------------------------------
            // Case1: SDR 1:1 - egress DDR2to1 -- "SDR Transaction"
            // ---------------------------------------------------------------------------------
            set_txdq_sdr_fc_dly   (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
            set_txdq_sdr_pipe_en  (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdq_sdr_x_sel    (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3200) );
            set_txdqs_sdr_fc_dly  (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
            set_txdqs_sdr_pipe_en (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3200) );

            set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(8'd0),  .rank_sel(RANK_ALL), .x_sel    ('h7654_3210) );  //WCK
            set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(8'd1),  .rank_sel(RANK_ALL), .x_sel    ('h7654_3210) );  //DQS/Parity

            set_txdq_ddr_pipe_en  (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdq_ddr_x_sel    (.byte_sel(ALL),    .dq (8'd99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );
            set_txdqs_ddr_pipe_en (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdqs_ddr_x_sel   (.byte_sel(ALL),    .dqs(8'd99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );

            //EGRESS_MODE 6:0 DEF=0x01 "Egress mode (one-hot) - 0: SDR, 1:DDR_2to1, 2:QDR_2to1, 3: ODR_2to1, 4:QDR_4to1, 5:ODR_4to1, 6: BSCAN ";
            set_dq_egress_mode    (.byte_sel(ALL),    .dq (8'd99), .mode('h02) );
            set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd99), .mode('h02) );
            set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd0),  .mode('h02) ); // WCK DDR2to1.
            set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd1),  .mode('h02) ); // DQS DDR2to1.

            set_rx_gb             (.byte_sel(DQ_ALL), .rgb_mode(DGB_1TO1_HF), .fgb_mode(FGB_1TO1),    .wck_mode(1'b0)); // for DQ, lopback DQS clock
            set_rx_gb             (.byte_sel(CA),     .rgb_mode(DGB_1TO1_HF), .fgb_mode(FGB_1TO1),    .wck_mode(1'b1)); // for CA, loop back CK clock
            set_tx_gb             (.byte_sel(ALL),    .tgb_mode(DGB_1TO1_HF), .wgb_mode(WGB_1TO1));

            
            //DFI Configuration
            set_dfiwrd_wdp_cfg     (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h0), .pre_gb_pipe_en(1'b0));
            set_dfiwrcctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
            set_dfickctrl_wdp_cfg  (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
            set_dfiwctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
            set_dfiwenctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
            //set_dfiwckctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
            set_dfirctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h2), .pre_gb_pipe_en(1'b1));
            set_dfi_rdgb_mode      (DFIRGB_1TO1);
            set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h1),   .wck_oe_cycles(4'h1),   .ie_cycles(4'h2),       .re_cycles(4'h6), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0)); // RE extended to 6 cycles to confirm independent control on RE.
            set_dfi_clken_pext_cfg (.wr_clken_cycles(4'h7), .rd_clken_cycles(4'hF), .ca_clken_cycles(4'h3));
        end

        2 : begin
            //----------------------------------------------------------------------------------
            // Case2: DDR - DP 2to1 - egress DDR2to1 - freq ratio 1:1 -- "DDR Transaction"
            // ---------------------------------------------------------------------------------
            set_txdq_sdr_fc_dly   (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
            set_txdq_sdr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdq_sdr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3210) );

            set_txdqs_sdr_fc_dly  (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
            set_txdqs_sdr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3210) );

            set_txdq_ddr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdq_ddr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );
            set_txdqs_ddr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdqs_ddr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );

            //EGRESS_MODE 6:0 DEF=0x01 "Egress mode (one-hot) - 0: SDR, 1:DDR_2to1, 2:QDR_2to1, 3: ODR_2to1, 4:QDR_4to1, 5:ODR_4to1, 6: BSCAN ";
            set_dq_egress_mode    (.byte_sel(ALL),    .dq (8'd99), .mode('h02) );
            set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(8'd99), .mode('h02) );

            set_rx_gb             (.byte_sel(DQ_ALL),     .rgb_mode(DGB_2TO1_HF), .fgb_mode(FGB_2TO2),    .wck_mode(1'b0)); // DQS Loop back
            set_rx_gb             (.byte_sel(CA),         .rgb_mode(DGB_2TO1_HF), .fgb_mode(FGB_2TO2),    .wck_mode(1'b1)); // CK  Loop back
            set_tx_gb             (.byte_sel(ALL),        .tgb_mode(DGB_2TO1_HF), .wgb_mode(WGB_1TO1));

            //DFI Configuration
            set_dfiwrd_wdp_cfg     (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h0), .pre_gb_pipe_en(1'b0));
            set_dfiwrcctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfickctrl_wdp_cfg  (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfiwctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfiwenctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            //set_dfiwckctrl_wdp_cfg (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfirctrl_wdp_cfg   (.gb_mode(DFIWGB_2TO2), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfi_rdgb_mode      (DFIRGB_2TO2);
            set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h3),   .wck_oe_cycles(4'h1),   .ie_cycles(4'h2),       .re_cycles(4'h2), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0));
            set_dfi_clken_pext_cfg (.wr_clken_cycles(4'h7), .rd_clken_cycles(4'hF), .ca_clken_cycles(4'h3));
        end

        3 : begin
            //----------------------------------------------------------------------------------
            // Case3: DDR - DP 4to1 - egress QDR2to1 -- "DFI 1:2 mode DDR Transaction"
            // ---------------------------------------------------------------------------------
            set_txdq_sdr_fc_dly   (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
            set_txdq_sdr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdq_sdr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h7654_3120) );

            set_txdqs_sdr_fc_dly  (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .fc_dly  ('h0000_0000) );
            set_txdqs_sdr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h7654_2020) );
            set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(0),  .rank_sel(RANK_ALL), .x_sel   ('h7654_3120) );// WCK
            set_txdqs_sdr_x_sel   (.byte_sel(ALL),    .dqs(1),  .rank_sel(RANK_ALL), .x_sel   ('h7654_3120) );// DQS/Parity

            set_txdq_ddr_pipe_en  (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdq_ddr_x_sel    (.byte_sel(ALL),    .dq (99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );
            set_txdqs_ddr_pipe_en (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .pipe_en ('h0000_0000) );
            set_txdqs_ddr_x_sel   (.byte_sel(ALL),    .dqs(99), .rank_sel(RANK_ALL), .x_sel   ('h0000_3210) );

            //EGRESS_MODE 6:0 DEF=0x02 "Egress mode (one-hot) - 0:SDR, 1:DDR_2to1, 2:QDR_2to1, 3: ODR_2to1, 4:QDR_4to1, 5:ODR_4to1, 6:BSCAN";
            set_dq_egress_mode    (.byte_sel(ALL),    .dq (99), .mode('h04) );
            set_dqs_egress_mode   (.byte_sel(ALL),    .dqs(99), .mode('h04) );

            set_rx_gb             (.byte_sel(DQ_ALL),     .rgb_mode (DGB_4TO1_HF), .fgb_mode(FGB_4TO4),  .wck_mode(1'b0)); // DQS Loop back
            set_rx_gb             (.byte_sel(CA),         .rgb_mode (DGB_4TO1_HF), .fgb_mode(FGB_4TO4),   .wck_mode(1'b1)); // CK  Loop back
            set_tx_gb             (.byte_sel(ALL),        .tgb_mode (DGB_4TO1_HF), .wgb_mode(WGB_1TO1));

            //DFI Configuration
            set_dfiwrd_wdp_cfg     (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h0), .pre_gb_pipe_en(1'b0));
            set_dfiwrcctrl_wdp_cfg (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfickctrl_wdp_cfg  (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfiwctrl_wdp_cfg   (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfiwenctrl_wdp_cfg (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            //set_dfiwckctrl_wdp_cfg (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfirctrl_wdp_cfg   (.gb_mode(DFIWGB_4TO4), .gb_pipe_dly(2'h3), .pre_gb_pipe_en(1'b1));
            set_dfi_rdgb_mode      (DFIRGB_4TO4);
            set_dfi_paden_pext_cfg (.wrd_oe_cycles(4'h2),   .wck_oe_cycles(4'h1),      .ie_cycles(4'h2),       .re_cycles(4'h2), .ren_cycles(4'h0), .wrd_en_cycles(4'h0), .rcs_cycles(4'h0));
            set_dfi_clken_pext_cfg (.wr_clken_cycles(4'h7), .rd_clken_cycles(4'hF), .ca_clken_cycles(4'h3));
        end 
    endcase

    sw_csp_byte_sync();
    set_dfi_wdata_clr;
    set_dfi_rdata_clr;
    set_dfibuf_ts_cfg(.en(1'b1), .rst(1'b0));
    wait_hclk (10);
    set_dfibuf_ts_cfg(.en(1'b0), .rst(1'b1));

    //----------------------------------------------------------------------------------
    // Case4: DFI 1:4 mode - DDR - DP 4to1 - egress QDR2to1
    // ---------------------------------------------------------------------------------
    #100ns;
    end
endtask
