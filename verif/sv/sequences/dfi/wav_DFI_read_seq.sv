/*
class base_test extends uvm_test;
    task run_phase();
        run wavious_base_sequence;
    endtask;
endclass

class <your_test_name> extends base_test;
    task run_phase();
        super.run_phase();
        run your_sequence_name;
    endtask;
endclass 

class dfi_<seq_name>_seq extends uvm_sequence #(<your_trans_type>);

endclass
*/


// `include "wav_DFI_transfer.sv"


/*
class dfi_rd_seq extends wddr_base_seq; // uvm_sequence #(wav_DFI_write_transfer);

`uvm_object_utils(dfi_rd_seq)

    function new(string name = "dfi_rd_seq");
        super.new(name);
    endfunction

    virtual task body();
        int err;
        dfi_cmd_t cmd_;

        DFI_rd_seq_item rd_seq_item;
        rd_seq_item = DFI_rd_seq_item::type_id::create("rd_seq_item");

        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        start_item(rd_seq_item);
        // TODO: We should try to encapsulate these things
        // in the rd_seq_item class itself
        rd_seq_item.data_len = 256;
        rd_seq_item.trddata_en = cfg.trddata_en;
        rd_seq_item.tphy_rdcslat = cfg.tphy_rdcslat;
        
        rd_seq_item.randomize(); // with {rd_seq_item.data_len == 256};

        cmd_ = DFI_ACT1;
        cmd_[6:3] = rd_seq_item.address.row[17:14];
        cmd_[10:7] = rd_seq_item.address.ba;
        cmd_[13:11] = rd_seq_item.address.row[13:11];
        
        rd_seq_item.preamble.push_back(cmd_);
        
        cmd_ = DFI_ACT2;
        cmd_[6:3] = rd_seq_item.address.row[10:7];
        cmd_[13:7] = rd_seq_item.address.row[6:0];


        rd_seq_item.preamble.push_back(cmd_);

        cmd_ = DFI_CAS_RD;

        rd_seq_item.preamble.push_back(cmd_);
        
        rd_seq_item.is_last = 1;
        rd_seq_item.final_en = 2;

        finish_item(rd_seq_item);

        // uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
    endtask

endclass

*/
class dfi_rd_seq extends wddr_base_seq; // uvm_sequence #(wav_DFI_write_transfer);

    virtual gp_LPDDR5_channel_intf ch0,ch1;
    `uvm_object_utils(dfi_rd_seq)

    function new(string name = "dfi_rd_seq");
        super.new(name);
    endfunction

    virtual task body();
        int err;
        
        dfi_cmd_t cmd_;
        DFI_rd_seq_item rd_seq_data;
        DFI_rd_slice slice;
        DFI_rd_stream_seq_item rd_seq_item;

        int slice_i;
        bit phase_i;
        
        rd_seq_data = DFI_rd_seq_item::type_id::create("rd_seq_data");
        slice = DFI_rd_slice::type_id::create("rd_slice");
        rd_seq_item = DFI_rd_stream_seq_item::type_id::create("rd_seq_item");

        uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch0_vif", ch0);
        uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch1_vif", ch1);
        
        super.body();
        ddr_boot(err);
        config_vips(806, 1);
        set_dfi_ca_rddata_en(1);
        set_dfi_rdout_mode(1,1);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        start_item(rd_seq_item);
        // TODO: We should try to encapsulate these things
        // in the rd_seq_item class itself
        ch0.DQ = $random(5);
        ch1.DQ = $random(8);
        rd_seq_data.randomize();
        rd_seq_data.data_len = 10; // can be randomized

        cmd_ = DFI_ACT1;
        cmd_[6:3] = rd_seq_data.address.row[17:14];
        cmd_[10:7] = rd_seq_data.address.ba;
        cmd_[13:11] = rd_seq_data.address.row[13:11];

        rd_seq_data.preamble.push_back(cmd_);
        
        cmd_ = DFI_ACT2;
        cmd_[6:3] = rd_seq_data.address.row[10:7];
        cmd_[13:7] = rd_seq_data.address.row[6:0];

        rd_seq_data.preamble.push_back(cmd_);

        cmd_ = DFI_CAS_RD;

        rd_seq_data.preamble.push_back(cmd_);

        cmd_ = DFI_RD16;
        cmd_[6:4] = rd_seq_data.address.col[5:3];
        cmd_[10:7] = rd_seq_data.address.ba;
        cmd_[12:11] = rd_seq_data.address.col[2:1];
        cmd_[3] = rd_seq_data.address.col[0];
        cmd_[13] = 1;

        // TODO: rename the preamble to reflect it contains all bus contents
        // or delete the RD16 instruction so the preamble name makes sense
        rd_seq_data.preamble.push_back(cmd_);
        
        if(!$cast(slice, slice.clone()))
            `uvm_error(get_name(), "Failed to cast slice")
        rd_seq_item.slice_q.push_back(slice);
        
        if(!$cast(slice, slice.clone()))
            `uvm_error(get_name(), "Failed to cast slice")
        rd_seq_item.slice_q.push_back(slice);

        // rd_seq_item.slice_q.push_back(slice.clone());

        rd_seq_item.slice_q[0].address[0] = rd_seq_data.preamble[0];
        rd_seq_item.slice_q[0].address[1] = rd_seq_data.preamble[1];
        rd_seq_item.slice_q[1].address[0] = rd_seq_data.preamble[2];
        rd_seq_item.slice_q[1].address[1] = rd_seq_data.preamble[3]; // RD16

        // CA bus DONE!

        // adjust en signal
        slice_i = 1;
        phase_i = 1;
        
        repeat (cfg.trddata_en) begin
            rd_seq_item.slice_q[slice_i].rddata_en[phase_i] = 0;
            phase_i++;
            if (!phase_i) begin
                slice_i++;
            end
            if (slice_i >= rd_seq_item.slice_q.size()) begin
                if(!$cast(slice, slice.clone()))
                    `uvm_error(get_name(), "Failed to cast slice")
                rd_seq_item.slice_q.push_back(slice);

            end
        end

        repeat (rd_seq_data.data_len) begin
            rd_seq_item.slice_q[slice_i].rddata_en[phase_i] = 1;
            phase_i++;
            if (!phase_i) begin
                slice_i++;
            end
            if (slice_i >= rd_seq_item.slice_q.size()) begin
                if(!$cast(slice, slice.clone()))
                    `uvm_error(get_name(), "Failed to cast slice")
                rd_seq_item.slice_q.push_back(slice);
            end
        end

        // assign last 2 en bits to zero
        repeat (2) begin
            rd_seq_item.slice_q[slice_i].rddata_en[phase_i] = 0;
            phase_i++;
            if (!phase_i) begin
                slice_i++;
            end
            if (slice_i >= rd_seq_item.slice_q.size()) begin
                if(!$cast(slice, slice.clone()))
                    `uvm_error(get_name(), "Failed to cast slice")
                rd_seq_item.slice_q.push_back(slice);
            end
        end
        

        // adjust cs signal
        slice_i = 1;
        phase_i = 1;

        repeat (cfg.tphy_rdcslat) begin
            phase_i++;
            if (!phase_i) begin
                slice_i++;
            end
            if (slice_i >= rd_seq_item.slice_q.size()) begin
                if(!$cast(slice, slice.clone()))
                    `uvm_error(get_name(), "Failed to cast slice")
                rd_seq_item.slice_q.push_back(slice);
            end
        end

        repeat (rd_seq_data.data_len) begin
            rd_seq_item.slice_q[slice_i].rddata_cs[phase_i] = rd_seq_data.address.cs;
            phase_i++;
            if (!phase_i) begin
                slice_i++;
            end
            if (slice_i >= rd_seq_item.slice_q.size()) begin
                if(!$cast(slice, slice.clone()))
                    `uvm_error(get_name(), "Failed to cast slice")
                rd_seq_item.slice_q.push_back(slice);
            end
        end



        slice_i = 2;
        // assign rest of the CA to NOP
        while (slice_i < rd_seq_item.slice_q.size()) begin
            rd_seq_item.slice_q[slice_i].address[0] = DFI_NOP;
            rd_seq_item.slice_q[slice_i].address[1] = DFI_NOP;
            slice_i++;
        end

        slice_i = 0;
        // assign cs
        while (slice_i < rd_seq_item.slice_q.size()) begin
            rd_seq_item.slice_q[slice_i].cs[0] = rd_seq_data.address.cs;
            rd_seq_item.slice_q[slice_i].cs[1] = rd_seq_data.address.cs;
            slice_i++;
        end

        finish_item(rd_seq_item);

        // uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
    endtask

endclass
