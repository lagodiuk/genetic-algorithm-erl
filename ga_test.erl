-module(ga_test).
-compile(export_all).

-include("ga.hrl").
-include_lib("eunit/include/eunit.hrl").

-define(CROSSOVER_PROBABILITY, 0.5).
-define(MUTATION_PROBABILITY, 0.5).

ga_test() ->
	GeneticOperator = fun
		({X, Y}) ->
			{X1, Y1} = crossover(X, Y),
			[X1, Y1];
		(X) ->
			[mutate(X)]
	end,
	Population1 = ga:launch(10, initial_population(), GeneticOperator, fun fit/1, 1),
	[Best1 | _] = Population1,
	#chromosome_fit{fit=FitBest1, _=_} = Best1,
	
	Population2 = ga:launch(30, initial_population(), GeneticOperator, fun fit/1, 1),
        [Best2 | _] = Population2,
        #chromosome_fit{fit=FitBest2, _=_} = Best2,

	[Best1, Best2].
	
initial_population() ->
        [[0, 0, 0, 0, 0],
         [1, 0, 0, 1, 0],
         [0, 1, 0, 1, 0],
         [1, 0, 1, 0, 1],
         [1, 1, 1, 1, 1]].

fit([A, B, C, D, E]) ->
	erlang:abs(A - 1) +
	erlang:abs(B - 2) +
	erlang:abs(C - 3) +
	erlang:abs(D - 4) +
	erlang:abs(E - 5).

crossover(X, Y) ->
	crossover(X, Y, [], []).
crossover([], [], Acc1, Acc2) ->
	{lists:reverse(Acc1), lists:reverse(Acc2)};
crossover([Hx | Tx], [Hy | Ty], Acc1, Acc2) ->
	case random:uniform() >= ?CROSSOVER_PROBABILITY of
		true ->
			crossover(Tx, Ty, [Hx | Acc1], [Hy | Acc2]);
		false ->
			crossover(Tx, Ty, [Hy | Acc1], [Hx | Acc2])
	end.

mutate(X) ->
	mutate(X, []).
mutate([], Acc) ->
	lists:reverse(Acc);
mutate([H | T], Acc) ->
	case random:uniform() >= ?MUTATION_PROBABILITY of
		true ->
			Mut = random:uniform() - random:uniform(),
			mutate(T, [H + Mut | Acc]);
		false ->
			mutate(T, [H | Acc])
	end.
