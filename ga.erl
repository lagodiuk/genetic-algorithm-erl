-module(ga).
-compile(export_all).

iterate(0, PopulationFit, _Operator, _Fit, _ParentsSurviveCount) ->
	PopulationFit;
iterate(Iter, PopulationFit, Operator, Fit, ParentsSurviveCount) ->
	NewPopulationFit = iteration(PopulationFit, Operator, Fit, ParentsSurviveCount),
	iterate(Iter - 1, NewPopulationFit, Operator, Fit, ParentsSurviveCount).

iteration(ParentsFit, Operator, Fit, ParentsSurviveCount) ->
	ParentChrs = [Chr || {Chr, _} <- ParentsFit],
	ChildrenFit = new_population_fit(ParentChrs, Operator, Fit),
	{SurvivedParentsFit, _} = lists:split(ParentsSurviveCount, ParentsFit),
	AllSortedFit = lists:sort(
		fun({_,Fit1}, {_,Fit2}) when Fit1 < Fit2 ->
			true;
		({_,_}, {_,_}) ->
			false
		end,
		SurvivedParentsFit ++ ChildrenFit ),
	ParentsLen = length(ParentsFit),
	{Return, _} = lists:split(ParentsLen, AllSortedFit),
	Return.

new_population_fit(ParentChrs, Operator, Fit) ->
	Pairs = pairs(utils:shuffle_list(ParentChrs)),
	lists:append(rpc:pmap({?MODULE, genetic_operation}, [Operator, Fit], Pairs ++ ParentChrs)).

pairs(ParentChrs) ->
	[FirstChr|_] = ParentChrs,
	pairs(FirstChr, ParentChrs, []).
pairs(FirstChr, [LastChr], Acc) ->
	[{LastChr, FirstChr}|Acc];
pairs(FirstChr, [Chr1, Chr2|T], Acc) ->
	pairs(FirstChr, [Chr2|T], [{Chr1, Chr2}|Acc]).

genetic_operation(X, Operator, Fit) ->
	Chrs = Operator(X),
	[{Chr, Fit(Chr)} || Chr <- Chrs].
