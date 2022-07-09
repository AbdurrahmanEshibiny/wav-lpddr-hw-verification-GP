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