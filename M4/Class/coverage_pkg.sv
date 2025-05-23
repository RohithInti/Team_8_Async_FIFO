////////////////////////////////////////////////////////////////////////////////
// File       : coverage_pkg.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: Coverage package for FIFO write/read flags and operations.
////////////////////////////////////////////////////////////////////////////////

`ifndef COVERAGE_PKG_SV
`define COVERAGE_PKG_SV

package coverage_pkg;
  import tb_pkg::*;

covergroup write_cg (ref logic wr_en, ref logic full, ref logic half_full);
     option.per_instance = 1;
    coverpoint wr_en {
      bins write = {1};
      bins no_write = {0};
    }
    coverpoint full {
      bins full_set = {1};
      bins full_clr = {0};
    }
    coverpoint half_full {
      bins hf_set = {1};
      bins hf_clr = {0};
    }
  endgroup : write_cg

covergroup read_cg (ref logic rd_en, ref logic empty, ref logic half_empty);
     option.per_instance = 1;
    coverpoint rd_en {
      bins read = {1};
      bins no_read = {0};
    }
    coverpoint empty {
      bins empty_set = {1};
      bins empty_clr = {0};
    }
    coverpoint half_empty {
      bins he_set = {1};
      bins he_clr = {0};
    }
  endgroup : read_cg

  class fifo_cov;
    write_cg write_h;
    read_cg  read_h;

    function new(virtual intf vif);
      write_h = write_cg::new(vif.wr_en, vif.full, vif.half_full);
      read_h  = read_cg::new(vif.rd_en, vif.empty, vif.half_empty);
    endfunction

    function void sample_wr();
      write_h.sample();
    endfunction

    function void sample_rd();
      read_h.sample();
    endfunction

    function void report();
      real cov_w = write_h.get_coverage();
      real cov_r = read_h.get_coverage();
      $display("\n=== COVERAGE REPORT ===");
      $display("  Write-side : %0.2f%%", cov_w);
      $display("  Read-side  : %0.2f%%", cov_r);
    endfunction
  endclass : fifo_cov

endpackage : coverage_pkg

`endif // COVERAGE_PKG_SV
