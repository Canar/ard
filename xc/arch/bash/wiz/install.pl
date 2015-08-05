%debian%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ps([H|T],Y):-c(H,' ',T),ps(T,Y).
ps([],[]).

opt(jessie,debian).
opt(sid,debian).
opt(intel686,intel).

optl(fangaorne,[fancore,gui]).
optl(fancore,[wiz,ben,intel686,realtek]).
optl(wiz,[sid,linux]).
optl(A,[P]):-atom(A),opt(A,P).
optl(A,[P]):-atom(P),opt(A,P).
optl(A,[]):-atom(A),opt(O,A),atom(O).
optl(A,[]):-atom(A),optl(O,L),atom(O),member(A,L).
optl(A,P):-atom(A),is_list(P),
	optl(A,O),
	sort(P,Sortp),
	sort(O,Sorto),
	subset(Sortp,Sorto).
optll(A,P):-var(A),is_list(P),
	setof(X,optl(X,P),A).
optll(A,P):-is_list(A),var(P),
	optllr(A,Po),
	flatten(Po,Pf),
	sort(Pf,P).
optllr([Ha|A],[Hp|P]):-atom(Ha),
	optl(Ha,Hp),
	optllr(A,P).
optllr([],[]).
optr(A,L):-atom(A),optr([A],L).
optr(A,L):-is_list(A),
	optll(A,P),
	union(A,P,U),
	((A==U,L=A);optr(U,L)).
lineage(A,P):-optr(A,P).
packages(linux,['firmware-linux-nonfree']).
packages(wiz,[git,ssh,'swi-prolog',lvm2]).
packages(ben,[vim,screen]).
packages(intel,'intel-microcode').
packages(intel686,'linux-image-686-pae').
packages(realtek,'firmware-realtek').
packages(gui,['gnome-core',gdm3,'xserver-xorg']).
packages_(X,Y):-packages(X,Y);Y=[].
line_packages(Line,Packages):-
	maplist(packages_,Line,A),
	pl(A),
	flatten(A,Packages).
mount(pts,Root):-
	append(Root,[dev,pts],Mount),
	c(Mount,'/',Where),
	x(mount,['-t',devpts,none,Where]).
git(clone,FromUri,ToPath):-x(git,[clone,FromUri,ToPath]).


bootstrap([A,B|C]):-bootstrap(A,B,C).
bootstrap([A,B]):-bootstrap(A,B).
bootstrap(Suite,Mountpoint):-bootstrap(Suite,Mountpoint,[]).
bootstrap(Opt,Mountpoint,_):-
	c([debootstrap,'--include=swi-prolog',jessie,Mountpoint,'http://http.debian.net/debian'],' ',Dbs),
	p(['Bootstrapping with command: ',Dbs]),
	x(Dbs),
	c([Mountpoint,usr,local],'/',Local),
	x(rm,['-rf',Local]),
	x(mkdir,['-p',Local]),
	x(git,[clone,'ssh://user@bed.ac/local',Local]),
	x(chroot,[Mountpoint,swipl,'/usr/local/src/wiz',bootstrapped,Opt]).
bootstrapped(Opt):-
	x(mount,['-t',devpts,none,'/dev/pts']),
	x('apt-get',[update]),
	x('apt-get',['dist-upgrade -y']),
	debopt(Opt,Pax),
	x('apt-get',[install,'-y'|Pax]),
	x(passwd),
	x('adduser user').
debopt(Opt,Pax):-
	lineage(Opt,Line),
	opt(Suite,debian),
	member(Suite,Line),
	line_packages(Line,Pax).



