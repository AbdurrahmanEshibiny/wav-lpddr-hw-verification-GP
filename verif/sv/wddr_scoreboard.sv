//`uvm_analysis_imp_decl(_LPDDR5_2)
//`uvm_analysis_imp_decl(_DFI_2)

class wddr_scoreboard extends uvm_scoreboard;
 
    `uvm_component_utils(wddr_scoreboard)
    //gp_LPDDR5_agent              lpddr5_agent;
    uvm_tlm_analysis_fifo #(wav_DFI_write_transfer) fifo_sent;  
    uvm_tlm_analysis_fifo #(wav_DFI_write_transfer) fifo_recieved; 
    uvm_analysis_export #(wav_DFI_write_transfer) lpddr5_sequence_item;        
    uvm_analysis_export #(wav_DFI_write_transfer) dfi_sequence_item;
    wav_DFI_write_transfer transaction_sent;
    wav_DFI_write_transfer transaction_recieved;
    int ratio;

    function new(string name, uvm_component parent);
       super.new(name, parent);
        transaction_sent = new();
        transaction_recieved = new(); 
    endfunction  
   
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //lpddr5_agent     = gp_LPDDR5_agent::type_id::create("lpddr5_agent", this);
        if(! uvm_config_db #(int) :: get(this, "", "ratio", ratio))
			`uvm_info("gp_LPDDR5_monitor", "Failed Ratio", UVM_MEDIUM)
        lpddr5_sequence_item = new("lpddr5_sequnce_item", this);
        dfi_sequence_item = new("dfi_sequnce_item", this);
        fifo_sent = new("fifo_sent", this);
        fifo_recieved = new("fifo_recieved", this);
    endfunction
   
    function void connect_phase(uvm_phase phase);
        dfi_sequence_item.connect(fifo_sent.analysis_export);
        lpddr5_sequence_item.connect(fifo_recieved.analysis_export);
    endfunction
   
    task run();
        forever begin
        fork
            begin 
                fifo_sent.get(transaction_sent);
                `uvm_info("wddr_scoreboard",$sformatf("sent transaction is: %p",transaction_sent), UVM_LOW)
            end
            begin
                fifo_recieved.get(transaction_recieved);
                `uvm_info("wddr_scoreboard",$sformatf("recieved transaction is: %p",transaction_recieved), UVM_MEDIUM)

            end
        join
        compare();
        end
    endtask
   
    function void compare();
    if(ratio == 2)begin
    if( transaction_recieved.wrdata[0][15:0] == transaction_sent.wrdata[0][15:0]  &&  transaction_recieved.wrdata[2][15:0] == transaction_sent.wrdata[2][15:0] ) begin
    //if( transaction_recieved.wrdata[0]== transaction_sent.wrdata[0] &&  transaction_recieved.wrdata[1] == transaction_sent.wrdata[1] ) begin
        `uvm_info("compare", $sformatf("Write Test Passed"), UVM_MEDIUM);
    end 
    else begin
        `uvm_info("compare", $sformatf("Test Failed"), UVM_MEDIUM);
    end
    end
    if(ratio == 4)begin
    //if( transaction_recieved.wrdata[0][15:0] == transaction_sent.wrdata[0][15:0]  &&  transaction_recieved.wrdata[2][15:0] == transaction_sent.wrdata[2][15:0] ) begin
    if( transaction_recieved.wrdata[0]== transaction_sent.wrdata[0] &&  transaction_recieved.wrdata[1] == transaction_sent.wrdata[1] ) begin
        `uvm_info("compare", $sformatf("Write Test Passed"), UVM_MEDIUM);
    end 
    else begin
        `uvm_info("compare", $sformatf("Test Failed"), UVM_MEDIUM);
    end
    end

    endfunction
   
   
endclass