class wav_DFI_write_seq extends uvm_sequence #(wav_DFI_write_transfer);

    `uvm_object_utils(wav_DFI_ctrlupd_seq)

    function new(string name = "wav_DFI_write_seq");
        super.new(name);  
    endfunction

    

endclass