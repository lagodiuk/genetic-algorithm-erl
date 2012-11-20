-module(arr_ga).
-compile(export_all).

init_population(Cnt) ->
	[FirstChr] = mut([1,1,1,1,1]),
	Mutated = [begin [Chr]=mut(FirstChr), {Chr,fit(Chr)} end || _I <- lists:seq(1,Cnt)],
	[{FirstChr,fit(FirstChr)}|Mutated].

operator({X,Y}) ->
	random:seed(now()),
	cross(X,Y);
operator(X) ->
	random:seed(now()),
	mut(X).

fit([A,B,C,D,E]) ->
	erlang:abs(A - 1) +
	erlang:abs(B - 2) +
	erlang:abs(C - 3) +
	erlang:abs(D - 4) +
	erlang:abs(E - 5).

mut(List) ->
	mut(List, []).
mut([], Acc) ->
	[lists:reverse(Acc)];
mut([H|T], Acc) ->
	Rand = (random:uniform()-random:uniform()),
	mut(T, [H+Rand|Acc]).

cross(List1, List2) ->
	cross(List1, List2, [], []).
cross([], [], Acc1, Acc2) ->
	[lists:reverse(Acc1), lists:reverse(Acc2)];	
cross([H1|T1], [H2|T2], Acc1, Acc2) ->
	case random:uniform() >= 0.5 of
		true ->
			cross(T1, T2, [H1|Acc1], [H2|Acc2]);
		false ->
			cross(T1, T2, [H2|Acc1], [H1|Acc2])
	end.
