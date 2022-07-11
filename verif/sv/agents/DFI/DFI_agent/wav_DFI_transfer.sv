`ifndef WAV_DFI_TRANSFER_H_
`define WAV_DFI_TRANSFER_H_

`include "wav_DFI_defines.svh"

typedef enum {
    DFI, cmd, control, lp, phymstr, update, status_freq, read, write, data
    } type_e;


// Base class for all DFI transactions
class wav_DFI_transfer extends uvm_sequence_item; 

    type_e tr_type; 
    bit is_rsp_required;
    
    `uvm_object_utils_begin(wav_DFI_transfer)
        `uvm_field_enum(type_e, tr_type, UVM_DEFAULT)
        `uvm_field_int(is_rsp_required, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name="wav_DFI_transfer"); 
        super.new(name); 
        tr_type = DFI;
        is_rsp_required = 1;
    endfunction

    virtual function void reset();

    endfunction
endclass


// Base class for DFI write transactions 
class wav_DFI_write_transfer extends wav_DFI_transfer; 
    rand bit [63:0]               wrdata [0:3];

    // randomization will be turned off by default in the "new" the constructor
    rand bit                      parity_in [0:3];
    rand bit [7:0]                wrdata_mask [0:3];

    bit [1:0]                wrdata_cs [0:3];
    bit                      wrdata_en [0:3];
    rand bit [13:0]          address [0:3];
    bit [1:0]                cs [0:3];
    bit [1:0]                cke [0:3];
    bit [1:0]                wck_cs [0:3];
    bit                      wck_en [0:3];
    bit [1:0]                wck_toggle [0:3];
    bit                      dram_clk_disable [0:3];

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
        `uvm_field_sarray_int(cs, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(cke, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_sarray_int(dram_clk_disable, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    function new(string name=" wav_DFI_write_transfer"); 
        super.new(name); 
        super.tr_type = write; 
        foreach(parity_in[i])
            parity_in[i].rand_mode(0);
        foreach(wrdata_mask[i])
            wrdata_mask[i].rand_mode(0);
        foreach(address[i])
            address[i].rand_mode(0);
    endfunction

    function void enable_randomization;
        foreach(parity_in[i])
            parity_in[i].rand_mode(1);
        foreach(wrdata_mask[i])
            wrdata_mask[i].rand_mode(1);
        foreach(address[i])
            address[i].rand_mode(1);
    endfunction

    virtual function void reset();
        wrdata = '{default:0};
        parity_in = '{default:0};
        wrdata_cs = '{default:0};
        wrdata_mask = '{default:0};
        wrdata_en = '{default:0};
        address = '{default:0};
        cs = '{default:0};
        wck_cs = '{default:0};
        wck_en = '{default:0};
        wck_toggle = '{default:0};
        dram_clk_disable = '{default:0};
    endfunction
endclass

// Base class for DFI control transactions (status, update, phymstr, lp)
/*
need to ask samuel about this:
*/
class wav_DFI_control_transfer extends wav_DFI_transfer; 
    bit req; 
    bit ack; 
    rand bit [7:0] cyclesCount;   // how many cycles should the trans be driven before returning to idle
    
    `uvm_object_utils_begin(wav_DFI_control_transfer)
        `uvm_field_int(req, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(ack, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int(cyclesCount, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    function new(string name=" wav_DFI_control_transfer"); 
        super.new(name); 
        super.tr_type = control; 
        reset();
    endfunction

    virtual function void reset();
        this.req = 0;
        this.ack = 0;
        this.cyclesCount = 0;
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
        reset();
    endfunction

    virtual function void reset();
        super.reset();
        this.wakeup = 0;
        this.is_ctrl = 0;
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
        this.reset();
    endfunction

    virtual function void reset();
        super.reset();
        this._type = 0;
        this.cs_state = 0;
        this.state_sel = 0;
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
        this.reset();
    endfunction

    virtual function void reset();
        super.reset();
        this._type = 0;
        this.is_ctrl = 0;
    endfunction
endclass

// the unassigned (i.e., = x) bits should be assigned
// by the driver before sending them to the interface
// N.B. the bits are reversed from the order of
// the JEDEC in order to account for this reversed
// order in the DFI
typedef enum logic [13:0] {
    DFI_DES = 14'bxxxxxxx_xxxxxxx,
    DFI_NOP = 14'bxxxxxxx_0000000,
    DFI_PDE = 14'bxxxxxxx_1000000,
    DFI_ACT1 = 14'bxxxxxxx_xxxx111,
    DFI_ACT2 = 14'bxxxxxxx_xxxx011,
    DFI_PRE = 14'bxxxxxxx_1111000,
    DFI_REF = 14'bxxxxxxx_0111000,
    DFI_MWR = 14'bxxxxxxx_xxxx010,
    DFI_WR16 = 14'bxxxxxxx_xxxx110,
    DFI_WR32 = 14'bxxxxxxx_xxx0100,
    DFI_RD16 = 14'bxxxxxxx_xxxx001,
    DFI_RD32 = 14'bxxxxxxx_xxxx101,
	DFI_CAS_WR = 14'b0000000_0011100,
    DFI_CAS_RD = 14'b0000000_0011010,
    DFI_CAS_FS = 14'b0000000_0011001,
    DFI_CAS_OFF = 14'b0000000_0011111,
    DFI_MPC = 14'bxxxxxxx_x110000,
    DFI_SRE = 14'bxxxxxxx_1101000,
    DFI_SRX = 14'bxxxxxxx_0101000,
    DFI_MRW1 = 14'bxxxxxxx_1011000,
    DFI_MRW2 = 14'bxxxxxxx_x001000,
    DFI_MRR = 14'bxxxxxxx_0011000,
    DFI_WFF = 14'b0000000_1100000,
    DFI_RFF = 14'b0000000_0100000,
    DFI_RDC = 14'b0000000_1010000
} dfi_cmd_t;

`define right_cmd(cmd) (cmd[6:0])
`define left_cmd(cmd) (cmd[13:7])


class dfi_data extends uvm_object;
    
    bit [63:0] data;
    bit [7:0] dbi;

    `uvm_object_utils_begin(dfi_data)
        `uvm_field_int(data, UVM_DEFAULT)
        `uvm_field_int(dbi, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "dfi_data");
        super.new(name);
    endfunction

endclass

class dram_address extends uvm_object;

    rand bit [17:0] row;
    rand bit [6:0] col;
    rand bit [1:0] bg;
    rand bit [3:0] ba;
    rand bit [1:0] cs;

    `uvm_object_utils_begin(dram_address)
        `uvm_field_int(row, UVM_DEFAULT)
        `uvm_field_int(col, UVM_DEFAULT)
        `uvm_field_int(bg, UVM_DEFAULT)
        `uvm_field_int(ba, UVM_DEFAULT)
        `uvm_field_int(cs, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "dram_address");
        super.new(name);
    endfunction

endclass

virtual class DFI_data_seq_item extends wav_DFI_transfer;

    dfi_cmd_t preamble [$];
    rand dram_address address;
    dfi_data data [$];
    rand int data_len;
    // bit is_last;
    // bit [2:0] final_en;

    // constraint c_is_last {if (is_last) final_en == 0;}
    // constraint c_data_len {
    //     data_len <= data.size();
    // }

    `uvm_object_utils_begin(DFI_data_seq_item)
        `uvm_field_queue_enum(dfi_cmd_t, preamble, UVM_DEFAULT)
        `uvm_field_object(address, UVM_DEFAULT)
        `uvm_field_queue_object(data, UVM_DEFAULT)
        `uvm_field_int(data_len, UVM_DEFAULT)
        // `uvm_field_int(is_last, UVM_COPY)
        // `uvm_field_int(final_en, UVM_COPY)
    `uvm_object_utils_end

    function new(string name = "DFI_data_seq_item", type_e tr_type = DFI);
        super.new(name);
        super.tr_type = tr_type;
        address = dram_address::type_id::create("address");
    endfunction

endclass


class DFI_rd_seq_item extends DFI_data_seq_item;
    // int trddata_en;
    // int tphy_rdcslat;

    `uvm_object_utils_begin(DFI_rd_seq_item)
        // `uvm_field_int(trddata_en, UVM_COPY)
        // `uvm_field_int(tphy_rdcslat, UVM_COPY)
    `uvm_object_utils_end

    function new(string name = "DFI_rd_seq_item");
        super.new(name, read);
    endfunction

endclass

class DFI_wr_seq_item extends DFI_data_seq_item;

    `uvm_object_utils(DFI_wr_seq_item)

    function new(string name = "DFI_rd_seq_item");
        super.new(name, write);
    endfunction
    
endclass

class DFI_rd_slice extends uvm_object;
    bit [13:0] address [0:3];
    bit [1:0] cs [0:3];
    bit [63:0] rddata [0:3];
    bit [1:0] rddata_cs [0:3];
    bit [7:0] rddata_dbi [0:3];
    bit rddata_en [0:3];
    bit rddata_valid [0:3];
    bit [1:0] wck_cs [0:3];
    bit wck_en [0:3];
    bit [1:0] wck_toggle [0:3];
    
    // int trddata_en;
    // int tphy_rdcslat;


    `uvm_object_utils_begin(DFI_rd_slice)
        `uvm_field_sarray_int(address, UVM_DEFAULT)
        `uvm_field_sarray_int(cs, UVM_DEFAULT)
        `uvm_field_sarray_int(rddata, UVM_DEFAULT)
        `uvm_field_sarray_int(rddata_cs, UVM_DEFAULT)
        `uvm_field_sarray_int(rddata_dbi, UVM_DEFAULT)
        `uvm_field_sarray_int(rddata_en, UVM_DEFAULT)
        `uvm_field_sarray_int(rddata_valid, UVM_DEFAULT)
        `uvm_field_sarray_int(wck_cs, UVM_DEFAULT)
        `uvm_field_sarray_int(wck_en, UVM_DEFAULT)
        `uvm_field_sarray_int(wck_toggle, UVM_DEFAULT)
        // `uvm_field_int(trddata_en, UVM_DEFAULT)
        // `uvm_field_int(tphy_rdcslat, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "DFI_rd_slice");
        super.new(name);
    endfunction
endclass

class DFI_rd_stream_seq_item extends wav_DFI_transfer;
    DFI_rd_slice slice_q [$];

    `uvm_object_utils_begin(DFI_rd_stream_seq_item)
        `uvm_field_queue_object(slice_q, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "DFI_rd_stream_seq_item");
        super.new(name);
        tr_type = read;
    endfunction 
endclass

/*
class data_trans extends uvm_object;

    dfi_cmd_t preamble [$];
    address_t address;
    rand data_t data [$];
    int data_len;
    

    `uvm_object_utils_begin (data_trans)
        `uvm_field_int(address.row)
    `uvm_component_utils_end

    function new(int data_len = 0, data_dir_t dir);
        this.data_len = data_len;
        this.dir = dir;
    endfunction
    // constraint c_data_len {if (this.data_len != 0) data.size() == data_len;}
endclass

class dfi_data_seq_item extends wav_DFI_transfer;
    // TODO: modify the factory appropriately
    // TODO: add print function
    `uvm_object_utils(dfi_data_seq_item)

    data_trans data_items [$];

    function new(string name = "dfi_data_seq_item");
        super.new(name);
        super.tr_type = data;
    endfunction
endclass
*/


class wav_DFI_cmd_transfer extends wav_DFI_transfer;
    dfi_cmd_t cmd_mc[$]; // commmand coming from MC
    rand    bit [13:0]  address[0:3];  
    rand    bit         dram_clk_disable[0:3];
    rand    bit [1:0]   cke [0:3];
    rand    bit [1:0]   cs[0:3];
    rand    bit         parity_in[0:3];
	        bit 		reset_n[0:3];

    `uvm_object_utils_begin(wav_DFI_cmd_transfer)
        `uvm_field_sarray_int(parity_in, UVM_DEFAULT)
        `uvm_field_sarray_int(address, UVM_DEFAULT)
        `uvm_field_sarray_int(cs, UVM_DEFAULT)
        `uvm_field_sarray_int(cke, UVM_DEFAULT)
		`uvm_field_sarray_int(reset_n, UVM_DEFAULT)
        `uvm_field_sarray_int(dram_clk_disable, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name="wav_DFI_cmd_transfer"); 
        super.new(name); 
        tr_type = cmd;
    endfunction

endclass

// TODO: we can turn the read_sequence_item into an array of sequence items
// to ease things in the driver and the sequence
/*
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
*/

class wav_DFI_status_transfer extends wav_DFI_control_transfer;
    
    rand bit [1:0] freq_fsp;
    rand bit [1:0] freq_ratio;
    rand bit [4:0] frequency;

    `uvm_object_utils_begin(wav_DFI_status_transfer)
        `uvm_field_int(freq_fsp, UVM_DEFAULT)
        `uvm_field_int(freq_ratio, UVM_DEFAULT)
        `uvm_field_int(frequency, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "wav_DFI_status_transfer"); 
        super.new(name);
        tr_type = status_freq;
    endfunction
endclass

`endif