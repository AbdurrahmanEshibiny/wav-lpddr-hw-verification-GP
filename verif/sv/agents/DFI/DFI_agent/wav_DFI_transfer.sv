`ifndef WAV_DFI_TRANSFER_H_
`define WAV_DFI_TRANSFER_H_

// ensure this line does not make problems
`include "wav_DFI_defines.svh"

/// ask samuel about this
typedef enum{DFI, control, lp, phymstr, update, status_freq, read, write} type_e;

/*
typedef struct {
    bit dfi_act_n;
    bit [13:0] dfi_address;
    bit [`WAV_DFI_BANK_WIDTH-1:0] dfi_bank;
    bit [`WAV_DFI_BG_WIDTH-1:0] dfi_bg;
    bit dfi_cas_n;
    bit [`WAV_DFI_CID_WIDTH-1:0] dfi_cid;
    bit [`WAV_DFI_CKE_WIDTH-1:0] dfi_cke;
    bit [`WAV_DFI_CS_WIDTH-1:0] dfi_cs;
    bit [`WAV_DFI_DRAM_CLK_DISABLE_WIDTH-1:0] dfi_dram_clk_disable;
    bit [`WAV_DFI_ODT_WIDTH-1:0] dfi_odt;
    // parity not implemented so we ignore it
    bit dfi_ras_n;
    bit [`WAV_DFI_RESET_WIDTH-1:0]dfi_reset_n;
    bit dfi_we_n;
} cmd_t; // this struct will be used for both read and write
*/

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
    bit                      wrdata_en [0:3];
    bit [13:0]               address [0:3];

    `uvm_object_utils_begin(wav_DFI_control_transfer)
        `uvm_field_int(wrdata, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(parity_in, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(wrdata_cs, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(wrdata_mask, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(wrdata_en, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(address, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    function new(string name=" wav_DFI_write_transfer"); 
        super.new(name); 
        super.tr_type = write; 
    endfunction
endclass

// Base class for DFI wck transactions 
class wav_DFI_wck_transfer extends wav_wck_transfer; 
    bit [1:0]                wck_cs [0:3];
    bit                      wck_en [0:3];
    bit [1:0]                wck_toggle [0:3];

    `uvm_object_utils_begin(wav_DFI_control_transfer)
        `uvm_field_int(wck_cs, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(wck_en, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(wck_toggle, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    function new(string name=" wav_DFI_wck_transfer"); 
        super.new(name); 
        super.tr_type = wck; 
    endfunction
endclass


// Base class for DFI control transactions (status, update, phymstr, lp)
/*
need to ask samuel about this:
*/
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


/*
// virtual to prevent making instances of it
// both read and write should create their own classes 
// by inheriting from this class

virtual class rw extends wav_DFI_transfer;
    // cmd_t command;

    // modify the factory appropriately
    `uvm_object_utils(rw);

    function new(string name="");
        super.new(name);
    endfunction //new()
endclass
*/

class read extends wav_DFI_transfer;
    bit [`WAV_DFI_DATA_WIDTH-1:0] dfi_rddata;
    bit [`WAV_DFI_PHYSICAL_RANK_WIDTH-1:0] dfi_rddata_cs;
    bit [`WAV_DFI_DBI_WIDTH-1:0] dfi_rddata_dbi;
    bit [(`WAV_DFI_DATA_WIDTH/8)-1:0] dfi_rddata_dnv;
    bit [`WAV_DFI_DATA_EN_WIDTH-1:0] dfi_rddata_en;
    bit [`WAV_READ_DATA_VALID_WIDTH-1:0] dfi_rddata_valid;
    

    // modify the factory appropriately
    `uvm_object_utils(read);

    function new(string name="read_seq_item");
        super.new(name);
        tr_type = read;
    endfunction
endclass

//extend the base class to implement remaining interfaces

`endif