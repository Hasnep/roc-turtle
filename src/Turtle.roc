module [
    Position,
    Turtle,
    new,
    getPosition,
    forward,
    moveTo,
    getDirection,
    turn,
    turnTo,
    pointAt,
    getPen,
    setPen,
    getLines,
    repeat,
    toSvg,
]

import Svg
import Attribute
import Utils

## A position on the canvas.
Position : { x : F64, y : F64 }

## A turtle that can move around the canvas and draw lines.
Turtle := {
    position : Position,
    direction : F64,
    pen : [Up, Down],
    lines : {
        current : List Position,
        previous : List (List Position),
    },
}

## Create a new turtle at the origin facing right with the pen down.
new : { position ? Position, direction ? F64, pen ? [Up, Down] } -> Turtle
new = \{ position ? { x: 0, y: 0 }, direction ? 0, pen ? Down } ->
    @Turtle { position, direction, pen, lines: { current: [{ x: 0, y: 0 }], previous: [] } }

## Get the turtle's current position.
getPosition : Turtle -> Position
getPosition = \@Turtle { position } -> position

## Move the turtle forward by a distance.
forward : Turtle, F64 -> Turtle
forward = \@Turtle { position, direction, pen, lines }, distance ->
    newPosition = {
        x: position.x + distance * Num.cos direction,
        y: position.y + distance * Num.sin direction,
    }
    newLines = { current: lines.current |> List.append newPosition, previous: lines.previous }
    @Turtle { position: newPosition, direction, pen, lines: newLines }

## Move the turtle to a new position without changing its direction.
moveTo : Turtle, Position -> Turtle
moveTo = \@Turtle { direction, pen, lines }, newPosition ->
    @Turtle { position: newPosition, direction, pen, lines }

## Get the turtle's current direction.
getDirection : Turtle -> F64
getDirection = \@Turtle { direction } -> direction

## Turn the turtle by an angle.
turn : Turtle, F64 -> Turtle
turn = \@Turtle { position, direction, pen, lines }, angle ->
    @Turtle {
        position,
        direction: Utils.clampAngle (direction + angle),
        pen,
        lines,
    }

## Turn the turtle to an absolute angle.
turnTo : Turtle, F64 -> Turtle
turnTo = \@Turtle { position, pen, lines }, newDirection ->
    @Turtle {
        position,
        direction: Utils.clampAngle newDirection,
        pen,
        lines,
    }

## Point the turtle at a position.
pointAt : Turtle, Position -> Turtle
pointAt = \@Turtle { position, direction, pen, lines }, pointAtPosition ->
    (deltaX, deltaY) = (pointAtPosition.x - position.x, pointAtPosition.y - position.y)
    newDirection =
        if Utils.isApproxEq0 deltaX then
            if Utils.isApproxEq0 deltaY then
                direction
            else if deltaY > 0 then
                Num.pi / 2
            else
                -Num.pi / 2
        else if deltaX > 0 then
            Num.atan (deltaY / deltaX)
        else if deltaY > 0 then
            Num.atan (deltaY / deltaX) + Num.pi
        else
            Num.atan (deltaY / deltaX) - Num.pi
    @Turtle { position, direction: Utils.clampAngle newDirection, pen, lines }

## Get the pens' current state.
getPen : Turtle -> [Up, Down]
getPen = \@Turtle { pen } -> pen

## Set the pen to `Up`, `Down`, or `Invert` (toggle between `Up` and `Down`)
setPen : Turtle, [Up, Down, Invert] -> Turtle
setPen = \@Turtle { position, direction, pen, lines }, setPenTo ->
    newPen =
        when setPenTo is
            Invert -> (if pen == Up then Down else Up)
            Up -> Up
            Down -> Down
    newLines =
        when (pen, newPen) is
            (Up, Down) -> { current: [position], previous: lines.previous }
            (Down, Up) ->
                # If the turtle hasn't moved since putting the pen down, we should ignore the dot it drew
                if List.len lines.current == 0 then
                    {
                        current: [],
                        previous: lines.previous,
                    }
                else
                    {
                        current: [],
                        previous: lines.previous |> List.append lines.current,
                    }

            _ -> lines
    @Turtle { position, direction, pen: newPen, lines: newLines }

## Get all the lines drawn by the turtle so far.
getLines : Turtle -> List (List Position)
getLines = \@Turtle { lines } -> lines.previous |> List.append lines.current

expect
    out = new {} |> forward 10
    (out |> getPosition |> .x |> Num.isApproxEq 10 {})
    && (out |> getPosition |> .y |> Num.isApproxEq 0 {})
    && (out |> getDirection |> Num.isApproxEq 0 {})
    && (out |> getPen == Down)

# Helpers

## Repeat a function n times
repeat : Turtle, U64, (Turtle -> Turtle) -> Turtle
repeat = \turtle, n, f ->
    if n == 0 then
        turtle
    else
        turtle |> f |> repeat (n - 1) f

# Output

## Convert the turtle's lines to an SVG string
toSvg : Turtle, { x : { from : F64, to : F64 }, y : { from : F64, to : F64 }, scale ? F64 } -> Str
toSvg = \@Turtle { lines }, { x, y, scale ? 1.0 } ->
    allLines = lines.previous |> List.append lines.current

    path =
        allCommands =
            allLines
            |> List.map
                (
                    \linePositions ->
                        lineCommands =
                            when linePositions is
                                [] -> []
                                [p] -> ["M $(Num.toStr p.x) $(Num.toStr p.y)"]
                                [p, .. as rest] -> List.concat ["M $(Num.toStr p.x) $(Num.toStr p.y) "] (List.map rest \{ x: pX, y: pY } -> "L $(Num.toStr pX) $(Num.toStr pY)")
                        lineCommands |> Str.joinWith " "
                )
            |> Str.joinWith " "
        Svg.path
            [
                Attribute.d allCommands,
                Attribute.fill "transparent",
                Attribute.stroke "black",
            ]
            []

    canvas =
        canvasWidth = scale * (x.to - x.from)
        canvasHeight = scale * (y.to - y.from)
        Svg.svg
            [
                Attribute.width (Num.toStr canvasWidth),
                Attribute.height (Num.toStr canvasHeight),
                Attribute.viewBox "$(Num.toStr x.from) $(Num.toStr y.from) $(Num.toStr (x.to - x.from)) $(Num.toStr (y.to - y.from))",
                Attribute.xmlns "http://www.w3.org/2000/svg",
            ]
            [path]

    Svg.render canvas
