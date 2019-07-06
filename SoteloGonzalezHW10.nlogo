;; Kat Sotelo and Tyler Gonzalez
;; SoteloGonzalezHW10.nlogo
;; Modeling the process of going through airport security

breed [ passengers passenger ]
breed [ tsa-agents tsa-agent ]

globals
[
  number-through-security
  total-number-of-passengers
  passengers-at-gate-1
  passengers-at-gate-2
  passengers-at-gate-3
  passengers-at-gate-4
  passengers-at-gate-5
  passengers-at-gate-6
  passengers-at-gate-7
  passengers-at-gate-8
  line-1-stop?
  line-2-stop?
  line-3-stop?
  line-4-stop?
  line-5-stop?
  count1
  count2
  count3
  count4
  count5
]

patches-own [ passengers-on-patch ]

;; sets up the environment
to setup
  clear-all
  reset-ticks
  setup-floor
  setup-tsa-agents
  initialize-globals
end

;; makes passengers move and updates monitors
to go
  setup-new-passengers
  move-passengers
  move-through-security
  stop-passengers
  go-passengers
  update-gate-monitors
  flight-departure
  set number-through-security count passengers with [ pycor > 0 ]
  set total-number-of-passengers count passengers
  tick
end

;; initializes all of the global varibles
to initialize-globals
  ask patches
  [
    let x pxcor
    let y pycor
    set passengers-on-patch count passengers with [ pycor = y and pxcor = x ]
  ]
  set total-number-of-passengers count passengers
  set line-1-stop? false
  set line-2-stop? false
  set line-3-stop? false
  set line-4-stop? false
  set line-5-stop? false
  set count1 0
  set count2 0
  set count3 0
  set count4 0
  set count5 0
end

;; creates the security lines and gates
to setup-floor
  ask patches [ set pcolor blue + 2 ]
  setup-lines
  setup-metal-detectors
  setup-divide
  setup-gates
end

;; sets up the lines, making them either green or yellow based on number of tsa agents
to setup-lines
  let x -4
  let z 0
  while [ z < (num-tsa-agents - 1) / 2 ]
  [
    ask patches with [ pxcor = ((min-pxcor + max-pxcor) / 2) + x and pycor < ((min-pycor + max-pycor) / 2) + 5 ] [ set pcolor green ]
    set x x + 2
    set z z + 1
  ]
  while [ z >= (num-tsa-agents - 1) / 2 and z < 5 ]
  [
    ask patches with [ pxcor = ((min-pxcor + max-pxcor) / 2) + x and pycor < ((min-pycor + max-pycor) / 2) + 5 ] [ set pcolor yellow ]
    set x x + 2
    set z z + 1
  ]
end

;; sets up metal detectors in each line
to setup-metal-detectors
  create-turtles 1
  [
    set shape "dot"
    setxy (((min-pxcor + max-pxcor) / 2) - 5) ((min-pycor + max-pycor) / 2)
    set color gray - 3
    set heading 90
    pen-down
    let x 0
    stamp
    while [ x < 5 ]
    [
      forward 2
      stamp
      set x x + 1
    ]
    die
  ]
end

;; sets up divide between the passengers who have gone through security and those who haven't
to setup-divide
  ask patches with [ pycor > (((min-pycor + max-pycor) / 2) - 5) and pycor < (((min-pycor + max-pycor) / 2) + 5)
    and pxcor < (((min-pxcor + max-pxcor) / 2) - 5) ]
  [
    set pcolor gray - 3
  ]
  ask patches with [ pycor > (((min-pycor + max-pycor) / 2) - 5) and pycor < (((min-pycor + max-pycor) / 2) + 5)
    and pxcor > (((min-pxcor + max-pxcor) / 2) + 5) ]
  [
    set pcolor gray - 3
  ]
  let x (((min-pxcor + max-pxcor) / 2) - 5)
  let y (((min-pycor + max-pycor) / 2) - 5)
  let z 0
  while [ z < 5 ]
  [
    ask patch x y
    [
      set pcolor gray - 3
    ]
    set x x + 2
    set z z + 1
  ]
end

;; sets up the gates at the top of the screen
to setup-gates
  let x 3
  while [ (x + min-pxcor) < max-pxcor - 3 ]
  [
    ask patches with [ pycor > max-pycor - 3 and pxcor >= min-pxcor + x and pxcor < min-pxcor + x + 3 ]
    [
      set pcolor black
    ]
    set x x + 6
  ]
  let y 1
  set x 4
  while[y < 9]
  [
    ask patches with [ pycor = max-pycor - 1 and pxcor = min-pxcor + x ]
    [
      set plabel y
    ]
    set y y + 1
    set x x + 6
  ]
end

;; creates new passengers based on busyness of airport and number of new passengers
to setup-new-passengers
  if ticks mod (30 - busyness-of-airport) = 0
  [
    create-passengers num-new-passengers
    [
      set shape "person"
      set color red
      setxy random-xcor random-ycor
      while [ ycor > (((min-pycor + max-pycor) / 2) - 17) ]
      [
        setxy random-xcor random-ycor
      ]
    ]
  ]
end

;; creates tsa agents based on number of tsa agents variable
to setup-tsa-agents
  let z 0
  let x (((min-pxcor + max-pxcor) / 2) - 5)
  let y (((min-pycor + max-pycor) / 2) - 4)
  while [ z < num-tsa-agents ]
  [
    ask patch x y
    [
      sprout-tsa-agents 1
      [
        set shape "person"
        set color blue
      ]
    ]
    if z mod 4 = 0
    [
      set y y + 5
    ]
    if z mod 4 = 1 or z mod 4 = 3
    [
      set x x + 2
    ]
    if z mod 4 = 2
    [
      set y y - 5
    ]
    set z z + 1
  ]
end

;; moves the passengers that have not gone through security yet
to move-passengers
  ask passengers with [ pycor < -7 ]
  [
    let x 0
    let y 0
    let z 0
    move-passengers-toward-line
    if pcolor = green
    [
      set heading 0
      ask patch-here
      [
        set x pxcor
        set y pycor
      ]
      ask patch x (y + 1)
      [
        ifelse spot-empty?
        [
          set z 1
        ]
        [
          move-to-new-line
        ]
      ]
    ]
    if z = 1 and pycor < -7
    [
      forward 1
    ]
  ]
  update-passengers-on-patch
end

;; sets all passengers toward security lines
to move-passengers-toward-line
  if pcolor != green
    [
      ifelse count patches with [ pcolor = green and spot-empty? and pycor < -12 and pycor > min-pycor ] > 0
      [
        set heading towards min-one-of patches with [ pcolor = green and spot-empty? and pycor < -12 and pycor >= min-pycor ] [ (((min-pycor + max-pycor) / 2) - 4) - pycor ]
      ]
      [
        set heading towards min-one-of patches with [ pcolor = green and pycor = min-pycor ] [ passengers-on-patch ]
      ]
      forward 1
    ]
end

;; updates the passengers on patch variable
to update-passengers-on-patch
  ask patches
  [
    let x pxcor
    let y pycor
    set passengers-on-patch count passengers with [ pycor = y and pxcor = x ]
  ]
end

;; reports true if spot is full, false otherwise
to-report spot-full?
  report passengers-on-patch > 1
end

;; reports true if spot is empty, false otherwise
to-report spot-empty?
  report passengers-on-patch = 0
end

;; moves passengers to new line if line becomes backed up
to move-to-new-line
  ask passengers with [ pcolor = green and pycor < -7]
  [
    let x 0
    let y 0
    let z 0
    set x pxcor
    set y pycor
    ask patch (x + 2) (y + 1)
    [
      if spot-empty? and pcolor = green and pycor < -5
      [
        set z 1
      ]
    ]
    ask patch (x - 2) (y + 1)
    [
      if spot-empty? and pcolor = green and pycor < -5
      [
        set z -1
      ]
    ]
    if z = 1 and spot-full?
    [
      move-to patch (x + 2) (y + 1)
    ]
    if z = -1 and spot-full?
    [
      move-to patch (x - 2) (y + 1)
    ]
  ]
end

;; moves passengers through security and toward their gate
to move-through-security
  wait-your-turn
  move-line-1
  move-line-2
  move-line-3
  move-line-4
  move-line-5
  go-to-gate
end

;; causes passengers to go through security one at a time
to wait-your-turn
  ask passengers with [ pycor = -7 ]
  [
    if not any? turtles-on patch-ahead 1 and not any? turtles-on patch-ahead 2 and not any? turtles-on patch-ahead 3
    and not any? turtles-on patch-ahead 4 and not any? turtles-on patch-ahead 5 and not any? turtles-on patch-ahead 6
    and not any? turtles-on patch-ahead 7
      [ forward 1 ]
  ]
end

;; moves the passengers in the first line
to move-line-1
  ask passengers with [ pycor > -7 and pycor < 5 and pxcor = -4 ]
  [
    if not line-1-stop?
    [
      set heading 0
      forward 1
    ]
  ]
end

;; moves the passengers in the second line
to move-line-2
  ask passengers with [ pycor > -7 and pycor < 5 and pxcor = -2 ]
  [
    if not line-2-stop?
    [
      set heading 0
      forward 1
    ]
  ]
end

;; moves the passengers in the third line
to move-line-3
  ask passengers with [ pycor > -7 and pycor < 5 and pxcor = 0 ]
  [
    if not line-3-stop?
    [
      set heading 0
      forward 1
    ]
  ]
end

;; moves the passengers in the fourth line
to move-line-4
  ask passengers with [ pycor > -7 and pycor < 5 and pxcor = 2 ]
  [
    if not line-4-stop?
    [
      set heading 0
      forward 1
    ]
  ]
end

;; moves the passengers in the fifth line
to move-line-5
  ask passengers with [ pycor > -7 and pycor < 5 and pxcor = 4 ]
  [
    if not line-5-stop?
    [
      set heading 0
      forward 1
    ]
  ]
end

;; causes passengers to go toward their gate
to go-to-gate
  let x 0
  let y 0
  ask passengers with [pycor = 5]
  [
    let z random 8 + 1
    ask patches with [ plabel = z ]
    [
      set x pxcor
      set y pycor
    ]
    set heading towards patch x y
    forward 1
  ]
  ask passengers with [ pycor > 5 and pycor < max-pycor - 1 ]
  [
    forward 1
  ]
end

;; updates all gate monitors
to update-gate-monitors
  set passengers-at-gate-1 count [ passengers in-radius 1 ] of patch (min-pxcor + 4) (max-pycor - 1)
  set passengers-at-gate-2 count [ passengers in-radius 1 ] of patch (min-pxcor + 10) (max-pycor - 1)
  set passengers-at-gate-3 count [ passengers in-radius 1 ] of patch (min-pxcor + 16) (max-pycor - 1)
  set passengers-at-gate-4 count [ passengers in-radius 1 ] of patch (min-pxcor + 22) (max-pycor - 1)
  set passengers-at-gate-5 count [ passengers in-radius 1 ] of patch (min-pxcor + 28) (max-pycor - 1)
  set passengers-at-gate-6 count [ passengers in-radius 1 ] of patch (min-pxcor + 34) (max-pycor - 1)
  set passengers-at-gate-7 count [ passengers in-radius 1 ] of patch (min-pxcor + 40) (max-pycor - 1)
  set passengers-at-gate-8 count [ passengers in-radius 1 ] of patch (min-pxcor + 46) (max-pycor - 1)
end

;; causes flights to leave when the number of people at the gate reaches 20
to flight-departure
  gate-1-departure
  gate-2-departure
  gate-3-departure
  gate-4-departure
  gate-5-departure
  gate-6-departure
  gate-7-departure
  gate-8-departure
end

;; flight 1 leaves
to gate-1-departure
  if passengers-at-gate-1 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 4) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 1 is now departing"
  ]
end

;; flight 2 leaves
to gate-2-departure
  if passengers-at-gate-2 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 10) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 2 is now departing"
  ]
end

;; flight 3 leaves
to gate-3-departure
  if passengers-at-gate-3 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 16) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 3 is now departing"
  ]
end

;; flight 4 leaves
to gate-4-departure
  if passengers-at-gate-4 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 22) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 4 is now departing"
  ]
end

;; flight 5 leaves
to gate-5-departure
  if passengers-at-gate-5 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 28) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 5 is now departing"
  ]
end

;; flight 6 leaves
to gate-6-departure
  if passengers-at-gate-6 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 34) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 6 is now departing"
  ]
end

;; flight 7 leaves
to gate-7-departure
  if passengers-at-gate-7 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 40) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 7 is now departing"
  ]
end

;; flight 8 leaves
to gate-8-departure
  if passengers-at-gate-8 >= 20
  [
    ask [ passengers in-radius 1 ] of patch (min-pxcor + 46) (max-pycor - 1) [ die ]
    output-print "The flight at Gate 8 is now departing"
  ]
end

;; randomly stops passengers for additional search
to stop-passengers
  let x random (10 - chance-of-being-stopped)
  if count passengers with [ pycor = 1 ] > 0
  [
    ask n-of 1 passengers with [ pycor = 1 ]
    [
      if x = 0 and pxcor = -4 and not line-1-stop?
      [
        set line-1-stop? true
        set count1 ticks
      ]
      if x = 0 and pxcor = -2 and not line-2-stop?
      [
        set line-2-stop? true
        set count2 ticks
      ]
      if x = 0 and pxcor = 0 and not line-3-stop?
      [
        set line-3-stop? true
        set count3 ticks
      ]
      if x = 0 and pxcor = 2 and not line-4-stop?
      [
        set line-4-stop? true
        set count4 ticks
      ]
      if x = 0 and pxcor = 4 and not line-5-stop?
      [
        set line-5-stop? true
        set count5 ticks
      ]
    ]
  ]
end

;; causes passengers to go after being searched
to go-passengers
  if ticks = count1 + 8
  [
    set line-1-stop? false
  ]
  if ticks = count2 + 8
  [
    set line-2-stop? false
  ]
  if ticks = count3 + 8
  [
    set line-3-stop? false
  ]
  if ticks = count4 + 8
  [
    set line-4-stop? false
  ]
  if ticks = count5 + 8
  [
    set line-5-stop? false
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
313
11
804
503
-1
-1
9.471
1
10
1
1
1
0
0
0
1
-25
25
-25
25
0
0
1
ticks
30.0

SLIDER
5
116
289
149
num-tsa-agents
num-tsa-agents
2
10
10.0
2
1
NIL
HORIZONTAL

BUTTON
4
10
140
63
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
145
10
292
62
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
7
67
139
112
Number through security
number-through-security
17
1
11

MONITOR
819
10
953
55
Passengers at Gate 1
passengers-at-gate-1
17
1
11

MONITOR
819
60
953
105
Passengers at Gate 2
passengers-at-gate-2
17
1
11

MONITOR
819
109
953
154
Passengers at Gate 3
passengers-at-gate-3
17
1
11

MONITOR
819
158
953
203
Passengers at Gate 4
passengers-at-gate-4
17
1
11

MONITOR
819
207
953
252
Passengers at Gate 5
passengers-at-gate-5
17
1
11

MONITOR
819
256
953
301
Passengers at Gate 6
passengers-at-gate-6
17
1
11

MONITOR
819
306
953
351
Passengers at Gate 7
passengers-at-gate-7
17
1
11

MONITOR
819
355
953
400
Passengers at Gate 8
passengers-at-gate-8
17
1
11

SLIDER
5
153
289
186
num-new-passengers
num-new-passengers
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
5
189
289
222
busyness-of-airport
busyness-of-airport
0
20
17.0
1
1
NIL
HORIZONTAL

OUTPUT
2
264
293
419
11

MONITOR
147
67
293
112
Total number of passengers
total-number-of-passengers
17
1
11

SLIDER
5
226
290
259
chance-of-being-stopped
chance-of-being-stopped
1
10
4.0
1
1
NIL
HORIZONTAL

PLOT
962
14
1327
350
plot 1
time
number of people
0.0
50.0
0.0
50.0
true
false
"" ""
PENS
"pen-1" 1.0 0 -13345367 true "" "plot number-through-security"
"pen-2" 1.0 0 -2674135 true "" "plot total-number-of-passengers"

@#$#@#$#@
## WHAT IS IT?

This model demonstrates how TSA security goes. You can change the amount of lines open for TSA and the passengers will look for the smallest line to get through security. In this model it spawns new passengers depending on how busy the airport is. The passengers react by moving to the shortest TSA line, and once they are through security they head to the gate at which their flight is at. 


## HOW IT WORKS

The observer controls how many people are being spawned as well has how often people are coming in to the airport. The monitors keep track of the amount of people that go through security, are in the airport, and are at each gate. Once there are 20 people at a gate the flight takes off which decreases the amount of passengers at a gate to 0. 

## HOW TO USE IT

 Click the SETUP button to set up the gates, lines and TSA agents in the airport. Click on the GO to get the passengers to start moving towards the lines to get through security and to their gate. 

The NUM-TSA-AGENTS slider controls the amount of TSA agents at the lines. Two TSA agents equals one line in this code. 

The NUM-NEW-PASSENGERS slider controls the amount of new passengers that are spawned after a certain amount of clicks.

The BUSYNESS-OF-AIRPORT slider controls how busy is the airport. The higher the number, the busier the airport which allows the passengers to spawn more frequently.

The CHANCE-OF-BEING-STOPPED slider controls the frequency that a passenger is stopped next to a TSA agent. Once the passenger stops, they stay there for 8 ticks, hold up the line, and then proceed to their gate. 

Through the monitors, you can keep track of how many people have gone through security and how many passengers there are in the airport in general. You can also keep track of how many people are at each gate. 


## THINGS TO NOTICE

The number of TSA agents greatly affects the efficiency of the airport security. When only one or two lines are open the line backs up really quickly. 

When the passengers are spawned they are seen running to the shortest line which demonstrates how the efficiency of the airport is important because the passengers just want to get through security. However, when there is not that many people in the airport, the passenger will just go to the line closest to them because they don't mind waiting a little bit.

When there are a lot of people spawned into the world it makes the line move slower. 

When the chances of being stopped is higher, it backs up the line more and makes it more inefficient.   

When the difference between the blue graph and the red graph is low we know that airport security is running efficiently. But, when the red graph is increasing at a higher rate than the blue graph the airport security is inefficient and the lines begin to back up. 

Notice how passengers are stopped for 8 ticks which backs up the line because no other passengers are let through. 

## THINGS TO TRY

Explore changes with the NUM-TSA-AGENTS slider and see how the efficiency of the airport changes by adding/subtracting the number of TSA agents. 

Explore changes with the NUM-NEW-PASSENGERS slider and the BUSYNESS-OF-AIRPORT slider. How do these affect the flow of the security line, how long does it take for the flow to be fixed? 

What slider settings would you use to maximize the efficiency of the airport? Under what circumstances would you want to add/subtract to TSA? 


## EXTENDING THE MODEL

Changing the while loops to make the grey divide smaller. Then changing the while loop to create more TSA agents/lines. Then changing the slider to allow more TSA agents Lastly, playing with the efficiency by using the sliders. 

Making a select button where you can track a single passenger on their journey through security and also a plot graph to track how long it took them to go through security. 

To make it more accurate, coding in a global variable that describes to attempt to describe the patience that each passenger may have. 


## NETLOGO FEATURES

We used flags by using global boolean variables for each line to create the stop effect to simulate passengers being stopped by TSA for surprise pat downs. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
