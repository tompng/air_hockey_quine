# Network Battle Air Hockey Quine

## Offline 2 Player Battle
`ruby hockey.rb`

Player1: Arrow keys

Player2: WASD keys

## Network Battle (server)
`ruby hockey.rb 4000`

## Network Battle (client)
`ruby hockey.rb localhost:4000`

If you don't have hockey.rb, get the code from server.

`curl localhost:4000 > hockey.rb` `telnet localhost 4000 [enter] [enter]`

## Generate
```
(sleep 1;curl localhost:4000 > hockey.rb) &;ruby hockey_generator.rb 4000
(sleep 1;curl localhost:5000 > hockey2.rb) &;ruby hockey.rb 5000
diff hockey.rb hockey2.rb && echo ok
```
