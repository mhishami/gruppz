-module (forum_controller).
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

handle_request(<<"GET">>, <<"welcome">>, [GroupId], Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),
  {ok, Post} = mongo_worker:find(?DB_POSTS, {<<"group">>, GroupId, <<"msgid">>, <<"welcome">>}),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),

  {render, <<"forum_welcome">>, [
    {user, User},
    {post, Post},
    {group, Group}
  ]};

handle_request(<<"GET">>, <<"news">>, [GroupId], Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),
  {ok, News} = mongo_worker:find(?DB_NEWS, {<<"group">>, GroupId, <<"msgid">>, <<"welcome">>}),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),

  {render, <<"forum_news">>, [
    {user, User},
    {news, News},
    {group, Group}
  ]};

handle_request(<<"GET">>, <<"settings">>, [GroupId], Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),

  {render, <<"forum_settings">>, [
    {user, User},
    {group, Group}
  ]};

handle_request(<<"GET">>, <<"category">>, [GroupId, Category], Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  {ok, Posts} = mongo_worker:find(?DB_POSTS, {<<"grpid">>, GroupId, <<"category">>, Category}),

  {render, <<"forum_discuss">>, [
    {user, User},
    {group, Group},
    {posts, Posts}
  ]};

handle_request(<<"GET">>, <<"tag">>, [GroupId, Tag], Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  {ok, Posts} = mongo_worker:find(?DB_POSTS, {<<"grpid">>, GroupId, <<"tag">>, Tag}),

  {render, <<"forum_discuss">>, [
    {user, User},
    {group, Group},
    {posts, Posts}
  ]};

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.
