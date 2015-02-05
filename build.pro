#!/usr/bin/swipl -q

% miscellaneous nonsense %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathagg(prefix,build,'prefix/').
pathagg(include,prefix,'include/').
pathagg(lib,prefix,'lib/').
pathagg(openssl,lib,'ssl/').
pathagg(aclocal,prefix,'share/aclocal/').
pathagg(pkgconfig,lib,'pkgconfig/').

% build configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

globalopts([shared,amd64,prefix]).
outputmode(quiet). % quiet or normal
%outputmode(normal).

dep(curl(zlib,openssl),[zlib,openssl(zlib)]).
dep(libtorrent,[zlib,openssl(zlib),curl(zlib,openssl),cppunit]).
dep(rtorrent,[ncurses,libtorrent(zlib)]).
dep(openssl,[zlib]).
dep(git,[expat,openssl(zlib),openssh,curl(zlib,openssl),zlib]).

preconf(curl,'./buildconf').
preconf(cppunit,'./autogen.sh').
preconf(expat,'./buildconf.sh').
preconf(git,'make configure').
preconf(libtorrent,'./autogen.sh').
preconf(rtorrent,'./autogen.sh').
preconf(openssh,'autoreconf').

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

optconfflag(openssh,[],F):-dirflag(openssl,'--without-hardening --with-ssl-dir=',F).

optconfflag(curl,[zlib],'--with-zlib').
optconfflag(curl,[openssl],F):-dirflag(openssl,'--with-ssl=',F).

optconfflag(libtorrent,[],F):-dirflag(prefix,'--with-posix-fallocate --with-zlib=',F).
optconfflag(ncurses,[],'--without-debug --with-widec --enable-pc-files --with-pkg-config').
optconfflag(git,[],'--without-perl --without-python --without-tcltk --without-gettext').
optconfflag(ruby,[],'--disable-nls').

optconfflag(Pkg,Opt,F):-
	optconfflagtmpl(_,Opt,Pkgs,F),!,
	member(Pkg,Pkgs).

optconfflagtmpl(autoconflink,[shared],
	[git,rtorrent,expat,ncurses,curl],
	'--disable-static --enable-shared').
optconfflagtmpl(autoconflink,[static],Pkg,'--enable-static --disable-shared'):-
	optconfflagtmpl(autoconflink,[shared],Pkg,_).

optenv(_,[],[['CFLAGS',F],['CPPFLAGS',F]]):-dirflag(include,'-I',F).
optenv(_,[],[['LIBS','-ldl'],['LDFLAGS',F],['LD_LIBRARY_PATH',F]]):-dirflag(lib,'-L',F).
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

repo(expat,cvs,'cvs -z3 -d:pserver:anonymous@expat.cvs.sourceforge.net:/cvsroot/expat co modulename').
repo(openssh,git,'git://anongit.mindrot.org/openssh.git').

% business logic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
		runstage(Pc,Pkg,'1-preconfigure','Preconfiguring')
	)).

configure(Pkg,Opts):-
	optconfflags(Pkg,Opts,Flags),
	configscript(Pkg,Scr),
	cs([Scr|Flags],Cmd),
	runstage(Cmd,Pkg,'2-configure','Configuring').

buildplan(Pkg,Plan):-expandplan(Pkg,Pkg,Plan).

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
make(Pkg):-runstage('make',Pkg,'3-make','Compiling').
makeinst(Pkg):-runstage('make install',Pkg,'4-install','Installing').

build(Pkg):-
	buildplan(Pkg,Plan),!,
	maplist(buildpkg,Plan).

compile(Pkg,Opts):-
	wl(['***** Building ',Pkg]),
	setupenv(Pkg,Opts),
	runstage('env',Pkg,'0-env','Checking environment'),
	preconfigure(Pkg),
	globalopts(Global),
	append([Global,Opts],Conf),
	configure(Pkg,Conf),
	make(Pkg),
	makeinst(Pkg),
	unsetupenv(Pkg).

buildpkg(PkgF):-
	PkgF=..[Pkg|Opts],	
	withinsubdir(Pkg,compile(Pkg,Opts)).

setup:-
	working_directory(Dir,Dir),
	asserta(path(build,Dir)),
	%	asserta(outputmode(quiet)),
	path(aclocal,Dac),
	setenv('ACLOCAL_PATH',Dac),
	path(pkgconfig,Dpc),
	setenv('PKG_CONFIG_PATH',Dpc).

setenvli(L):-maplist(setenvl,L).
setenvl([K,V]):-setenv(K,V).
unsetenvli(L):-maplist(unsetenvl,L).
unsetenvl([K,_]):-unsetenv(K).

setupenv(Pkg,Opts):-PkgF=..[Pkg|Opts],setupenv(PkgF).
procenv(Pkg,Pred):-
	ignore(
	(	optenvs(Pkg,Env)
	,	maplist(Pred,Env)
)).
setupenv(Pkg):-procenv(Pkg,setenvli).
unsetupenv(Pkg):-procenv(Pkg,unsetenvli).

runstage(Cmd,Pkg,Stage,Desc):-
	outputmode(Mode),
	working_directory(Dir,Dir),
	wl(['  ***',Dir,'$ ',Cmd]),
	cz(['../build-',Pkg,'-',Stage,'.log'],File),
	cs([Cmd,'2>&1'],Co),
	process_create(path(sh),['-c',Co],[stdout(pipe(Out)),process(Pid)]),
	open(File,write,Log,[]),
	handleopen(Mode,File,Pkg,Desc),
	hideoutput(Out,Log,Mode),
	process_wait(Pid,Status),
	( Status == exit(0) ; throw(fuck) ).
	
hideoutput(Out,Log,Mode):-
	read_line_to_codes(Out,Codes),
	\+ Codes == end_of_file,
	atom_codes(Atom,Codes),
	handleline(Mode,Atom),
	write(Log,Atom),
	nl(Log),
	hideoutput(Out,Log,Mode).
hideoutput(Out,Log,_):-
	read_line_to_codes(Out,end_of_file),
	close(Log),
	nl,!.

handleline(quiet,_):-write('.'),flush_output.
handleline(normal,Line):-wl(['    * ',Line]).

handleopen(quiet,File,Pkg,Description):-w(['  *** [',File,'] ',Description,' ',Pkg]).
handleopen(normal,_,Pkg,Description):-wl(['  *** ',Description,' ',Pkg,'...']).


% miscellaneous helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

withindir(Dir,Goal):-
	working_directory(Old,Dir),
	call(Goal),
	working_directory(_,Old).
withinsubdir(Dir,Goal):-
	working_directory(Old,Old),
	cz([Old,Dir,'/'],Path),
	withindir(Path,Goal).

c(L,S,A):-atomic_list_concat(L,S,A).
cs(L,A):-c(L,' ',A).
cc(Sa,Sb,S):-c([Sa,Sb],'',S).
cz(L,A):-c(L,'',A).

w(L):-L=[_|_],maplist(write,L).
wl(L):-w(L),nl.

:- dynamic path/2.
path(P,D):-pathagg(P,Pp,Dc),path(Pp,Dp),cc(Dp,Dc,D).

eval :-
	setup,
	current_prolog_flag(argv, Argv),
%	build(Argv).
	Argv=[Pkg],
	buildpkg(Pkg).

main :-
	catch(eval, E, (print_message(error, E), fail)),
	halt.
main :-
	halt(1).

:- initialization main.
