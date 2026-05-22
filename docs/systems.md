# Systems

Core game systems and their relationships.

This project supports a larger objective: build and automate on a dying planet, launch to a nearby planet for extra resources, then progress toward solar system escape.

## Coal Generator

The coal generator is a simple building node that:

- stores a small amount of coal
- consumes `1` coal per cycle
- adds power into `PowerSystem`
- stops automatically when coal reaches `0`

Example scene:

- `res://scenes/examples/coal_generator_example.tscn`
