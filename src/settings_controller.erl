-module (settings_controller).
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

handle_request(<<"GET">>, <<"profile">>, _Args, Params, _Req) ->    
  {render, <<"settings_profile">>, [{user, form_util:get_user(Params)}]};

handle_request(<<"GET">>, <<"passwd">>, _Args, Params, _Req) ->    
  {render, <<"settings_passwd">>, [{user, form_util:get_user(Params)}]};

handle_request(<<"GET">>, <<"billing">>, _Args, Params, _Req) ->    
  {render, <<"settings_billing">>, [{user, form_util:get_user(Params)}]};

handle_request(<<"GET">>, <<"security">>, _Args, Params, _Req) ->    
  {render, <<"settings_security">>, [{user, form_util:get_user(Params)}]};

handle_request(<<"POST">>, <<"profile">>, [<<"update">>], Params, _Req) ->
  {ok, Email} = maps:find(<<"auth">>, Params),
  ?INFO("Updating user profile for ~p~n", [Email]),

  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  case form_util:not_empty(PostVals) of
    {error, Err} ->
      {render, <<"settings_profile">>, [
          {user, form_util:get_user(Params)},
          {error, Err} | PostVals
      ]};
    _ ->
      %% ok, update the profile
      Fullname = proplists:get_value(<<"fullname">>, PostVals),
      MobileNo = proplists:get_value(<<"mobile_no">>, PostVals),

      {ok, User} = mongo_worker:find_one(?DB_USERS, {<<"email">>, Email}),
      mongo_worker:update(?DB_USERS, User#{
        <<"fullname">> := Fullname,
        <<"mobile_no">> := MobileNo,
        <<"updated_at">> := erlang:timestamp()
      }),
      {redirect, <<"/app">>}
  end;

handle_request(<<"POST">>, <<"passwd">>, [<<"update">>], Params, _Req) ->
  {ok, Email} = maps:find(<<"auth">>, Params),
  {ok, PostVals} = maps:find(<<"qs_body">>, Params),

  ?INFO("Changing password for user ~p~n", [Email]),
  case form_util:not_empty(PostVals) of
    {error, _Err} ->
      {render, <<"settings_passwd">>, [
        {user, form_util:get_user(Params)},
        {pass_error, <<"All passwords are required">>} | PostVals
      ]};
    _ ->
      Pass1 = proplists:get_value(<<"password">>, PostVals),
      Pass2 = proplists:get_value(<<"password2">>, PostVals),

      case Pass1 =/= Pass2 of
        true ->
          {render, <<"settings_passwd">>, [
            {user, form_util:get_user(Params)},
            {pass_error, <<"Passwords are not the same">>} | PostVals
          ]};
        false ->
          %% ok, update password                    
          {ok, User} = mongo_worker:find_one(?DB_USERS, {<<"email">>, Email}),

          ?DEBUG("User= ~p~n", [User]),
          mongo_worker:update(?DB_USERS, User#{
            <<"password">> => web_util:hash_password(Pass2),
            <<"updated_at">> => erlang:timestamp()
          }),

          %% invalidate, and ask to login again
          {ok, Sid} = maps:find(<<"sid">>, Params),
          session_worker:del_cookies(Sid),
          {redirect, <<"/auth/login">>}
      end
  end;

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.
