
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

handle_request(<<"POST">>, <<"article">>, [], Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),

  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  Title = proplists:get_value(<<"title">>, PostVals),
  Content = proplists:get_value(<<"content">>, PostVals),
  Category = proplists:get_value(<<"category">>, PostVals),
  Tags = proplists:get_all_values(<<"tag">>, PostVals),
  GroupId = proplists:get_value(<<"grpid">>, PostVals),

  CurrPost = maps:get(<<"posts">>, User),
  User2 = User#{<<"posts">> => CurrPost + 1, 
                <<"last_post">> => erlang:timestamp()},

  TagList = lists:map(fun(Id) -> 
                        {ok, T} = mongo_worker:find_one(?DB_TAGS, {<<"_id">>, Id}), 
                        T 
                      end, Tags),

  %% save the post    
  mongo_worker:save(?DB_POSTS, #{
      <<"_id">> => uuid:gen(),
      <<"title">> => Title,
      <<"content">> => Content,
      <<"category">> => Category,
      <<"tags">> => TagList,
      <<"author">> => User2,
      <<"grpid">> => GroupId,
      <<"created_at">> => erlang:timestamp(),
      <<"updated_at">> => erlang:timestamp()
    }),
  mongo_worker:update(?DB_USERS, User2),

  {redirect, << <<"/forum/discuss/">>/binary, GroupId/binary >>};

handle_request(<<"GET">>, <<"message">>, [_MsgId], _Params, _Req) ->
  {ok, Content} = forum_message_dtl:render([]),
  {render, Content};

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.
