`ifndef _WAV_DFI_STATUS_SEQ_
`define _WAV_DFI_STATUS_SEQ_

// `include "wav_DFI_transfer.sv"

class wav_DFI_status_seq extends wddr_base_seq; // uvm_sequence #(wav_DFI_write_transfer);

`uvm_object_utils(wav_DFI_status_seq);

wav_DFI_status_transfer seq_item;

    function new(string name = "wav_DFI_status_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err;
        seq_item = wav_DFI_status_transfer::type_id::create("seq_item");
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
            
        // according to the RTL, the interface value of the init_start is almost ignored
        // so we have to use the registers
        // this task will override the value of the init_start in the registers
        // according to the value we want on the interface        
        handle_status_internally(); // defined in the driver    
        
        start_item(seq_item);
        assert(seq_item.randomize());
        finish_item(seq_item);       
        
        `uvm_info(
            get_name(),
            $sformatf("STATUS SEQUENCE: FSP: %0d, Ratio = %0d, Freq = %0d", 
            seq_item.freq_fsp, seq_item.freq_ratio, seq_item.frequency),
            UVM_MEDIUM
        )        
            
        // wait for the start and end of the transaction
        EventHandler::wait_for_transaction(EventHandler::status); //defined in the wav_DFI_events

        // `uvm_send(seq_item);
        // fsp = 0, ratio = 4:1, frequency = 3200

        // uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        
    endtask    
endclass

`endif