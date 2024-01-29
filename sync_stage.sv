module sync_stage(
    input logic data_av_ai,
    output logic data_av_sync,
    clk_rst_intrfc interfc
    );
    
logic out_1;
logic out_2;
    
always_ff @(posedge interfc.clk or negedge interfc.rstn)begin
    if(!interfc.rstn) begin
        out_1<=0;
        out_2<=0;
    end
    else begin
        out_1<=data_av_ai;     //ulopoihsh 2 dff
        out_2<=out_1;
    end
end

assign data_av_sync = out_2; //ulopoihsh me exwteriko assign, anti na lew data_av_synce<=out_1
                            //mallon einai pio katharh lush  
endmodule
