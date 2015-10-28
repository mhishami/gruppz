-module (auth_controller).
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

handle_request(<<"GET">>, <<"login">> = Page, _Args, _Params, _Req) ->   
    {render, Page, []};

handle_request(<<"POST">>, <<"login">> = Page, _Args, Params, _Req) ->
    % PostVals= [{<<"email">>,<<"mhishami@gmail.com">>},{<<"password">>,<<"sa">>}] 
    {ok, PostVals} = maps:find(<<"qs_body">>, Params),
    case form_util:not_empty(PostVals) of
        {error, Err} ->
            {render, Page, [{error, Err} | PostVals]};
        _ ->
            Email = proplists:get_value(<<"email">>, PostVals),
            Pass = proplists:get_value(<<"password">>, PostVals),

            {ok, User} = mongo_worker:find_one(?DB_USER, {<<"email">>, Email}),
            P1 = web_util:hash_password(Pass),
            {ok, P2} = maps:find(<<"password">>, User),
            case P1 =/= P2 of
                true ->
                    {render, Page, [{error, <<"Invalid username, or password">>}]};
                _ ->
                    %% set cookies
                    {ok, Sid} = maps:find(<<"sid">>, Params),
                    session_worker:set_cookies(Sid, Email),
                    {redirect, <<"/app">>, {cookie, <<"auth">>, Email}}
            end
    end;

handle_request(<<"GET">>, <<"signup">>, _Args, _Params, _Req) ->    
    {render, <<"signup">>, []};

handle_request(<<"POST">>, <<"signup">> = Page, _Args, Params, _Req) ->
    ?INFO("Registering new user...~n", []),
    % auth_controller:27: Params = #{<<"auth">> => <<>>,<<"files">> => [],
    %  <<"qs_body">> => [
    %   {<<"fullname">>,<<>>},
    %   {<<"email">>,<<>>},
    %   {<<"password">>,<<>>},
    %   {<<"password2">>,<<>>}],
    %   <<"qs_vals">> => [],
    % <<"sid">> => <<"8614191b2d032810bc0d767f7c677cbd2726d618">>}
    {ok, PostVals} = maps:find(<<"qs_body">>, Params),

    case form_util:not_empty(PostVals) of
        {error, Err} ->
            ?DEBUG("Res= ~p~n", [{error, Err} | PostVals]),
            {render, Page, [{error, Err} | PostVals]};
        _ ->
            Pass1 = proplists:get_value(<<"password">>, PostVals),
            Pass2 = proplists:get_value(<<"password2">>, PostVals),
            case Pass2 =/= Pass1 of
                true ->
                    %% wrong password
                    {render, Page, [{error, <<"Passwords are not the same">>} | PostVals]};
                false ->
                    User = #{
                        <<"_id">> => uuid:gen(),
                        <<"fullname">> => proplists:get_value(<<"fullname">>, PostVals),
                        <<"email">> => proplists:get_value(<<"email">>, PostVals),
                        <<"password">> => web_util:hash_password(Pass2),
                        <<"mobile_no">> => <<>>,
                        <<"created_at">> => web_util:now(),
                        <<"updated_at">> => web_util:now()
                    },
                    mongo_worker:save(?DB_USER, User),
                    {redirect, <<"/auth/login">>}
            end
    end;

handle_request(<<"GET">>, <<"logout">>, _Args, Params, _Req) ->    
    {ok, Sid} = maps:find(<<"sid">>, Params),
    session_worker:del_cookies(Sid),
    {redirect, <<"/">>};

handle_request(_, _, _, _, _) ->
    {error, <<"Opps, Forbidden">>}.
