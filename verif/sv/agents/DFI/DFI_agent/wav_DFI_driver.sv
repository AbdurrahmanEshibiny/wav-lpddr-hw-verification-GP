class wav_DFI_driver extends uvm_driver; // use default value to adhere to the wavious standard, not #(wav_DFI_transfer); 

    wav_DFI_vif vif;
    uvm_phase driver_run_phase;
	
    `uvm_component_utils_begin(wav_DFI_driver)
    `uvm_component_utils_end

    function new (string name = "wav_DFI_driver", uvm_component parent=null);
        super.new(name, parent);
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
        `uvm_info(get_name(), "Driving ctrlupd", UVM_MEDIUM);              
        @(posedge vif.mp_drv.cb_drv)         
        if (trans.is_ctrl) begin
            vif.mp_drv.cb_drv.ctrlupd_req <= trans.req;       
            `uvm_info(get_name(), "done driving ctrlupd", UVM_MEDIUM);  
            // if (trans.cyclesCount > 0) begin
            
			`uvm_info(get_name(), "wait for ctrlupd_ack goes HIGH", UVM_MEDIUM);
            wait(vif.mp_drv.cb_drv.ctrlupd_ack == 1);   
			`uvm_info(get_name(), "wait for ctrlupd_ack goes LOW", UVM_MEDIUM);
            wait(vif.mp_drv.cb_drv.ctrlupd_ack == 0);
			
			vif.mp_drv.cb_drv.ctrlupd_req <= 0;
			`uvm_info(get_name(), "done resetting ctrlupd", UVM_MEDIUM);  
            // repeat(trans.cyclesCount) @(posedge vif.mp_drv.cb_drv);
            // vif.mp_drv.cb_drv.ctrlupd_req <= 0;
            // `uvm_info(get_name(), "Done resetting ctrlupd", UVM_MEDIUM); 
        end
    endtask

    task automatic drive_write(wav_DFI_write_transfer trans);         
        @(posedge vif.mp_drv.cb_drv);
        `uvm_info(get_name(), "write xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", UVM_MEDIUM); 
        trans.print();
        // For arrays
        foreach(trans.address[i])
            vif.mp_drv.cb_drv.address[i] <= trans.address[i]; 
        foreach(trans.wrdata[i])
            vif.mp_drv.cb_drv.wrdata[i] <= trans.wrdata[i];
        foreach(trans.parity_in[i])
            vif.mp_drv.cb_drv.parity_in[i] <= trans.parity_in[i]; 
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
        foreach(trans.cs[i])        
            vif.mp_drv.cb_drv.cs[i] <= trans.cs[i];
        foreach(trans.dram_clk_disable[i])        
            vif.mp_drv.cb_drv.dram_clk_disable[i] <= trans.dram_clk_disable[i];  
    endtask

    //there are different types of DFI transactions 
    //this task checks the tr_type in the transaction and call the corresponding task 
    task automatic drive_transaction(wav_DFI_transfer trans);
        `uvm_info(get_name(), "write xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", UVM_MEDIUM); 
        trans.print();
		fork 
		begin
			wav_DFI_lp_transfer lp_trans;
			wav_DFI_update_transfer update_trans;
			wav_DFI_write_transfer write_trans;
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