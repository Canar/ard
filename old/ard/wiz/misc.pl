%pattrd(I,D):-I=..['=',class,V],c(Va,' ',V),c(Va,',',Vb),attrdesc(class,Vb,D).
%pattrd(I,D):-I=..['=',N|V],attrdesc(N,V,D).

%c(['lynx -anonymous -use-mouse -noreferer -nopause -nostatus -cookies "http://google.ca/search?q=',U,'&ie=UTF-8"'],'',C),xs(C,0).
%:search
%http://google.ca/search?q=swi+prolog&ie=UTF-8&

exploder([H,Lh|Lt],[[H|Lh]|O]):-exploder([H|Lt],O).
exploder([_],[]).

term_expansion(quality_option(A),Goals):-
	exploder(A,B),
	findall( ( quality_option(C,D,E) :- true ),
		member([C,D,E],B),
		Goals).

quality_option([open,
	[reading,arg(2,open,read)],
	[reopening,eof_action(reset)],
	[byte,type(binary)],
	[unbuffered,buffer(false)]
]).

%quality_option(Predicate,Quality,Option)
mem(L,C,[]):-member(C,L).
%exploder(A,A).
explode(I,[[I|Oh]|Ot]):-phrase(exploder(Oh),I,Remain),explode(Remain,Ot).

%quality_option(open,read
/*streams a file-read byte stream from file,create stream to read bytes from file
*/create_read_unbuffered_byte_stream_from_file(Filename,Stream):-
	Options=[type(binary),eof_action(reset),buffer(false)],
	open(Filename,read,Stream,Options).

/*enters mouse loop
*/mouse:-
	create_read_unbuffered_byte_stream_from_file('/dev/gpmdata',S),
	mouseloop(S).
mouseloop(S):-
	get_byte(S,B),
	B>=0,
	print(B),print(','),
	mouseloop(S).

test:-atom_codes(' this\nis \n  a\n  test  .',C),parse([],C,O,[split(10),trim]),notrace,pl(O).
test_1:-atom_codes(' a\nb ',C),trace,parse([],C,O,[split(10),trim]),notrace,pl(O).
test_2:-parse([]," a  \nb \n ",["a","b"],[split(10),trim]).
test_n:-trace,test([parse]).
test_d:-trace,phrase(par([],[psplit(10),ptrim])," a \n test ",[]).
test(parse,[[]," a  \nb \n ",["a","b"],[split(10),trim]]).
test(A):-A=[H|T]->(forall(test(H,B),apply(H,B)),test(T));A=[].


