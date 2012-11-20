-module(utils).
-compile(export_all).


shuffle_list(List) ->
	random:seed(now()),
        shuffle_list(List, []).
shuffle_list([], Acc) ->
        Acc;
shuffle_list(List, Acc) ->
        SplitIndx = random:uniform(length(List)) - 1,
        {Left, [H|Tail]} = lists:split(SplitIndx, List),
        shuffle_list(Left ++ Tail, [H|Acc]).
	
