-module (form_util).
-export ([not_empty/1]).
-export ([not_empty/2]).
-export ([get_user/1]).

-include ("gruppz.hrl").


-spec not_empty(list()) -> ok | {error, list()}.
not_empty(PropList) ->
    {Keys, _} = lists:unzip(PropList),
    not_empty(PropList, Keys).

-spec not_empty(list(), list()) -> ok | {error, list()}.
not_empty(Vals, [H|T]) ->
    ?DEBUG("~p => ~p~n", [H, proplists:get_value(H, Vals)]),
    case proplists:get_value(H, Vals) of
        <<>> ->
            {error, << <<"Param ">>/binary, H/binary, <<" is empty">>/binary >>};
        _ ->
            not_empty(Vals, T)
    end;

not_empty(_Vals, []) -> ok.

get_user(Params) ->
    case maps:find(<<"auth">>, Params) of
        {ok, User} -> 
            {ok, U} = mongo_worker:find_one(?DB_USER, {<<"email">>, User}),
            U;
        _  -> 
            undefined
    end.
