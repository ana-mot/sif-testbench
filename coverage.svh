class Coverage;
  virtual xw_if.MONITOR vif;

  typedef enum {NO_GAP, GAP1, MORE_GAP} gap_t;

  direction prev_op, curr_op;
  gap_t gap_type;
  int gap_count;
  bit rst_between;

  covergroup normal_cov;
    cp_wr : coverpoint vif.cbm.wr_s { bins wr = {1}; }

    cp_rd : coverpoint vif.cbm.rd_s { bins rd = {1}; }
  endgroup

  covergroup mix_cov;
    cp_previous : coverpoint prev_op {
      bins rd = {READ};
      bins wr = {WRITE};
    }

    cp_current : coverpoint curr_op {
      bins rd = {READ};
      bins wr = {WRITE};  
    }

    cp_gap : coverpoint gap_type {
      bins no_gap = {NO_GAP};
      bins gap1 = {GAP1};
      bins more_gap = {MORE_GAP};
    }

    cp_rst : coverpoint rst_between {
      bins no_rst  = {0};
      bins has_rst = {1};
    }

    mix_cross : cross cp_previous, cp_gap, cp_current;
    reset_cross : cross cp_previous, cp_rst, cp_current;
  endgroup

  function new(virtual xw_if.MONITOR vif);
    this.vif = vif;
    normal_cov = new();
    mix_cov = new();
  endfunction

task run();
forever begin
  @(vif.cbm);

  if (vif.cbm.rst_b == 1'b0) begin
    rst_between = 1;
    gap_count = 0;
  end 
  else begin
    if (vif.cbm.wr_s)
      curr_op = WRITE;
    else if (vif.cbm.rd_s)
      curr_op = READ;
    else begin
      gap_count++;
    end

    if (vif.cbm.wr_s || vif.cbm.rd_s) begin
      if (gap_count == 0) gap_type = NO_GAP;
      else if (gap_count == 1) gap_type = GAP1;
      else gap_type = MORE_GAP;

      normal_cov.sample();

      mix_cov.sample();

      prev_op = curr_op;
      gap_count = 0;
      rst_between = 0;
    end
  end
end
endtask
endclass

