`ifndef WAV_DFI_TRANSFER_H_
`define WAV_DFI_TRANSFER_H_

`include "wav_DFI_defines.svh"

typedef enum {
    DFI, cmd, control, lp, phymstr, update, status_freq, read, write
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
    bit [63:0]               wrdata [0:3];
    bit                      parity_in [0:3];
    bit [1:0]                wrdata_cs [0:3];
    bit [7:0]                wrdata_mask [0:3];
    bit                           wrdata_en [0:3];
    bit [13:0]               address [0:3];
    bit [1:0]                cs [0:3];
    bit [1:0]                wck_cs [0:3];
    bit                      wck_en [0:3];
    bit [1:0]                wck_toggle [0:3];

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

// the unassigned (i.e., = x) bits should be assigned
// by the driver before sending them to the interface
// N.B. the bits are reversed from the order of
// the JEDEC in order to account for this reversed
// order in the DFI
typedef enum logic [13:0] {
    DES = 14'bxxxxxxx_xxxxxxx,
    NOP = 14'bxxxxxxx_0000000,
    PDE = 14'bxxxxxxx_1000000,
    ACT1 = 14'bxxxxxxx_xxxx111,
    ACT2 = 14'bxxxxxxx_xxxx011,
    PRE = 14'bxxxxxxx_1111000,
    REF = 14'bxxxxxxx_0111000,
    MWR = 14'bxxxxxxx_xxxx010,
    WR16 = 14'bxxxxxxx_xxxx110,
    WR32 = 14'bxxxxxxx_xxx0100,
    RD16 = 14'bxxxxxxx_xxxx001,
    RD32 = 14'bxxxxxxx_xxxx101,
	CAS_WR = 14'b0000000_0011100,
    CAS_RD = 14'b0000000_0011010,
    CAS_FS = 14'b0000000_0011001,
    CAS_OFF = 14'b0000000_0011111,
    MPC = 14'bxxxxxxx_x110000,
    SRE = 14'bxxxxxxx_1101000,
    SRX = 14'bxxxxxxx_0101000,
    MRW1 = 14'bxxxxxxx_1011000,
    MRW2 = 14'bxxxxxxx_x001000,
    MRR = 14'bxxxxxxx_0011000,
    WFF = 14'b0000000_1100000,
    RFF = 14'b0000000_0100000,
    RDC = 14'b0000000_1010000    
} cmd_t;

class wav_DFI_cmd_transfer extends wav_DFI_transfer;
    cmd_t cmd_mc[$]; // commmand coming from MC

    // TODO: modify the factory appropriately
    // TODO: add print function
    `uvm_object_utils(wav_DFI_cmd_transfer)

    function new(string name="wav_DFI_cmd_transfer"); 
        super.new(name); 
        tr_type = cmd;
    endfunction

endclass

typedef struct {
    bit [63:0] data;
    bit [7:0] dbi;
} read_data_t;

typedef struct {
    bit [17:0] row;
    bit [6:0] col;
    bit [1:0] bg;
    bit [3:0] ba;
} address_t;
// TODO: we can turn the read_sequence_item into an array of sequence items
// to ease things in the driver and the sequence 
class wav_DFI_read_transfer extends wav_DFI_transfer;
    
    address_t address;
    // wav_DFI_cmd_transfer cmd_seq_item;
    // acts as preamble to the read transaction
    cmd_t cmd_mc[$]; // commmand coming from MC
    bit [1:0] cs;
    read_data_t rd [$];
    // TODO: modify the factory appropriately
    // TODO: add print function
    `uvm_object_utils(wav_DFI_read_transfer)

    function new(string name="wav_DFI_read_transfer");
        super.new(name);
        tr_type = read;
        // cmd_seq_item = wav_DFI_cmd_transfer::type_id::create(cmd_seq_item);
    endfunction
endclass

class wav_DFI_status_transfer extends wav_DFI_transfer;
    bit [1:0] freq_fsp;
    bit [1:0] freq_ratio;
    bit [4:0] frequency;

    `uvm_object_utils(wav_DFI_status_transfer)
    // TODO: modify the factory appropriately
    // TODO: add print function
    function new(string name = "wav_DFI_status_transfer"); 
        super.new(name);
        tr_type = status_freq;
    endfunction
endclass

// TODO: create a generic data class to unify write and read data
`endif