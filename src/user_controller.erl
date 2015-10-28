-module (user_controller).
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

handle_request(<<"POST">>, <<"update_profile">>, _Args, Params, _Req) ->
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

            {ok, User} = mongo_worker:find_one(?DB_USER, {<<"email">>, Email}),
            mongo_worker:update(?DB_USER, User#{
                <<"fullname">> := Fullname,
                <<"mobile_no">> := MobileNo,
                <<"updated_at">> := web_util:now()
            }),
            {redirect, <<"/app">>}
    end;

handle_request(<<"POST">>, <<"change_passwd">>, _Args, Params, _Req) ->
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
                    {ok, User} = mongo_worker:find_one(?DB_USER, {<<"email">>, Email}),

                    ?DEBUG("User= ~p~n", [User]),
                    mongo_worker:update(?DB_USER, User#{
                        <<"password">> => web_util:hash_password(Pass2),
                        <<"updated_at">> => web_util:now()
                    }),

                    %% invalidate, and ask to login again
                    {ok, Sid} = maps:find(<<"sid">>, Params),
                    session_worker:del_cookies(Sid),
                    {redirect, <<"/auth/login">>}
            end
    end;

handle_request(_, _, _, _, _) ->
    {error, <<"Opps, Forbidden">>}.
