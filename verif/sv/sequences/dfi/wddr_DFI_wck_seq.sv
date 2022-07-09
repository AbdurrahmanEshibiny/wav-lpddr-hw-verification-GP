typedef struct packed {
    // bit                  i_dfi_cke_p0;
    // bit                  i_dfi_cke_p1;
    // bit                  i_dfi_cke_p2;
    // bit                  i_dfi_cke_p3;
    // bit                  i_dfi_cs_p0;
    // bit                  i_dfi_cs_p1;
    // bit                  i_dfi_cs_p2;
    // bit                  i_dfi_cs_p3;
    bit                  i_dfi_dram_clk_disable_p0;
    bit                  i_dfi_dram_clk_disable_p1;
    bit                  i_dfi_dram_clk_disable_p2;
    bit                  i_dfi_dram_clk_disable_p3;
 
    // // bit                      i_dfi_parity_in_p0,
    // // bit                      i_dfi_parity_in_p1,
    // // bit                      i_dfi_parity_in_p2,
    // // bit                      i_dfi_parity_in_p3,
    // bit                          i_dfi_wrdata_cs_p0;
    // bit /*[1:0]*/                i_dfi_wrdata_cs_p1;
    // bit /*[1:0]*/                i_dfi_wrdata_cs_p2;
    // bit /*[1:0]*/                i_dfi_wrdata_cs_p3;
    // //bit [7:0]                i_dfi_wrdata_mask_p0,
    // // bit [7:0]                i_dfi_wrdata_mask_p1,
    // // bit [7:0]                i_dfi_wrdata_mask_p2,
    // // bit [7:0]                i_dfi_wrdata_mask_p3,
    // bit                      i_dfi_wrdata_en_p0;
    // bit                      i_dfi_wrdata_en_p1;
    // bit                      i_dfi_wrdata_en_p2;
    // bit                      i_dfi_wrdata_en_p3;
    // bit [1:0]                i_dfi_wck_cs_p0;
    // bit [1:0]                i_dfi_wck_cs_p1;
    // bit [1:0]                i_dfi_wck_cs_p2;
    // bit [1:0]                i_dfi_wck_cs_p3;
    // bit                      i_dfi_wck_en_p0;
    // bit                      i_dfi_wck_en_p1;
    // bit                      i_dfi_wck_en_p2;
    // bit                      i_dfi_wck_en_p3;
    // bit [1:0]                i_dfi_wck_toggle_p0;
    // bit [1:0]                i_dfi_wck_toggle_p1;
    // bit [1:0]                i_dfi_wck_toggle_p2;
    // bit [1:0]                i_dfi_wck_toggle_p3;
} wck_control;

class wck_c;
    randc wck_control values;
endclass //wck_c

class wddr_DFI_wck_seq extends wddr_base_seq;
    virtual wav_DFI_if vif;
    virtual gp_LPDDR5_channel_intf ch0_vif;
    virtual gp_LPDDR5_channel_intf ch1_vif;

    function new(string name="wddr_DFI_wck_seq");
        super.new(name);
    endfunction

    `uvm_object_utils(wddr_DFI_wck_seq)

    task automatic drive_wc(wck_control item);

    
        vif.dram_clk_disable[0] <= item.i_dfi_dram_clk_disable_p0;
        vif.dram_clk_disable[1] <= item.i_dfi_dram_clk_disable_p1;
        vif.dram_clk_disable[2] <= item.i_dfi_dram_clk_disable_p2;
        vif.dram_clk_disable[3] <= item.i_dfi_dram_clk_disable_p3;

        // vif.wrdata_cs[0] <= item.i_dfi_wrdata_cs_p0;
        // vif.wrdata_cs[1] <= item.i_dfi_wrdata_cs_p1;
        // vif.wrdata_cs[2] <= item.i_dfi_wrdata_cs_p2;
        // vif.wrdata_cs[3] <= item.i_dfi_wrdata_cs_p3;
    
        // vif.wrdata_en[0] <= item.i_dfi_wrdata_en_p0;
        // vif.wrdata_en[1] <= item.i_dfi_wrdata_en_p1;
        // vif.wrdata_en[2] <= item.i_dfi_wrdata_en_p2;
        // vif.wrdata_en[3] <= item.i_dfi_wrdata_en_p3;
    
    

    endtask //automatic

    function bit any_signal();
        return ch0_vif.dq0_wck_t != 'z || 
        ch0_vif.dq1_wck_t != 'z ||
        ch0_vif.dq0_wck_c != 'z || 
        ch0_vif.dq1_wck_c != 'z ||

        ch1_vif.dq0_wck_t != 'z || 
        ch1_vif.dq1_wck_t != 'z ||
        ch1_vif.dq0_wck_c != 'z || 
        ch1_vif.dq1_wck_c != 'z;
    endfunction

    virtual task body();
		bit [$bits(item.values)-1 : 0] end_val;
        bit err;
        wck_c item;
        // freqRatio = 2;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt <= %d ", err_cnt));
        end
        // config_vips(200,2);
        set_dfi_wck_mode(1);
        set_dfi_rdout_mode(1, 1);
        set_dfi_ca_rddata_en (.en(1'b1));  // Enable CA RDDATA en for CA loopback.


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




        `CSR_WRF1(DDR_DFICH0_OFFSET,DDR_DFICH_TOP_1_CFG,RDATA_ENABLE, 1);
        // phy_bringup(err);
        item = new;
		end_val = ~end_val;
        if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif)) begin
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".DFI_vif"});
        end
        if(!uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch0_vif", ch0_vif)) begin
			`uvm_fatal("gp_LPDDR5_monitor", "Failed to get virtual interface from config db")
        end
        if(!uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch1_vif", ch1_vif)) begin
			`uvm_fatal("gp_LPDDR5_monitor", "Failed to get virtual interface from config db")
		end

        repeat(50) @(posedge vif.clock);

		/*
        @(posedge vif.clock);
        vif.cke[0]  <= 2'b01;
        vif.cs[0]	<= 2'b01;
        vif.cs[2]	<= 2'b01;
        vif.dram_clk_disable[0] <= 0;
        vif.dram_clk_disable[1] <= 1;
        vif.dram_clk_disable[2] <= 1;
        vif.dram_clk_disable[3] <= 1;
		
        vif.wck_cs[0] <= 2'b01;
        vif.wck_cs[1] <= 2'b01;
        vif.wck_cs[2] <= 2'b01;
        vif.wck_cs[3] <= 2'b01;

		// p0 p1 p2 p3
		// 01 01 01 01 no use
		// 01 00 00 01 (fast toggle) or static with c == 1
		// 01 00 00 00
        vif.wck_en[0] <= 1;
        vif.wck_en[1] <= 0;
        vif.wck_en[2] <= 0;
        vif.wck_en[3] <= 1;
        */
        
        for (item.values = 0; item.values < end_val; ++item.values)  begin
            //assert(item.randomize());
			// item.values
            `uvm_info(get_name(), $psprintf("Trying values %0h", item.values), UVM_MEDIUM);            
            drive_wc(item.values);
            repeat(50) @(posedge vif.clock);
            // if (any_signal()) begin
            //    `uvm_info(get_name(), "FINALLY!!!!!!!!!!!!!!!!!!!!!!!!!!", UVM_MEDIUM);                
            //     // break;
            // end
        end
        
        
		`uvm_info(get_name(), $psprintf("Trying values %0h", item.values), UVM_MEDIUM);            
        drive_wc(item.values);
        //repeat(20) @(posedge vif.clock);

        /*
        `uvm_info(get_name(), $psprintf("wck st = %0h", WCKT_SL), UVM_MEDIUM);
        `uvm_info(get_name(), $psprintf("wck sh = %0h", WCKT_SH), UVM_MEDIUM);
        `uvm_info(get_name(), $psprintf("wck t = %0h", WCKT_T), UVM_MEDIUM);
        `uvm_info(get_name(), $psprintf("wck ft = %0h", WCKT_FT), UVM_MEDIUM);
		*/
    endtask : body

endclass