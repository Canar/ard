reply(wiz(repeated_exename),'you got a stutter?').
reply(wiz(exe(N,'.'),['the fuck you callin me ~w for, and HOW THE FUCK DID YOU GET IN HERE?',N])).
reply(wiz(exe(N,P)),['the fuck you callin me ~w for, and why the fuck am i in ~w?',N,P]).
reply(wiz(exe(N)),['the fuck you callin me ~w for, and why the fuck are you up in my face?',N]).
reply(wiz(bad_args([H|T])),['the fuck you tellin me to ~w for?',H]).
reply(wiz(blank_invocation(O)),R)
:-	option(exefilename(Efn),O)
,	option(exepath(Ep),O)
,	reply(wiz(exe(Efn,Ep)),R).
