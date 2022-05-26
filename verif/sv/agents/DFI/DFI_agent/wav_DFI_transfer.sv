`ifndef WAV_DFI_TRANSFER_H_
`define WAV_DFI_TRANSFER_H_

// ensure this line does not make problems
`include "wav_DFI_defines.svh"

/// ask samuel about this
typedef enum {
    DFI, control, lp, phymstr, update, status_freq, read, write
    } type_e;


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

// Base class for DFI write transactions 
class wav_DFI_write_transfer extends wav_DFI_transfer; 
    rand bit [63:0]               wrdata [0:3];
    rand bit                      parity_in [0:3];
    rand bit [1:0]                wrdata_cs [0:3];
    rand bit [7:0]                wrdata_mask [0:3];
    rand bit                      wrdata_en [0:3];
    rand bit [13:0]               address [0:3];

    rand bit [1:0]                wck_cs [0:3];
    rand bit                      wck_en [0:3];
    rand bit [1:0]                wck_toggle [0:3];

    `uvm_object_utils_begin(wav_DFI_write_transfer)
        `uvm_field_sarray_int(wrdata, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(parity_in, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(wrdata_cs, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(wrdata_mask, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(wrdata_en, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(address, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(wck_cs, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(wck_en, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(wck_toggle, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    function new(string name=" wav_DFI_write_transfer"); 
        super.new(name); 
        super.tr_type = write; 
    endfunction
endclass

// Base class for DFI control transactions (status, update, phymstr, lp)
/*
need to ask samuel about this:
*/
class wav_DFI_control_transfer extends wav_DFI_transfer; 
    bit req; 
    bit ack; 
    rand bit [15:0] cyclesCount;   // how many cycles should the trans be driven before returning to idle
    
    `uvm_object_utils_begin(wav_DFI_control_transfer)
        `uvm_field_int(req, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(ack, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(cyclesCount, UVM_DEFAULT | UVM_NOCOMPARE)
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

    constraint cyclesCount_c {
        super.cyclesCount >= (`tlp_resp);
    }

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

    constraint cyclesCount_c {
        super.cyclesCount inside {[(`tctrlupd_min) : (`tctrlupd_max)]};
    }
    
    function new(string name = "wav_DFI_update_transfer"); 
        super.new(name); 
        super.tr_type = update; 
    endfunction
endclass

typedef struct {
    bit [63:0] data;
    bit [7:0] dbi;
} read_data_t;


class wav_DFI_read_transfer extends wav_DFI_transfer;
    
    // TODO: add address here

    bit [1:0] cs;
    read_data_t rd [$];

    // TODO: modify the factory appropriately
    `uvm_object_utils(wav_DFI_read_transfer);

    function new(string name="wav_DFI_read_transfer");
        super.new(name);
        tr_type = read;
    endfunction
endclass

//extend the base class to implement remaining interfaces

`endif