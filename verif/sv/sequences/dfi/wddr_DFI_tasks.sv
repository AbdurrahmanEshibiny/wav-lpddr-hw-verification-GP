// `include "DFI/DFI_agent/wav_DFI_transfer.sv"

task automatic set_dfi_phymstr_req;
    input wav_DFI_phymstr_transfer trans;
    begin
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_REQ_OVR, 1'b1);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_REQ_VAL, trans.req);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_CS_STATE, trans.cs_state);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_STATE_SEL, trans.state_sel);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_CFG, SW_TYPE, trans._type);
    end
endtask

task automatic get_dfi_phymstr_ack;
    output logic val;
    begin
        `CSR_RDF1(DDR_DFI_OFFSET,DDR_DFI_PHYMSTR_IF_STA, ACK, val);
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

task t_dfi_phyupd;
        output int err;
        logic ack = 0, req = 0;
        wav_DFI_update_transfer trans;
    begin
        `uvm_info(get_name(), "starting t_dfi_phyupd", UVM_MEDIUM);

        trans = new();
        err = 0;
        #1us;
        `uvm_info(get_name(), "calling ddr_boot", UVM_MEDIUM);
        ddr_boot(err);
        
        `uvm_info(get_name(), "starting t_dfi_phyupd main body", UVM_MEDIUM);
        assert(trans.randomize());
        `uvm_info(get_name(), "Randomized the phyupd trans HIGH", UVM_MEDIUM);
        trans.req = 1;
        trans.print();
        
        `uvm_info(get_name(), "driving the phyupd trans HIGH", UVM_MEDIUM);
        set_dfi_phyupd_req(trans);
        do begin
            get_dfi_phyupd_ack(ack);
        end while (!ack);
        `uvm_info(get_name(), $psprintf("ack = %0d", ack), UVM_MEDIUM);     
        
        trans.req = 0;
        `uvm_info(get_name(), "driving the phyupd req to LOW", UVM_MEDIUM);
        set_dfi_phyupd_req(trans);

        `uvm_info(get_name(), "overriding phyupd event to HIGH", UVM_MEDIUM);
        `CSR_WRF2(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, 
                    SW_EVENT_OVR, SW_EVENT_VAL,
                    1'b1, 1'b1);
        do begin
            get_dfi_phyupd_req(req);
        end while (req);
        `uvm_info(get_name(), $psprintf("req = %0d", req), UVM_MEDIUM);

        `uvm_info(get_name(), "overriding phyupd event to LOW", UVM_MEDIUM);
        `CSR_WRF2(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, 
                    SW_EVENT_OVR, SW_EVENT_VAL,
                    1'b1, 1'b0);
        #10ns;

        `uvm_info(get_name(), "DFI phyupd test completed!!!!!!!!", UVM_MEDIUM);
    end
 endtask

task t_dfi_phymstr;
    output int err;
    logic ack;
    wav_DFI_phymstr_transfer trans;
    begin
        `uvm_info(get_name(), "starting t_dfi_phymstr", UVM_MEDIUM);   
        #1us;

        `uvm_info(get_name(), "calling ddr_boot", UVM_MEDIUM);
        ddr_boot(err);  
        
        `uvm_info(get_name(), "starting t_dfi_phymstr body", UVM_MEDIUM);     
        trans = new();
        assert(trans.randomize());
        trans.req = 1;
        trans.print();
        err = 0;
        `uvm_info(get_name(), "driving the phymstr trans HIGH", UVM_MEDIUM);
        set_dfi_phymstr_req(trans);
        do begin
            get_dfi_phymstr_ack(ack);
        end while (!ack);
        trans.req = 0;
        `uvm_info(get_name(), "driving the phymstr trans LOW", UVM_MEDIUM);
        set_dfi_phymstr_req(trans);

        #10ns;

        $display("DFI phymstr test completed!!!!!!!!");
    end
endtask