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
	FitPopulation1 = ga:launch(10, initial_population(), GeneticOperator, fun fit/1, 1),
	[Best1 | _] = FitPopulation1,
	#chromosome_fit{fit=FitBest1, _=_} = Best1,
	
	ChromosomesOfPopulation1 = [Chr || #chromosome_fit{chromosome=Chr, _=_} <- FitPopulation1],

	FitPopulation2 = ga:launch(30, ChromosomesOfPopulation1, GeneticOperator, fun fit/1, 1),
        [Best2 | _] = FitPopulation2,
        #chromosome_fit{fit=FitBest2, _=_} = Best2,

	ChromosomesOfPopulation2 = [Chr || #chromosome_fit{chromosome=Chr, _=_} <- FitPopulation2],

	FitPopulation3 = ga:launch(30, ChromosomesOfPopulation2, GeneticOperator, fun fit/1, 1),
	[Best3 | _] = FitPopulation3,
        #chromosome_fit{fit=FitBest3, _=_} = Best3,

	?assert(FitBest2 =< FitBest1),
	?assert(FitBest3 =< FitBest1),
	?assert(FitBest3 =< FitBest2).
	
initial_population() ->
        [[0, 0, 0, 0, 0],
         [1, 0, 0, 1, 0],
         [0, 1, 0, 1, 0],
         [1, 0, 1, 0, 1],
         [1, 1, 1, 1, 1]].

%%
%% Target is [1, 2, 3, 4, 5]
%%
fit([A, B, C, D, E]) ->
	erlang:abs(A - 1) +
	erlang:abs(B - 2) +
	erlang:abs(C - 3) +
	erlang:abs(D - 4) +
	erlang:abs(E - 5).

%%
%% Symmetric randomly uniformed crossover.
%% For example:
%% [1,1,1,1,1] and [2,2,2,2,2] after crossover might return:
%% {[1,1,2,2,1], [2,2,1,1,2]}
%%
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

%%
%% Randomly change values of single input chromosome.
%% For example:
%% [1,1,1,1,1] might mutate into [1, 1.03, 1, 2.3, 1]
%%
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
