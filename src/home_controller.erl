-module (home_controller).
-export ([handle_request/5]).
% -export ([before_filter/1]).

% before_filter(SessionId) ->
%       %% do some checking
%       Sid = session_worker:get_cookies(SessionId),
%       case Sid of
%           {error, undefined} ->
%               {redirect, <<"/auth/login">>};
%           _ ->
%               {ok, proceed}
%       end.

handle_request(<<"GET">>, <<"index">>, _Args, _Params, _Req) ->    
    {render, <<"index">>, []};

handle_request(_, _, _, _, _) ->
    {error, <<"Opps, Forbidden">>}.
