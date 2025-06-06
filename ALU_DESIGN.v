`include "CMD.vh"

module ALU_DESIGN #(parameter WIDTH_OP = 8, WIDTH_CMD = 4)(CLK,RST,INP_VALID,MODE,CMD,CE,OPA,OPB,CIN,ERR,RES,OFLOW,COUT,G,L,E);

localparam WIDTH = WIDTH_OP*2;

input [WIDTH_OP-1 : 0] OPA,OPB ; // Inputs
input CLK,RST,MODE,CIN,CE;
input [1:0] INP_VALID ;
input [WIDTH_CMD-1:0] CMD ;

output reg ERR,OFLOW,COUT,G,L,E; // Outputs

`ifdef MUL
  output reg [WIDTH-1:0] RES;
`else
  output reg [WIDTH_OP:0] RES;
`endif

reg [WIDTH_OP-1 : 0] TEMP_A , TEMP_B ;
reg [WIDTH_OP:0] TEMP_RES ;
reg signed [WIDTH_OP:0] SIGN_RES ;
reg [WIDTH-1:0] TEMP_MULT ;
reg [2:0] valid_pipe;

  localparam ROL_WIDTH = $clog2(WIDTH_OP);
reg [ROL_WIDTH-1 : 0] rotation ;
reg [ ( WIDTH_OP-(ROL_WIDTH+2)) : 0 ] err_flag;

always@(posedge CLK, posedge RST) begin
        if(RST) begin // Asyn-active high reset !!
                ERR <= 1'b0;
                OFLOW <= 1'b0;
                COUT <= 1'b0;
                G <= 1'b0;
                L <= 1'b0;
                E <= 1'b0;
                RES <= {WIDTH{1'b0}};
                valid_pipe <= 3'd0;
                TEMP_A <= 0;
                TEMP_B <= 0;
                SIGN_RES <= 0;
                TEMP_RES <= 0;
                TEMP_MULT <= 0;
        end
        else if(CE) begin
                ERR <= 1'b0;
                OFLOW <= 1'b0;
                COUT <= 1'b0;
                G <= 1'b0;
                L <= 1'b0;
                E <= 1'b0;
                RES <= {WIDTH{1'b0}};

                if(MODE) // MODE ==  1 -> Arithmetic operation...
                begin
                        case(CMD)
                          `ADD : begin // CMD = 0
                            valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                            if(INP_VALID == 2'b11) begin
                                TEMP_RES <= OPA + OPB ;
                            end
                            if(valid_pipe[0]) begin
                              RES <= TEMP_RES ;
                              COUT <= (TEMP_RES[WIDTH_OP])? 1 : 0 ;
                              valid_pipe = 0;
                              TEMP_RES = 0;
                            end
                            if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                              COUT <= 1'b0;
                            end
                          end
                          `SUB : begin  // CMD = 1
                            valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                            if(INP_VALID == 2'b11) begin
                                TEMP_RES <= OPA - OPB ;
                                TEMP_A <= OPA;
                                TEMP_B <= OPB;
                            end
                            if(valid_pipe[0]) begin
                                RES <= TEMP_RES ;
                                //$display("SUB TRACTION PIPE");
                                OFLOW <= (TEMP_A < TEMP_B)? 1 : 0 ;
                                valid_pipe = 0;
                                TEMP_RES = 0;
                                TEMP_A = 0;
                                TEMP_B = 0;
                            end
                            if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                RES <= {WIDTH{1'b0}};
                                //$display("INP PIN is $+===");
                                ERR <= 1'b1;
                                OFLOW <= 1'b0;
                            end
                          end
                          `ADD_CIN : begin  // CMD = 2
                            valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                            if(INP_VALID == 2'b11) begin
                                TEMP_RES <= OPA + OPB + CIN ;
                            end
                            if(valid_pipe[0]) begin
                              RES <= TEMP_RES ;
                              COUT <= (TEMP_RES[WIDTH_OP])? 1 : 0 ;
                              valid_pipe = 0;
                              TEMP_RES = 0;
                            end
                            if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                              COUT <= 1'b0;
                            end
                          end
                          `SUB_CIN : begin // CMD = 3
                            valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                            if(INP_VALID == 2'b11) begin
                                TEMP_RES <= OPA - OPB - CIN ;
                            end
                            if(valid_pipe[0]) begin
                              RES <= TEMP_RES ;
                              OFLOW <= (OPA < (OPB+CIN) )? 1 : 0 ;
                              valid_pipe = 0;
                              TEMP_RES = 0;
                            end
                            if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                              OFLOW <= 1'b0;
                            end
                          end
                         `INC_A : begin // CMD = 4
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b01)};
                           if(INP_VALID == 2'b01) begin
                             TEMP_RES <= OPA + 1 ;
                           end
                           if(valid_pipe[0]) begin
                             RES <= TEMP_RES ;
                             OFLOW <= (TEMP_RES[WIDTH_OP])? 1 : 0;
                             valid_pipe = 0;
                             TEMP_RES = 0;
                           end
                           if(INP_VALID == 2'b10 || INP_VALID == 2'b11 || INP_VALID == 2'b00) begin
                             RES <= {WIDTH{1'b0}};
                             ERR <= 1'b1;
                             OFLOW <= 1'b0;
                           end
                         end
                         `DEC_A : begin // CMD = 5
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b01)};
                           if(INP_VALID == 2'b01) begin
                             TEMP_RES <= OPA - 1 ;
                           end
                           if(valid_pipe[0]) begin
                             RES <= TEMP_RES ;
                             OFLOW <= (TEMP_RES[WIDTH_OP])? 1 : 0;
                             valid_pipe = 0;
                             TEMP_RES = 0;
                           end
                           if(INP_VALID == 2'b10 || INP_VALID == 2'b11 || INP_VALID == 2'b00) begin
                             RES <= {WIDTH{1'b0}};
                             ERR <= 1'b1;
                             OFLOW <= 1'b0;
                           end
                         end
                         `INC_B : begin // CMD = 6
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b10)};
                           if(INP_VALID == 2'b10) begin
                             TEMP_RES <= OPB + 1 ;
                           end
                           if(valid_pipe[0]) begin
                             RES <= TEMP_RES;
                             OFLOW <= (TEMP_RES[WIDTH_OP])? 1 : 0;
                             valid_pipe = 0;
                             TEMP_RES = 0;
                           end
                           if(INP_VALID == 2'b11 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                             RES <= {WIDTH{1'b0}};
                             ERR <= 1'b1;
                             OFLOW <= 1'b0;
                           end
                         end
                         `DEC_B : begin // CMD = 7
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b10)};
                           if(INP_VALID == 2'b10) begin
                             TEMP_RES <= OPB - 1'b1 ;
                           end
                           if(valid_pipe[0]) begin
                             RES <= TEMP_RES ;
                             OFLOW <= (TEMP_RES[WIDTH_OP])? 1 : 0;
                             valid_pipe = 0;
                             TEMP_RES = 0;
                           end
                           if(INP_VALID == 2'b11 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                             RES <= {WIDTH{1'b0}};
                             ERR <= 1'b1;
                             OFLOW <= 1'b0;
                           end
                         end
                         `CMP : begin // CMD = 8
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                           if(INP_VALID == 2'b11) begin
                                TEMP_A <= OPA ;
                                TEMP_B <= OPB ;
                                TEMP_RES <= {WIDTH{1'b0}};
                            end
                           if(valid_pipe[0]) begin
                             RES <= TEMP_RES ;
                             if(TEMP_A == TEMP_B) begin
                               E <= 1'b1;
                               G <= 1'b0;
                               L <= 1'b0;
                             end
                             else if(TEMP_A > TEMP_B) begin
                               E <= 1'b0;
                               G <= 1'b1;
                               L <= 1'b0;
                             end
                             else begin
                               E <= 1'b0;
                               G <= 1'b0;
                               L <= 1'b1;
                             end
                             valid_pipe = 0;
                             TEMP_A = 0;
                             TEMP_B = 0;
                             TEMP_RES =0 ;
                           end
                           if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                              OFLOW <= 1'b0;
                            end
                         end
                         `INCR_MULT : begin // CMD = 9
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                           if(INP_VALID == 2'b11) begin
                             TEMP_A <= OPA ;
                             TEMP_B <= OPB ;
                           end
                           if(valid_pipe[0]) begin
                             TEMP_MULT <= (TEMP_A + 1) * (TEMP_B + 1) ;
                           end
                           if(valid_pipe[1]) begin
                             RES <= TEMP_MULT ;
                             valid_pipe = 0;
                             //TEMP_MULT = 0;
                             //TEMP_A = 0;
                             //TEMP_B = 0;
                           end
                           if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                            end
                         end
                         `SHIFT_MULT : begin // CMD = 10
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                           if(INP_VALID == 2'b11) begin
                             TEMP_A <= OPA ;
                             TEMP_B <= OPB ;
                           end
                           if(valid_pipe[0]) begin
                             TEMP_MULT <= (TEMP_A <<< 1) * (TEMP_B) ; // left shift and mult
                           end
                           if(valid_pipe[1]) begin
                             RES <= TEMP_MULT ;
                             valid_pipe = 0;
                             TEMP_MULT = 0;
                             TEMP_A = 0;
                             TEMP_B = 0;
                           end
                           if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                              COUT <= 1'b0;
                            end
                         end
                         `SIGN_ADD : begin // CMD = 11
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};
                           if(INP_VALID == 2'b11) begin
                             SIGN_RES <= $signed(OPA)+$signed(OPB) ; // Take the sign extention ...
                             TEMP_A <= OPA;
                             TEMP_B <= OPB;
                           end
                           if(valid_pipe[0]) begin // sign addition to be handled ...
                             RES <= SIGN_RES ;
                             OFLOW <= (~TEMP_A[WIDTH_OP-1] && ~TEMP_B[WIDTH_OP-1] && SIGN_RES[WIDTH_OP-1] || TEMP_A[WIDTH_OP-1]  && TEMP_B[WIDTH_OP-1]  && ~SIGN_RES[WIDTH_OP-1] )? 1 : 0 ;
                             COUT <= (~TEMP_A[WIDTH_OP-1] && ~TEMP_B[WIDTH_OP-1] && SIGN_RES[WIDTH_OP-1] || TEMP_A[WIDTH_OP-1]  && TEMP_B[WIDTH_OP-1]  && ~SIGN_RES[WIDTH_OP-1] )? 1 : 0 ;
                             if($signed(TEMP_A) == $signed(TEMP_B)) begin
                               E <= 1'b1;
                               G <= 1'b0;
                               L <= 1'b0;
                             end
                             else if($signed(TEMP_A) > $signed(TEMP_B)) begin
                               E <= 1'b0;
                               G <= 1'b1;
                               L <= 1'b0;
                             end
                             else begin
                               E <= 1'b0;
                               G <= 1'b0;
                               L <= 1'b1;
                             end
                             valid_pipe = 0;
                             SIGN_RES = 0;
                             TEMP_A = 0;
                             TEMP_B = 0;
                           end
                           if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                              COUT <= 1'b0;
                            end
                         end
                         `SIGN_SUB : begin // CMD = 12
                           valid_pipe <= {valid_pipe[1:0],(INP_VALID == 2'b11)};

                           if(INP_VALID == 2'b11) begin
                             SIGN_RES <= $signed(OPA)-$signed(OPB);
                             TEMP_A <= OPA;
                             TEMP_B <= OPB;
                           end
                           if(valid_pipe[0]) begin
                             RES <= SIGN_RES;
                             OFLOW <= ( (TEMP_A[WIDTH_OP-1] != TEMP_B[WIDTH_OP-1]) && SIGN_RES[WIDTH_OP-1] != TEMP_A[WIDTH_OP-1] ) ? 1 : 0 ;
                             COUT <= ( (TEMP_A[WIDTH_OP-1] != TEMP_B[WIDTH_OP-1]) && SIGN_RES[WIDTH_OP-1] != TEMP_A[WIDTH_OP-1] ) ? 1 : 0 ;
                             if($signed(TEMP_A) == $signed(TEMP_B)) begin
                               E <= 1'b1;
                               G <= 1'b0;
                               L <= 1'b0;
                             end
                             else if($signed(TEMP_A) > $signed(TEMP_B)) begin
                               E <= 1'b0;
                               G <= 1'b1;
                               L <= 1'b0;
                             end
                             else begin
                               E <= 1'b0;
                               G <= 1'b0;
                               L <= 1'b1;
                             end
                             valid_pipe = 0;
                             SIGN_RES = 0;
                             TEMP_A = 0;
                             TEMP_B = 0;
                           end
                           if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                              RES <= {WIDTH{1'b0}};
                              ERR <= 1'b1;
                              OFLOW <= 1'b0;
                            end
                         end
                         default : begin
                           RES <= {WIDTH{1'b0}};
                           ERR <= 1'b1;
                         end

                     endcase
               end
               else begin // MODE == 0 -> Logical operation...

                case(CMD)
                 `AND : begin // CMD = 0
                         valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b11)};
                         if(INP_VALID == 2'b11) begin
                                        TEMP_RES <= OPA & OPB ;
                                 end
                         if(valid_pipe[0])begin
                                        RES <= TEMP_RES;
                                        valid_pipe = 0;
                                        TEMP_RES = 0;
                                 end
                                 if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                 ERR <= 1;
                                 RES <= {WIDTH{1'b0}};
                                 end
                                end

                 `NAND : begin // CMD = 1
                      valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b11)};
                      if(INP_VALID == 2'b11) begin
                                TEMP_RES <= ~(OPA & OPB);
                      end
                      if(valid_pipe[0])begin
                          RES <= TEMP_RES ;
                          valid_pipe = 0;
                          TEMP_RES = 0;
                      end
                      if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                ERR <= 1;
                                RES <= {WIDTH{1'b0}};
                      end
                   end
                  `OR : begin // CMD = 2
                     valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b11)};

                        if(INP_VALID == 2'b11) begin
                                TEMP_RES <= OPA | OPB ;
                        end
                        if(valid_pipe[0])begin
                          RES <= TEMP_RES ;
                          TEMP_RES = 0;
                          valid_pipe = 0;
                        end
                        if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                ERR <= 1;
                                RES <= {WIDTH{1'b0}};
                        end
                       end
                   `NOR : begin // CMD = 3
                                 valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b11)};
                     if(INP_VALID == 2'b11) begin
                        TEMP_RES <= ~(OPA | OPB) ;
                     end
                     if(valid_pipe[0])begin
                        RES <= TEMP_RES;
                        TEMP_RES = 0;
                        valid_pipe = 0;
                     end
                     if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                        ERR <= 1;
                        RES <= {WIDTH{1'b0}};
                     end
                    end
                   `XOR : begin // CMD = 4
                                 valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b11)};
                     if(INP_VALID == 2'b11) begin
                                        TEMP_RES <= (OPA ^ OPB);
                                  end
                        if(valid_pipe[0])begin
                          RES <= TEMP_RES;
                          TEMP_A = 0;
                          TEMP_B = 0;
                          valid_pipe = 0;
                        end
                        if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                        ERR <= 1;
                                        RES <= {WIDTH{1'b0}};
                                 end
                                end
                   `XNOR : begin  // CMD = 5
                    valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b11)};
                     if(INP_VALID == 2'b11) begin
                                        TEMP_RES <= ~(OPA ^ OPB) ;                                   end
                     if(valid_pipe[0])begin
                          RES <= TEMP_RES;
                          TEMP_A = 0;
                          TEMP_B = 0;
                          valid_pipe = 0;
                         end
                         if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                        ERR <= 1;
                                        RES <= {WIDTH{1'b0}};
                                 end
                                end
             `NOT_A : begin  // CMD = 6
                  valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b01)};

                  if(INP_VALID == 2'b01)begin
                                TEMP_A <= OPA;
                          end
                  if(valid_pipe[0])begin
                                RES <= ~(TEMP_A);
                                TEMP_A = 0;
                                valid_pipe = 0;
                          end
                  if(INP_VALID == 2'b10 || INP_VALID == 2'b11 || INP_VALID == 2'b00) begin
                                        ERR <= 1;
                                        RES <= {WIDTH{1'b0}};
                                 end
                                end
            `NOT_B : begin  // CMD = 7
                  valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b10)};
                  if(INP_VALID == 2'b10) begin
                                  TEMP_B <= OPB;
                          end
                  if(valid_pipe[0])begin
                                RES <= ~TEMP_B;
                                TEMP_B = 0;
                                valid_pipe = 0;
                          end
                  if(INP_VALID == 2'b11 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                ERR <= 1;
                                RES <= {WIDTH{1'b0}};
                  end
                 end
              `SHR1_A : begin  // CMD = 8
                  valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b01)};
                  if(INP_VALID == 2'b01) begin
                                TEMP_A <= OPA >> 1;
                  end
                  if(valid_pipe[0])begin
                      RES <= TEMP_A;
                      TEMP_A = 0;
                      valid_pipe = 0;
                  end
                  if(INP_VALID == 2'b10 || INP_VALID == 2'b11 || INP_VALID == 2'b00) begin
                                ERR <= 1;
                                RES <= {WIDTH{1'b0}};
                  end
                 end
                `SHL1_A : begin  // CMD = 9
                    valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b01)};
                    if(INP_VALID == 2'b01) begin
                                TEMP_A <= OPA;
                      end
                      if(valid_pipe[0])begin
                                RES <= (TEMP_A << 1);
                                TEMP_A = 0;
                      end
                      if(INP_VALID == 2'b10 || INP_VALID == 2'b11 || INP_VALID == 2'b00) begin
                                ERR <= 1;
                                RES <= {WIDTH{1'b0}};
                            end
                          end
                   `SHR1_B : begin  // CMD = 10
                        valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b10)};
                        if(INP_VALID == 2'b10) begin
                                TEMP_B <= OPB;
                            end
                        if(valid_pipe[0])begin
                                RES <= (TEMP_B >> 1);
                                TEMP_B = 0;
                                valid_pipe = 0;
                        end
                        if(INP_VALID == 2'b11 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                ERR <= 1;
                                RES <= {WIDTH{1'b0}};
                           end
                          end
                   `SHL1_B : begin  // CMD = 11
                        valid_pipe <= {valid_pipe[1:0],(INP_VALID==2'b10)};
                        if(INP_VALID == 2'b10) begin
                                    TEMP_B <= OPB;
                            end
                        if(valid_pipe[0])begin
                                RES <= (TEMP_B << 1);
                                TEMP_B = 0;
                                valid_pipe = 0;
                        end
                        if(INP_VALID == 2'b11 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                ERR <= 1;
                                RES <= {WIDTH{1'b0}};
                        end
                    end
                `ROL_A_B : begin // CMD = 12
                  valid_pipe <= {valid_pipe[1:0], (INP_VALID==2'b11)};
                  if(INP_VALID == 2'b11) begin
                      TEMP_A <= OPA;
                      rotation <= OPB[ROL_WIDTH-1:0] ;
                      err_flag <= OPB[WIDTH_OP-1 : ROL_WIDTH + 1] ;
                  end
                  if(valid_pipe[0]) begin // upper bit are padded to zero
                    RES <= { ( (TEMP_A << rotation) | (TEMP_A >> WIDTH_OP - rotation) ) };
                    if(err_flag != 0) ERR <= 1'b1 ;
                    TEMP_A = 0;
                    TEMP_B = 0;
                    rotation = 0;
                    err_flag = 0;
                    valid_pipe = 0;
                  end
                  if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                        ERR <= 1;
                                        RES <= {WIDTH{1'b0}};
                          end
                end
                `ROR_A_B : begin
                           valid_pipe <= {valid_pipe[1:0], (INP_VALID==2'b11)};
                           if(INP_VALID==2'b11) begin
                                TEMP_A <= OPA;
                                rotation <= OPB[ROL_WIDTH-1:0];
                                err_flag <= OPB[WIDTH_OP-1 : ROL_WIDTH + 1] ;
                           end
                  if(valid_pipe[0])begin
                    RES <= { ( (TEMP_A >> rotation) | (TEMP_A << WIDTH_OP - rotation) )};
                    if(err_flag != 0) ERR <= 1'b1 ;
                    TEMP_A = 0;
                    TEMP_B = 0;
                    rotation = 0;
                    err_flag = 0;
                    valid_pipe = 0;
                  end
                  if(INP_VALID == 2'b10 || INP_VALID == 2'b01 || INP_VALID == 2'b00) begin
                                        ERR <= 1;
                                        RES <= {WIDTH{1'b0}};
                          end
                end
                default : begin
                        ERR <= 1'b1;
                        OFLOW <= 1'b0;
                        COUT <= 1'b0;
                        G <= 1'b0;
                        L <= 1'b0;
                        E <= 1'b0;
                        RES <= {WIDTH{1'b0}};
                end
              endcase
          end
        end
        else begin // CE == 0 !!
                ERR <= 1'b0;
                OFLOW <= 1'b0;
                COUT <= 1'b0;
                G <= 1'b0;
                L <= 1'b0;
                E <= 1'b0;
                RES <= {WIDTH{1'b0}};
        end
end
endmodule
