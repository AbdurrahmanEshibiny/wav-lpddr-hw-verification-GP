// import uvm_pkg::*;
// `include "uvm_macros.svh"

interface gp_LPDDR5_channel_intf(
	wire ddr_reset_n,
    wire ddr_rext,
    wire ddr_test
);	

    wire ca0;
    wire ca1;
    wire ca2;
    wire ca3;
    wire ca4;
    wire ca5;
    wire ca6;
    wire cs0;
    wire cs1;
    wire ck_c;
    wire ck_t;

    wire dq0_wck_t;
    wire dq1_wck_t;
    wire dq0_wck_c;
    wire dq1_wck_c;
    wire dq0_dqs_t;
    wire dq1_dqs_t;
    wire dq0_dqs_c;
    wire dq1_dqs_c;
    wire dq0_dq0;
    wire dq0_dq1;
    wire dq0_dq2;
    wire dq0_dq3;
    wire dq0_dq4;
    wire dq0_dq5;
    wire dq0_dq6;
    wire dq0_dq7;
    wire dq0_dbim;
    wire dq1_dq0;
    wire dq1_dq1;
    wire dq1_dq2;
    wire dq1_dq3;
    wire dq1_dq4;
    wire dq1_dq5;
    wire dq1_dq6;
    wire dq1_dq7;
    wire dq1_dbim;

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

	// sequence CAS;
	// 	@(posedge ck_t) (cs==1 && ca[0:3]==4'b0011);
	// endsequence

	sequence CAS_WR;
		(cs==1 && ca[0:6]==7'b0011100);///
	endsequence	

	sequence CAS_RD;
		(cs==1 && ca[0:6]==7'b0011010);//
	endsequence	

	sequence CAS_FS;
		(cs==1 && ca[0:6]==7'b0011001);//
	endsequence	

	sequence CAS_OFF;
		(cs==1 && ca[0:6]==7'b0011111);//
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
			PDE |=> ##5 ~$isunknown(ck_t); //tCSLCK
	endproperty		
	
	property check_clock_during_write16;
	@(posedge ck_t)	
			WR16 |=> ~$isunknown(dq0_wck_t)[*6]; //[*latency_with_clock_cycles_in_16]
	endproperty		
	property check_clock_during_MWR;
	@(posedge ck_t)	
			MWR |=> ~$isunknown(dq0_wck_t)[*6]; //[*latency_with_clock_cycles_in_16]
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

	//------------------------------Ziad's stuff--------------------------------------
	logic [15:0] DQ;	
	assign DQ = {	dq1_dq7,dq1_dq6,dq1_dq5,dq1_dq4,dq1_dq3,dq1_dq2,dq1_dq1,dq1_dq0,
					dq0_dq7,dq0_dq6,dq0_dq5,dq0_dq4,dq0_dq3,dq0_dq2,dq0_dq1,dq0_dq0
				};
	//assertions layer
	//NOTE `uvm_error needs to be tested outside of uvm class
	
	CAS_WR_property: assert property(@(posedge ck_t) (CAS_WR) |=> ((WR32) or (WR16) or (MWR))
	) else $error("CAS_WR Property Assertion Failed");//`uvm_error("gp_lpddr5_monitor", "CAS_WR Property Assertion Failed")

	CAS_RD_property: assert property(@(posedge ck_t) (CAS_WR) |=> ((RD32) or (RD16))
	) else $error("CAS_RD Property Assertion Failed");//`uvm_error("gp_lpddr5_monitor", "CAS_RD Property Assertion Failed")

	CAS_FS_Property: assert property(@(posedge ck_t) 
		(CAS_FS) |-> ((##[1:8]WR32) or (##[1:8]WR16) or (##[1:8]MWR)or (##[1:8]RD32) or (##[1:8]RD16) or (##[1:$]CAS_OFF))
	) else $error("CAS_FS Property Assertion Failed");//`uvm_error("gp_lpddr5_monitor", "CAS_FS Property Assertion Failed")

endinterface : gp_LPDDR5_channel_intf
