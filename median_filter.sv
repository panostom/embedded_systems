module median_filter(
    input logic [15:0] data_i,
    input logic data_av_sync,
    output logic [15:0] median,
    output logic median_en,
    clk_rst_intrfc inst_in
    );
    
    logic [15:0] fifo[2:0];
    logic [1:0] wr_p=2'b00; //write index
    logic [1:0] index_m;

    always_ff @(posedge inst_in.clk or negedge inst_in.rstn) begin //kanw clocked to grapsimo sth fifo
        if(!inst_in.rstn)begin
            wr_p=2'b00;
            fifo[0]<=16'b0; //arxikopoiw th fifo
            fifo[1]<=16'b0;
            fifo[2]<=16'b0;
        end
        else begin
            if(data_av_sync) begin //otan parw shma energopoihshs
                fifo[wr_p]<=data_i; //grafw sth thesh pou deixnei o index
                wr_p<=wr_p+1;       //auxanw index
                if(wr_p==2) //de m aresei
                    wr_p<=2'b0;
            end
        end
    end    
        
    always_ff @(posedge inst_in.clk or negedge inst_in.rstn)begin //edw kanw to control shma opws mas proteinate
        if(!inst_in.rstn)begin
            median_en<=0;
        end
        else begin
            if(data_av_sync)begin   //elegxei an pairnw sync shma kai bgazei to enable
                median_en<=1;
            end
            else begin
                median_en<=0;
            end
        end
    end
        
    always_comb begin
        if(!inst_in.rstn) begin
            median=16'b0;
        end
        else begin
            if(fifo[0] < fifo[1])  //krataw to index tou mikroterou
                index_m=0;
            else
                index_m=1;
            if(fifo[2] < fifo[index_m])
                index_m=2;
            else
                index_m=index_m;
            if(index_m==0)begin         //analoga poios einai o mikroteros, elegxw tous allous 2
                if(fifo[1] < fifo[2]) begin
                    median=fifo[1];
                end    
                else begin
                    median=fifo[2];
                end
            end
            else if(index_m==1)begin
                if(fifo[0] < fifo[2]) begin
                    median=fifo[0];
                end
                else begin
                    median=fifo[2];
                end
            end 
            else begin
                if(fifo[0] < fifo[1]) begin
                    median=fifo[0];
                end
                else begin
                    median=fifo[1];
                end
            end
        end                 
    end
    
endmodule
