-module (msg_controller).
-export ([handle_request/5]).
-include ("gruppz.hrl").

handle_request(<<"GET">>, _Id, _Args, _Params, _Req) ->
  ?DEBUG("Getting messages in msg_controller...~n", []),
  {render, <<"forum_message">>, []}.

