-module (group_controller).
-include ("gruppz.hrl").

-export ([handle_request/5]).
-export ([before_filter/1]).

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

%% ----------------------------------------------------------------------------
%% new group handling
%%
handle_request(<<"GET">>, <<"new">>, _Args, Params, _Req) -> 
  {render, <<"group_new">>, [
    {user, form_util:get_user(Params)}
  ]};

handle_request(<<"POST">>, <<"new">>, _Args, Params, _Req) ->
  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  User = form_util:get_user(Params),

  case form_util:not_empty(PostVals) of
    {error, Err} ->
      ?DEBUG("Error in form: ~p~n", [Err]),
      {render, <<"group_new">>, [{error, Err} | PostVals]};
    _ ->
      %% okay, forms look good
      Group = #{
        <<"_id">> => uuid:gen(),
        <<"name">> => proplists:get_value(<<"name">>, PostVals),
        <<"description">> => proplists:get_value(<<"description">>, PostVals),
        <<"members">> => [maps:get(<<"_id">>, User)],  %% contain the user list
        <<"boards">> => [],   %% contain boards id, where post is tagged to
        <<"admin">> => [maps:get(<<"_id">>, User)],
        <<"categories">> => [<<"General">>],
        <<"tags">> => [<<"#cool">>],
        <<"created_at">> => erlang:localtime(),
        <<"updated_at">> => erlang:localtime()
      },
      %% ok, save the data
      ?DEBUG("Group= ~p~n", [Group]),
      mongo_worker:save(?DB_GROUPS, Group),

      UserGroup = #{
        <<"_id">> => maps:get(<<"_id">>, Group),
        <<"name">> => maps:get(<<"name">>, Group),
        <<"description">> => maps:get(<<"description">>, Group)
      },
      mongo_worker:update(?DB_USERS, User#{ 
        <<"groups">> => lists:merge(maps:get(<<"groups">>, User), [UserGroup]),
        <<"updated_at">> => erlang:localtime()
      }),
      {redirect, <<"/app">>}
  end;

%% ----------------------------------------------------------------------------
%% forum handler
%%
handle_request(<<"GET">>, <<"forum">>, [GroupId], Params, _Req) ->
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  {render, <<"forum_discuss">>, [
    {user, form_util:get_user(Params)},
    {group, Group}
  ]};

%% ----------------------------------------------------------------------------
%% category handling
%%
handle_request(<<"POST">>, <<"category">>, [GroupId, <<"add">>], Params, _Req) ->
  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),

  Cat = proplists:get_value(<<"category">>, PostVals),
  case Cat =:= <<>> of
    true ->
      %% redirect back
      {redirect, << <<"/forum/settings/">>/binary, GroupId/binary >>};
    _ ->
      G2 = Group#{<<"categories">> => lists:merge(maps:get(<<"categories">>, Group), [Cat])},
      mongo_worker:update(?DB_GROUPS, G2),
      {redirect, << <<"/forum/settings/">>/binary, GroupId/binary >>}
  end;

handle_request(<<"POST">>, <<"category">>, [GroupId, <<"del">>], Params, _Req) ->
  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),

  Cat = proplists:get_value(<<"category">>, PostVals),
  G2 = Group#{<<"categories">> => lists:subtract(maps:get(<<"categories">>, Group), [Cat])},
  mongo_worker:update(?DB_GROUPS, G2),
  {redirect, << <<"/forum/settings/">>/binary, GroupId/binary >>};

%% ----------------------------------------------------------------------------
%% tags handling
%%
handle_request(<<"POST">>, <<"tag">>, [GroupId, <<"add">>], Params, _Req) ->
  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),

  Tag = proplists:get_value(<<"tag">>, PostVals),
  case Tag =:= <<>> of
    true ->
      %% redirect back
      {redirect, << <<"/forum/settings/">>/binary, GroupId/binary >>};
    _ ->
      G2 = Group#{<<"tags">> => lists:merge(maps:get(<<"tags">>, Group), [Tag])},
      mongo_worker:update(?DB_GROUPS, G2),
      {redirect, << <<"/forum/settings/">>/binary, GroupId/binary >>}
  end;

handle_request(<<"POST">>, <<"tag">>, [GroupId, <<"del">>], Params, _Req) ->
  {ok, PostVals} = maps:find(<<"qs_body">>, Params),
  {ok, Group} = mongo_worker:find_one(?DB_GROUPS, {<<"_id">>, GroupId}),
  ?DEBUG("Group= ~p~n", [Group]),

  Tag = proplists:get_value(<<"tag">>, PostVals),
  G2 = Group#{<<"tags">> => lists:subtract(maps:get(<<"tags">>, Group), [Tag])},
  mongo_worker:update(?DB_GROUPS, G2),
  {redirect, << <<"/forum/settings/">>/binary, GroupId/binary >>};

%% ----------------------------------------------------------------------------
%% catch all
%%
handle_request(Method, Action, Args, _, _) ->
  {error, [{method, Method}, {action, Action}, {args, Args}]}.

