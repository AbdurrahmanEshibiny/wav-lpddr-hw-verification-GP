typedef enum{DFI, control, lp, phymstr, update, status} type_e; 


// Base class for all DFI transactions
class wav_DFI_transfer extends uvm_sequence_item; 

    type_e tr_type; 
    
    `uvm_object_utils_begin(wav_DFI_transfer)
        `uvm_field_enum(type_e, tr_type, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name="wav_DFI_transfer"); 
        super.new(name); 
        tr_type = DFI;
    endfunction

endclass

// Base class for DFI control transactions (status, update, phymstr, lp)
class wav_DFI_control_transfer extends wav_DFI_transfer; 
    bit req; 
    bit ack; 
    
    `uvm_object_utils_begin(wav_DFI_control_transfer)
        `uvm_field_int(req, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(ack, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    function new(string name=" wav_DFI_control_transfer"); 
        super.new(name); 
        super.tr_type = control; 
    endfunction
endclass
    
    
class wav_DFI_lp_transfer extends wav_DFI_control_transfer; 
    rand bit [5:0] wakeup; 
    bit is_ctrl; //1 for lp_ctrl, 0 for lp_data 
        
    //constaint wakeup to be from 0 up to 19 inclusive 
    constraint wakeup_c {wakeup inside {[0: 19]};}

    `uvm_object_utils_begin(wav_DFI_lp_transfer)
        `uvm_field_int(wakeup, UVM_DEFAULT)
        `uvm_field_int(is_ctrl, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name="wav_DFI_lp_transfer"); 
        super.new(name); 
        super.tr_type = lp; 
    endfunction
endclass
    
    
class wav_DFI_phymstr_transfer extends wav_DFI_control_transfer;  
    rand bit [1:0] _type; 
    rand bit [1:0] cs_state; 
    rand bit state_sel; 

    `uvm_object_utils_begin(wav_DFI_phymstr_transfer)
        `uvm_field_int(_type, UVM_DEFAULT)
        `uvm_field_int(cs_state, UVM_DEFAULT)
        `uvm_field_int(state_sel, UVM_DEFAULT)
    `uvm_object_utils_end
        
    function new(string name = "wav_DFI_phymstr_transfer"); 
        super.new(name); 
        super.tr_type = phymstr; 
    endfunction
endclass
      
    
class wav_DFI_update_transfer extends wav_DFI_control_transfer; 
    rand bit [1:0] _type;	// meaningful only in case of phyupd 
    bit is_ctrl;	// 1 for ctrlupd, 0 for phyupd 
              
    `uvm_object_utils_begin(wav_DFI_update_transfer)
        `uvm_field_int(_type, UVM_DEFAULT)
        `uvm_field_int(is_ctrl, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "wav_DFI_update_transfer"); 
        super.new(name); 
        super.tr_type = update; 
    endfunction
endclass