-module (auth_controller).
-export ([handle_request/5]).
% -export ([before_filter/1]).
-export ([gen_portraits/2]).
-export ([regen_portraits/0]).

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

handle_request(<<"GET">>, <<"login">>, _Args, _Params, _Req) ->   
  {render, <<"auth_login">>, []};

handle_request(<<"POST">>, <<"login">>, _Args, Params, _Req) ->
  % PostVals= [{<<"email">>,<<"mhishami@gmail.com">>},{<<"password">>,<<"sa">>}] 
  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  case form_util:not_empty(PostVals) of
    {error, Err} ->
      {render, <<"auth_login">>, [{error, Err} | PostVals]};
    _ ->
      Email = proplists:get_value(<<"email">>, PostVals),
      Pass = proplists:get_value(<<"password">>, PostVals),

      case mongo_worker:find_one(?DB_USERS, {<<"email">>, Email}) of
        {error, _} ->
          {render, <<"auth_login">>, [{error, <<"Invalid username, or password">>}]};
        {ok, User} ->
          P1 = web_util:hash_password(Pass),
          {ok, P2} = maps:find(<<"password">>, User),
          case P1 =/= P2 of
            true ->
              {render, <<"auth_login">>, [{error, <<"Invalid username, or password">>}]};
            _ ->
              %% set cookies
              {ok, Sid} = maps:find(<<"sid">>, Params),
              session_worker:set_cookies(Sid, Email),
              {redirect, <<"/app">>, {cookie, <<"auth">>, Email}}
          end
      end
  end;

handle_request(<<"GET">>, <<"signup">>, _Args, _Params, _Req) ->    
    {render, <<"auth_signup">>, []};

handle_request(<<"POST">>, <<"signup">>, _Args, Params, _Req) ->
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
  ?DEBUG("PostVals= ~p~n", [PostVals]),

  case form_util:not_empty(PostVals) of
    {error, Err} ->
      {render, <<"auth_signup">>, [{error, Err} | PostVals]};
    _ ->
      Pass1 = proplists:get_value(<<"password">>, PostVals),
      Pass2 = proplists:get_value(<<"password2">>, PostVals),
      case Pass2 =/= Pass1 of
        true ->
          %% wrong password
          {render, <<"auth_signup">>, [
              {error, <<"Passwords are not the same">>} | PostVals]};
        false ->
          User = #{
            <<"_id">> => uuid:gen(),
            <<"fullname">> => proplists:get_value(<<"fullname">>, PostVals),
            <<"email">> => proplists:get_value(<<"email">>, PostVals),
            <<"password">> => web_util:hash_password(Pass2),
            <<"mobile_no">> => <<>>,
            <<"groups">> => [],
            <<"posts">> => 0,
            <<"gender">> => proplists:get_value(<<"gender">>, PostVals),
            <<"last_post">> => erlang:timestamp(),
            <<"created_at">> => erlang:timestamp(),
            <<"updated_at">> => erlang:timestamp()
          },
          ?DEBUG("User= ~p~n", [User]),
          mongo_worker:save(?DB_USERS, User),

          %% copy profile pic
          gen_portraits(maps:get(<<"_id">>, User), maps:get(<<"gender">>, User)),

          {redirect, <<"/auth/login">>}
      end
  end;

handle_request(<<"GET">>, <<"forgot">>, _Args, _Params, _Req) ->
  {render, <<"auth_forgot">>, []};

handle_request(<<"GET">>, <<"lock">>, _Args, _Params, _Req) ->
  {render, <<"auth_lock">>, []};

handle_request(<<"POST">>, <<"lock">>, _Args, _Params, _Req) ->
  %% compare pasword
  {redirect, <<"/app">>};    

handle_request(<<"GET">>, <<"logout">>, _Args, Params, _Req) ->    
  {ok, Sid} = maps:find(<<"sid">>, Params),
  session_worker:del_cookies(Sid),
  {redirect, <<"/">>};

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.

-spec gen_portraits(binary(), binary()) -> any().
gen_portraits(User, Gender) when is_binary(User); is_binary(Gender) ->
  PixDir = "/static/assets/portraits/",
  PrivDir = code:priv_dir(gruppz),
  UserId = erlang:binary_to_list(User),

  case Gender of
    <<"male">> ->
      %% copy male picture as id
      Cmd = "cp " ++ PrivDir ++ PixDir ++ "generic-male.jpg " ++ 
            PrivDir ++ PixDir ++ UserId ++ ".jpg",
      os:cmd(Cmd);
    <<"female">> ->
      Cmd = "cp " ++ PrivDir ++ PixDir ++ "generic-female.jpg " ++ 
            PrivDir ++ PixDir ++ UserId ++ ".jpg",
      os:cmd(Cmd)
  end.          

-spec regen_portraits() -> any().
regen_portraits() ->
  {ok, Users} = mongo_worker:find(?DB_USERS, {}),
  lists:map(fun(U) ->
              Id = maps:get(<<"_id">>, U),
              Gender = maps:get(<<"gender">>, U),
              gen_portraits(Id, Gender)
            end, Users).

