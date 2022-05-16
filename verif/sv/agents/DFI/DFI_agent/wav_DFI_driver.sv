class wav_DFI_driver extends uvm_driver #(wav_DFI_transfer); 

    wav_DFI_vif vif;

    `uvm_component_utils_begin(wav_DFI_driver)
    `uvm_component_utils_end

    function new (string name = "wav_DFI_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

	/*should we drive the signal through sequencer*/

    //drive lp interface according to the specified transaction
    task drive_lp(wav_DFI_lp_transfer trans);  
        @(posedge vif.mp_drv.cb_drv) 
        if (trans.is_ctrl) begin 
            vif.mp_drv.cb_drv.lp_ctrl_req <= trans.req; 
            vif.mp_drv.cb_drv.lp_ctrl_wakeup <= trans.wakeup; 
        end 
        else begin         
            vif.mp_drv.cb_drv.lp_data_req <= trans.req;         
            vif.mp_drv.cb_drv.lp_data_wakeup <= trans.wakeup; 
        end
    endtask                        
        
    //drive ctrlupd interface according to the specified transaction
    task drive_ctrlupd(wav_DFI_update_transfer trans);         
    @(posedge vif.mp_drv.cb_drv)         
    if (trans.is_ctrl)         
        vif.mp_drv.cb_drv.ctrlupd_req <= trans.req;         
    else begin     
        // `CSR_WRF1(DDR_DFI_OFFSET,DDR_DFI_STATUS_IF_CFG, SW_ACK_OVR, 1'b0);
        // write to register phyupd_req <= trans.req;         
        // write to register phyupd_type <= trans.type;               
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
    endtask

    task drive_wck(wav_DFI_wck_transfer trans);         
        @(posedge vif.mp_drv.cb_drv);
        // For arrays
        foreach(trans.wck_cs[i])
            vif.mp_drv.cb_drv.wck_cs[i] <= trans.wck_cs[i];  
        foreach(trans.wck_en[i])
            vif.mp_drv.cb_drv.wck_en[i] <= trans.wck_en[i]; 
        foreach(trans.wck_toggle[i])        
            vif.mp_drv.cb_drv.wck_toggle[i] <= trans.wck_toggle[i];        
    endtask

    //there are different types of DFI transactions 
    //this task checks the tr_type in the transaction and call the corresponding task 
    task drive_transaction(wav_DFI_transfer trans);
        wav_DFI_lp_transfer lp_trans;
        wav_DFI_update_transfer update_trans;
        wav_DFI_write_transfer write_trans;
        wav_DFI_wck_transfer wck_trans;
	//add the remaining interface cases
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
            wck: begin     
                $cast(wck_trans, trans);
                drive_wck(wck_trans); 
            end
        endcase    
    endtask

    //monitors requests from the PHY on phyupd interface and grant them
    task respond_to_phyupd();
        forever begin
            @(posedge vif.mp_drv.cb_drv)
            if (vif.mp_drv.cb_drv.phyupd_req)
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b1;
            else
                vif.mp_drv.cb_drv.phyupd_ack <= 1'b0;
        end
    endtask
    
    //monitors requests from the PHY on phymstr interface and grant them
    task respond_to_phymstr();         
        forever begin
            @(posedge vif.mp_drv.cb_drv) 
            if (vif.mp_drv.cb_drv.phymstr_req)
                vif.mp_drv.cb_drv.phymstr_ack <= 1'b1;
            else
                vif.mp_drv.cb_drv.phymstr_ack <= 1'b0;
        end
    endtask

endclass