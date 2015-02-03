#!/usr/bin/swipl -q

%:- initialization main.

% miscellaneous helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c(L,S,A):-atomic_list_concat(L,S,A).
cs(L,A):-atomic_list_concat(L,' ',A).
ca(Sa,Sb,S):-c([Sa,Sb],'',S).

:- dynamic dird/2.
dird(P,D):-dirda(P,Pp,Dc),dird(Pp,Dp),ca(Dp,Dc,D).

% build configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirda(prefix,build,'prefix/').
dirda(include,prefix,'include/').
dirda(lib,prefix,'lib/').
dirda(openssl,lib,'ssl/').
dirda(aclocal,prefix,'share/aclocal/').
dirda(pkgconfig,lib,'pkgconfig/').

link(shared).

pkg(curl).
pkg(zlib).
pkg(cppunit).
pkg(ncurses).
pkg(libtorrent).

dep(libtorrent,[zlib,openssl(zlib),curl(zlib,openssl),cppunit]).
dep(rtorrent,[ncurses,libtorrent]).
dep(openssl,[zlib]).

depopt(curl,zlib).
depopt(curl,openssl).

preconf(curl,'./buildconf').
preconf(cppunit,'./autogen.sh').
preconf(libtorrent,'./autogen.sh').

confflag(openssl,F):-
	dird(openssl,D),
	c(['--openssldir=',D,' -fPIC linux-x86_64'],'',F).
confflag(libtorrent,'--with-posix-fallocate').

confflag(Pkg,prefix,F):-confflagodir(Pkg,prefix,'--prefix=',F).

confflag(curl,zlib,'--with-zlib').
confflag(curl,shared,'--disable-static').
confflag(curl,openssl,F):-confflagodir(curl,openssl,'--with-ssl=',F).

confflag(openssl,shared,shared).
confflag(openssl,zlib,F):-
	dird(include,Di),
	dird(lib,Dl),
	c(['zlib-dynamic --with-zlib-include=',Di,' --with-zlib-lib=',Dl],'',F).

pkgenv(openssl,[['CFLAGS','-fPIC']]).

configscript(openssl,'./Configure').
configscript(_,'./configure').

% business logic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setenvl([K,V]):-setenv(K,V).
unsetenvl([K,_]):-unsetenv(K).

setupenv(Pkg):-
	pkgenv(Pkg,Env)
	->	maplist(setenvl,Env)
	;	true.

unsetupenv(Pkg):-
	pkgenv(Pkg,Env)
	->	maplist(unsetenvl,Env)
	;	true.

confflagodir(Pkg,Opt,Prefix,Flag):-confflagdir(Pkg,Opt,Opt,Prefix,Flag).
confflagdir(_,_,Dir,Prefix,Flag):-
	dird(Dir,D),
	ca(Prefix,D,Flag).

confflags(Pkg,[Opt|Opts],[Flag|Flags]):-
	confflag(Pkg,Opt,Flag),
	confflags(Pkg,Opts,Flags).
confflags(Pkg,[Opt|Opts],Flags):-
	write(Opt),
	write(' unrecognized as an option. Ignoring...'),
	nl,
	confflags(Pkg,Opts,Flags).
	
confflags(Pkg,[],[Flag]):-confflag(Pkg,Flag),atom(Flag).
confflags(Pkg,[],Flags):-confflag(Pkg,Flags),is_list(Flags).
confflags(_,[],[]).

configure(Pkg,Opts):-
	confflags(Pkg,Opts,Flags),
	configscript(Pkg,Scr),
	cs([Scr|Flags],Cmd),
	shell(Cmd).

build(Pkg):-
	builddep(Pkg),
	buildpkg(Pkg).

builddep(PkgF):-
	PkgF=..[Pkg|_],	
	dep(Pkg,Deps)->maplist(buildpkg,Deps);true.

buildpkg(PkgF):-
	PkgF=..[Pkg|Opts],	
	working_directory(Old,Pkg),
	setupenv(Pkg),
	( preconf(Pkg,Pc) -> shell(Pc) ; true ),
	configure(Pkg,[prefix,shared|Opts]),
	shell('make install'),
	unsetupenv(Pkg),
	working_directory(_,Old).

go:-
	working_directory(Dir,Dir),
	asserta(dird(build,Dir)),
	dird(aclocal,Dac),
	setenv('ACLOCAL_PATH',Dac),
	dird(pkgconfig,Dpc),
	setenv('PKG_CONFIG_PATH',Dpc),
	build(libtorrent).

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
