class wav_DFI_sequencer extends uvm_sequencer #(wav_DFI_transfer);

    `uvm_component_utils(wav_DFI_sequencer)
 
   function new (string name, uvm_component parent);
     super.new(name, parent);
   endfunction
 
 endclass