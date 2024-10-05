iverilog -o run.vvp -g2012 ..\tb\free_list_ff_tb.v ..\rtl\m_free_list_ff.v  ..\rtl\m_counter.v  ..\rtl\m_ff.v  ..\rtl\m_assert.v ..\rtl\m_first_set.v
vvp run.vvp