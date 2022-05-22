interface gp_LPDDR5_channel_intf(
	logic ddr_reset_n,
    logic ddr_rext,
    logic ddr_test
);

    logic ca0;
    logic ca1;
    logic ca2;
    logic ca3;
    logic ca4;
    logic ca5;
    logic ca6;
    logic cs0;
    logic cs1;
    logic ck_c;
    logic ck_t;

    logic dq0_wck_t;
    logic dq1_wck_t;
    logic dq0_wck_c;
    logic dq1_wck_c;
    logic dq0_dqs_t;
    logic dq1_dqs_t;
    logic dq0_dqs_c;
    logic dq1_dqs_c;
    logic dq0_dq0;
    logic dq0_dq1;
    logic dq0_dq2;
    logic dq0_dq3;
    logic dq0_dq4;
    logic dq0_dq5;
    logic dq0_dq6;
    logic dq0_dq7;
    logic dq0_dbim;
    logic dq1_dq0;
    logic dq1_dq1;
    logic dq1_dq2;
    logic dq1_dq3;
    logic dq1_dq4;
    logic dq1_dq5;
    logic dq1_dq6;
    logic dq1_dq7;
    logic dq1_dbim;

	logic [0:6] ca;
	assign ca = {ca0, ca1, ca2, ca3, ca4, ca5, ca6};

	logic cs;
	assign cs = cs0 | cs1;

	//-------------------timing parameter declarations-------------------------------
	int min_reset_time = 1;
	int tREFi = 1;
	int min_delay_between_act_to_ref = 1;
	int tCKCSH = 1;
	int tCSLCK = 1;
	int BL = 16, tCK = 8;
	int latency_with_clock_cycles_in_16 = BL + 0.5* tCK;
	int latency_with_clock_cycles_in_32 = BL + 0.5* tCK;;
	//----------------------------Sequences------------------------------------------

	sequence PDE;
		@(posedge ck_t) (cs==1 && ca==7'b0000001) ##1 (cs==0);
	endsequence

	sequence ACT1;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b111);
	endsequence

	sequence ACT2;
		@(posedge ck_t) (cs==1 && ca[2:0]==3'b110);
	endsequence

	sequence PRE;
		@(posedge ck_t) (cs==1 && ca==7'b0001111);
	endsequence

	sequence REF;
		@(posedge ck_t) (cs==1 && ca==7'b0001110);
	endsequence

	sequence MWR;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b010);
	endsequence

	sequence WR16;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b011);
	endsequence

	sequence WR32;
		@(posedge ck_t) (cs==1 && ca[0:3]==4'b0010);
	endsequence
	
	sequence RD16;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b100);
	endsequence

	sequence RD32;
		@(posedge ck_t) (cs==1 && ca[0:3]==3'b101);
	endsequence

	sequence CAS;
		@(posedge ck_t) (cs==1 && ca[0:3]==4'b0011);
	endsequence

	sequence MPC;
		@(posedge ck_t) (cs==1 && ca[0:5]==6'b000011);
	endsequence

	sequence SRE;
		@(posedge ck_t) (cs==1 && ca==7'b0001011);
	endsequence

	sequence SRX;
		@(posedge ck_t) (cs==1 && ca[0:3]==4'b0010);
	endsequence

	sequence MRW1;
		@(posedge ck_t) (cs==1 && ca[0:6]==7'b0001101);
	endsequence

	sequence MRW2;
		@(posedge ck_t) (cs==1 && ca[0:5]==6'b000100);
	endsequence

	sequence MRR;
		@(posedge ck_t) (cs==1 && ca[0:6]==7'b0001100);
	endsequence

	sequence WFF;
		@(posedge ck_t) (cs==1 && ca==7'b0000011);
	endsequence

	sequence RFF;
		@(posedge ck_t) (cs==1 && ca==7'b0000010);
	endsequence

	sequence PDX;
		@(posedge ck_t) (cs==0 && ca==7'b0000001);
	endsequence

	//----------------------------Properties------------------------------------------

	property Max_Refresh_Interval;
		@(posedge ck_t) 
			   (REF |-> ##[1: 2] REF); //[tREFi: 2*tREFi]
		endproperty
	
		property Illegal_refresh_after_activate;
		@(posedge ck_t)
			  ACT1 |-> not (##[0: 6] (REF)); //[0: min_delay_between_act_to_ref]
		endproperty
	
		property clock_stable_before_PDX;
		@(posedge ck_t)
			  PDX |=> $past(dq0_wck_t, tCKCSH) != 'bZ; 
		endproperty
	
		property clock_off_after_PDE;
		@(posedge ck_t)
			  PDE |=> ##5 ~isunknown(ck_t); //tCSLCK
		endproperty
		
		property check_clock_during_write16;
		@(posedge ck_t)
			  WR16 |=> ~isunknown(dq0_wck_t)[*6]; //[*latency_with_clock_cycles_in_16]
		endproperty
		property check_clock_during_MWR;
		@(posedge ck_t)
			  MWR |=> ~isunknown(dq0_wck_t)[*6]; //[*latency_with_clock_cycles_in_16]
		endproperty
		
	
		//----------------------------Assertions------------------------------------------
		
		assertion1: 
			assert property (@(negedge ddr_reset_n)  ##[5: $] ddr_reset_n); //##[min_reset_time: $]
		assertion2:
			assert property (@(posedge ck_t) Max_Refresh_Interval);
		assertion3:
			assert property (@(posedge ck_t) Illegal_refresh_after_activate);
		assertion4:
			assert property (@(posedge ck_t) clock_stable_before_PDX);
		assertion5:
			assert property (@(posedge ck_t) clock_off_after_PDE);
		assertion6:
			assert property (@(posedge ck_t) check_clock_during_write16);
		assertion7:
			assert property (@(posedge ck_t) check_clock_during_MWR);

endinterface : gp_LPDDR5_channel_intf
