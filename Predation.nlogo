globals [ max-rabbit ]  ; don't let the rabbit population grow too large

; Rabbit and foxes are both breeds of turtles
breed [ rabbit a-rabbit ]  ; rabbit is its own plural, so we use "a-rabbit" as the singular
breed [ foxes fox ]

turtles-own [ energy ]       ; both foxes and rabbit have energy

patches-own [ countdown ]    ; this is for the rabbit-foxes-grass model version

to setup
  clear-all
  ifelse netlogo-web? [ set max-rabbit 10000 ] [ set max-rabbit 30000 ]

  ; Check model-version switch
  ; if we're not modeling grass, then the rabbit don't need to eat to survive
  ; otherwise each grass' state of growth and growing logic need to be set up
  ifelse model-version = "rabbit-foxes-grass" [
    ask patches [
      set pcolor one-of [ green brown ]
      ifelse pcolor = green
        [ set countdown grass-regrowth-time ]
      [ set countdown random grass-regrowth-time ] ; initialize grass regrowth clocks randomly for brown patches
    ]
  ]
  [
    ask patches [ set pcolor green ]
  ]

  create-rabbit initial-number-rabbit  ; create the rabbit, then initialize their variables
  [
    set shape  "rabbit"
    set color white
    set size 1.5  ; easier to see
    set label-color blue - 2
    set energy random (2 * rabbit-gain-from-food)
    setxy random-xcor random-ycor
  ]

  create-foxes initial-number-foxes  ; create the foxes, then initialize their variables
  [
    set shape "fox"
    set color black
    set size 2  ; easier to see
    set energy random (2 * fox-gain-from-food)
    setxy random-xcor random-ycor
  ]
  display-labels
  reset-ticks
end

to go
  ; stop the model if there are no foxes and no rabbit
  if not any? turtles [ stop ]
  ; stop the model if there are no foxes and the number of rabbit gets very large
  if not any? foxes and count rabbit > max-rabbit [ user-message "The rabbit have inherited the earth" stop ]
  ask rabbit [
    move

    ; in this version, rabbit eat grass, grass grows, and it costs rabbit energy to move
    if model-version = "rabbit-foxes-grass" [
      set energy energy - 1  ; deduct energy for rabbit only if running rabbit-foxes-grass model version
      eat-grass  ; rabbit eat grass only if running the rabbit-foxes-grass model version
      death ; rabbit die from starvation only if running the rabbit-foxes-grass model version
    ]

    reproduce-rabbit  ; rabbit reproduce at a random rate governed by a slider
  ]
  ask foxes [
    move
    set energy energy - 1  ; foxes lose energy as they move
    eat-rabbit ; foxes eat a rabbit on their patch
    death ; foxes die if they run out of energy
    reproduce-foxes ; foxes reproduce at a random rate governed by a slider
  ]

  if model-version = "rabbit-foxes-grass" [ ask patches [ grow-grass ] ]

  tick
  display-labels
end

to move  ; turtle procedure
  rt random 50
  lt random 50
  fd 1
end

to eat-grass  ; rabbit procedure
  ; rabbit eat grass and turn the patch brown
  if pcolor = green [
    set pcolor brown
    set energy energy + rabbit-gain-from-food  ; rabbit gain energy by eating
  ]
end

to reproduce-rabbit  ; rabbit procedure
  if random-float 100 < rabbit-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)                ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]   ; hatch an offspring and move it forward 1 step
  ]
end

to reproduce-foxes  ; fox procedure
  if random-float 100 < fox-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)               ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]  ; hatch an offspring and move it forward 1 step
  ]
end

to eat-rabbit  ; fox procedure
  let prey one-of rabbit-here                    ; grab a random rabbit
  if prey != nobody  [                          ; did we get one? if so,
    ask prey [ die ]                            ; kill it, and...
    set energy energy + fox-gain-from-food     ; get energy from eating
  ]
end

to death  ; turtle procedure (i.e. both fox and rabbit procedure)
  ; when energy dips below zero, die
  if energy < 0 [ die ]
end

to grow-grass  ; patch procedure
  ; countdown on brown patches: if you reach 0, grow some grass
  if pcolor = brown [
    ifelse countdown <= 0
      [ set pcolor green
        set countdown grass-regrowth-time ]
      [ set countdown countdown - 1 ]
  ]
end

to-report grass
  ifelse model-version = "rabbit-foxes-grass" [
    report patches with [pcolor = green]
  ]
  [ report 0 ]
end


to display-labels
  ask turtles [ set label "" ]
  if show-energy? [
    ask foxes [ set label round energy ]
    if model-version = "rabbit-foxes-grass" [ ask rabbit [ set label round energy ] ]
  ]
end
