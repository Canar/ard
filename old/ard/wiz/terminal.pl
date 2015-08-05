clear_tty:-tty(clear).
tty(clear):-tcx(cl).
tty(save_cursor_pos):-tcx(sc).
tty(load_cursor_pos):-tcx(rc).
tcx(A):-tcx(A,string,_,1).
tcx(A,B,C,D):-tty_get_capability(A,B,C),tty_put(C,D).

