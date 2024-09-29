# Principles
## Data-Driven
Where possible, static data should be defined in external files.
## Composition-Preferred
We want to be able to build out functionality by adding in additional classes. Parents should as as "container ", with little direct functionality themselves and with its children acting independently - or as much as is possible. 
Components should very closely follow the single responsibility principle. 
## Constants and Enums
Almost all constants and enums are required in multiple places, so they are held in an autoload script called `constants.gd`. We use local enums, as part of `export_enum`, where we want categorised, editor defined values that are not used in any other file.

# Templates and Instances
## Overview
Most of the game is built using specific classes, often derived from an `Abstract Base Class` (denoted by an `ABC` prefix), an example would be `ABCEffectChain`, which has many children, including `EffectChainFireblast`.
However, some things, such as `Actors` or `CombatActives` are built from an approach using templates. This approach is described in this section. 
Note that a template may itself be a subclass of an `ABC`, as projectiles are. The distinction is whether the most specific class is taking a generic or specific approach. Another way to put this would be that `EffectChainFireblast` is only useful for the specific use-case of defining the effects for the fireblast `CombatActive`, whereas `ProjectileThrowable` is used by many types of projectiles. 
## Templates
A generic class, to be populated by data. Examples are `Actor`, `CombatActive`, `Projectile*` and others. 
## Data Source
Data is held in  the global `library.gd`.
## Instance Creation
The instance is usually, but not exclusively, created via `factory.gd`.
## Data Population
Data is passed around via a relevant data class, such as `DataProjectile`. Whilst holding data in a dict in `library.gd` and a data class `Resource` may seem redundant, it allows us to be prescriptive in the definition whilst easily pass the data around. 
## Gotchas
Godot sets the type of everything coming out of a `Dictionary` as `Variant`.  This will then cause an error when the data is passed to a method that expects a type. This is true across Godot, but regularly comes up as part of this process. Use the following approach to `assign` the type after retrieving the data from `library.gd`.
```
var dict_data: Dictionary =  Library.get_library_data("actor", actor_name)
var tags: Array[Constants.COMBAT_TAG]
tags.assign(dict_data["tags"])
```

# Containers
Some *things* are held in `Containers`. This is a concept, rather than a class., so `Container` is a suffix, rather than a prefix.  A `Container` holds 0 to many of a class and provides an interface to manage and utilise the classes held. An example is `CombatActiveContainer` or `StatContainer`.
# Building Combat Functionality
## Effects
We use an approach of chaining together a series of `atomic_actions`, granular actions that change the state of combat. Examples are `atomic_action_apply_stat_mod` and `atomic_action_deal_damage`. These do a single very simple action. These can be used anywhere, but are often used together to define the behaviour of an `EffectChain`, which in turn is used to "power" `CombatActive`'s effect on the world.
## AI
This is very much a **work in progress**.
We use an addon called `LimboAI` to define both state machines and behaviour trees.
