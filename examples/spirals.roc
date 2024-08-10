app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    turtle: "../src/main.roc",
}

import cli.File
import cli.Task
import turtle.Turtle

resetPosition : Turtle.Turtle -> Turtle.Turtle
resetPosition = \t ->
    t
    |> Turtle.setPen Up
    |> Turtle.moveTo { x: 0, y: 0 }
    |> Turtle.setPen Down

spiral = \t, { nArms, direction } ->
    spiralArm = \t2 ->
        t2
        |> resetPosition
        |> Turtle.repeat
            500
            (
                \t3 -> t3
                    |> Turtle.forward 1
                    |> Turtle.turn ((if direction == Clockwise then -1 else 1) * Num.pi / 500)
            )

    t
    |> resetPosition
    |> Turtle.repeat nArms (\t2 -> t2 |> spiralArm |> Turtle.turn (2 * Num.pi / (Num.toF64 nArms)))

main =
    drawingSvgStr =
        Turtle.new {}
        |> spiral { nArms: 100, direction: Clockwise }
        |> spiral { nArms: 100, direction: AntiClockwise }
        |> Turtle.toSvg { x: { from: -500, to: 500 }, y: { from: -500, to: 500 } }
    File.writeUtf8 "examples/spirals.svg" drawingSvgStr
