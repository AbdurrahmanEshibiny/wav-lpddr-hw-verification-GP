`include "DFI/DFI_agent/wav_DFI_transfer.sv"

task set_dfi_phymstr_req;
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
    // import wav_DFI_pkg::wav_DFI_update_transfer;
    input wav_DFI_update_transfer trans;
    begin
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, SW_REQ_OVR, 1'b1);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, SW_REQ_VAL, trans.req);
        `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_CFG, SW_TYPE, trans._type);
    end
endtask

task automatic get_dfi_phyupd_ack;
    output logic val;
    begin
        `CSR_RDF1(DDR_DFI_OFFSET,DDR_DFI_PHYUPD_IF_STA, ACK, val);
    end
endtask

task t_dfi_phyupd;
        output int err;
        logic ack;
        wav_DFI_update_transfer trans;
    begin
        // import wav_DFI_pkg::wav_DFI_update_transfer;
        trans = new();
        err = 0;
        #1us;

        ddr_boot(err);

        assert(trans.randomize());
        trans.req = 1;
        set_dfi_phyupd_req(trans);
        do begin
            get_dfi_phyupd_ack(ack);
        end while (!ack);
        
        set_dfi_phyupd_req(trans);

        #10ns;

        $display("DFI phyupd test completed!!!!!!!!");
    end
 endtask

task t_dfi_phymstr;
    output int err;
    logic ack;
    begin
        // import wav_DFI_pkg::wav_DFI_phymstr_transfer;
        wav_DFI_phymstr_transfer trans;
        trans = new();
        assert(trans.randomize());
        trans.req = 1;
        err = 0;
        #1us;

        ddr_boot(err);

        set_dfi_phymstr_req(trans);
        do begin
            get_dfi_phymstr_ack(ack);
        end while (!ack);
        trans.req = 0;
        set_dfi_phymstr_req(trans);

        #10ns;

        $display("DFI phymstr test completed!!!!!!!!");
    end
endtask