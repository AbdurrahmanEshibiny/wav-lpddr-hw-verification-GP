class wav_DFI_driver extends uvm_driver;
// use default value to adhere to the wavious standard, not #(wav_DFI_transfer); 

    wav_DFI_vif vif;
    uvm_phase driver_run_phase;
    virtual wddr_config cfg;

    `uvm_component_utils_begin(wav_DFI_driver)
    `uvm_component_utils_end

    function new (string name = "wav_DFI_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void connect_phase(uvm_phase phase);
        uvm_config_db#(virtual wddr_config)::get(null, "*", "cfg_obj", cfg);
    endfunction

    virtual task run_phase(uvm_phase phase);
        driver_run_phase = phase;
        fork
            get_and_drive();
            respond_to_phyupd();
            respond_to_phymstr();
        join
    endtask

    virtual protected task get_and_drive();
        forever begin
            `uvm_info(get_type_name(), "wav_DFI driver waiting for the next item", UVM_MEDIUM);
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(), "wav_DFI driver received the next item", UVM_MEDIUM);

            $cast(rsp, req.clone());

            rsp.set_id_info(req);
            `uvm_info(get_type_name(),$psprintf("wav_DFI driver start driving transfer :\n%s", rsp.sprint()), UVM_MEDIUM);

            drive_transaction(rsp);
            `uvm_info(get_type_name(),$psprintf("wav_DFI driver done driving transfer :\n%s", rsp.sprint()), UVM_MEDIUM);

            seq_item_port.item_done();
            seq_item_port.put_response(rsp);
        end
      endtask

    /*should we drive the signal through sequencer*/
      
    //reset tasks
    task reset_lp(bit is_ctrl);
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
    task drive_lp(wav_DFI_lp_transfer trans);  
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
    task drive_ctrlupd(wav_DFI_update_transfer trans);   
        `uvm_info(get_name(), "Driving ctrlupd", UVM_MEDIUM);              
        @(posedge vif.mp_drv.cb_drv)         
        if (trans.is_ctrl) begin
            vif.mp_drv.cb_drv.ctrlupd_req <= trans.req;       
            `uvm_info(get_name(), "done driving lp", UVM_MEDIUM);  
            if (trans.cyclesCount > 0) begin
                // wait for ctrlupd_ack goes HIGH and then LOW
                // wait(vif.mp_drv.cb_drv.ctrlupd_ack == 1);   
                // wait(vif.mp_drv.cb_drv.ctrlupd_ack == 0);
                repeat(trans.cyclesCount) @(posedge vif.mp_drv.cb_drv);
                vif.mp_drv.cb_drv.ctrlupd_req <= 0;
                `uvm_info(get_name(), "Done resetting ctrlupd", UVM_MEDIUM); 
            end
        end
    endtask

    task drive_write(wav_DFI_write_transfer trans);         
        @(posedge vif.mp_drv.cb_drv);
        // For arrays
        foreach(trans.wrdata[i])
            vif.mp_drv.cb_drv.wrdata[i] <= trans.wrdata[i];  
        foreach(trans.wrdata_cs[i])
            vif.mp_drv.cb_drv.wrdata_cs[i] <= trans.wrdata_cs[i]; 
        foreach(trans.wrdata_en[i])
            vif.mp_drv.cb_drv.wrdata_en[i] <= trans.wrdata_en[i];   
        foreach(trans.wrdata_mask[i])              
            vif.mp_drv.cb_drv.wrdata_mask[i] <= trans.wrdata_mask[i]; 
        foreach(trans.wck_cs[i])
            vif.mp_drv.cb_drv.wck_cs[i] <= trans.wck_cs[i];  
        foreach(trans.wck_en[i])
            vif.mp_drv.cb_drv.wck_en[i] <= trans.wck_en[i]; 
        foreach(trans.wck_toggle[i])        
            vif.mp_drv.cb_drv.wck_toggle[i] <= trans.wck_toggle[i];   
    endtask

    task automatic drive_status(wav_DFI_status_transfer trans);
        vif.mp_drv.cb_drv.init_start <= 0;
        vif.mp_drv.cb_drv.freq_fsp <= trans.freq_fsp;
        vif.mp_drv.cb_drv.freq_ratio <= freq_ratio;
        vif.mp_drv.cb_drv.frequency <= frequency;
        @(vif.mp_drv.cb_drv);
        vif.mp_drv.cb_drv.init_start <= 1;
        @(vif.mp_drv.cb_drv);

        // need to drive dfi_cke and dfi_reset_n
        // until the dfi_init_complete signal is asserted.


        /*
        string msg;
        string freq_details = $sformatf (
            "Frequency# = %5d, ", trans.frequency,
            "Freq Ratio = %1d, ", trans.freq_ratio,
            "FSP# = %1d", trans.freq_fsp
        );
        // FIXME: WE ARE TESTING FOR THE FREQUENCIES HERE
        // TODO: print the count of the timing if it succeeds
        int t_init_start = 1;
        while (t_init_start != 0) begin
            if (vif.mp_drv.cb_drv.init_complete == 1'b0) begin
                break;
            end
            t_init_start++;
            @(vif.mp_drv.cb_drv);
        end
        if (t_init_start == 0) begin
            msg = "PHY rejects new freq setting";
        end else begin
            msg = "PHY accepts new freq setting";
        end
        `uvm_info (
            get_name(), {msg, "\n", freq_details}, UVM_MEDIUM
        )
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

    task drive_read (wav_DFI_read_transfer trans);
    // we will assume the frequency ratio is 1:1 for now
        `uvm_info(get_name(), "Driving read", UVM_MEDIUM);
        foreach (trans.cmd_mc[i]) begin
            @(vif.mp_drv.cb_drv) begin
                vif.mp_drv.cb_drv.address[0] <= trans.cmd_mc[i];
            end
        end
        // preamble and read instruction is done
        // next put dfi_address in NOP
        @(vif.mp_drv.cb_drv) begin
            vif.mp_drv.cb_drv.address[0] <= 14'bxxxxxxx_0000000;
        end
        // assign the pins of the read interface
        fork
            begin
                // -2 because we already skipped a cycle and because we want to
                // set the signal on this cycle not the next cycle (the
                // clocking block will delay the assignment by a small amount of
                // time such that the assignment is captured on the next cycle)
                repeat ((cfg.trddata_en)-2) begin
                    @(vif.mp_drv.cb_drv);
                end
                vif.vif.mp_drv.cb_drv.rddata_en <= 1;

                // cycles needed for rddata_en to stay 1
                repeat (trans.rd.size()-1) begin
                    @(vif.mp_drv.cb_drv);
                end
                vif.vif.mp_drv.cb_drv.rddata_en <= 0;
            end
            begin
                repeat ((cfg.tphy_rdcslat)-2) begin
                    @(vif.mp_drv.cb_drv);
                end
                vif.vif.mp_drv.cb_drv.rddata_cs[0] <= trans.cs;
            end
        join
    endtask

    //there are different types of DFI transactions 
    //this task checks the tr_type in the transaction and call the corresponding task 
    task drive_transaction(wav_DFI_transfer trans);
        wav_DFI_lp_transfer lp_trans;
        wav_DFI_update_transfer update_trans;
        wav_DFI_write_transfer write_trans;
        wav_DFI_status_transfer status_trans;
        wav_DFI_read_transfer read_trans;
    //add the remaining interface cases
        driver_run_phase.raise_objection(this, "start driving transaction");
        case(trans.tr_type)
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
            // status_freq: begin
               //  $cast(status_trans, trans);
                // drive_status;
            // end
            read: begin
                $cast(read_trans, trans);
                drive_read(read_trans);
            end
        endcase    
        driver_run_phase.drop_objection(this, "done driving transaction");
    endtask

    //monitors requests from the PHY on phyupd interface and grant them
    task respond_to_phyupd();
        `uvm_info(get_name(), "starting respond_to_phyupd", UVM_MEDIUM);  
        forever begin
            @(posedge vif.mp_drv.cb_drv);
            if (vif.mp_drv.cb_drv.phyupd_req) begin
                driver_run_phase.raise_objection(this, "Respond to phyupd started");

                `uvm_info(get_name(), "Captured phyupd request HIGH", UVM_MEDIUM);  
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b1;
                `uvm_info(get_name(), "Responded to the phyupd request LOW", UVM_MEDIUM);  

                wait(vif.mp_drv.cb_drv.phyupd_req == 0);

                `uvm_info(get_name(), "Captured phyupd request LOW", UVM_MEDIUM);  
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b0;
                `uvm_info(get_name(), "Responded to the phyupd request LOW", UVM_MEDIUM);  

                driver_run_phase.drop_objection(this, "Respond to phyupd finished");
            end
            else
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b0;
        end
    endtask
    
    //monitors requests from the PHY on phymstr interface and grant them
    task respond_to_phymstr();        
        `uvm_info(get_name(), "Waiting_to_phymstr", UVM_MEDIUM);   
        forever begin
            @(posedge vif.mp_drv.cb_drv) 
            if (vif.mp_drv.cb_drv.phymstr_req) begin 
                driver_run_phase.raise_objection(this, "Respond to phymstr started");

                `uvm_info(get_name(), "Captured phymstr requst", UVM_MEDIUM);  
                vif.mp_drv.cb_drv.phymstr_ack <= 1'b1;
                `uvm_info(get_name(), "Responded to the phymstr request", UVM_MEDIUM);

                driver_run_phase.drop_objection(this, "Respond to phymstr finished");
            end
            else
                vif.mp_drv.cb_drv.phymstr_ack <= 1'b0;
        end
    endtask

endclass