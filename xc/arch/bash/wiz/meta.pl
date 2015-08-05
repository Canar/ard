monitor(G):-findall(A,clause(G,A),H),maplist(monitor,H).
choices(G,B):-catch(findall(A,clause(G,A),B),C,(C=..D,pl(D))).
subgoals(G,[H|To]):-G=..[',',H,T],subgoals(T,To).
subgoals(A,[A]):-callable(A).
subgoal(G,Z):-subgoals(G,A),(A==[G]->Z=G;Z=[G,A]).

pred_list_tree(P,[P|Z]):-choices(P,A),maplist(subgoal,A,B),pltm(B,Z).
pltm([[A|Ta]|Tb],[[D|Ta]|Tb]):-A=..[','|_],term_to_atom(_,B),
	c(['anonymous_clause<',B,'>'],D).
pltm(A,[A]).
pltm(A,A).
	
/* pred list-tree list
pltl - pred list tree lister */
pltl(A,[[E|I]|O]):-c([A,' | '],B),pltl(B,E),pltl(B,I),pltl(B,O).
pltl(A, [E|I]   ):-               pltl(A,E),pltl(A,I).
pltl(A, [E]     ):-               pltl(A,E). %only encounters I==[]?
pltl(A,  E):-E==[];p([A,' +-',E]).


