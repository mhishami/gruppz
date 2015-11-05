-module (msg_controller).
-export ([handle_request/5]).
-include ("gruppz.hrl").

handle_request(<<"GET">>, GroupId, [MsgId], _Params, _Req) ->
  ?DEBUG("Getting messages for ~p, ~p ~n", [GroupId, MsgId]),
  {ok, Post} = mongo_worker:find_one(?DB_POSTS, {<<"_id">>, MsgId, <<"grpid">>, GroupId}),
  {render, <<"forum_message">>, [{post, Post}]}.

