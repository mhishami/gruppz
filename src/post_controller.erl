
-module (post_controller).
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

handle_request(<<"POST">>, <<"article">>, _Args, Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),

  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  Title = proplists:get_value(<<"title">>, PostVals),
  Content = proplists:get_value(<<"content">>, PostVals),
  Category = proplists:get_value(<<"category">>, PostVals),
  Tags = proplists:get_all_values(<<"tag">>, PostVals),

  %% save the post    
  mongo_worker:save(?DB_POSTS, #{
      <<"_id">> => uuid:gen(),
      <<"title">> => Title,
      <<"content">> => Content,
      <<"category">> => Category,
      <<"tags">> => Tags,
      <<"author">> => User,
      <<"created_at">> => erlang:localtime(),
      <<"updated_at">> => erlang:localtime()
    }),
  {redirect, <<"/app/forum">>};

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.
