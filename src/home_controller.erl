-module (home_controller).
-export ([handle_request/5]).
% -export ([before_filter/1]).

-include ("gruppz.hrl").

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
  {redirect, <<"/app">>};

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.
