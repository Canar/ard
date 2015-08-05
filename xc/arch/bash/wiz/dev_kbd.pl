get_le_int2n(0,Value):-get_byte(Value).
get_le_int2n(N,Value):-M=N-1,get_int2n(M,Lo),get_int2n(M,Hi),Value is Lo+Hi*2**N.
get_kb(TimeS,TimeU,Type,Code,Value):-
	get_byte(B11),get_byte(B12),get_byte(B13),get_byte(B14),TimeS is B11+B12*2**8+B13*2**16+B14*2**24,
	get_byte(B21),get_byte(B22),get_byte(B23),get_byte(B24),TimeU is B21+B22*2**8+B23*2**16+B24*2**24,
	get_byte(B31),get_byte(B32),Type is B31+B32*2**8,
	get_byte(B41),get_byte(B42),Code is B41+B42*2**8,
	get_byte(B51),get_byte(B52),get_byte(B53),get_byte(B54),Value is B51+B52*2**8+B53*2**16+B54*2**24.

get_kbev(Type,Code,State):-
	get_kb(_Ta,_Sa,4,4,Type),
	get_kb(_Tb,_Sb,1,Code,State),
	get_kb(_Tc,_Sc,0,0,0).

slp :-  
	set_stream(I,tty(true)),
	stream_property(user_output,tty(true)),
	slp2(I).

get_n(I,[]):-I<1.
get_n(I,[H|T]):-
	J is I - 1,
	print(J),
	get_byte(H),
	get_n(J,T).

alias(quit,[exit,halt,break,return,escape]).
halt_command(quit).

keyboard(_)
:-	open('/dev/input/event0',read,Stream,[type(binary),buffer(false),bom(false)])
,	set_input(Stream)
,	repeat
,	get_kbev(Type,Code,State)
,	report(kbd(Type,Code,State))
,	fail.

