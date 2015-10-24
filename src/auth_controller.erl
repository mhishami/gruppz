-module (auth_controller).
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

handle_request(<<"GET">>, <<"login">>, _Args, _Params, _Req) ->    
    {render, <<"login">>, []};

handle_request(<<"POST">>, <<"login">>, _Args, _Params, _Req) ->
	{redirect, <<"/app">>};

handle_request(<<"GET">>, <<"signup">>, _Args, _Params, _Req) ->    
    {render, <<"signup">>, []};

handle_request(<<"POST">>, <<"signup">>, _Args, _Params, _Req) ->    
    {redirect, <<"/app">>};

handle_request(<<"GET">>, <<"logout">>, _Args, _Params, _Req) ->    
    {redirect, <<"/">>};

handle_request(_, _, _, _, _) ->
    {error, <<"Opps, Forbidden">>}.
