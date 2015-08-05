xpapt(Deb,Phrase):-atom_codes(Deb,Debc),xp('apt-cache',[depends,Deb],(dcg_read_token(10,Debc),Phrase)).

dcg_read_tokens(Sp,[])-->dcg_read_token(Sp,[]).
dcg_read_tokens(Sp,[H|T])-->dcg_read_token(Sp,H),dcg_read_tokens(Sp,T).
dcg_read_tokens(_,[])-->[].
dcg_read_token(Sp,[])-->[Sp].
dcg_read_token(Sp,[H|T])-->[H],dcg_read_token(Sp,T).
dcg_read_token(_,[])-->[].
dcg_trimmed(Out)-->dcg_trim,dcg_trim_content(Out).
dcg_trim-->[C],{char_type(C,white)},dcg_trim.
dcg_trim-->[].
dcg_trim_content([H|T])-->[H],dcg_trim_content(T),{ T==[] -> \+ char_type(H,white) }.
dcg_trim_content([])-->[],dcg_trim.
dcg_read_fields(_,_,[])-->[].
dcg_read_fields(SpF,SpNV,[[Name,Value]|L])-->dcg_read_field(SpF,SpNV,Name,Value),dcg_read_fields(SpF,SpNV,L).
dcg_read_fields(SpF,SpNV,L)-->dcg_read_token(SpF,Token),
	{atom_codes(A,Token),p(['Spurious token "',A,'" encountered.'])},
	dcg_read_fields(SpF,SpNV,L).
dcg_read_field(SpF,SpNV,Name,Value)-->
	dcg_trim,
	dcg_read_token(SpNV,NameC),
	dcg_trim,
	dcg_read_token(SpF,ValueC),{
		atom_codes(Name,NameC),
		atom_codes(Value,ValueC)
	}.
dcg_read_field(_,_,_,_)-->[].
dcgrf(L)-->dcg_read_fields(10,58,L).
dcg_read_forever-->[_],dcg_read_forever;[].
%dcg_per_token(Sp,[H|T],Phrase)-->dcg_read_token(Sp,Token),{ phrase(Phrase,Token) }.
xf(F):-xpapt(gnome,dcgrf(L)),trace,replace(L,L2),predsort(fcsort,L2,S),field_collapse(F,S).
fcsort(=,A,A).
fcsort(P,[Ha|Ta],[Hb|Tb]):-compare(P,Ha,Hb),P\=='=';fcsort(P,Ta,Tb).
replace([['|Depends',V]|T],[['Depends',V]|Ta]):-replace(T,Ta).
replace([H|T],[H|Ta]):-replace(T,Ta).
freplace([],[]).
field_collapse([[N,V|Fv]|F],[[N,V]|L]):-field_collapse([[N|Fv]|F],L);(Fv=[],field_collapse(F,L)).
field_collapse([],[]).

testsp(A,Z):-A=..Z.
testpr:-trace,
	testsp(Sp,[psz,32]),
%	testsp(Sp,[psplit,32]),
	phrase(par([],[Sp]),"a b c d e",R),
	phrase(par([],[Sp]),"aa bb cc dd ee",R2),
	phrase(par([],[Sp]),"aaa bbb ccc ddd ee",R3),
	pl([R,R2,R3]).

pr([H|T]),[O]-->H,pr(T),[O].
pr([_|T]),[O]-->pr(T),[O].
pr([])-->[].
par(_,D)-->phrase(pr(D)). %,par(Opts,D),[].

psz(S,[H|T],O):-
    H==S->psz(S,T,O);
    T==[]->O=H.
psz(S,[A,S|T],O):-psz(S,[[A]|T],O).
psz(S,[A,B,S|T],O):-append([A,[B]],C),psz(S,[C|T],O).
psz(_,[],[]).
%psz(S,[[A|B],S|T]):-psz(S,[[A,B]|T]

psx(S),[[A]]-->[S],[A],{A\==S},psx(S). %[],psp(S). %[H],[],psp(S,T).
psx(S),[C]-->[A],[B],{append([A,[B]],C)},psx(S).
psx(S),[[A]]-->[A],{A\==[_|_]},psx(S). %[],psp(S). %[H],[],psp(S,T).
psx(S)-->[S],psx(S). %[],psp(S). %[H],[],psp(S,T).
psx(_)-->[]. %[],psp(S). %[H],[],psp(S,T).


%psp(S)[]. %psp(S),[]. %[S|O],[],O. %,psp(S). %[H],[],psp(S,T).
psp(S)-->[S],psp(S). %[],psp(S). %[H],[],psp(S,T).
psp(S),[A]-->[A],{A\==S},psp(S). %[],psp(S). %[H],[],psp(S,T).

%psp(S),[A]-->[A],psp(S),{A\==S}. %psp(S),[]. %[S|O],[],O. %,psp(S). %[H],[],psp(S,T).
%psp(S),[A],[B]-->[A],[B],{A\==S,B\==S},psp(S),[]. %psp(S),[]. %[S|O],[],O. %,psp(S). %[H],[],psp(S,T).
%psp(S),[A]-->[A],{A\==S},psp(S),[].
%psp(S)-->[].

psplit(S,[O])-->[S],psplit(S,O).
psplit(S,[H|T])-->[H],psplit(S,T).
psplit(_,[])-->[].
psplit(S,[S|O],[[],O]). %,[O]-->[S],[O]. %,psplit(S),[T].
psplit(S,[Ha,Hb|T],[[Ha|Oh]|[Hb|Ot]]):-psplit(S,T,[Oh|Ot]). %-->[H],psplit(S),[]. %,psplit(S),[T].
%psplit(S).[O]-->psplit(S).
psplit(_),[[A]]-->[A].
ptrim(A)-->[B],(({w(B)},ptrim(A));(A=[B|C],ptrim(C))).

pars(_,A,A,[]).
pars(_,[],[[]],A):-member(A,[split(_)]). % converts multiple codes to list, string to list of strings.
pars(_,[],[],A):-member(A,[trim_end,trim]),!.

pars(Opts,split(S))-->[S];[_],pars(Opts,split(S)).
%pars(Opts,[C|It],[[C|Oh]|Ot],split(S)):-parse(Opts,It,[Oh|Ot],split(S)).

pars(Opts,trim,[[W|It]|I],O,trim):-[W],{w(W)},parse(Opts,[It|I],O,trim).
pars(Opts,trim,I,O,trim):-parse(Opts,I,O,trim_mid);parse(Opts,I,O,trim_end).
pars(Opts,trim_mid,[[C|Ih]|I],[[C|Oh]|O],trim_mid):-parse(Opts,[Ih|I],[Oh|O],trim_mid).
pars(Opts,trim_mid,[[C|Ih]|It],[[C]|Ot],trim_mid):- \+w(C), parse(Opts,[Ih|It],Ot,trim_end).
pars(Opts,trim_end,[[C|Ih]|I],O,trim_end):-is_white(C),parse(Opts,[Ih|I],O,trim_end).
pars(Opts,trim_end,[[]|I],O,trim_end):-!,parse(Opts,I,O,trim).

parse(Opts,A,C,[D|Dt]):-
	parse(Opts,A,B,D),!,
	parse(Opts,B,C,Dt).

parse(_,A,A,[]).
parse(_,[],[[]],A):-member(A,[split(_)]). % converts multiple codes to list, string to list of strings.
parse(_,[],[],A):-member(A,[trim_end,trim]),!.

parse(Opts,[I,S|It],[[I]|Ot],split(S)):-parse(Opts,It,Ot,split(S)).
parse(Opts,[C|It],[[C|Oh]|Ot],split(S)):-parse(Opts,It,[Oh|Ot],split(S)).

parse(Opts,[[Ih|It]|I],O,trim):-w(Ih),parse(Opts,[It|I],O,trim).
parse(Opts,I,O,trim):-parse(Opts,I,O,trim_mid);parse(Opts,I,O,trim_end).
parse(Opts,[[C|Ih]|I],[[C|Oh]|O],trim_mid):-parse(Opts,[Ih|I],[Oh|O],trim_mid).
parse(Opts,[[C|Ih]|It],[[C]|Ot],trim_mid):- \+w(C), parse(Opts,[Ih|It],Ot,trim_end).
parse(Opts,[[C|Ih]|I],O,trim_end):-is_white(C),parse(Opts,[Ih|I],O,trim_end).
parse(Opts,[[]|I],O,trim_end):-!,parse(Opts,I,O,trim).

trim([Ih|It],[Oh|Ot]):-var(Oh),w(Ih),trim(It,[Oh|Ot]).
trim([Ih|It],[Oh|Ot]):-var(Oh),Oh=Ih,trim([Ih|It],[Ih|Ot]).
trim([A,B|It],[A,B|Ot]):-trim([Ih|It],[Ih|Ot]).
trim_start([Ih|It],[Oh|Ot]):-w(Ih)->trim_start(It,[Oh|Ot]);(Ih=Oh,It=Ot).
trim_end([Ih|It],[Oh|Ot]):-trim_end(It,Ot),((w(Ih),Oh=[]);Oh=Ih).
trim_end([],[]).


