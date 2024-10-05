module m_first_set #(
    parameter EN = 64
)(
    input   [EN-1:0]    set_in,
    output  [EN-1:0]    set_out
);

reg     [EN-1:0]    C;

assign C[0] = set_in[0];

generate
for (genvar i0=1; i0<EN; i0++) begin
assign C[i0] = C[i0-1] || set_in[i0];
end
endgenerate

assign set_out = (~{C[EN-2:0], 1'b0} & set_in);

endmodule