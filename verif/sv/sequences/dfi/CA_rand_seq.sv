`include "genena_randseq.sv"

class ca_rand_seq extends wddr_base_seq; // uvm_sequence #(wav_DFI_write_transfer);

    // virtual gp_LPDDR5_channel_intf ch0,ch1;

    `uvm_object_utils(ca_rand_seq)

    function new(string name = "ca_rand_seq");
        super.new(name);
    endfunction

    virtual task body();
        int err;
        
        dfi_cmd_t cmd_;
        DFI_rd_seq_item rd_seq_data;
        DFI_rd_slice slice;
        DFI_rd_stream_seq_item rd_seq_item;

        seqitem rand_gen;

        bit [13:0] cmd_slice;
        bit [13:0] cmd_qq[$];


        int slice_i;
        bit phase_i;
        
        rd_seq_data = DFI_rd_seq_item::type_id::create("rd_seq_data");
        slice = DFI_rd_slice::type_id::create("rd_slice");
        rd_seq_item = DFI_rd_stream_seq_item::type_id::create("rd_seq_item");

        rand_gen = new();

        // if (!uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch0_vif", ch0)) begin
        //     `uvm_error(get_name(),"Cannot get CH0 interface")
        // end
        // if (!uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch1_vif", ch1)) begin
        //     `uvm_error(get_name(),"Cannot get CH1 interface")
        // end
        
        super.body();

        ddr_boot(err);
        // phy_bringup(err);
        config_vips(vcoFreq1, freqRatio);
        set_freq_ratio(2);
        // gb_set = 1;

        // t_mcu_boot(err_cnt);
        set_dfi_ca_rddata_en(1); // included in the functions
        // set_dfi_rdout_mode(1,1);
        set_dfi_wck_mode(1);
        
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        start_item(rd_seq_item);
        // TODO: We should try to encapsulate these things
        // in the rd_seq_item class itself
        // ch0.DQ = $random(5);
        // ch1.DQ = $random(8);

        rand_gen.generate_seq(2000);
        if (rand_gen.cmd_queue.size() != rand_gen.BA_queue.size()) begin
            `uvm_error(get_name(), "cmd and BA queues are not of equal length!")
        end

        foreach (rand_gen.cmd_queue[i]) begin
            if (
                rand_gen.cmd_queue[i] == _CAS_FS ||
                rand_gen.cmd_queue[i] == _CAS_WR ||
                rand_gen.cmd_queue[i] == _CAS_FS ||
                rand_gen.cmd_queue[i] == _CAS_OFF ||
                rand_gen.cmd_queue[i] == _MPC ||
                rand_gen.cmd_queue[i] == _MRW1 ||
                rand_gen.cmd_queue[i] == _MRW2 ||
                rand_gen.cmd_queue[i] == _MRR ||
                rand_gen.cmd_queue[i] == _WFF ||
                rand_gen.cmd_queue[i] == _RFF
            ) begin
                cmd_slice [13:7] = 7'b0; 
            end else begin
                cmd_slice [13:11] = 3'b0;
                cmd_slice [10:7] = rand_gen.BA_queue[i][3:0];
            end
            cmd_slice [6:0] = rand_gen.cmd_queue[i][6:0];
            cmd_qq.push_back(cmd_slice);
        end

        foreach (cmd_qq[i]) begin
            if(!$cast(slice, slice.clone()))
                `uvm_error(get_name(), "Failed to cast slice")
            rd_seq_item.slice_q.push_back(slice);
            rd_seq_item.slice_q[$].address[0] = cmd_qq[i];
        end

        // rd_seq_data.randomize();
        // rd_seq_data.data_len = 10; // can be randomized

        // cmd_ = DFI_ACT1;
        // cmd_[6:3] = rd_seq_data.address.row[17:14];
        // cmd_[10:7] = rd_seq_data.address.ba;
        // cmd_[13:11] = rd_seq_data.address.row[13:11];

        // rd_seq_data.preamble.push_back(cmd_);
        
        // cmd_ = DFI_ACT2;
        // cmd_[6:3] = rd_seq_data.address.row[10:7];
        // cmd_[13:7] = rd_seq_data.address.row[6:0];

        // rd_seq_data.preamble.push_back(cmd_);

        // cmd_ = DFI_CAS_RD;

        // rd_seq_data.preamble.push_back(cmd_);

        // cmd_ = DFI_RD16;
        // cmd_[6:4] = rd_seq_data.address.col[5:3];
        // cmd_[10:7] = rd_seq_data.address.ba;
        // cmd_[12:11] = rd_seq_data.address.col[2:1];
        // cmd_[3] = rd_seq_data.address.col[0];
        // cmd_[13] = 1;

        // // TODO: rename the preamble to reflect it contains all bus contents
        // // or delete the RD16 instruction so the preamble name makes sense
        // rd_seq_data.preamble.push_back(cmd_);
        
        // if(!$cast(slice, slice.clone()))
        //     `uvm_error(get_name(), "Failed to cast slice")
        // rd_seq_item.slice_q.push_back(slice);
        
        // if(!$cast(slice, slice.clone()))
        //     `uvm_error(get_name(), "Failed to cast slice")
        // rd_seq_item.slice_q.push_back(slice);

        // // rd_seq_item.slice_q.push_back(slice.clone());

        // rd_seq_item.slice_q[0].address[0] = rd_seq_data.preamble[0];
        // rd_seq_item.slice_q[0].address[1] = rd_seq_data.preamble[1];
        // rd_seq_item.slice_q[1].address[0] = rd_seq_data.preamble[2];
        // rd_seq_item.slice_q[1].address[1] = rd_seq_data.preamble[3]; // RD16

        // // CA bus DONE!

        // // adjust part1 of wck_toggle
        // // 3 because there were three instructions before RD16
        // // slice_i = 0;
        // // phase_i = 0;
        // // repeat (3) begin
        // //    rd_seq_item.slice_q[slice_i].wck_toggle[phase_i] = 2'b00;
        // //    phase_i++;
        // //     if (!phase_i) begin
        // //         slice_i++;
        // //     end
        //     // this part is not needed since we know there are enough slices
        //     // if (slice_i >= rd_seq_item.slice_q.size()) begin
        //     //    if(!$cast(slice, slice.clone()))
        //     //        `uvm_error(get_name(), "Failed to cast slice")
        //     //     rd_seq_item.slice_q.push_back(slice);
        //     // end
        // // end

        // // adjust rddata_en & pt2 of wck_toggle
        // slice_i = 1;
        // phase_i = 1;
        
        // repeat (cfg.trddata_en) begin
        //     rd_seq_item.slice_q[slice_i].rddata_en[phase_i] = 0;
        //     rd_seq_item.slice_q[slice_i].wck_toggle[phase_i] = 0;
        //     phase_i++;
        //     if (!phase_i) begin
        //         slice_i++;
        //     end
        //     if (slice_i >= rd_seq_item.slice_q.size()) begin
        //         if(!$cast(slice, slice.clone()))
        //             `uvm_error(get_name(), "Failed to cast slice")
        //         rd_seq_item.slice_q.push_back(slice);

        //     end
        // end

        // // assign rddata_en & pt3 of wck_toggle
        // repeat (rd_seq_data.data_len) begin
        //     rd_seq_item.slice_q[slice_i].rddata_en[phase_i] = 1;
        //     rd_seq_item.slice_q[slice_i].wck_toggle[phase_i] = 2'b11;
        //     phase_i++;
        //     if (!phase_i) begin
        //         slice_i++;
        //     end
        //     if (slice_i >= rd_seq_item.slice_q.size()) begin
        //         if(!$cast(slice, slice.clone()))
        //             `uvm_error(get_name(), "Failed to cast slice")
        //         rd_seq_item.slice_q.push_back(slice);
        //     end
        // end

        // // assign last 2 en bits to zero
        // // SUPPOSEDLY no need to assign it since the default
        // // value of bits is zero
        // repeat (2) begin
        //     rd_seq_item.slice_q[slice_i].rddata_en[phase_i] = 0;
        //     rd_seq_item.slice_q[slice_i].wck_toggle[phase_i] = 0;
        //     phase_i++;
        //     if (!phase_i) begin
        //         slice_i++;
        //     end
        //     if (slice_i >= rd_seq_item.slice_q.size()) begin
        //         if(!$cast(slice, slice.clone()))
        //             `uvm_error(get_name(), "Failed to cast slice")
        //         rd_seq_item.slice_q.push_back(slice);
        //     end
        // end
        

        // // adjust cs signal
        // slice_i = 1;
        // phase_i = 1;

        // repeat (cfg.tphy_rdcslat) begin
        //     phase_i++;
        //     if (!phase_i) begin
        //         slice_i++;
        //     end
        //     if (slice_i >= rd_seq_item.slice_q.size()) begin
        //         if(!$cast(slice, slice.clone()))
        //             `uvm_error(get_name(), "Failed to cast slice")
        //         rd_seq_item.slice_q.push_back(slice);
        //     end
        // end

        // repeat (rd_seq_data.data_len) begin
        //     rd_seq_item.slice_q[slice_i].rddata_cs[phase_i] = rd_seq_data.address.cs;
        //     phase_i++;
        //     if (!phase_i) begin
        //         slice_i++;
        //     end
        //     if (slice_i >= rd_seq_item.slice_q.size()) begin
        //         if(!$cast(slice, slice.clone()))
        //             `uvm_error(get_name(), "Failed to cast slice")
        //         rd_seq_item.slice_q.push_back(slice);
        //     end
        // end


        // slice_i = 2;
        // // assign rest of the CA to NOP
        // while (slice_i < rd_seq_item.slice_q.size()) begin
        //     rd_seq_item.slice_q[slice_i].address[0] = DFI_NOP;
        //     rd_seq_item.slice_q[slice_i].address[1] = DFI_NOP;
        //     slice_i++;
        // end

        // // add a few empty slices to account for the need
        // // for the PHY to start capturing data on CA
        // // and assign the CA of those slices to NOP
        // repeat (4) begin
        //     if(!$cast(slice, slice.clone()))
        //         `uvm_error(get_name(), "Failed to cast slice")
        //     rd_seq_item.slice_q.push_front(slice);
        //     rd_seq_item.slice_q[0].address[0] = DFI_NOP;
        //     rd_seq_item.slice_q[0].address[1] = DFI_NOP;
        // end

        // slice_i = 0;
        // // adjust wck_en, cs and wck_cs
        // // -1 so last slice is equal to zero
        // while (slice_i < rd_seq_item.slice_q.size() - 1) begin
        //     rd_seq_item.slice_q[slice_i].wck_en[0] = 1'b1;
        //     rd_seq_item.slice_q[slice_i].wck_en[1] = 1'b1;

        //     rd_seq_item.slice_q[slice_i].cs[0] = rd_seq_data.address.cs;
        //     rd_seq_item.slice_q[slice_i].cs[1] = rd_seq_data.address.cs;

        //     rd_seq_item.slice_q[slice_i].wck_cs[0] = rd_seq_data.address.cs;
        //     rd_seq_item.slice_q[slice_i].wck_cs[1] = rd_seq_data.address.cs;
        //     slice_i++;
        // end
        // // disable wck_en, wck_cs & cs on the last slice
        // rd_seq_item.slice_q[slice_i].wck_en[0] = 0;
        // rd_seq_item.slice_q[slice_i].wck_en[1] = 0;

        // rd_seq_item.slice_q[slice_i].cs[0] = 0;
        // rd_seq_item.slice_q[slice_i].cs[1] = 0;

        // rd_seq_item.slice_q[slice_i].wck_cs[0] = 0;
        // rd_seq_item.slice_q[slice_i].wck_cs[1] = 0;
        
        finish_item(rd_seq_item);
    endtask

endclass
