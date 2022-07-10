// import wav_DFI_pkg::*;
`include "wddr_config.sv"
`include "wav_DFI_transfer.sv"

class wav_DFI_driver extends uvm_driver;
// use default value to adhere to the wavious standard, not #(wav_DFI_transfer); 

    wav_DFI_vif vif;
    uvm_phase driver_run_phase;
    wddr_config cfg;
	
    `uvm_component_utils_begin(wav_DFI_driver)
    `uvm_component_utils_end

    function new (string name = "wav_DFI_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // function void connect_phase(uvm_phase phase);
        
    // endfunction

    virtual task run_phase(uvm_phase phase);
        driver_run_phase = phase;
        
        fork
            get_and_drive();
            respond_to_phyupd();
            respond_to_phymstr();
        join
    endtask
	
    virtual protected task get_and_drive();
        wav_DFI_transfer trans;
        forever begin
            `uvm_info(get_type_name(), "wav_DFI driver waiting for the next item", UVM_MEDIUM);
            seq_item_port.get_next_item(req);
			`uvm_info(get_type_name(), "wav_DFI driver received the next item", UVM_MEDIUM);
			
            $cast(rsp, req.clone());
            $cast(trans, req.clone());

            rsp.set_id_info(req);
            `uvm_info(get_type_name(),$psprintf("wav_DFI driver start driving transfer :\n%s", rsp.sprint()), UVM_MEDIUM);

            drive_transaction(rsp);
            `uvm_info(get_type_name(),$psprintf("wav_DFI driver done driving transfer :\n%s", rsp.sprint()), UVM_MEDIUM);

            seq_item_port.item_done();
            if (trans.is_rsp_required)
			    seq_item_port.put_response(rsp);
        end
      endtask

    /*should we drive the signal through sequencer*/
      
    //reset tasks
    task automatic reset_lp(bit is_ctrl);
        if (is_ctrl) begin
            vif.mp_drv.cb_drv.lp_ctrl_req <= 0; 
            vif.mp_drv.cb_drv.lp_ctrl_wakeup <= 0; 
        end
        else begin
            vif.mp_drv.cb_drv.lp_data_req <= 0; 
            vif.mp_drv.cb_drv.lp_data_wakeup <= 0; 
        end
        `uvm_info(get_name(), "done resetting lp", UVM_MEDIUM);  
    endtask

    //drive lp interface according to the specified transaction
    task automatic drive_lp(wav_DFI_lp_transfer trans);  
        `uvm_info(get_name(), "Driving lp", UVM_MEDIUM);  
        @(posedge vif.mp_drv.cb_drv) 
        if (trans.is_ctrl) begin 
            vif.mp_drv.cb_drv.lp_ctrl_req <= trans.req; 
            vif.mp_drv.cb_drv.lp_ctrl_wakeup <= trans.wakeup; 
        end 
        else begin         
            vif.mp_drv.cb_drv.lp_data_req <= trans.req;         
            vif.mp_drv.cb_drv.lp_data_wakeup <= trans.wakeup; 
        end
        `uvm_info(get_name(), "done driving lp", UVM_MEDIUM);  

        if (trans.cyclesCount > 0) begin
            repeat (trans.cyclesCount) @(posedge vif.mp_drv.cb_drv);
            reset_lp(trans.is_ctrl);
        end
        `uvm_info(get_name(), "done driving lp transaction", UVM_MEDIUM);  
    endtask                        
        
    //drive ctrlupd interface according to the specified transaction
    task automatic drive_ctrlupd(wav_DFI_update_transfer trans);   
		int timer = 0;
        `uvm_info(get_name(), "Driving ctrlupd", UVM_MEDIUM);              
        @(posedge vif.mp_drv.cb_drv)         
        if (trans.is_ctrl) begin
            vif.mp_drv.cb_drv.ctrlupd_req <= trans.req;       
            `uvm_info(get_name(), "done driving ctrlupd", UVM_MEDIUM);  
            // if (trans.cyclesCount > 0) begin
            
			`uvm_info(get_name(), "wait for ctrlupd_ack goes HIGH", UVM_MEDIUM);
			forever begin
				@(posedge vif.mp_drv.cb_drv);
				++timer;
				if (vif.mp_drv.cb_drv.ctrlupd_ack == 1)
					break;
			end
            //wait(vif.mp_drv.cb_drv.ctrlupd_ack == 1);   
			`uvm_info(get_name(), "wait for ctrlupd_ack goes LOW, or timer to goes off", UVM_MEDIUM);
            //wait(vif.mp_drv.cb_drv.ctrlupd_ack == 0);
			forever begin
				@(posedge vif.mp_drv.cb_drv);
				++timer;
				if (vif.mp_drv.cb_drv.ctrlupd_ack == 0 || timer >= trans.cyclesCount)
					break;
			end
			
			vif.mp_drv.cb_drv.ctrlupd_req <= 0;
			`uvm_info(get_name(), "done resetting ctrlupd", UVM_MEDIUM);  
            // repeat(trans.cyclesCount) @(posedge vif.mp_drv.cb_drv);
            // vif.mp_drv.cb_drv.ctrlupd_req <= 0;
            // `uvm_info(get_name(), "Done resetting ctrlupd", UVM_MEDIUM); 
        end
    endtask

    task automatic drive_write(wav_DFI_write_transfer trans);  
        
        vif.mp_drv.cb_drv.dram_clk_disable[0] <= trans.dram_clk_disable[0];
        vif.mp_drv.cb_drv.dram_clk_disable[1] <= trans.dram_clk_disable[1];
        vif.mp_drv.cb_drv.dram_clk_disable[2] <= trans.dram_clk_disable[2];
        vif.mp_drv.cb_drv.dram_clk_disable[3] <= trans.dram_clk_disable[3];
        
        vif.mp_drv.cb_drv.cke[0] <= trans.cke[0];
        vif.mp_drv.cb_drv.cke[1] <= trans.cke[1];
        vif.mp_drv.cb_drv.cke[2] <= trans.cke[2];
        vif.mp_drv.cb_drv.cke[3] <= trans.cke[3];
        
            
        vif.mp_drv.cb_drv.wck_cs[0] <= trans.wck_cs[0];
        vif.mp_drv.cb_drv.wck_cs[1] <= trans.wck_cs[1];
        vif.mp_drv.cb_drv.wck_cs[2] <= trans.wck_cs[2];
        vif.mp_drv.cb_drv.wck_cs[3] <= trans.wck_cs[3];

        vif.mp_drv.cb_drv.wck_en[0] <= trans.wck_en[0];
        vif.mp_drv.cb_drv.wck_en[1] <= trans.wck_en[1];
        vif.mp_drv.cb_drv.wck_en[2] <= trans.wck_en[2];
        vif.mp_drv.cb_drv.wck_en[3] <= trans.wck_en[3];
            
        vif.mp_drv.cb_drv.wck_toggle[0] <= trans.wck_toggle[0];
        vif.mp_drv.cb_drv.wck_toggle[1] <= trans.wck_toggle[1];
        vif.mp_drv.cb_drv.wck_toggle[2] <= trans.wck_toggle[2];
        vif.mp_drv.cb_drv.wck_toggle[3] <= trans.wck_toggle[3];
 
        vif.mp_drv.cb_drv.address[0] <= trans.address[0];
        vif.mp_drv.cb_drv.address[1] <= trans.address[1];
        vif.mp_drv.cb_drv.address[2] <= trans.address[2];
        vif.mp_drv.cb_drv.address[3] <= trans.address[3];
        
        vif.mp_drv.cb_drv.cs[0] <= trans.cs[0];
        vif.mp_drv.cb_drv.cs[1] <= trans.cs[1];
        vif.mp_drv.cb_drv.cs[2] <= trans.cs[2];
        vif.mp_drv.cb_drv.cs[3] <= trans.cs[3];
            
        vif.mp_drv.cb_drv.wrdata_en[0] <= trans.wrdata_en[0];
        vif.mp_drv.cb_drv.wrdata_en[1] <= trans.wrdata_en[1];
        vif.mp_drv.cb_drv.wrdata_en[2] <= trans.wrdata_en[2];
        vif.mp_drv.cb_drv.wrdata_en[3] <= trans.wrdata_en[3];

        vif.mp_drv.cb_drv.wrdata[0] <= trans.wrdata[0];
        vif.mp_drv.cb_drv.wrdata[1] <= trans.wrdata[1];
        vif.mp_drv.cb_drv.wrdata[2] <= trans.wrdata[2];
        vif.mp_drv.cb_drv.wrdata[3] <= trans.wrdata[3];

        vif.mp_drv.cb_drv.wrdata_cs[0] <= trans.wrdata_cs[0];
        vif.mp_drv.cb_drv.wrdata_cs[1] <= trans.wrdata_cs[1];
        vif.mp_drv.cb_drv.wrdata_cs[2] <= trans.wrdata_cs[2]; 
        vif.mp_drv.cb_drv.wrdata_cs[3] <= trans.wrdata_cs[3];

        vif.mp_drv.cb_drv.wrdata_mask[0] <= trans.wrdata_mask[0];
        vif.mp_drv.cb_drv.wrdata_mask[1] <= trans.wrdata_mask[1];
        vif.mp_drv.cb_drv.wrdata_mask[2] <= trans.wrdata_mask[2];
        vif.mp_drv.cb_drv.wrdata_mask[3] <= trans.wrdata_mask[3];
    endtask

    task automatic drive_status(wav_DFI_status_transfer trans);
        string msg;
        int tinit_start;

        foreach(vif.cb_drv.cke[i]) begin
            vif.cb_drv.cke[i] <= 2'b11;
            vif.cb_drv.dram_clk_disable[i] <= 0;
            // vif.cb_drv.cs[i] <= trans.address.cs;
            vif.cb_drv.reset_n[i] <= '1;
        end

        vif.cb_drv.init_start <= 0;
        vif.cb_drv.freq_fsp <= trans.freq_fsp;
        vif.cb_drv.freq_ratio <= trans.freq_ratio;
        vif.cb_drv.frequency <= trans.frequency;
        @(vif.cb_drv);

        while (!vif.cb_drv.init_complete) @(vif.cb_drv);
        vif.cb_drv.init_start <= 1;

        tinit_start = 1;

        while (tinit_start != 0) begin
            @(vif.cb_drv) begin
                if (vif.cb_drv.init_complete == 1'b0) begin
                    break;
                end
            end
            tinit_start++;
        end
        vif.cb_drv.init_start <= 0;

        if (tinit_start == 0) begin
            msg = "PHY rejects new freq setting";
        end else begin
            msg = $sformatf (
                "PHY accepts new freq setting, tinit_start = %0d", tinit_start);
        end
        // `uvm_info (get_name(), {msg, "\n", freq_details}, UVM_MEDIUM)
        trans.print();

        // need to drive dfi_cke and dfi_reset_n
        // until the dfi_init_complete signal is asserted.


        /*
        
        // FIXME: WE ARE TESTING FOR THE FREQUENCIES HERE
        // TODO: print the count of the timing if it succeeds
        */
    endtask

    // TODO: we need to declare variables for the current phase and the data
    // to be given to the signals on the command interface that are common
    // between read and write transactions (and any other transaction that
    // needs the command interface). These variables (could implemented as 
    // a struct) should be passed by reference as an input argument to the
    // drive_<sub_interface_name> task so that it can fill the struct
    // whenever the task needs to use the command interface. once the struct
    // is full (e.g., for a 4:1 system the struct contains 4 slices of command
    // interface signals) the task assigns the struct to the DFI interface. 
    // checking the fullness of the struct can be done by the current phase
    // variable.
    // Till now, the struct should consist of:
    // dfi_address, dfi_cke, dfi_cs,
    // dfi_dram_clk_disable, dfi_parity_in, dfi_reset

    // The above idea can be split into two main tasks:
    // task1: fills the command interface struct with the values it wants to
    // send
    // task2: whenever the struct has a size that is equal to or larger than
    // the frequency ratio. it assigns the values inside the struct to the
    // command interface. this can be used with other things as well

    // TODO: recheck that there are there are no other command interface
    // signals (other than the ones mentioned above) that are mentioned
    // in the DFI standard and implemented in the wavious design

    // TODO: we need to think about cases in ratioed systems when we want
    // to send multiple consecutive read instructions. the above idea
    // should solve it
/*
    task drive_cmd_2_1(dfi_cmd_t _cmd_);
        static bit phase;
        static bit [13:0] adrs [0:1];
        adrs [phase] = _cmd_;
        phase = phase + 1;
        if (!phase) begin
            @(vif.cb_drv) begin
                vif.cb_drv.address[0] <= adrs[0];
                vif.cb_drv.address[1] <= adrs[1];
                adrs[0] = 0;
                adrs[1] = 0;
            end
        end
    endtask

    task drive_rd_en(DFI_rd_seq_item trans);
        // works with 2:1 ONLY
        static bit phase;
        repeat (trans.trddata_en) begin
            // phase = phase + 1;
            phase = ~phase;
            if (!phase) begin
                @(vif.cb_drv);    
            end
        end
        // cycles needed for rddata_en to stay 1
        // some synchronization control could be needed here
        repeat (trans.data_len) begin
            vif.cb_drv.rddata_en[phase] <= 1;
            // phase = phase + 1;
            phase = ~phase;
            if (!phase) begin
                @(vif.cb_drv);
            end
        end

        repeat (trans.final_en) begin
            vif.cb_drv.rddata_en[phase] <= 0;
            // phase = phase + 1;
            phase = ~phase;
            if (!phase) begin
                @(vif.cb_drv);
            end  
        end
    endtask

    task drive_rd_cs(DFI_rd_seq_item trans);
        // works with 2:1 ONLY
        static bit phase;
        repeat (trans.tphy_rdcslat) begin
            // phase = phase + 1;
            phase = ~phase;
            if (!phase) begin
                @(vif.cb_drv);
            end
        end
        vif.cb_drv.rddata_cs[phase] <= trans.address.cs;
        // phase = phase + 1;
        phase = ~phase;
        if (!phase) begin
            @(vif.cb_drv);
        end
       
        if (trans.data_len > 1) begin
            vif.cb_drv.rddata_cs[phase] <= trans.address.cs;
            // phase = phase + 1;
            phase = ~phase;
            if (!phase) begin
                @(vif.cb_drv);
            end
        end
        
    endtask



    task automatic drive_read (DFI_rd_seq_item trans);
        // This works for 2:1 ONLY
        // TODO: dbi receive
        dfi_cmd_t cmd_;
        // if (!uvm_config_db#(wddr_config)::get(uvm_root::get(), "*", "cfg_obj", cfg))
        // begin
        //     `uvm_fatal(get_full_name(), "FAILED to get config obj");
        // end
        trans.print();

        foreach(vif.cb_drv.cke[i]) begin
            vif.cb_drv.cke[i] <= 2'b11;
            vif.cb_drv.dram_clk_disable[i] <= 0;
            vif.cb_drv.cs[i] <= trans.address.cs;
            vif.cb_drv.reset_n[i] <= '1;
        end

        // write preamble
        foreach (trans.preamble[i]) begin
            drive_cmd_2_1(trans.preamble[i]);
        end

        // prepare read instruction
        cmd_ = DFI_RD16;
        cmd_[6:4] = trans.address.col[5:3];
        cmd_[10:7] = trans.address.ba;
        cmd_[12:11] = trans.address.col[2:1];
        cmd_[3] = trans.address.col[0];
        cmd_[13] = 1;

        fork
            begin
                drive_cmd_2_1(cmd_);
                if (trans.is_last) begin
                    repeat (2) begin
                        drive_cmd_2_1(DFI_NOP);    
                    end
                end    
            end
            begin
                fork
                    drive_rd_en(trans);
                    drive_rd_cs(trans);
                join_none
            end
        join
    endtask

*/

    task automatic drive_read (DFI_rd_stream_seq_item trans);
        @(vif.cb_drv) begin
            foreach(vif.cb_drv.cke[i]) begin
                vif.cb_drv.cke[i] <= 2'b11;
                vif.cb_drv.dram_clk_disable[i] <= 0;
                vif.cb_drv.reset_n[i] <= '1;
            end    
        end
        
        foreach (trans.slice_q[i]) begin
            @(vif.cb_drv) begin
                vif.cb_drv.address[0] <= trans.slice_q[i].address[0];
                vif.cb_drv.address[1] <= trans.slice_q[i].address[1];
                vif.cb_drv.address[2] <= trans.slice_q[i].address[2];
                vif.cb_drv.address[3] <= trans.slice_q[i].address[3];

                vif.cb_drv.cs[0] <= trans.slice_q[i].cs[0];
                vif.cb_drv.cs[1] <= trans.slice_q[i].cs[1];
                vif.cb_drv.cs[2] <= trans.slice_q[i].cs[2];
                vif.cb_drv.cs[3] <= trans.slice_q[i].cs[3];

                vif.cb_drv.rddata_cs[0] <= trans.slice_q[i].rddata_cs[0];
                vif.cb_drv.rddata_cs[1] <= trans.slice_q[i].rddata_cs[1];
                vif.cb_drv.rddata_cs[2] <= trans.slice_q[i].rddata_cs[2];
                vif.cb_drv.rddata_cs[3] <= trans.slice_q[i].rddata_cs[3];

                vif.cb_drv.rddata_en[0] <= trans.slice_q[i].rddata_en[0];
                vif.cb_drv.rddata_en[1] <= trans.slice_q[i].rddata_en[1];
                vif.cb_drv.rddata_en[2] <= trans.slice_q[i].rddata_en[2];
                vif.cb_drv.rddata_en[3] <= trans.slice_q[i].rddata_en[3];
            end
        end
        
    endtask

    task automatic drive_cmd(wav_DFI_cmd_transfer trans);
        foreach(trans.address[i])
            vif.mp_drv.cb_drv.address[i] <= trans.address[i];
        foreach(trans.dram_clk_disable[i])
            vif.mp_drv.cb_drv.dram_clk_disable[i] <= trans.dram_clk_disable[i];
        foreach(trans.cke[i])
            vif.mp_drv.cb_drv.cke[i] <= trans.cke[i];
        foreach(trans.cs[i])
            vif.mp_drv.cb_drv.cs[i] <= trans.cs[i];
        foreach(trans.parity_in[i])
            vif.mp_drv.cb_drv.parity_in[i] <= trans.parity_in[i];
		foreach(trans.reset_n[i])
            vif.mp_drv.cb_drv.reset_n[i] <= trans.reset_n[i];
    endtask

    //there are different types of DFI transactions 
    //this task checks the tr_type in the transaction and call the corresponding task 

    task automatic drive_transaction(wav_DFI_transfer trans); 
        trans.print();
		fork begin
			wav_DFI_lp_transfer lp_trans;
			wav_DFI_update_transfer update_trans;
			wav_DFI_write_transfer write_trans;
            DFI_rd_stream_seq_item read_trans;
            wav_DFI_status_transfer status_trans;
            wav_DFI_cmd_transfer cmd_trans;
		//add the remaining interface cases
			driver_run_phase.raise_objection(this, "start driving transaction");
            case(trans.tr_type)
                cmd: begin
                    $cast(cmd_trans, trans);
					drive_cmd(cmd_trans);
                end
				lp: begin
					$cast(lp_trans, trans);
					drive_lp(lp_trans);
				end 
				update: begin     
					$cast(update_trans, trans);
					drive_ctrlupd(update_trans); 
				end
				write: begin     
					$cast(write_trans, trans);
					drive_write(write_trans); 
				end
                status_freq: begin
                    $cast(status_trans, trans);
                    drive_status(status_trans);
                end
                read: begin
                    $cast(read_trans, trans);
                    drive_read(read_trans);
                end
			endcase
			driver_run_phase.drop_objection(this, "done driving transaction");
		end
        join_none
    endtask

    //monitors requests from the PHY on phyupd interface and grant them
    task automatic respond_to_phyupd();
        `uvm_info(get_name(), "starting respond_to_phyupd", UVM_MEDIUM);  
        forever begin
            @(posedge vif.mp_drv.cb_drv);
            if (vif.mp_drv.cb_drv.phyupd_req) begin
                driver_run_phase.raise_objection(this, "Respond to phyupd started");

                `uvm_info(get_name(), "Captured phyupd request HIGH", UVM_MEDIUM);  
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b1;
                `uvm_info(get_name(), "Turned phyupd ack HIGH", UVM_MEDIUM);  

                wait(vif.mp_drv.cb_drv.phyupd_req == 0);

                `uvm_info(get_name(), "Captured phyupd request LOW", UVM_MEDIUM);  
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b0;
                `uvm_info(get_name(), "Turned phyupd ack LOW", UVM_MEDIUM);  

                driver_run_phase.drop_objection(this, "Respond to phyupd finished");
            end
            else
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b0;
        end
    endtask
    
    //monitors requests from the PHY on phymstr interface and grant them
    task automatic respond_to_phymstr();        
        `uvm_info(get_name(), "Waiting_to_phymstr", UVM_MEDIUM);   
        forever begin
            @(posedge vif.mp_drv.cb_drv) 
            if (vif.mp_drv.cb_drv.phymstr_req) begin 
                driver_run_phase.raise_objection(this, "Respond to phymstr started");

                `uvm_info(get_name(), "Captured phymstr request HIGH", UVM_MEDIUM);  
                vif.mp_drv.cb_drv.phymstr_ack <= 1'b1;
                `uvm_info(get_name(), "Turned phymstr ack HIGH", UVM_MEDIUM);
				
				wait(vif.mp_drv.cb_drv.phymstr_req == 0);
				
				`uvm_info(get_name(), "Captured phymstr request LOW", UVM_MEDIUM);  
                vif.mp_drv.cb_drv.phymstr_ack <= 1'b0;
                `uvm_info(get_name(), "Turned phymstr ack LOW", UVM_MEDIUM);

                driver_run_phase.drop_objection(this, "Respond to phymstr finished");
            end
            else
                vif.mp_drv.cb_drv.phymstr_ack <= 1'b0;
        end
    endtask

endclass