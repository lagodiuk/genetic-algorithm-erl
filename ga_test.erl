-module(ga_test).
-compile(export_all).

-include("ga.hrl").
-include_lib("eunit/include/eunit.hrl").

-define(CROSSOVER_PROBABILITY, 0.5).
-define(MUTATION_PROBABILITY, 0.5).
-define(PARENTS_SURVIVE_COUNT, 1).

%%
%% Kind of integration test
%%
ga_test() ->
	%% 1) Launch evolve for 10 iterations
	%% FitPopulation1 is list of records #chromosome_fit{chromosome, fit}
	%% contains population after 10 iterations
	FitPopulation1 = ga:launch(10, initial_population(), fun genetic_operator/1, fun fit/1, ?PARENTS_SURVIVE_COUNT),
	[Best1 | _] = FitPopulation1,
	%% FitBest1 - fitness of best chromosome after 10 iterations
	#chromosome_fit{fit=FitBest1, _=_} = Best1,
	
	%% extract chromosomes from FitPopulation1 (list of records #chromosome_fit{chromosome, fit}) 
	ChromosomesOfPopulation1 = [Chr || #chromosome_fit{chromosome=Chr, _=_} <- FitPopulation1],

	%% 2) Continue evolving - 30 iterations
	FitPopulation2 = ga:launch(30, ChromosomesOfPopulation1, fun genetic_operator/1, fun fit/1, ?PARENTS_SURVIVE_COUNT),
        [Best2 | _] = FitPopulation2,
	%% FitBest2 - fitness of best chromosome after next 30 iterations
        #chromosome_fit{fit=FitBest2, _=_} = Best2,

	ChromosomesOfPopulation2 = [Chr || #chromosome_fit{chromosome=Chr, _=_} <- FitPopulation2],

	%% 3) Continue evolving - 30 iterations
	FitPopulation3 = ga:launch(30, ChromosomesOfPopulation2, fun genetic_operator/1, fun fit/1, ?PARENTS_SURVIVE_COUNT),
	[Best3 | _] = FitPopulation3,
        %% FitBest3 - fitness of best chromosome after next 30 iterations
	#chromosome_fit{fit=FitBest3, _=_} = Best3,

	%% Genetic algorithm works correctly, when fitness of each iterations best chromosome
	%% is less or equals that on previous iterations best chromosome
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
%% Unifying function, which depending on arguments
%% delegates call to crossover or mutation functions
%%
genetic_operator({X, Y}) ->
	{X1, Y1} = crossover(X, Y),
	[X1, Y1];
genetic_operator(X) ->
	[mutate(X)].
	
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
