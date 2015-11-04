-module (app_controller).
-export ([handle_request/5]).
-export ([before_filter/1]).

-include ("gruppz.hrl").

before_filter(SessionId) ->
  %% do some checking
  Sid = session_worker:get_cookies(SessionId),
  case Sid of
    {error, undefined} ->
      {redirect, <<"/auth/login">>};
    _ ->
      {ok, proceed}
  end.

handle_request(<<"GET">>, <<"index">>, _Args, Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),
  {ok, PubGroups} = mongo_worker:find(?DB_GROUPS, {}),

  {render, <<"app">>, [
    {user, User},
    {pubgroups, PubGroups}
  ]};

handle_request(<<"GET">>, <<"base">>, _Args, _Params, _Req) ->    
  {render, <<"base">>, []};

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.
