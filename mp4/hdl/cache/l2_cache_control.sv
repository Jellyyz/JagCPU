/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

module l2_cache_control #(
    parameter num_ways = 8,
    parameter num_bits = 1
)
(
    input logic clk,
    input logic rst, 
    input logic dirty_out[num_ways], valid_out[num_ways], hit[num_ways],
    input logic [num_ways-1:0] lru_out,
    
    input logic [31:0] mem_byte_enable256,
    input logic mem_read, mem_write,
    input logic pmem_resp,
    
    output logic dirty_in[num_ways], valid_in[num_ways],
    output logic ld_dirty[num_ways], ld_valid[num_ways], ld_lru, ld_tag[num_ways],
    output logic rd_data[num_ways], rd_dirty[num_ways], rd_valid[num_ways], rd_lru, rd_tag[num_ways], 
    output logic datain_sel[num_ways], pmem_read, pmem_write, mem_resp,
    output logic [num_ways-1:0] lru_in,

    output logic mem_addr_sel, 
    output logic [31:0] byte_enable[num_ways]
);

enum int unsigned {
	idle, cache_access, write_back, read, done
} state, next_state;

function void set_defaults();

    rd_lru = 1'b1;
    rd_data[0] = 1'b1;
    rd_data[1] = 1'b1;
    rd_dirty[0] = 1'b1;
    rd_dirty[1] = 1'b1; 
    rd_valid[0] = 1'b1; 
    rd_valid[1] = 1'b1;
    rd_tag[0] = 1'b1; 
    rd_tag[1] = 1'b1;

    ld_lru = 1'b0;
    ld_dirty[0] = 1'b0;
    ld_dirty[1] = 1'b0;
    ld_valid[0] = 1'b0;
    ld_valid[1] = 1'b0;
    ld_tag[0] = 1'b0;
    ld_tag[1] = 1'b0;

    dirty_in[0] = dirty_out[0];
    dirty_in[1] = dirty_out[1];
    valid_in[0] = valid_out[0];
    valid_in[1] = valid_out[1];

    byte_enable[0] = {32{1'b0}};
    byte_enable[1] = {32{1'b0}};

    rd_data[2] = 1'b1;
    rd_data[3] = 1'b1;
    rd_dirty[2] = 1'b1;
    rd_dirty[3] = 1'b1; 
    rd_valid[2] = 1'b1; 
    rd_valid[3] = 1'b1;
    rd_tag[2] = 1'b1; 
    rd_tag[3] = 1'b1;

    ld_dirty[2] = 1'b0;
    ld_dirty[3] = 1'b0;
    ld_valid[2] = 1'b0;
    ld_valid[3] = 1'b0;
    ld_tag[2] = 1'b0;
    ld_tag[3] = 1'b0;

    dirty_in[2] = dirty_out[2];
    dirty_in[3] = dirty_out[3];
    valid_in[2] = valid_out[2];
    valid_in[3] = valid_out[3];

    byte_enable[2] = {32{1'b0}};
    byte_enable[3] = {32{1'b0}};

	mem_addr_sel = 1'b0;
	datain_sel[0] = 1'b0;
	datain_sel[1] = 1'b0;
    datain_sel[2] = 1'b0;
	datain_sel[3] = 1'b0;

    rd_data[4] = 1'b1;
    rd_data[5] = 1'b1;
    rd_dirty[4] = 1'b1;
    rd_dirty[5] = 1'b1; 
    rd_valid[4] = 1'b1; 
    rd_valid[5] = 1'b1;
    rd_tag[4] = 1'b1; 
    rd_tag[5] = 1'b1;

    ld_dirty[4] = 1'b0;
    ld_dirty[5] = 1'b0;
    ld_valid[4] = 1'b0;
    ld_valid[5] = 1'b0;
    ld_tag[4] = 1'b0;
    ld_tag[5] = 1'b0;

    dirty_in[4] = dirty_out[4];
    dirty_in[5] = dirty_out[5];
    valid_in[4] = valid_out[4];
    valid_in[5] = valid_out[5];

    byte_enable[4] = {32{1'b0}};
    byte_enable[5] = {32{1'b0}};

    rd_data[6] = 1'b1;
    rd_data[7] = 1'b1;
    rd_dirty[6] = 1'b1;
    rd_dirty[7] = 1'b1; 
    rd_valid[6] = 1'b1; 
    rd_valid[7] = 1'b1;
    rd_tag[6] = 1'b1; 
    rd_tag[7] = 1'b1;

    ld_dirty[6] = 1'b0;
    ld_dirty[7] = 1'b0;
    ld_valid[6] = 1'b0;
    ld_valid[7] = 1'b0;
    ld_tag[6] = 1'b0;
    ld_tag[7] = 1'b0;

    dirty_in[6] = dirty_out[6];
    dirty_in[7] = dirty_out[7];
    valid_in[6] = valid_out[6];
    valid_in[7] = valid_out[7];

    byte_enable[6] = {32{1'b0}};
    byte_enable[7] = {32{1'b0}};

	datain_sel[4] = 1'b0;
	datain_sel[5] = 1'b0;
    datain_sel[6] = 1'b0;
	datain_sel[7] = 1'b0;
    pmem_read = 1'b0;
    pmem_write = 1'b0;

    mem_resp = 1'b0;
endfunction

function void write_to_mem();
    pmem_write = 1'b1;
    mem_addr_sel = 1'b1; 
endfunction

always_comb
begin : state_actions
    set_defaults();
	case(state)
	    idle: ;

	    cache_access: begin
            if (hit[0]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[1]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[2]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[3]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[4]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[5]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[6]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[7]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

		    if(hit[0] && mem_write) begin
				dirty_in[0] = 1'b1;
				ld_dirty[0] = 1'b1; rd_dirty[0] = 1'b0;
				byte_enable[0] = mem_byte_enable256; rd_data[0] = 1'b0;
			end

			else if (hit[1] && mem_write) begin
				dirty_in[1] = 1'b1;
				ld_dirty[1] = 1'b1; rd_dirty[1] = 1'b0;
				byte_enable[1] = mem_byte_enable256; rd_data[1] = 1'b1;
			end

            else if (hit[2] && mem_write) begin
				dirty_in[2] = 1'b1;
				ld_dirty[2] = 1'b1; rd_dirty[2] = 1'b0;
				byte_enable[2] = mem_byte_enable256; rd_data[2] = 1'b1;
			end

            else if (hit[3] && mem_write) begin
				dirty_in[3] = 1'b1;
				ld_dirty[3] = 1'b1; rd_dirty[3] = 1'b0;
				byte_enable[3] = mem_byte_enable256; rd_data[3] = 1'b1;
			end

            else if (hit[4] && mem_write) begin
				dirty_in[4] = 1'b1;
				ld_dirty[4] = 1'b1; rd_dirty[4] = 1'b0;
				byte_enable[4] = mem_byte_enable256; rd_data[4] = 1'b1;
			end

            else if (hit[5] && mem_write) begin
				dirty_in[5] = 1'b1;
				ld_dirty[5] = 1'b1; rd_dirty[5] = 1'b0;
				byte_enable[5] = mem_byte_enable256; rd_data[5] = 1'b1;
			end

            else if (hit[6] && mem_write) begin
				dirty_in[6] = 1'b1;
				ld_dirty[6] = 1'b1; rd_dirty[6] = 1'b0;
				byte_enable[6] = mem_byte_enable256; rd_data[6] = 1'b1;
			end

            else if (hit[7] && mem_write) begin
				dirty_in[7] = 1'b1;
				ld_dirty[7] = 1'b1; rd_dirty[7] = 1'b0;
				byte_enable[7] = mem_byte_enable256; rd_data[7] = 1'b1;
			end
        end

        write_back: begin
            write_to_mem(); 
        end

        read: begin
            if(lru_out[0] | (~lru_out[1] && ~lru_out[2] && ~lru_out[3] && ~lru_out[4] && ~lru_out[5] && ~lru_out[6] && ~lru_out[7])) begin
                datain_sel[0] = 1'b1;
				ld_tag[0] = 1'b1; rd_tag[0] = 1'b0;
				dirty_in[0] = 1'b0;
				ld_dirty[0] = 1'b1; rd_dirty[0] = 1'b0;
                valid_in[0] = 1'b1;
                ld_valid[0] = 1'b1; rd_valid[0] = 1'b0;
                byte_enable[0] = {32{1'b1}}; rd_data[0] = 1'b0;
            end

            else if (lru_out[1]) begin
                datain_sel[1] = 1'b1;
				ld_tag[1] = 1'b1; rd_tag[1] = 1'b0;
				dirty_in[1] = 1'b0;
				ld_dirty[1] = 1'b1; rd_dirty[1] = 1'b0; 
                valid_in[1] = 1'b1;
				ld_valid[1] = 1'b1; rd_valid[1] = 1'b0;
                byte_enable[1] = {32{1'b1}}; rd_data[1] = 1'b0;
            end

            else if (lru_out[2]) begin
                datain_sel[2] = 1'b1;
				ld_tag[2] = 1'b1; rd_tag[2] = 1'b0;
				dirty_in[2] = 1'b0;
				ld_dirty[2] = 1'b1; rd_dirty[2] = 1'b0; 
                valid_in[2] = 1'b1;
				ld_valid[2] = 1'b1; rd_valid[2] = 1'b0;
                byte_enable[2] = {32{1'b1}}; rd_data[2] = 1'b0;
            end

            else if (lru_out[3]) begin
                datain_sel[3] = 1'b1;
				ld_tag[3] = 1'b1; rd_tag[3] = 1'b0;
				dirty_in[3] = 1'b0;
				ld_dirty[3] = 1'b1; rd_dirty[3] = 1'b0; 
                valid_in[3] = 1'b1;
				ld_valid[3] = 1'b1; rd_valid[3] = 1'b0;
                byte_enable[3] = {32{1'b1}}; rd_data[3] = 1'b0;
            end

            else if (lru_out[4]) begin
                datain_sel[4] = 1'b1;
				ld_tag[4] = 1'b1; rd_tag[4] = 1'b0;
				dirty_in[4] = 1'b0;
				ld_dirty[4] = 1'b1; rd_dirty[4] = 1'b0; 
                valid_in[4] = 1'b1;
				ld_valid[4] = 1'b1; rd_valid[4] = 1'b0;
                byte_enable[4] = {32{1'b1}}; rd_data[4] = 1'b0;
            end

            else if (lru_out[5]) begin
                datain_sel[5] = 1'b1;
				ld_tag[5] = 1'b1; rd_tag[5] = 1'b0;
				dirty_in[5] = 1'b0;
				ld_dirty[5] = 1'b1; rd_dirty[5] = 1'b0; 
                valid_in[5] = 1'b1;
				ld_valid[5] = 1'b1; rd_valid[5] = 1'b0;
                byte_enable[5] = {32{1'b1}}; rd_data[5] = 1'b0;
            end

            else if (lru_out[6]) begin
                datain_sel[6] = 1'b1;
				ld_tag[6] = 1'b1; rd_tag[6] = 1'b0;
				dirty_in[6] = 1'b0;
				ld_dirty[6] = 1'b1; rd_dirty[6] = 1'b0; 
                valid_in[6] = 1'b1;
				ld_valid[6] = 1'b1; rd_valid[6] = 1'b0;
                byte_enable[6] = {32{1'b1}}; rd_data[6] = 1'b0;
            end

            else if (lru_out[7]) begin
                datain_sel[7] = 1'b1;
				ld_tag[7] = 1'b1; rd_tag[3] = 1'b0;
				dirty_in[7] = 1'b0;
				ld_dirty[7] = 1'b1; rd_dirty[7] = 1'b0; 
                valid_in[7] = 1'b1;
				ld_valid[7] = 1'b1; rd_valid[7] = 1'b0;
                byte_enable[7] = {32{1'b1}}; rd_data[7] = 1'b0;
            end

            pmem_read = 1'b1;
            mem_addr_sel = 1'b0;
        end

        done: begin
            if(lru_out[0] && mem_write) begin
                dirty_in[0] = 1'b1;
                ld_dirty[0] = 1'b1; rd_dirty[0] = 1'b0;
                byte_enable[0] = mem_byte_enable256; rd_data[0] = 1'b0;
            end

            else if(lru_out[1] && mem_write) begin
                dirty_in[1] = 1'b1;
                ld_dirty[1] = 1'b1; rd_dirty[1] = 1'b0;
                byte_enable[1] = mem_byte_enable256; rd_data[1] = 1'b0;                       
            end

            else if(lru_out[2] && mem_write) begin
                dirty_in[2] = 1'b1;
                ld_dirty[2] = 1'b1; rd_dirty[2] = 1'b0;
                byte_enable[2] = mem_byte_enable256; rd_data[2] = 1'b0;                       
            end

            else if(lru_out[3] && mem_write) begin
                dirty_in[3] = 1'b1;
                ld_dirty[3] = 1'b1; rd_dirty[3] = 1'b0;
                byte_enable[3] = mem_byte_enable256; rd_data[3] = 1'b0;                       
            end

            else if(lru_out[4] && mem_write) begin
                dirty_in[4] = 1'b1;
                ld_dirty[4] = 1'b1; rd_dirty[4] = 1'b0;
                byte_enable[4] = mem_byte_enable256; rd_data[4] = 1'b0;                       
            end

            else if(lru_out[5] && mem_write) begin
                dirty_in[5] = 1'b1;
                ld_dirty[5] = 1'b1; rd_dirty[5] = 1'b0;
                byte_enable[5] = mem_byte_enable256; rd_data[5] = 1'b0;                       
            end

            else if(lru_out[6] && mem_write) begin
                dirty_in[6] = 1'b1;
                ld_dirty[6] = 1'b1; rd_dirty[6] = 1'b0;
                byte_enable[6] = mem_byte_enable256; rd_data[6] = 1'b0;                       
            end

            else if(lru_out[7] && mem_write) begin
                dirty_in[7] = 1'b1;
                ld_dirty[7] = 1'b1; rd_dirty[7] = 1'b0;
                byte_enable[7] = mem_byte_enable256; rd_data[7] = 1'b0;                       
            end

            if (hit[0]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[1]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[2]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[3]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[4]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[5]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[6]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit[7]) begin
                mem_resp = 1'b1;
	            lru_in = {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end
        end
    endcase
end


always_comb
begin : next_state_logic
	unique case(state)
		idle: begin
            if (mem_read | mem_write) next_state = cache_access;
            else next_state = idle;
        end

		cache_access: begin
		    if(hit[0] | hit[1] | hit[2] | hit[3] | hit[4] | hit[5] | hit[6] | hit[7]) next_state = idle;
		    else if(lru_out[0] && dirty_out[0] && valid_out[0]) next_state = write_back;
		    else if(lru_out[1] && dirty_out[1] && valid_out[1]) next_state = write_back;
		    else if(lru_out[2] && dirty_out[2] && valid_out[2]) next_state = write_back;
		    else if(lru_out[3] && dirty_out[3] && valid_out[3]) next_state = write_back;
            else if(lru_out[4] && dirty_out[4] && valid_out[4]) next_state = write_back;
            else if(lru_out[5] && dirty_out[5] && valid_out[5]) next_state = write_back;
            else if(lru_out[6] && dirty_out[6] && valid_out[6]) next_state = write_back;
            else if(lru_out[7] && dirty_out[7] && valid_out[7]) next_state = write_back;
            else next_state = read;   
        end

        write_back: begin
            if(pmem_resp) next_state = read;
            else next_state = write_back;
        end

        read: begin
            if(pmem_resp) next_state = done;
            else next_state = read;
        end

        done: begin
            next_state = idle;
        end
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    if (rst)
        state <= idle;
    else state <= next_state;
end

endmodule : l2_cache_control
