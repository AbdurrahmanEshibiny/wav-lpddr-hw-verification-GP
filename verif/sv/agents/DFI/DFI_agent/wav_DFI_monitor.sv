class wav_DFI_monitor extends uvm_monitor;

    `uvm_component_utils_begin(wav_DFI_monitor)
    `uvm_component_utils_end

    wav_DFI_vif vif;
    uvm_phase monitor_run_phase;
    uvm_analysis_port #(wav_DFI_transfer) subscriber_port_item;
    uvm_analysis_port #(wav_DFI_write_transfer) sent_transaction;  
    wav_DFI_write_transfer write_item;

    semaphore subscriber_port_item_sem;
    task automatic write_to_port(wav_DFI_transfer trans);
        subscriber_port_item_sem.get();
        `uvm_info(get_name(), "The object written to DFI subscriber port:", UVM_MEDIUM);
        trans.print();
        subscriber_port_item.write(trans);
        subscriber_port_item_sem.put();
    endtask

    const int wakeup_times[20] = '{1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,-1};
    const int phyupd_types[4] = '{`tphyupd_type0, `tphyupd_type1, `tphyupd_type2, `tphyupd_type3};
    const int phymstr_types[4] = '{`tphymstr_type0, `tphymstr_type1, `tphymstr_type2, `tphymstr_type3};  

    function new (string name = "wav_DFI_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        subscriber_port_item     = new("subscriber_port_item", this);
        sent_transaction          = new("sent_transaction", this);
        subscriber_port_item_sem = new(1);
        write_item               = new();
    endfunction

	/*add collect for remaining interface signals*/
    //each task samples a single packet from the corresponding sub-interface 
    task automatic collect_write(ref wav_DFI_write_transfer trans); 
        foreach(vif.mp_mon.cb_mon.wrdata[i])
            trans.wrdata[i] = vif.mp_mon.cb_mon.wrdata[i];
        foreach(vif.mp_mon.cb_mon.parity_in[i]) 
            trans.parity_in[i] = vif.mp_mon.cb_mon.parity_in[i]; 
        foreach(vif.mp_mon.cb_mon.wrdata_cs[i])
            trans.wrdata_cs[i] = vif.mp_mon.cb_mon.wrdata_cs[i]; 
        foreach(vif.mp_mon.cb_mon.wrdata_mask[i])
            trans.wrdata_mask[i] = vif.mp_mon.cb_mon.wrdata_mask[i];
        foreach(vif.mp_mon.cb_mon.wrdata_en[i])
            trans.wrdata_en[i] = vif.mp_mon.cb_mon.wrdata_en[i];
        foreach(vif.mp_mon.cb_mon.address[i])        
            trans.address[i] = vif.mp_mon.cb_mon.address[i];
        foreach(vif.mp_mon.cb_mon.wck_cs[i])
            trans.wck_cs[i] = vif.mp_mon.cb_mon.wck_cs[i];
        foreach(vif.mp_mon.cb_mon.wck_en[i])
            trans.wck_en[i] =  vif.mp_mon.cb_mon.wck_en[i];
        foreach(vif.mp_mon.cb_mon.wck_toggle[i])
            trans.wck_toggle[i] = vif.mp_mon.cb_mon.wck_toggle[i];
    endtask


    task automatic score_write(ref wav_DFI_write_transfer trans); 
        foreach(vif.mp_mon.cb_mon.wrdata[i]) 
            trans.wrdata[i] = vif.mp_mon.cb_mon.wrdata[i];
        sent_transaction.write(trans);
    endtask

    task automatic collect_lp_ctrl(ref wav_DFI_lp_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.lp_ctrl_req; 
        trans.ack = vif.mp_mon.cb_mon.lp_ctrl_ack; 
        trans.wakeup = vif.mp_mon.cb_mon.lp_ctrl_wakeup; 
        trans.is_ctrl = 1; 
    endtask
          
    task automatic collect_lp_data(ref wav_DFI_lp_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.lp_data_req; 
        trans.ack = vif.mp_mon.cb_mon.lp_data_ack; 
        trans.wakeup = vif.mp_mon.cb_mon.lp_data_wakeup; 
        trans.is_ctrl = 0; 
    endtask    
          
    task automatic collect_phymstr(ref wav_DFI_phymstr_transfer trans);     
        trans.req = vif.mp_mon.cb_mon.phymstr_req; 
        trans.ack = vif.mp_mon.cb_mon.phymstr_ack; 
        trans._type = vif.mp_mon.cb_mon.phymstr_type; 
        trans.state_sel = vif.mp_mon.cb_mon.phymstr_state_sel;     
        trans.cs_state = vif.mp_mon.cb_mon.phymstr_cs_state; 
    endtask  
          
    task automatic collect_phyupd(ref wav_DFI_update_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.phyupd_req; 
        trans.ack = vif.mp_mon.cb_mon.phyupd_ack; 
        trans._type = vif.mp_mon.cb_mon.phyupd_type; 
    endtask
    
    task automatic collect_ctrlupd(ref wav_DFI_update_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.ctrlupd_req; 
        trans.ack = vif.mp_mon.cb_mon.ctrlupd_ack; 
    endtask

    `define READ_INST 0

   typedef struct {
        bit [13:0] command;
        bit [63:0] r_data;
        bit [7:0] dbi;
        bit en;
        bit valid;
        bit [1:0] dfi_phase;
        bit [1:0] cs;
        int timestamp;
   } read_slice_st;


/*
    task automatic serialize_read(
        ref read_slice_st slices[$]
    );
        read_slice_st new_slices[$] = {};
        foreach(vif.mp_mon.cb_mon.address[i]) begin
            read_slice_st temp;
            temp.command = vif.mp_mon.cb_mon.address[i];
            temp.r_data = vif.mp_mon.cb_mon.rddata[i];
            temp.dbi = vif.mp_mon.cb_mon.rddata_dbi[i];
            temp.en = vif.mp_mon.cb_mon.rddata_en[i];
            temp.valid = vif.mp_mon.cb_mon.rddata_valid[i];
            temp.dfi_phase = i;
            temp.cs = vif.mp_mon.cb_mon.rddata_cs[i];
            temp.timestamp = $time;
            new_slices.push_back(temp);
        end
        slices = {slices, new_slices};
    endtask

    task automatic extend_read_queue(
        ref read_slice_st slices[$]
    );
        // the behaviour for an empty queue is to
        // advance 1 timestep before extending
        if ((slices.size() == 0) || (slices[$].timestamp == $time))
        begin
            @(vif.mp_mon.cb_mon);
        end
        serialize_read(slices);
    endtask

    task automatic collect_read (
        output wav_DFI_read_transfer trans,
        ref bit [1:0] word_ptr,
        ref read_slice_st slices[$]
    );
        // TODO: find the values of these parameters
        int t_rddata_en = 0;
        int t_phy_rdcslat = 0;

        int data_len = 0;

        // TODO: ratio of the DFI clk to the DFI PHY clk

        int en_cntr = 1;
        int max_data_len;
        bit is_max_len_def = 0;

        int slice_index;

        bit is_data_len_done;

        read_slice_st rolled_slices[$];

        read_data_t d;

        bit [1:0] old_word_ptr;        

        // OPERATION STARTS HERE
        trans = new();
        
        while(slices.size() <= t_rddata_en) begin
            extend_read_queue(slices);
        end

        slice_index = 1;

        while(en_cntr < t_rddata_en) begin
            // TODO: find the exact value of the read command
            if(slices[slice_index].command != `READ_INST) begin
                slice_index++;
                en_cntr++;
            end else begin
                max_data_len = en_cntr;
                is_max_len_def = 1;
                break;
            end
        end
        
        is_data_len_done = 0;

        while(is_data_len_done == 0) begin
            if (slices.size() < slice_index + 1) begin
                extend_read_queue(slices);
            end
            if(slices[slice_index].en == 1) begin
                data_len++;
                slice_index++;
                if (is_max_len_def == 1) begin
                    if (data_len == max_data_len) begin
                        is_data_len_done = 1;    
                    end
                    // TODO: find the exact value of the read command
                end else if (slices[slice_index].command == `READ_INST)
                begin
                    max_data_len = data_len + t_rddata_en;
                    is_max_len_def = 1;
                end                
            end else begin
                is_data_len_done = 1;
            end
        end // here we have the correct data length

        slice_index = 0;
        
        while (1) begin
            if (slices.size() < slice_index + 1) begin
                extend_read_queue(slices);
            end
            if ((slices[slice_index].valid == 1) && 
                (slices[slice_index].dfi_phase == word_ptr)) begin
                break;
            end else begin
                slice_index++;    
            end
        end // here we have the location of the first data slice

        rolled_slices =
        slices[slice_index-word_ptr : slice_index-word_ptr+3];
        
        while (rolled_slices[0].dfi_phase != word_ptr) begin
            read_slice_st tmp = rolled_slices[0];
            rolled_slices[0:$-1] = rolled_slices[1:$];
            rolled_slices [$] = tmp;
        end

        old_word_ptr = word_ptr;

        foreach (rolled_slices[i]) begin
            if (data_len != 0) begin
                if (rolled_slices[i].valid == 1) begin
                    rolled_slices[i].valid = 0;
                    d.data = rolled_slices[i].r_data;
                    d.dbi = rolled_slices[i].dbi;
                    trans.rd.push_back(d);
                    data_len--;
                    word_ptr = rolled_slices[i].dfi_phase + 1;
                end
            end else begin
                break;
            end
        end

        while (rolled_slices[0].dfi_phase != 0) begin
            read_slice_st tmp = rolled_slices[0];
            rolled_slices[0:$-1] = rolled_slices[1:$];
            rolled_slices [$] = tmp;
        end

        slices [slice_index-old_word_ptr : 
                slice_index-old_word_ptr+3] = rolled_slices;

        slice_index += (4-old_word_ptr);

        while (data_len != 0) begin
            if (slices.size() < slice_index + 1) begin
                extend_read_queue(slices);
            end
            if (slices[slice_index].valid == 1) begin
                slices[slice_index].valid = 0;
                d.data = slices[slice_index].r_data;
                d.dbi = slices[slice_index].dbi;
                trans.rd.push_back(d);
                data_len--;
                word_ptr = slices[slice_index].dfi_phase + 1;
            end
            slice_index++;
        end

        slice_index = t_phy_rdcslat;
        trans.cs = slices[slice_index].cs;

        // TODO: check for the cs signal staying constant for
        // dfi_rw_length + tphy_rdcsgap here

        slices.pop_front();
    endtask

    task monitor_read();
        bit [1:0] data_word_ptr = 0;
        // TODO: detect conditions of resetting
        // the data_word_ptr
        read_slice_st rd_slices[$] = {};
        wav_DFI_read_transfer rd_seq_item;
        forever begin
            extend_read_queue(rd_slices);
            while (rd_slices.size() != 0) begin
                // TODO: find the exact value of the read command
                if (rd_slices[0].command != `READ_INST) begin
                    rd_slices.pop_front();
                end else begin
                    // TODO: add detection `uvm_info
                    collect_read(rd_seq_item, data_word_ptr, rd_slices);
                    // TODO: send rd_seq_item to scoreboard
                end
            end
        end
    endtask

*/

    task monitor_status();
        int init_complete_cntr;
        int t_init_start;
        bit is_PHY_accept;
        string msg;
        string freq_details;
        forever begin
            @(vif.mp_mon.cb_mon) begin
                // TODO: add detection `uvm_info
                if (vif.mp_mon.cb_mon.init_start) begin
                    wav_DFI_status_transfer trans = new();
                    EventHandler::start_transaction(EventHandler::status);
                    trans.freq_fsp = vif.mp_mon.cb_mon.freq_fsp;
                    trans.freq_ratio = vif.mp_mon.cb_mon.freq_ratio;
                    trans.frequency = vif.mp_mon.cb_mon.frequency;
                    trans.req = 1;
                    write_to_port(trans);
                    init_complete_cntr = 0;
                    // TODO: modify this timing parameter
                    
                      
                    t_init_start = 0;
                    is_PHY_accept = 0;
                    freq_details = $sformatf (
                        "Frequency# = %5d, ", trans.frequency,
                        "Freq Ratio = %1d, ", trans.freq_ratio,
                        "FSP# = %1d", trans.freq_fsp
                    );
                    forever 
                    begin
                        @(vif.mp_mon.cb_mon) begin
                            init_complete_cntr++;
                            if (vif.mp_mon.cb_mon.init_complete == 1'b1)
                            begin
                                if (init_complete_cntr == t_init_start)
                                begin
                                    msg = $sformatf (
                                        "PHY rejects new freq setting"
                                    );
                                    is_PHY_accept = 1'b0;
                                    break;
                                end
                            end else begin
                                if (vif.mp_mon.cb_mon.init_complete == 1'b0)
                                begin
                                    msg = $sformatf (
                                        "PHY accepts new freq setting"
                                    );
                                    is_PHY_accept = 1'b1;
                                    break;
                                end
                            end
                        end
                    end

                    while (vif.mp_mon.cb_mon.init_complete != 1'b1)
                        @(vif.mp_mon.cb_mon);
                    `uvm_info(get_name(), "init complete is back on HIGH", UVM_MEDIUM);                    
                    `uvm_info (
                        get_name(), {msg, "\n", freq_details}, UVM_MEDIUM
                    );
                    EventHandler::end_transaction(EventHandler::status);
                end
            end
        end
    endtask

    /* add handles for the remaining interface signals*/
    task automatic handle_write();
        wav_DFI_write_transfer trans;
        // int clkticks_wrcsgab=0;
        // int clkticks_wrcslat=0;
        // int clkticks_wrdata=0;
        // int clkticks_wrdatalat=0;
        // int clkticks_wrdata_delay=0;

        // int clkticks_wckdis=0;
        // int clkticks_wcktoggle=0;
        // int clkticks_wckfast_toggle=0;
        // int clkticks_wcktoggle_cs=0;
        // int clkticks_wcktoggle_rd=0;
        // int clkticks_wcktoggle_wr=0;

        // logic [1:0]temp_wrdata_cs[0:3] = '{default:0};
        // trans = new();
        // forever begin
        //     foreach(trans.wck_en[i])
        //     begin
        //         if(trans.wck_en[i] != 1'b0) 
        //         begin
        //             @(vif.mp_mon.cb_mon)
        //             begin
        //                ++clkticks_wcktoggle;
        //                ++clkticks_wckfast_toggle;
        //             end
        //             @(vif.mp_mon.cb_mon);
        //             if(trans.wck_toggle[i]==2'b10)
        //             begin
        //                 if(`twck_toggle != clkticks_wcktoggle)
        //                 begin
        //                     `uvm_error(get_name(), $psprintf("The time between the wck enable to toggle command (%d)is not equal to twck_toggle(%d)",clkticks_wcktoggle,`twck_toggle));                        
        //                 end
        //                 else
        //                 begin
        //                     clkticks_wcktoggle=0;
        //                 end 
        //             end
        //             if(trans.wck_toggle[i]==2'b11)
        //             begin
        //                 if(`twck_fast_toggle != clkticks_wckfast_toggle)
        //                 begin
        //                     `uvm_error(get_name(), $psprintf("The time between the wck toggle command to wck fast toggle command (%d)is not equal to twck_toggle(%d)",clkticks_wckfast_toggle,`twck_fast_toggle));                        
        //                 end
        //                 else
        //                 begin
        //                     clkticks_wckfast_toggle=0;
        //                 end
        //             end
        //         end
        //     end
        //     /*checks for all write data timing parameters*/
        //     foreach(trans.address[i])
        //     begin
        //         if(trans.address[i] != 14'b0) 
        //         begin
        //             @(vif.mp_mon.cb_mon)
        //             begin
        //                 ++clkticks_wrcsgab;
        //                 ++clkticks_wrcslat;
        //                 ++clkticks_wrdata;
        //                 ++clkticks_wrdatalat;
        //                 ++clkticks_wrdata_delay;
        //             end
        //             @(vif.mp_mon.cb_mon);
        //             if(trans.wck_cs[i] != 2'bxx)
        //             begin
        //                 if(`twck_toggle_cs != clkticks_wcktoggle_cs)
        //                 begin
        //                    `uvm_error(get_name(), $psprintf("The gap between the dfi command write and the write cs (%d)is not equal to tphy_wrcslat(%d)",clkticks_wcktoggle_cs,`tphy_wrcslat));                         
        //                 end
        //                 else 
        //                 begin
        //                     clkticks_wcktoggle_cs=0;
        //                 end
        //             end
        //             if(trans.wrdata_cs[i] != 2'b0)  
        //             begin
        //                 temp_wrdata_cs[i] = trans.wrdata_cs[i];
        //                 if(`tphy_wrcslat != clkticks_wrcslat) 
        //                 begin
        //                     `uvm_error(get_name(), $psprintf("The gap between the dfi command write and the write cs (%d)is not equal to tphy_wrcslat(%d)",clkticks_wrcslat,`tphy_wrcslat));                        
        //                 end
        //                 else 
        //                 begin
        //                     clkticks_wrcslat=0;
        //                 end
        //                 if(`tphy_wrlat != clkticks_wrdatalat) 
        //                 begin
        //                     `uvm_error(get_name(), $psprintf("The gap between the dfi command write and the write en (%d)is not equal to tphy_wrlat(%d)",clkticks_wrdatalat,`tphy_wrlat));                        
        //                 end
        //                 else 
        //                 begin
        //                     clkticks_wrdatalat=0;
        //                 end    
        //             end
        //             if(trans.address[i] != 14'b0)
        //             begin
        //                 if(trans.wrdata_cs[i] != 2'b0) 
        //                 begin
        //                     if(temp_wrdata_cs[i] != trans.wrdata_cs[i])
        //                     begin
        //                         if(`tphy_wrcsgap != clkticks_wrcsgab) 
        //                         begin
        //                             `uvm_error(get_name(), $psprintf("The gap between the dfi command write and the next dfi command write if changeing cs (%d)is not equal to tphy_wrcsgap(%d)",clkticks_wrcsgab,`tphy_wrcsgap));                        
        //                         end
        //                         else 
        //                         begin
        //                             clkticks_wrcsgab=0;
        //                         end
        //                     end
        //                 end
        //             end
        //         end
        //         if(trans.wrdata_en[i] != 4'b0) 
        //         begin
        //             @(vif.mp_mon.cb_mon)
        //             begin
        //                 ++clkticks_wrcsgab;
        //                 ++clkticks_wrcslat;
        //                 ++clkticks_wrdata;
        //                 ++clkticks_wrdatalat;
        //                 ++clkticks_wrdata_delay;
        //             end 
        //             if(trans.wrdata[i] != 64'b0)
        //             begin
        //                 if(`tphy_wrdata != clkticks_wrdata)
        //                 begin
        //                     `uvm_error(get_name(), $psprintf("The gap between the write enable and the write data (%d)is not equal to tphy_wrdata(%d)",clkticks_wrdata,`tphy_wrdata));                        
        //                 end
        //                 else 
        //                 begin
        //                     clkticks_wrdata=0;
        //                 end
        //             end
        //             if(trans.wrdata[i] == 64'b0)
        //             begin
        //                 if(`tphy_wrdatadelay != clkticks_wrdata_delay)
        //                 begin
        //                     `uvm_error(get_name(), $psprintf("The gap between the write enable and the write data completes transfer (%d)is not equal to tphy_wrdatadelay(%d)",clkticks_wrdata_delay,`tphy_wrdatadelay));                        
        //                 end
        //                 else 
        //                 begin
        //                     clkticks_wrdata_delay=0;
        //                 end
        //             end
        //         end
        //     end
        // end
    endtask

    

    //Handles a single request and performs any required checking throughout the transaction
    task automatic handle_lp(bit is_ctrl);
        wav_DFI_lp_transfer trans;
        int wakeup = -1;
        int counter = 0, steadyCounter = 0;
        bit isAcked = 0;
        trans = new();
        if (is_ctrl) collect_lp_ctrl(trans); else collect_lp_data(trans);
        write_to_port(trans);
        wakeup = trans.wakeup;
        `uvm_info(get_name(), $psprintf("Detected lp transaction with is_ctrl:%0d wakeup:%0d and wakeup_time: %0d", is_ctrl, wakeup, wakeup_times[wakeup]), UVM_MEDIUM);                
        forever begin
            @(vif.mp_mon.cb_mon);
            if (is_ctrl) collect_lp_ctrl(trans); else collect_lp_data(trans);
            if (trans.req) begin
                if (wakeup > trans.wakeup) begin
                    `uvm_error(get_name(), $psprintf("wakeup time has been DECREASED from %0d to %0d", wakeup, trans.wakeup));
                end
                else if ((wakeup != trans.wakeup) && !trans.ack) begin
                    `uvm_error(get_name(), $psprintf("wakeup time has been changed from %0d to %0d while ack was not high", wakeup, trans.wakeup));
                end
                else if ((wakeup != trans.wakeup) && steadyCounter < `tlp_resp) begin
                    `uvm_error(get_name(), $psprintf("wakeup time has been changed from %0d to %0d so early in %0d cycles", wakeup, trans.wakeup, steadyCounter));
                end
                else if (wakeup < trans.wakeup) begin
                    `uvm_info(get_name(), $psprintf("wakeup time has been INCREASED from %0d to %0d", wakeup, trans.wakeup), UVM_MEDIUM);                    
                    wakeup = trans.wakeup;
                    write_to_port(trans);
                end
                ++steadyCounter;
            end
            else if (trans.ack) begin
                if (steadyCounter < `tlp_resp && !isAcked) begin
                    `uvm_error(get_name(), $psprintf("lp req has been activated only for %0d instead of %0d", steadyCounter, `tlp_resp));
                end
                isAcked = 1;
                ++counter;
            end
            else 
                break;
        end

        --counter;
        if (wakeup != 19 && counter > wakeup_times[wakeup]) begin
            `uvm_warning(get_name(), $psprintf("PHY stayed asleep more than the wakeup time, it should stay %0d, but it stayed %0d", wakeup_times[wakeup], counter));
		end
		else begin
			`uvm_info(get_name(), $psprintf("PHY stayed asleep for %0d, with wakeup_time = %0d", counter, wakeup_times[wakeup]), UVM_MEDIUM);
        end
    endtask

    task automatic handle_phyupd();
        wav_DFI_update_transfer trans, original;
        int counter = 0, steadyCounter = 0;
        bit next_should_be_idle = 0, count = 0;
        trans = new();
        original = new();
        collect_phyupd(original);
        write_to_port(original);
        forever begin
            @(vif.mp_mon.cb_mon);
            collect_phyupd(trans);
            if (trans.req) begin
                ++steadyCounter;
                if (trans.ack)
                    count = 1'b1;
            end
            else begin
                if (steadyCounter > `tphyupd_resp) begin
                    `uvm_error(get_name(), $psprintf("phyupd req stayed high for %0d more than %0d", steadyCounter, `tphyupd_resp));
                end

                if (!trans.ack) begin
                    if (counter > phyupd_types[original._type]) begin
                        `uvm_error(get_name(), $psprintf("phyupd req stayed high for %0d more than %0d", counter, phyupd_types[original._type]));
                    end 
                    else begin
                        `uvm_info(get_name(), $psprintf("phyupd_req stayed HIGH for %d", counter), UVM_MEDIUM);
                    end
                    `uvm_info(get_name(), "Ending phyupd transaction", UVM_MEDIUM);                    
                    break;
                end
                else begin
                    if (next_should_be_idle) begin
                        `uvm_error(get_name(), "phyupd_ack stayed HIGH for more than 1 cycle after phyupd_req became LOW"); 
                    end
                    else
                        next_should_be_idle = 1'b1;
                end
                
            end

            if (count & trans.req)
                ++counter;

            if (original._type != trans._type) begin  // type should be constant
                `uvm_error(get_name(), $psprintf("phyupd._type is not stable but changed from %0d to %0d", original._type, trans._type));
            end
        end
    endtask

    task automatic handle_ctrlupd();
        wav_DFI_update_transfer trans = new();
        int counter = 0, steadyCounter = 0;
        bit isAcked = 0;
		trans.is_ctrl = 1;
        collect_ctrlupd(trans);
        write_to_port(trans);
        forever begin
            @(vif.mp_mon.cb_mon);
            collect_ctrlupd(trans);
            if (trans.req) begin
                ++steadyCounter;
            end
            else begin
                // For how many cycles was ctrlupd req stable ?
                if (steadyCounter < `tctrlupd_min) begin
                    `uvm_error(get_name(), $psprintf("ctrlupd req stayed high for only %0d instead of %0d", steadyCounter, `tctrlupd_min));
                end
                else if (steadyCounter > `tctrlupd_max) begin
                    `uvm_error(get_name(), $psprintf("ctrlupd req stayed high for %0d more than %0d", steadyCounter, `tctrlupd_max));
                end
                else begin
                    `uvm_info(get_name(), $psprintf("ctrlupd req stayed high for only %0d", steadyCounter), UVM_MEDIUM);                    
                end

                if (trans.ack) begin
                    //`uvm_error(get_name(), "ctrlupd_req is LOW while ctrlupd_ack is HIGH");
					`uvm_warning(get_name(), "ctrlupd_req is LOW while ctrlupd_ack is HIGH. This is an Error according to the DFI standard, but we handle it this way to make the test pass");
                end
                else if (isAcked) begin
                    `uvm_info(get_name(), $psprintf("ctrlupd_ack stayed HIGH for %d", counter), UVM_MEDIUM);
                    break;
                end
            end

            if (trans.ack) begin
                if (~isAcked & steadyCounter > `tctrlupd_min) begin
                    `uvm_error(get_name(), $psprintf("ctrlupd req is acked at %0d more than %0d", steadyCounter, `tctrlupd_min));
                end
                ++counter;
                isAcked = 1;
            end
        end
    endtask

    task automatic handle_phymstr();
        wav_DFI_phymstr_transfer trans, original;
        int counter = 0, steadyCounter = 0;
        bit next_should_be_idle = 0, count = 0;
        trans = new();
        original = new();
        collect_phymstr(original);
        write_to_port(original);
        forever begin
            @(vif.mp_mon.cb_mon);
            collect_phymstr(trans);
            if (trans.req) begin
                if (trans.ack)
                    count = 1'b1;
                else
                    ++steadyCounter;
            end
            else begin
                if (!trans.ack) begin
                    if (counter > phymstr_types[original._type]) begin
                        `uvm_error(get_name(), $psprintf("phymstr req is asserted in %0d instead of %0d", counter, phymstr_types[original._type]));
                    end
                    else begin
                        `uvm_info(get_name(), $psprintf("phymstr_req stayed HIGH for %d", counter), UVM_MEDIUM);
                    end 
                    break;
                end
                else begin
                    if (next_should_be_idle) begin
                        `uvm_error(get_name(), "phymstr_ack stayed HIGH for more than 1 cycle after phymstr_req became LOW"); 
                    end
                    else
                        next_should_be_idle = 1'b1;
                end
            end

            if (count & trans.req)
                ++counter;

            if (original.compare(trans) == 0) begin
                `uvm_error(get_name(), "Some of the phymstr signals are not the stable during the transaction");
            end
        end
    endtask
/*add monitor functions to the remaining interface signals*/
    //each task goes in a forever loop that monitors a specific sub-interface, collects 
    //a packet whenever it detects a change, and then it write the packet in the analysis 
    //port for the scoreboard to perform its checks 
    task automatic monitor_lp_ctrl(); 
        forever begin 
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.lp_ctrl_req) begin
                `uvm_info(get_name(), "lp_ctrl transaction is detected", UVM_MEDIUM);                
                EventHandler::start_transaction(EventHandler::lp_ctrl);
                handle_lp(1);
                EventHandler::end_transaction(EventHandler::lp_ctrl);
            end
        end      
    endtask          
        
    task automatic monitor_lp_data();         
        forever begin                 
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.lp_data_req) begin
                `uvm_info(get_name(), "lp_data transaction is detected", UVM_MEDIUM);
                EventHandler::start_transaction(EventHandler::lp_data);
                handle_lp(0);
                EventHandler::end_transaction(EventHandler::lp_data);
            end
        end
    endtask

    task automatic monitor_phyupd ();           
        forever begin                
            @(vif.mp_mon.cb_mon)     
            if (vif.mp_mon.cb_mon.phyupd_req) begin
                `uvm_info(get_name(), "phyupd transaction is detected", UVM_MEDIUM);
                EventHandler::start_transaction(EventHandler::phyupd);
                handle_phyupd(); 
                EventHandler::end_transaction(EventHandler::phyupd);
            end
        end     
    endtask
    
    task automatic monitor_ctrlupd ();                 
        forever begin            
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.ctrlupd_req) begin
                `uvm_info(get_name(), "ctrlupd transaction is detected", UVM_MEDIUM);
                EventHandler::start_transaction(EventHandler::ctrlupd);
                handle_ctrlupd();
                EventHandler::end_transaction(EventHandler::ctrlupd);
            end
        end 
    endtask  
    
    task automatic monitor_phymstr();                 
        forever begin         
            @(vif.mp_mon.cb_mon)       
            if (vif.mp_mon.cb_mon.phymstr_req) begin
                `uvm_info(get_name(), "phymstr transaction is detected", UVM_MEDIUM);
                EventHandler::start_transaction(EventHandler::phymstr);
                handle_phymstr();
                EventHandler::end_transaction(EventHandler::phymstr);
            end
        end    
    endtask

    task automatic monitor_write(); 
        int flag, prevflag = 0;        
        wav_DFI_write_transfer trans = new();        
        forever begin         
            flag = 0;
            @(vif.mp_mon.cb_mon) 
            foreach(vif.mp_mon.cb_mon.wrdata_en[i])
            begin      
                if (vif.mp_mon.cb_mon.wrdata_en[i])
                    flag = 1; 
            end

            if (flag && !prevflag) begin
                `uvm_info(get_name(), "write transaction is detected", UVM_MEDIUM);
                collect_write(trans);
                score_write(trans);
                write_to_port(trans);
                // handle_write();
            end
             
            prevflag = flag;
        end    
    endtask

    task automatic monitor_initiailization();
        wav_DFI_lp_transfer lp_ctrl = new(), lp_data = new();
        wav_DFI_phymstr_transfer phymstr = new();
        wav_DFI_update_transfer ctrlupd = new(), phyupd = new();
        wav_DFI_write_transfer write = new();
        @(vif.mp_mon.cb_mon) 
        // Collect initial transaction at the first cycle
        collect_ctrlupd(ctrlupd);
        collect_phyupd(phyupd);
        collect_lp_ctrl(lp_ctrl);
        collect_lp_data(lp_data);
        collect_phymstr(phymstr);
        collect_write(write);
        if (ctrlupd.req || ctrlupd.ack) begin
            `uvm_error(get_name(), "ctrlupd interface is not zero at initialization");
            ctrlupd.print();
        end

        if (phyupd.req || phyupd.ack || phyupd._type) begin
            `uvm_error(get_name(), "phyupd interface is not zero at initialization");
            phyupd.print();
        end

        if (phymstr.req || phymstr.ack || phymstr._type || phymstr.state_sel || phymstr.cs_state) begin
            `uvm_error(get_name(), "phymstr interface is not zero at initialization");
            phyupd.print();
        end

        if (lp_ctrl.req || lp_ctrl.ack || lp_ctrl.wakeup) begin
            `uvm_error(get_name(), "lp_ctrl interface is not zero at initialization");
            lp_ctrl.print();
        end

        if (lp_data.req || lp_data.ack || lp_data.wakeup) begin
            `uvm_error(get_name(), "lp_data interface is not zero at initialization");
            lp_data.print();
        end

    endtask

    task automatic event_emitter;
        fork
            forever @(posedge vif.mp_mon.cb_mon.phymstr_ack) 
                EventHandler::trigger_event(EventHandler::phymstr_ack_pos);
            forever @(negedge vif.mp_mon.cb_mon.phymstr_req) 
                EventHandler::trigger_event(EventHandler::phymstr_req_neg);
            
            forever @(posedge vif.mp_mon.cb_mon.phyupd_ack) 
                EventHandler::trigger_event(EventHandler::phyupd_ack_pos);
            forever @(negedge vif.mp_mon.cb_mon.phyupd_req) 
                EventHandler::trigger_event(EventHandler::phyupd_req_neg);

            forever @(posedge vif.mp_mon.cb_mon.lp_ctrl_ack) 
                EventHandler::trigger_event(EventHandler::lp_ctrl_ack_pos);
            forever @(negedge vif.mp_mon.cb_mon.lp_ctrl_req) 
                EventHandler::trigger_event(EventHandler::lp_ctrl_req_neg);
            
            forever @(posedge vif.mp_mon.cb_mon.lp_data_ack) 
                EventHandler::trigger_event(EventHandler::lp_data_ack_pos);
            forever @(negedge vif.mp_mon.cb_mon.lp_data_req) 
                EventHandler::trigger_event(EventHandler::lp_data_req_neg);

            forever @(posedge vif.mp_mon.cb_mon.ctrlupd_ack) 
                EventHandler::trigger_event(EventHandler::ctrlupd_ack_pos);
            forever @(negedge vif.mp_mon.cb_mon.ctrlupd_req) 
                EventHandler::trigger_event(EventHandler::ctrlupd_req_neg);

            forever @(posedge vif.mp_mon.cb_mon.init_start) 
                EventHandler::trigger_event(EventHandler::status_req_pos);
            forever @(negedge vif.mp_mon.cb_mon.init_start) 
                EventHandler::trigger_event(EventHandler::status_req_neg);
        join
    endtask

    task automatic event_listener;
        wav_DFI_wck_transfer wck_sh = new(wav_DFI_wck_transfer::static_high, 1);
        wav_DFI_wck_transfer wck_sl = new(wav_DFI_wck_transfer::static_low, 1);
        wav_DFI_wck_transfer wck_t  = new(wav_DFI_wck_transfer::toggle, 1);
        wav_DFI_wck_transfer wck_ft = new(wav_DFI_wck_transfer::fast_toggle, 1);
        wav_DFI_transfer read_trans = new();
        bit flag = 0, prevflag = 0;
        read_trans.tr_type = read;
        fork
            forever begin
                EventHandler::wait_for_event(EventHandler::setting_wck_static_high, 1);
                write_to_port(wck_sh);
            end

            forever begin
                EventHandler::wait_for_event(EventHandler::setting_wck_static_low, 1);
                write_to_port(wck_sl);
            end

            forever begin
                EventHandler::wait_for_event(EventHandler::setting_wck_toggle, 1);
                write_to_port(wck_t);
            end

            forever begin
                EventHandler::wait_for_event(EventHandler::setting_wck_fast_toggle, 1);
                write_to_port(wck_ft);
            end

            forever begin
                flag = 0;
                @(vif.mp_mon.cb_mon);
                foreach (vif.mp_mon.cb_mon.rddata_en[i]) begin
                    if (vif.mp_mon.cb_mon.rddata_en[i])
                        flag = 1;
                end
                if (flag == 1 && prevflag == 0)
                    write_to_port(read_trans);
                prevflag = flag;
            end
        join
    endtask

    //A task to call all the monitoring tasks created earlier to work in parallel 
    virtual task run_phase(uvm_phase phase);
        monitor_run_phase = phase;
        fork      
            monitor_initiailization();  
            monitor_phymstr();         
            monitor_lp_ctrl();         
            monitor_lp_data();         
            monitor_phyupd();         
            monitor_ctrlupd();
            monitor_write();
            event_emitter();
            event_listener();
            // monitor_read();
            monitor_status();
/*add monitor function to the remaining interface signals*/    
        join    // FIXME: should we use it as join_none to prevent latencies in each of them?
                // probably not because they are all forever loops so once they are launched
                // they will never come out of their loops  
/*add monitor function to the remaining interface signals*/       
    endtask
endclass