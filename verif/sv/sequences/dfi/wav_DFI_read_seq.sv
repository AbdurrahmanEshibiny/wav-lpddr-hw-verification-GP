/*
class base_test extends uvm_test;
    task run_phase();
        run wavious_base_sequence;
    endtask;
endclass

class <your_test_name> extends base_test;
    task run_phase();
        super.run_phase();
        run your_sequence_name;
    endtask;
endclass 

class dfi_<seq_name>_seq extends uvm_sequence #(<your_trans_type>);

endclass
*/


`include "wav_DFI_transfer.sv"

class dfi_rd_seq extends extends wddr_base_seq; // uvm_sequence #(wav_DFI_write_transfer);

`uvm_object_utils(dfi_rd_seq)

    function new(string name = "dfi_rd_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err;
        // wav_DFI_cmd_transfer cmd_seq_item = new();
        dfi_data_seq_item rd_seq_item = new();
        data_trans data_item = new($urandom_range(1, 10) ,read_dir);

        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        start_item(rd_seq_item);
        // TODO: We should try to encapsulate these things
        // in the rd_seq_item class itself
        dfi_cmd_t cmd_ = DFI_ACT1;
        cmd_[6:3] = data_item.address.row[17:14];
        cmd_[10:7] = data_item.address.ba;
        cmd_[13:11] = data_item.address.row[13:11];
        data_item.preamble.push_back(cmd_);
        
        cmd_ = DFI_ACT2;
        cmd_[6:3] = data_item.address.row[10:7];
        cmd_[13:7] = data_item.address.row[6:0];
        data_item.preamble.push_back(cmd_);

        cmd_ = DFI_CAS_RD;
        data_item.preamble.push_back(cmd_);

        rd_seq_item.data_items.push_back(data_item);
        finish_item(rd_seq_item);


        // uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        
    endtask

/*
`uvm_object_utils (dif_activation_seq_no_violation);
function new(string name="dif_activation_seq_no_violation");
super.new(name);
endfunction
wav_DFI_write_transfer act_item;

virtual task body();
act_item=dif_activation_seq_no_violation::type_id::Create("dif_activation_seq_no_violation");
start_item(act_item);
act_item.address[0]=14'b00000000000111;
act_item.cs[0]=2'b11;
act_item.cs[1]=2'b11;
act_item.cs[2]=2'b11;
act_item.cs[3]=2'b11;
fnish_item(act_item);

start_item(act_item);
act_item.address[0]=14'b00000000000011;
act_item.cs[0]=2'b11;
act_item.cs[1]=2'b11;
act_item.cs[2]=2'b11;
act_item.cs[3]=2'b11;
fnish_item(act_item);

endtask
*/

endclass