-module (board_controller).
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
    {render, <<"app">>, [{user, form_util:get_user(Params)}]};

handle_request(<<"GET">>, <<"base">>, _Args, _Params, _Req) ->    
    {render, <<"base">>, []};

handle_request(_, _, _, _, _) ->
    {error, <<"Opps, Forbidden">>}.
