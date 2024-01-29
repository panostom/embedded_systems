module fsm_rd(
    input logic read_en,
    input logic [15:0] rd_data,
    output logic [2:0] addr_rd,
    output logic [15:0] avg_o,
    clk_rst_intrfc interfc
    );
    
typedef enum logic[2:0] {IDLE, ASK, WAITING, WAITING2, READ, CALCULATE, PRINT } state_t;
state_t fsm_state;    

logic [15:0] array_of_mem[7:0]; //pinakas gia tis 8 times pou kanei read
logic [3:0] array_index;
logic [2:0] addr_rd_mem;    //adress diabasmatos
logic [31:0] average_calc;  //32bit gia ton upologismo tou average
    
always_ff @(posedge interfc.clk or negedge interfc.rstn)begin
    if(!interfc.rstn)begin    
        avg_o<=0;
        addr_rd<=3'b0;
        fsm_state<=IDLE;
        array_index<=0;
        addr_rd_mem<=0;
        average_calc<=0;
        array_of_mem[0]<=16'b0;array_of_mem[1]<=16'b0;array_of_mem[2]<=16'b0;array_of_mem[3]<=16'b0;array_of_mem[4]<=16'b0;array_of_mem[5]<=16'b0;array_of_mem[6]<=16'b0;array_of_mem[7]<=16'b0;
    end
    else begin
        case(fsm_state)
            IDLE:begin
                avg_o<=0;
                addr_rd<=3'b0;
                array_index<=0;
                addr_rd_mem<=0;
                average_calc<=0;
                if(read_en)begin
                    fsm_state<=ASK;
                end
                else begin
                    fsm_state<=IDLE;
                end            
            end
            ASK:begin   //ftiaxnw tis exodous gia na zhthsw dedomena apo th ram
                addr_rd<=addr_rd_mem;   
                //addr_rd_mem<=addr_rd_mem+1;
                fsm_state<=WAITING;
            end
            WAITING:begin           //2 kukloi anamonhs
                addr_rd_mem<=addr_rd_mem+1;
                fsm_state<=WAITING2;
            end
            WAITING2:begin
                fsm_state<=READ;
            end
            READ:begin
                array_of_mem[array_index]<=rd_data; //grafw thn apanthsh ston pinaka
                array_index<=array_index+1;
                if(array_index==7)begin     
                    fsm_state<=CALCULATE;   //otan kanw 8 eggrafes, paw gia upologismo
                    array_index<=0;
                end
                else begin
                    fsm_state<=ASK;
                end
            end
            /*CALCULATE:begin         //9 kukloi gia ton upologismo tou average
                if(array_index<8)begin
                    average_calc<=average_calc+32'(array_of_mem[array_index]);
                    array_index<=array_index+1; 
                    fsm_state<=CALCULATE;
                end
                else begin
                    average_calc<=average_calc >> 3;
                    fsm_state<=PRINT;
                end
            end */
            CALCULATE:begin        
                average_calc<=array_of_mem[0]+array_of_mem[1]+array_of_mem[2]+array_of_mem[3]+array_of_mem[4]+array_of_mem[5]+array_of_mem[6]+array_of_mem[7];
                fsm_state<=IDLE;
            end       //pio grhgoro calculate auto, kai sto assign kanw thn olisthsh, PETYXAINEI
            /*PRINT:begin
                avg_o<=average_calc;
                $display("the result is %d",average_calc);
                fsm_state<=IDLE;
            end */      
        endcase    
    end 
end    
    
assign avg_o=average_calc >> 3;    //diairesh dia 8
    
endmodule
