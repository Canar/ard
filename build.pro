#!/usr/bin/swipl -q

% miscellaneous nonsense %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

str(A,B):-str(A,B,_).
str(acsh,'--disable-static --enable-shared','standard autoconf shared configure flags').
str(acst,'--enable-static --disable-shared','standard autoconf static configure flags').

pathagg(prefix,build,'prefix/').
pathagg(include,prefix,'include/').
pathagg(lib,prefix,'lib/').
pathagg(openssl,lib,'ssl/').
pathagg(aclocal,prefix,'share/aclocal/').
pathagg(pkgconfig,lib,'pkgconfig/').

link(shared).

pkg(curl).
pkg(zlib).
pkg(cppunit).
pkg(ncurses).
pkg(libtorrent).

depopt(curl,zlib).
depopt(curl,openssl).

% build configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

globalopts([shared,amd64,prefix]).

dep(curl(zlib,openssl),[zlib,openssl(zlib)]).
dep(libtorrent,[zlib,openssl(zlib),curl(zlib,openssl),cppunit]).
dep(rtorrent,[ncurses,libtorrent(zlib)]).
dep(openssl,[zlib]).

preconf(curl,'./buildconf').
preconf(cppunit,'./autogen.sh').
preconf(libtorrent,'./autogen.sh').
preconf(rtorrent,'./autogen.sh').

optconfflag(_,[prefix],F):-dirflag(prefix,'--prefix=',F).

optconfflag(zlib,[static],'--static').

optconfflag(openssl,[],F):-dirflag(openssl,'--openssldir=',F).
optconfflag(openssl,[amd64],'linux-x86_64').
optconfflag(openssl,[shared],'shared -fPIC -DOPENSSL_PIC').
optconfflag(openssl,[shared,zlib],'zlib-dynamic').
optconfflag(openssl,[static],'no-shared').
optconfflag(openssl,[static,zlib],'zlib').
optconfflag(openssl,[zlib],F):-
	dirflag(include,'--with-zlib-include=',A),
	dirflag(lib,'--with-zlib-lib=',B),
	cs([A,B],F).

optconfflag(curl,[zlib],'--with-zlib').
optconfflag(curl,[shared],F):-str(acsh,F).
optconfflag(curl,[static],F):-str(acst,F).
optconfflag(curl,[openssl],F):-dirflag(openssl,'--with-ssl=',F).

optconfflag(libtorrent,[],F):-dirflag(prefix,'--with-posix-fallocate --with-zlib=',F).

optconfflag(ncurses,[],'--without-debug --with-widec --enable-pc-files --with-pkg-config').
optconfflag(ncurses,[shared],F):-str(acsh,F).
optconfflag(ncurses,[static],F):-str(acst,F).

optconfflag(rtorrent,[shared],F):-str(acsh,F).
optconfflag(rtorrent,[static],F):-str(acst,F).

optenv(openssl,[shared,zlib],[['CFLAGS','-fPIC']]).
optenv(rtorrent,[],[
	['CFLAGS',A],
	['CPPFLAGS',A],
	['LDFLAGS',B],
	['LIBS','-ldl']]):-
	path(include,Y),
	cz(['-I',Y,'ncurses -I',Y],A),
	path(lib,Z),
	cz(['-L',Z,' -lncurses'],B).	

configscript(openssl,'./Configure').
configscript(_,'./configure').

% business logic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setenvl([K,V]):-setenv(K,V).
unsetenvl([K,_]):-unsetenv(K).

setupenv(Pkg):-
	ignore(
	(	optenvs(Pkg,Env)
	,	maplist(setenvl,Env))).

unsetupenv(Pkg)
:-	ignore(
	(	optenvs(Pkg,Env)
	,	maplist(unsetenvl,Env))).

dirflag(Dir,Pre,Flag):-path(Dir,D),cc(Pre,D,Flag).

getsubsets(Pred,Id,In,Out)
:-	findall(SubOut,
	(	call(Pred,Id,SubIn,SubOut)
	,	subset(SubIn,In)
	),Out).

optconfflags(Pkg,Opt,Fla):-getsubsets(optconfflag,Pkg,Opt,Fla).

optenvs(Pkg,Fla):-Pkg=..[P|O],optenvs(P,O,Fla).
optenvs(Pkg,Opt,Fla):-getsubsets(optenv,Pkg,Opt,Fla).

preconfigure(Pkg):-
	ignore((
		preconf(Pkg,Pc),
		cz(['build-preconfigure-',Pkg,'.log'],Fn),
		hideout(Pc,'Preconfiguring',Fn)
	)).

configure(Pkg,Opts):-
	optconfflags(Pkg,Opts,Flags),
	configscript(Pkg,Scr),
	cs([Scr|Flags],Cmd),
	cz(['build-configure-',Pkg,'.log'],Fn),
	hideout(Cmd,'Configuring',Fn).

buildplan(Pkg,Plan):-
	expandplan([Pkg],[Pkg],Plan).

memberr(A,B):-member(B,A).
expandplan(OldPlan,[PkgF|Pkgs],NewPlan):-
	PkgF=..[Pkg|_],
	dep(Pkg,Dep),
	append([Dep,[PkgF]],Curr),
	exclude(memberr(OldPlan),Curr,New),
	expandplan(OldPlan,Pkgs,Plan),
	append([New,Plan],CurrPlan),
	(	CurrPlan == OldPlan
	->	NewPlan = CurrPlan
	;	expandplan(CurrPlan,CurrPlan,NewPlan)).
expandplan(OldPlan,[_|Pkgs],NewPlan):-
	expandplan(OldPlan,Pkgs,NewPlan).
expandplan(Plan,[],Plan).

hideout(Cmd,Message,LogFile):-
	cs([Cmd,'2>&1'],Co),
	process_create(path(sh),['-c',Co],[stdout(pipe(Out)),process(Pid)]),
	write('# '),write(Cmd),nl,
	cz(['../',LogFile],File),
	open(File,write,Log,[]),
	write(Message),
	hideoutput(Out,Log),
	close(Log),
	process_wait(Pid,Status),
	( Status == exit(0) ; throw(fuck) ).
hideoutput(Out,Log):-
	read_line_to_codes(Out,Codes),
	\+ Codes == end_of_file,
	write('.'),
	flush_output,
	atom_codes(Atom,Codes),
	write(Log,Atom),
	nl(Log),
	hideoutput(Out,Log).
hideoutput(_,_):-nl,!.

make(Pkg):-
	cz(['build-make-',Pkg,'.log'],Fn),
	hideout('make','Compiling',Fn).

makeinst(Pkg):-
	cz(['build-install-',Pkg,'.log'],Fn),
	hideout('make install','Installing',Fn).

build(Pkg):-
	buildplan(Pkg,Plan),
	maplist(buildpkg,Plan).

buildpkg(PkgF):-
	PkgF=..[Pkg|Opts],	
	working_directory(Old,Pkg),
	write('Building '),write(Pkg),nl,
	setupenv(PkgF),
	preconfigure(Pkg),
	globalopts(Global),
	append([Global,Opts],Conf),
	configure(Pkg,Conf),
	make(Pkg),
	makeinst(Pkg),
	unsetupenv(Pkg),
	working_directory(_,Old).


% miscellaneous helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c(L,S,A):-atomic_list_concat(L,S,A).
cs(L,A):-c(L,' ',A).
cc(Sa,Sb,S):-c([Sa,Sb],'',S).
cz(L,A):-c(L,'',A).

:- dynamic path/2.
path(P,D):-pathagg(P,Pp,Dc),path(Pp,Dp),cc(Dp,Dc,D).

setup:-
	working_directory(Dir,Dir),
	asserta(path(build,Dir)),
	path(aclocal,Dac),
	setenv('ACLOCAL_PATH',Dac),
	path(pkgconfig,Dpc),
	setenv('PKG_CONFIG_PATH',Dpc).

go:-
	setup,
	build(rtorrent).

eval :-
	go.
%	current_prolog_flag(argv, Argv),
%	concat_atom(Argv, ' ', SingleArg),
%	term_to_atom(Term, SingleArg),
%	Val is Term,
%	format('~w~n', [Val]).

main :-
	catch(eval, E, (print_message(error, E), fail)),
	halt.
main :-
	halt(1).

%:- initialization main.
