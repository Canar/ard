in_index([A|E],I):-
	select([A|F],I,_),
	in_index(E,F).
in_index([],[[]]).

% I=[]
% I=[t,[h,[y]]
% I=[t,[h,[o,[u]],[y]]]
% I=[[t,[h,[e,[y]],[i,[n,[e]]],[o,[u]],[y]],[o,[o]]],[i,[f]]]
% eg. index contains too,the,thou,if. I=[[t,[h,[e]],[o,[u]],[o,[o]],[i,f]],word=thy,[h,e]->[h,[e,y]]
index([],A,A).
index(A,[],[A]).
index(A,B,B):-member(A,B).
index(A,B,C):-A=[D,E],
	(	select([D|F],B,G)
	->	(index(E,F,H),C=[[D|H]|G])
	;	C=[A|B]
	).

index_element([A|B],[A,C]):-index_element(B,C).
index_element(A,A).
index_element(_,[]).
ti:-
	index_element("the",A),
	index_element("tea",B),
	index(A,[B],D),
	pltl('',D),
	index_element("thy",C),
	index_element("toy",F),
	index_element("too",G),
	index_element("thou",H),
	print(D),nl,
	index(C,D,I),
	print(I),nl,
	index(F,I,J),
	print(J),nl,
	index(G,J,K),
	print(K),nl,
	index(H,K,L),
	print(L),nl,
	in_index("toy",L).
%list-tree sort
ltsort([],[]).
ltsort(A,Z):-A=[[B|C]|D],
	ltsort(B,E),
	ltsort(C,F),
	ltsort(D,G),
	sort([[E|F]|G],Z).
ltsort(A,Z):-A=[B|C],
	ltsort(B,D),
	ltsort(C,E),
	sort([D|E],Z).
ltsort(A,A):- \+ compound(A).

/* print list tree
plt - print list tree */
plt(A):-plt2(0,'',A).
%plt(A, [[B|C]]):-plt(A,[B|C]).
plt2(L,A,B)
  :- M is L+1
  ,( M>3 -> c([A,' | '],C) ; C=A
 ),( is_list(B)
      -> maplist(plt2(M,C),B) 
       ; p([C,' +- ',B])
).
plt(A,[[]]):-plt(A,'[]').
plt(A,[E|I]):-E=[_|_],
	c([A,' | '],B),
	plt(B,[[],E]),
	plt(A,I).
plt(A, [E|I]):-
	plt(A,E),
	(I\==[],plt(A,I);true).
plt(A,  E):-
	E==[];
	%	E==[[]];
	p([A,' +- ',E]).

collapse_index(A,A):-atom(A).
%collapse_index([[]],[]).
collapse_index([[A,B]],[[Y,Z]]):-collapse_index(A,Y),collapse_index(B,Z).
%collapse_index([A,[]],A).
collapse_index([A,[B|C]],Z):-atom(A),atom(B),atom_length(B,1),c([A,B],D),collapse_index([D|C],Z).
collapse_index([A,B],Z):-
	(atom(A)->X=A;collapse_index(A,X)),
	collapse_index(B,Y),
	(atom(Y)->c([X,Y],Z);Z=[X,Y]).
collapse_index([A|B],Z):-atom(A),maplist(collapse_index,B,X),Z=[A,X].
%collapse_index(A,A).

length_over(L,V,I,O):-
	length(L,Ll),
	Ll>V,
	O=I,
	!.
switch([Ha|Ta],[Hb,Tb],[Hc,Tc],D):-call(Ha,Hb,Hc,D);switch(Ta,Tb,Tc,D).
switch([],[],[],_):-fail.


ticp([H|T],A,Z):-
	index(H,A,B),
	ltsort(B,C),
	collapse_index(C,D),
	plt(D),
	ticp(T,C,Z).
ticp([],A,A).
index_(A,B,C):-index(B,A,C).
ticp_(B,A,C):-ticp(A,B,C).
ticp:-
    setof(A,current_predicate(A),B),
    maplist(term_to_atom,B,C),
    maplist(atom_chars,C,D),
    maplist(index_element,D,E),
    trace,
    maplist(ticp_([]),E,F),
    plt('',F).


