// module multiplier_control (

//     input logic clk, rst, 
//     input logic 
//     output logic state, 





// ); 
// enum logic [5:0] {
//     RST, 
//     WAIT, 
//     LOADED, 
//     CLEAR_XA
//     ADD1, ADD2, ADD3, ADD4, ADD5, ADD6, ADD7, ADD8, ADD9, ADD10, ADD11, ADD12, ADD13, ADD14, ADD15,
//     SH1, SH2, SH3, SH4, SH5, SH6, SH7, SH8, SH9, SH10, SH11, SH12, SH13, SH14, SH15, 

    
// } curr_state, next_state; 

// always_ff @(posedge clk or posedge rst)begin
//     if(rst)
//         curr_state <= RST;    
//     else 
//         curr_state <= next_state; 

// end

// 	always_comb:SHIFTING_ALGORITHM
// 	begin
// 		next_state = curr_state;
		
// 		unique case (curr_state)
// 			RST:	
// 					next_state = WAIT;
// 			LOADED: next_state = WAIT;
// 			WAIT: 
// 				if (Run)
// 					next_state = Clear_XA;
// 				else if (Reset)
// 					next_state = Loaded;
// 			Clear_XA: next_state = ADD1;
// 			ADD1:	next_state = SH1;
// 			SH1 : next_state = ADD2;
// 			ADD2:	next_state = SH2;
// 			SH2:  next_state = ADD3;
// 			ADD3:	next_state = SH3;
// 			SH3:  next_state = ADD4;
// 			ADD4:	next_state = SH4;
// 			SH4:  next_state = ADD5;
// 			ADD5:	next_state = SH5;
// 			SH5:  next_state = ADD6;
// 			ADD6:	next_state = SH6;
// 			SH6:  next_state = ADD7;
// 			ADD7:	next_state = SH7;
// 			SH7:  next_state = Do8;
// 			Do8:	next_state = SH8;
// 			SH8:	next_state = Finish;
// 			Finish :	if(~Run) next_state = WAIT;
// 		endcase

// 		case (curr_state)
// 			Rst:
// 			begin
// 				ADD 		= 1'b0;
// 				Sub 		= 1'b0;
// 				SHift_En = 1'b0;
// 				Clr_Ld 	= 1'b1;  // loads B
// 				Clr_XA 	= 1'b1; // clear XA
// 			end
			
// 			Loaded:
// 				begin
// 					ADD 		= 1'b0;
// 					Sub 		= 1'b0;
// 					SHift_En = 1'b0;
// 					Clr_Ld 	= 1'b1;  // loads B
// 					Clr_XA 	= 1'b1; // clear XA
// 				end
				
// 			ADD1, ADD2, ADD3, ADD4, ADD5, ADD6, ADD7:
// 				begin
// 					if(M)
// 						ADD 	= 1'b1;
// 					else
// 						ADD 	= 1'b0;
// 					Sub 		= 1'b0;
// 					SHift_En = 1'b0;
// 					Clr_Ld 	= 1'b0;
// 					Clr_XA 	= 1'b0;
// 				end
			
// 			Do8:
// 				begin
// 					ADD 		= 	1'b0;
// 					if(M)
// 						Sub 	= 1'b1;
// 					else
// 						Sub 	= 1'b0;
// 					SHift_En = 1'b0;
// 					Clr_Ld 	= 1'b0;
// 					Clr_XA 	= 1'b0;
// 				end
				
// 			SH1, SH2, SH3, SH4, SH5, SH6, SH7, SH8:
// 				begin
// 					ADD 		= 1'b0;
// 					Sub 		= 1'b0;
// 					SHift_En = 1'b1;
// 					Clr_Ld 	= 1'b0;
// 					Clr_XA 	= 1'b0;
// 				end
				
// 			WAIT:
// 				begin
// 					ADD 		= 1'b0;
// 					Sub 		= 1'b0;
// 					SHift_En = 1'b0;
// 					Clr_Ld	= 1'b0;
// 					Clr_XA 	= 1'b0;
// 				end
				
// 			Clear_XA:
// 				begin
// 					ADD 		= 1'b0;
// 					Sub 		= 1'b0;
// 					SHift_En = 1'b0;
// 					Clr_Ld 	= 1'b0;
// 					Clr_XA 	= 1'b1;
// 				end
				
// 			Finish:
// 				begin
// 					ADD 		= 1'b0;
// 					Sub 		= 1'b0;
// 					SHift_En = 1'b0;
// 					Clr_Ld 	= 1'b0;
// 					Clr_XA 	= 1'b0;
// 				end
				
// 			default:
// 				begin
// 					ADD 		= 1'b0;
// 					Sub 		= 1'b0;
// 					SHift_En = 1'b0;
// 					Clr_Ld 	= 1'b0;
// 					Clr_XA 	= 1'b0;
// 				end
				
// 		endcase
		
// 	end

// endmodule 