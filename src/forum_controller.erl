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
  {ok, Posts} = mongo_worker:find(?DB_POSTS, {<<"grpid">>, GroupId, <<"category">>, <<"Welcome">>}),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  {ok, Tags} = mongo_worker:match(?DB_TAGS, {<<"grpid">>, GroupId}, {<<"name">>, 1}),

  {render, <<"forum_welcome">>, [
    {user, User},
    {posts, Posts},
    {group, Group},
    {tags, Tags}
  ]};

handle_request(<<"GET">>, <<"news">>, [GroupId], Params, _Req) ->
  User = form_util:get_user(Params),
  {ok, Posts} = mongo_worker:find(?DB_POSTS, {<<"grpid">>, GroupId, <<"category">>, <<"News">>}),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  {ok, Tags} = mongo_worker:match(?DB_TAGS, {<<"grpid">>, GroupId}, {<<"name">>, 1}),

  {render, <<"forum_news">>, [
    {user, User},
    {posts, Posts},
    {group, Group},
    {tags, Tags}
  ]};

handle_request(<<"GET">>, <<"discuss">>, [GroupId], Params, _Req) ->
  User = form_util:get_user(Params),
  {ok, Posts} = mongo_worker:find(?DB_POSTS, {
      <<"grpid">>, GroupId,
      <<"category">>, {<<"$ne">>, <<"News">>},
      <<"category">>, {<<"$ne">>, <<"Welcome">>}
    }),

  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  {ok, Tags} = mongo_worker:match(?DB_TAGS, {<<"grpid">>, GroupId}, {<<"name">>, 1}),

  {render, <<"forum_discuss">>, [
    {user, User},
    {posts, Posts},
    {group, Group},
    {tags, Tags}
  ]};

handle_request(<<"GET">>, <<"settings">>, [GroupId], Params, _Req) ->
  %% check if our user has any board subscribed to
  User = form_util:get_user(Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  {ok, Tags} = mongo_worker:match(?DB_TAGS, {<<"grpid">>, GroupId}, {<<"name">>, 1}),

  ?DEBUG("Group= ~p, Tags= ~p~n", [Group, Tags]),
  {render, <<"forum_settings">>, [
    {user, User},
    {group, Group},
    {tags, Tags}
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
