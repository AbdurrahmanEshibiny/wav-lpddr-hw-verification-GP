`define ma 200
`define maxx 12
`define minn 8//`RU(`tRCD/`tCK)
`define max(a, b) (``a`` > ``b``)? ``a``:``b``
`define min(a, b) (``a`` < ``b``)? ``a``:``b``
`define period 20
`define tCK 20
`define max_WR16orMWR_after_WR16orMWR_ANB (`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//8*tCK
`define max_MWR_after_WR16orMWR_SB /*20*`tCK*/(`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//8*tCK
`define min_WR16_after_WR16orMWR_ANB `BL_nmax*`tCK//4*tCK
`define min_MWR_after_WR16orMWR_SB 4*`BL_nmax*`tCK//16*tCK
`define min_MWR_after_WR16orMWR_DB `BL_nmax*`tCK//4*tCK
`define min_RD16_after_WR16orMWR_ANB (`WL+`BL_nmax+$ceil(`tWTR/`tCK))*`tCK//12*tCK
`define max_RD16orWR16orMWR_after_RD16_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//10*tCK
`define min_WR16orMWR_after_RD16_ANB (`RL+`BL_nmax+$ceil(`tWCKDQO/`tCK)-`WL)*`tCK//6*tCK
`define min_RD16_after_RD16_ANB `BL_nmax*`tCK//4*tCK
`define tAAD 8//between _ACT1 and _ACT2 for the same bank
`define tRAS (`max(42,3*`tCK))//3*10//between PRECHARGE and  _ACT2 for the same bank
`define tRP (`max(18ns,2*`tCK))//2*10//between _ACT2 and PRECHARGE for the same bank
`define tRRD (`max(5ns,2*`tCK)) //2*10//4//between _ACT2 commands for two different banks
`define tRC (`tRAS+`tRP)//3+2*10//12//between _ACT2 commands for the same bank
`define tRCD (`max(18ns,2*`tCK))//2*10//between _ACT2 and (READ OR WRITE Operations)
`define tRBTP (`max(7.5ns,4*`tCK)-4*`tCK)//0*10//between read operation and precharge in case 2:1
`define tWR (`max(34ns, 3*`tCK))//3*10between write operation and precahrge
`define tPPD 2//precharge to precharge delay for the same bank
`define tcas_wr 1*`tCK// to check write shoulb be after only one cycle from _CAS_WR
`define tcas_rd 1*`tCK// to check READ shoulb be after only one cycle from _CAS_RD
`define BL 16//Burst length is 16
`define n 4//in case 2:1 & n=8 in case 4:1
`define BL_nmax `BL/`n
`define BL_nmin `BL/`n
`define WL 4 //write latency
`define RL 6 //read latency
`define tWTR (`max(12ns,4*`tCK))// write to read delay
`define tWCKPST (2.5*(`tCK/4))// postamble
`define tWCKDQO 0
`define tWCKDQI 0
`define tWRTOPRE ((`WL+`BL_nmax+1+$ceil(`tWR/`tCK))*`tCK)
`define tRDTOPRE ((`BL_nmax+$ceil(`tRBTP/`tCK))*`tCK)
`define RU(a) $ceil(``a``/`tCK)
//`define abs(a) (``a`` > 0)? ``a``: -1*``a``

typedef enum bit [0:6] {	
	  _DES=7'b1111111, 
	  _NOP=7'b0000000, 
	  _PDE=7'b0000001,
	  //_ACT1=7'b111xxxx, 
	  _ACT1=7'b1110000,
	  //_ACT2=7'b110xxxx, 
	  _ACT2=7'b1100000,
	  _PRE=7'b0001111,
	  _REF=7'b0001110,
	  //_MWR=7'b010xxxx, 
	  _MWR=7'b0100000,
	  //_WR16=7'b011xxxx, 
	  _WR16=7'b0110000,
	  //WR32=7'b0010xxx,
	  //_RD16=7'b100xxxx,
	  _RD16=7'b1000000,
	  //RD32=7'b101xxxx,
	  _CAS_WR=7'b0011100,
	  _CAS_RD=7'b0011010,
	  _CAS_FS=7'b0011001,
	  _CAS_OFF=7'b0011111,
	  /*_MPC=7'b000011x, 
	  _MRW1=7'b0001101,
	  _MRW2=7'b000100x,*/
	  _MPC=7'b0000110, 
	  _MRW1=7'b0001101,
	  _MRW2=7'b0001000,
	  _MRR=7'b0001100, 
	  _WFF=7'b0000011, 
	  _RFF=7'b0000010
		} command;

class seqitem;
	  
      int tAAD_tb= `tAAD;//between _ACT1 and _ACT2 for the same bank
      int tRRD_tb= `tRRD;//4//between _ACT2 commands for two different banks
      int tRC_tb= `tRC;//12//between _ACT2 commands for the same bank
      int tRCD_tb= `tRCD;//between _ACT2 and (READ OR WRITE Operations)
      int tRP_tb= `tRP;//between _ACT2 and PRECHARGE for the same bank
      int tRAS_tb= `tRAS;//between PRECHARGE and  _ACT2 for the same bank
      int tRBTP_tb= `tRBTP;//between read operation and precharge
      int tWR_tb= `tWR;//between write operation and precahrge*/
      int tWRTOPRE_tb= `tWRTOPRE;
      int tRDTOPRE_tb= `tRDTOPRE;
	  int i=0;
      rand int rd_after_wr;
      rand int wr_after_rd;
      rand int wr_after_wr_ANB;
      rand int wr_after_wr_SB;
      rand int rd_after_rd;
      time last_act2;
      time last_rd_or_wr;
      time temp;
      bit [3:0] BA_queue[$];
      command cmd_queue[$];
      command prev;
	  bit [3:0] BA;
      bit [3:0] old_address;
	  command cmd;
      rand command tr;
      rand bit [3:0]address;
      rand int iterations;
      constraint const1{
        tr inside {_WR16,_MWR,_RD16};
        wr_after_wr_ANB inside{[int'(`RU(`min_WR16_after_WR16orMWR_ANB)):int'(`RU(`max_WR16orMWR_after_WR16orMWR_ANB)+1)]};
        wr_after_wr_ANB !=int'(`RU(`max_WR16orMWR_after_WR16orMWR_ANB));
        if (`min_MWR_after_WR16orMWR_SB>`max_MWR_after_WR16orMWR_SB){
          wr_after_wr_SB inside{[int'(`RU(`max_MWR_after_WR16orMWR_SB)):int'(`RU(`min_MWR_after_WR16orMWR_SB))+1]};
          wr_after_wr_SB != int'(`RU(`min_MWR_after_WR16orMWR_SB));
        }else {
        wr_after_wr_SB inside{[int'(`RU(`min_MWR_after_WR16orMWR_SB)):int'(`RU(`max_MWR_after_WR16orMWR_SB))+1]};
        wr_after_wr_SB != int'(`RU(`max_MWR_after_WR16orMWR_SB));
        }
        rd_after_rd inside{[int'(`RU(`min_RD16_after_RD16_ANB)):int'(`RU(`max_RD16orWR16orMWR_after_RD16_ANB))+1]};
        rd_after_rd != int'(`RU(`max_RD16orWR16orMWR_after_RD16_ANB));
        wr_after_rd inside {[int'(`RU(`min_WR16orMWR_after_RD16_ANB)):int'(`RU(`max_RD16orWR16orMWR_after_RD16_ANB))+1]};
        wr_after_rd != int'(`RU(`max_RD16orWR16orMWR_after_RD16_ANB));
        rd_after_wr inside{[int'(`RU(`min_RD16_after_WR16orMWR_ANB)):int'(`RU(`min_RD16_after_WR16orMWR_ANB))+1]};
        iterations inside {[1:2]};
      }
	  
    task delay(int delay);
		repeat(delay) begin
			cmd=_NOP;
			this.cmd_queue.push_back(cmd);
			this.BA_queue.push_back(BA);
		end
	  endtask

	  task generate_seq(int loops);
	    repeat(loops) begin 
      randsequence(main)
        main:single_trans|multi_trans;
        single_trans: {
          delay(`RU(this.tRP_tb));
          $display("at time=%0t i'm inside single test num%0d",$time,this.i);
         this.randomize();
          this.old_address=this.address;
          BA=this.address;
          cmd=_ACT1;
          this.cmd_queue.push_back(cmd);this.BA_queue.push_back(BA);
          
          cmd=_ACT2;
          this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
          this.last_act2=$time;
          delay(`RU(this.tRCD_tb));
          
          if (this.tr==_RD16) begin
            cmd=_CAS_RD;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
            
            this.prev=this.tr;
            cmd=this.tr;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
            this.last_rd_or_wr=$time;
          end
          else begin
            cmd=_CAS_WR;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
            
            this.prev=this.tr;
            cmd=this.tr;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
            this.last_rd_or_wr=$time;
          end
          if (this.prev==_RD16) begin
            delay(`RU(this.tRDTOPRE_tb));
              cmd=_PRE;
              this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              this.last_rd_or_wr=$time;
          end
          else begin
            delay(`RU(this.tWRTOPRE_tb));
              cmd=_PRE;
              this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
          end
          repeat (1) begin
            
            cmd=_NOP;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
          end
          i++;
        };
        multi_trans:{
          delay(`RU(this.tRP_tb));
          $display("at time=%0t i'm inside multi test num%0d",$time,i);
          this.randomize();
          this.old_address=this.address;
          BA=this.address;
          cmd=_ACT1;
          this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
          
          cmd=_ACT2;
          this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
          this.last_act2=$time;
          delay(`RU(this.tRCD_tb));
          if (this.tr==_RD16) begin
            cmd=_CAS_RD;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
            
            this.prev=this.tr;
            cmd=this.tr;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
             this.last_rd_or_wr=$time;
          end
          else begin
            cmd=_CAS_WR;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
            
            this.prev=this.tr;
            cmd=this.tr;
            this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
             this.last_rd_or_wr=$time;
          end
          for (int j=0;j<this.iterations;j++) begin
            this.iterations.rand_mode(0);
            this.randomize();
            if (this.old_address!=this.address) begin//this means we need to send ACtivation commands but first precharge last BANK
              if (this.prev==_RD16) begin
                delay(`RU(this.tRDTOPRE_tb));
                cmd=_PRE;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              end
              else begin
                delay(`RU(this.tWRTOPRE_tb));
                cmd=_PRE;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              end
              
              BA=this.address;
              cmd=_ACT1;
              this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              
              cmd=_ACT2;
              this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              this.last_act2=$time;
              this.temp=this.last_act2-this.last_rd_or_wr;
              if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_WR16) && (this.wr_after_wr_ANB*`period+this.temp> `max_WR16orMWR_after_WR16orMWR_ANB)) begin //we need to send _CAS_WR first
                delay(this.wr_after_wr_ANB+`RU(this.temp));
                cmd=_CAS_WR;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                
                this.prev=this.tr;
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              end
              if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_MWR) && (this.wr_after_wr_ANB*`period+this.temp> `max_WR16orMWR_after_WR16orMWR_ANB)) begin //we need to send _CAS_WR first
                delay(this.wr_after_wr_ANB+`RU(this.temp));
                cmd=_CAS_WR;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                
                this.prev=this.tr;
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              end
              else if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_WR16) && (this.wr_after_wr_ANB*`period+this.temp<=`max_WR16orMWR_after_WR16orMWR_ANB) && (this.wr_after_wr_ANB*`period+this.temp>=`min_WR16_after_WR16orMWR_ANB)) begin//we don't need to send sync
               delay(this.wr_after_wr_ANB+`RU(this.temp));
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
              else if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_MWR) && (this.wr_after_wr_ANB*`period+this.temp<=`max_WR16orMWR_after_WR16orMWR_ANB) && (this.wr_after_wr_ANB*`period+this.temp>=`min_MWR_after_WR16orMWR_DB)) begin//we don't need to send sync
               delay(this.wr_after_wr_ANB+`RU(this.temp));
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
              else if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_RD16)&& (this.rd_after_wr*`period+this.temp>=`min_RD16_after_WR16orMWR_ANB)) begin//we don't need to send sync for just now but it should
               delay(this.rd_after_wr+`RU(this.temp));
                cmd=_CAS_RD;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
              else if((this.prev==_RD16) && (this.tr==_RD16 || this.tr==_MWR || this.tr==_WR16) &&( (this.rd_after_rd*`period+this.temp>`max_RD16orWR16orMWR_after_RD16_ANB) || (this.wr_after_rd*`period+this.temp>`max_RD16orWR16orMWR_after_RD16_ANB))) begin//we should send sync
               if (this.tr==_RD16) begin                 
                  delay(this.rd_after_rd+`RU(this.temp));
                  cmd=_CAS_RD;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                  
                  this.prev=this.tr;
                  cmd=_RD16;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                end
                else begin                
                  delay(this.wr_after_rd+`RU(this.temp));
                  cmd=_CAS_WR;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                  
                  this.prev=this.tr;
                  cmd=this.tr;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA); 
                end
              end
              else if((this.prev==_RD16) && (this.tr==_MWR || this.tr==_WR16) && (this.wr_after_rd*`period+this.temp<=`max_RD16orWR16orMWR_after_RD16_ANB) && (this.wr_after_rd*`period+this.temp>=`min_WR16orMWR_after_RD16_ANB)) begin//we don't need to send sync              
               delay(this.wr_after_rd+`RU(this.temp));
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
              else if((this.prev==_RD16) && (this.tr==_RD16) && (this.rd_after_rd*`period+this.temp<=`max_RD16orWR16orMWR_after_RD16_ANB) && (this.rd_after_rd*`period+this.temp>=`min_RD16_after_RD16_ANB)) begin//we don't need to send sync            
              delay(this.rd_after_rd+`RU(this.temp));
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
            end
            else begin//this means we don't need to send activation or precharge because we will deal with the same bank
            
              if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_WR16 /*|| this.tr==_MWR*/) && (this.wr_after_wr_ANB*`period> `max_WR16orMWR_after_WR16orMWR_ANB)) begin //we need to send _CAS_WR first
                delay(this.wr_after_wr_ANB);
                cmd=_CAS_WR;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                
                this.prev=this.tr;
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
              end
              else if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_MWR)) begin
                if (`max_MWR_after_WR16orMWR_SB>`min_MWR_after_WR16orMWR_SB) begin
                  if (this.wr_after_wr_SB*`period>`max_MWR_after_WR16orMWR_SB) begin//we have to send sync
                    delay(this.wr_after_wr_SB);
                    cmd=_CAS_WR;
                    this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                    
                    this.prev=this.tr;
                    cmd=this.tr;
                    this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                  end
                  else begin//we don't need to send sync
                    delay(this.wr_after_wr_SB);
                    this.prev=this.tr;
                    cmd=this.tr;
                    this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                  end
                end
                else begin // this means max is less than min so we have to send sync first
                  delay(this.wr_after_wr_SB);
                  cmd=_CAS_WR;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                  
                  this.prev=this.tr;
                  cmd=this.tr;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                end
              end
              else if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_WR16) && (this.wr_after_wr_ANB*`period<=`max_WR16orMWR_after_WR16orMWR_ANB) && (this.wr_after_wr_ANB*`period>=`min_WR16_after_WR16orMWR_ANB)) begin//we don't need to send sync
                delay(this.wr_after_wr_ANB);
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end            
              else if((this.prev==_WR16 || this.prev==_MWR) && (this.tr==_RD16) && (this.rd_after_wr*`period>=`min_RD16_after_WR16orMWR_ANB)) begin//we don't need to send sync for just now but it should
                delay(this.rd_after_wr);
                cmd=_CAS_RD;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
              else if((this.prev==_RD16) && (this.tr==_RD16 || this.tr==_MWR || this.tr==_WR16) && ((this.rd_after_rd*`period>`max_RD16orWR16orMWR_after_RD16_ANB) || (this.wr_after_rd*`period>`max_RD16orWR16orMWR_after_RD16_ANB))) begin//we should send sync
               if (this.tr==_RD16) begin             
                delay(this.rd_after_rd);
                  cmd=_CAS_RD;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                  
                  this.prev=this.tr;
                  cmd=_RD16;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                end
                else begin              
                delay(this.wr_after_rd);
                  cmd=_CAS_WR;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                  
                  this.prev=this.tr;
                  cmd=this.tr;
                  this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA); 
                end
              end
              else if((this.prev==_RD16) && (this.tr==_MWR || this.tr==_WR16) && (this.wr_after_rd*`period<=`max_RD16orWR16orMWR_after_RD16_ANB) && (this.wr_after_rd*`period>=`min_WR16orMWR_after_RD16_ANB)) begin//we don't need to send sync              
                delay(this.wr_after_rd);
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
              else if((this.prev==_RD16) && (this.tr==_RD16) && (this.rd_after_rd*`period<=`max_RD16orWR16orMWR_after_RD16_ANB) && (this.rd_after_rd*`period>=`min_RD16_after_RD16_ANB)) begin//we don't need to send sync
                delay(this.rd_after_rd);
                cmd=this.tr;
                this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
                this.prev=this.tr;
              end
            end
          end//at the end of transaction we should precharge the last bank we used
         this.iterations.rand_mode(1);
          BA=this.address;
          if (this.prev==_RD16) begin
            delay(`RU(this.tRDTOPRE_tb));
              cmd=_PRE;
              this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
          end
          else begin
            delay(`RU(this.tWRTOPRE_tb));
              cmd=_PRE;
              this.cmd_queue.push_back(cmd);
this.BA_queue.push_back(BA);
          end
          this.i++;
        };
  endsequence
 end
 endtask
endclass