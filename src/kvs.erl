%%%-------------------------------------------------------------------
%%% @author fuchuan
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 十二月 2018 12:30
%%%-------------------------------------------------------------------
-module(kvs).
-author("fuchuan").

%% Unit test
-include_lib("eunit/include/eunit.hrl").

%% API
-export([start/0, store/2, lookup/1]).

-spec start() -> true.

-spec store(Key :: any(), Value :: any()) -> true.

-spec lookup(Key :: any()) -> {ok, Value :: any()}|undefined.

start() ->
  register(kvs, spawn(fun() -> loop() end)).

store(Key, Value) ->
  rpc({store, Key, Value}).

lookup(Key) ->
  rpc({lookup, Key}).

loop() ->
  receive
    {From, {store, Key, Value}} ->
      put(Key, {ok, Value}),
      From ! {kvs, true},
      loop();
    {From, {lookup, Key}} ->
      From ! {kvs, get(Key)},
      loop()
  end.

rpc(Q) ->
  kvs ! {self(), Q},
  receive
    {kvs, Reply} ->
      Reply
  end.

kvs_test() ->
  ?assert(start()),
  ?assert(store("name", "fuchuan")),
  {ok, Name} = lookup("name"),
  ?assert(string:equal(Name, "fuchuan")),
  ?assert(string:equal(Name, "77") == false),
  ?assert(lookup("xx") == undefined).