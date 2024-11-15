# Roc Turtle

A pure Roc turtle library with no effects, the final drawing is converted to an SVG string and can be saved to a file for viewing.

## Usage

Add the `roc-turtle` package to your header.

```roc
app [main] {turtle: "..."}
```

Import the `Turtle` module.

```roc
import turtle.Turtle
```

Create a `Turtle` using the `Turtle.new` function.

```roc
turtle = Turtle.new {}
```

Use functions like `Turtle.forward` and `Turtle.turn` to move the turtle.

```roc
path = turtle |> Turtle.forward 1 |> Turtle.turn (Num.pi / 4)
```

When your drawing is done, use the `Turtle.toSvg` function to convert it into an SVG string which you can output to a file.

```roc
svgStr = Turtle.toSvg path { x: { from: -500, to: 500 }, y: { from: -500, to: 500 } }
```
