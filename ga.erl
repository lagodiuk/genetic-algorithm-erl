-module(ga).
-compile(export_all).

-define(NO_CALLBACK, null).

-record(chromosome_fit, {chromosome, fit}).

chromosome_fit(Chromosome, FitnessFunc) ->
	#chromosome_fit{chromosome=Chromosome, fit=FitnessFunc(Chromosome)}.

launch(IterationsCount, InitialPopulation, Operator, FitnessFunc, ParentsSurviveCount) ->
	launch(IterationsCount, InitialPopulation, Operator, FitnessFunc, ParentsSurviveCount, ?NO_CALLBACK).

launch(IterationsCount, InitialPopulation, Operator, FitnessFunc, ParentsSurviveCount, CallbackFunc) ->
	InitialPopulationFit = [chromosome_fit(Chr, FitnessFunc) || Chr <- InitialPopulation],
	iterate(IterationsCount, InitialPopulationFit, Operator, FitnessFunc, ParentsSurviveCount, CallbackFunc).

iterate(0, PopulationFit, _Operator, _Fit, _ParentsSurviveCount, _CallbackFunc) ->
	PopulationFit;
iterate(Iter, PopulationFit, Operator, Fit, ParentsSurviveCount, CallbackFunc) ->
	NextPopulationFit = iteration(PopulationFit, Operator, Fit, ParentsSurviveCount),
	{NewIterNum, NewPopulationFit, NewOperator, NewFit, NewParentsSurviveCount} =
	case CallbackFunc /= ?NO_CALLBACK of
		true ->
			CallbackFunc(Iter - 1, NextPopulationFit, Operator, Fit, ParentsSurviveCount);
		false ->
			{Iter - 1, NextPopulationFit, Operator, Fit, ParentsSurviveCount}
	end,
	iterate(NewIterNum, NewPopulationFit, NewOperator, NewFit, NewParentsSurviveCount, CallbackFunc).

iteration(ParentsFit, Operator, Fit, ParentsSurviveCount) ->
	ParentChrs = [Chr || #chromosome_fit{chromosome=Chr, _=_} <- ParentsFit],
	ChildrenFit = new_population_fit(ParentChrs, Operator, Fit),
	{SurvivedParentsFit, _} = lists:split(ParentsSurviveCount, ParentsFit),
	AllSortedFit = lists:sort(
		fun(#chromosome_fit{fit=Fit1, _=_}, #chromosome_fit{fit=Fit2, _=_}) when Fit1 < Fit2 ->
			true;
		(#chromosome_fit{_=_}, #chromosome_fit{_=_}) ->
			false
		end,
		SurvivedParentsFit ++ ChildrenFit ),
	ParentsLen = length(ParentsFit),
	{Return, _} = lists:split(ParentsLen, AllSortedFit),
	Return.

new_population_fit(ParentChrs, Operator, Fit) ->
	Pairs = pairs(utils:shuffle_list(ParentChrs)),
	lists:append(rpc:pmap({?MODULE, genetic_operation}, [Operator, Fit], Pairs)).

pairs(ParentChrs) ->
	[FirstChr|_] = ParentChrs,
	pairs(FirstChr, ParentChrs, []).
pairs(FirstChr, [LastChr], Acc) ->
	[LastChr, {LastChr, FirstChr}|Acc];
pairs(FirstChr, [Chr1, Chr2|T], Acc) ->
	pairs(FirstChr, [Chr2|T], [Chr1, {Chr1, Chr2}|Acc]).

genetic_operation(X, Operator, Fit) ->
	Chrs = Operator(X),
	[chromosome_fit(Chr, Fit) || Chr <- Chrs].
