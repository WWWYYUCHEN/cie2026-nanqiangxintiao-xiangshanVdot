`timescale 1ns/1ps

module tb_vdot_exact;
    reg  [127:0] vs1, vs2;
    wire [127:0] vd;
    integer errors = 0;
    integer checks = 0;

    vdot_exact_unit dut(.vs1(vs1), .vs2(vs2), .vd(vd));

    task check;
        input [127:0] a;
        input [127:0] b;
        input [31:0] expected;
        begin
            vs1 = a;
            vs2 = b;
            #1;
            checks = checks + 1;
            if (vd !== {96'd0, expected}) begin
                errors = errors + 1;
                $display("[FAIL] expected=%08h got=%032h", expected, vd);
            end else begin
                $display("[PASS] expected=%08h result=%032h", expected, vd);
            end
        end
    endtask

    initial begin
        $dumpfile("vdot_exact_wave.vcd");
        $dumpvars(0, tb_vdot_exact);
        check(128'h0000000000000000_0101010101010101,
              128'h0000000000000000_0202020202020202,
              32'h00000010);
        check(128'h0000000000000000_8080808080808080,
              128'h0000000000000000_0101010101010101,
              32'hfffffc00);
        check(128'h0000000000000000_0000000001ff0201,
              128'h0000000000000000_000000000103ff02,
              32'hfffffffe);
        check(128'h0000000000000000_7f7f7f7f7f7f7f7f,
              128'h0000000000000000_7f7f7f7f7f7f7f7f,
              32'h0001f808);
        check(128'h0000000000000000_8080808080808080,
              128'h0000000000000000_7f7f7f7f7f7f7f7f,
              32'hfffe0400);
        $display("checks=%0d errors=%0d", checks, errors);
        if (errors != 0) $fatal(1);
        $finish;
    end
endmodule

