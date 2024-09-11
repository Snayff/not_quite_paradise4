# Brief
For self and for others who might want to contribute, we need a consistent way of working. This document seeks to define that way. It will also support easier introduction and reading of the project. 

We try to follow Godot's [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) as a primary authority, and Python's [PEP8](http://pep8.org/) after that, specifically the [Hitchhiker's Guide to Python version.](https://docs.python-guide.org/writing/style/).
# The Zen of ~~Python~~ This Project
The [Zen of Python](https://www.python.org/dev/peps/pep-0020) is excellent inspiration and is copied here. 

```
Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
```
# Structure
## Overview
The top level folder structure should look like this:
-assets
-data
-docs
-scenes
-scripts
-scenes_with_scripts

## Assets
The `assets` folder contains all non-code assets. 

While utilising assets from a variety of places we include the `license.txt` file alongside the related assets. 
## Data
Config and data files.
## Docs
Project documentation is held here.
## Scenes
xxx
## Scripts
xxx
# Folders
We use folders to group like things and create identifiable separation. For example, a set of sprites for a single animation should be in their own folder.
# Naming
## Private or Public
Private or local variables and functions should be prefixed with an underscore, i.e. `_`. This is to keep the external API of the class as clean and simple as possible. 
## Simple Differentiation
We use a trailing underscore, i.e. `_` where we need a simple differnetiation between variable names. This is often used where arguments in a function might otherwise match class variables. 

## Is or Has
For any conditions that check the *thing*-ness of a class, we use `Is*` or `Has*`, e.g. `IsReady` naming conventions. 
## Objects, Names & Cases

| Object      | Casing     | Note                  |
| ----------- | ---------- | --------------------- |
| Folder      | snake_case |                       |
| File        | snake_case |                       |
| Class       | PascalCase |                       |
| Node        | PascalCase |                       |
| Function    | snake_case | verb                  |
| Variable    | snake_case | noun                  |
| Signal      | snake_case | past tense verb       |
| Constant    | UPPERCASE  | noun                  |
| Enum Name   | UPPERCASE  | pep8 > gdscript style |
| Enum Member | snake_case | pep8 > gdscript style |
Note, when using PascalCase we capitalise all elements of an acronym, e.g.  `YAMLParser`, rather than `YamlParser`.
## Always Longform
We avoid shortened names, unless they are widely-used outside of the project. This is to support understanding in the long term. 

# Formatting
## Ordering
A template is provided, which provides a standard organisation for .gd files. Every gd file should use this template. 

The code order, broken into discrete regions, is:
1. Class definition
	1. tags, e.g. `@tool`
	2. Class documentation
	3. Icon
	4. Class name
	5. Extends
2. Signals
3. On ready variables
4. Exported variables, broken into Groups and Sub Groups
5. Class variables
6. Functions
## Indentation
### Tabs
We use tabs, rather than spaces. A tab should be the equivalent of 4 spaces. 
### Indentation Style
We use K&R indentation, specifically the One True Brace version, e.g.
```
func is_negative(int x) -> bool:
    if (x < 0):
        return true
    else:
        return false
    

```
Or
```
bool is_negative(int x) {
    if (x < 0) {
        return true;
    } else {
        return false;
    }
}
```
## Line Length
Lines should be 100 characters or less. 
## Blank Lines
1 blank line is left between each functions. 
2 blank lines are left between each code region. 
## Trailing Commas
Always leave a trailing comma, where possible. Smaller diffs and easier refactoring.
## One Statement Per Line
1 statement per line is preferred. We avoid multiple concatenated statements for readibility. 
e.g. this
```
if position.x > width:
	position.x = 0

if flag:
	print("flagged") 
```
and  not this:
```

if position.x > width: position.x = 0

if flag: print("flagged")
```
# Type Hints & Static Typing
Static typing is used for everything. This is both for comprehension and for performance increases. We avoid type inference in favour of explicitness. 
# Comments
## Location
Comment precede the thing they refer to. We use the preceding line for most things, and inline for class variables, to make scanning the block of variables easier.
## Spacing
The content of a comment should start 1 space after the `#` identifier. The identifier should either begin a line, or be 2 spaces after the last code character. 
For "commented out" code, no space is required and is in fact preferred, for differentiation. 
## Tags
While not respected by Godot, we use tags to quickly identify aspects of functions.

| Tag       | Usage                                      |
| --------- | ------------------------------------------ |
| @virtual  | A function to be overridden by subclasses. |
| @nullable | A function that can return null.           |
# Warnings & Errors
## Types
`assert`s are used where we want the game to fail hard. These are predominantly for things that will be known at initialisation.
`push_error`s are used where we want to log a serious, game breaking issue found during run-time.
`push_warning`s are for anything that isnt game breaking, but as a developer we still want to log has happened. 
## Ignoring Warnings
Some Godot warnings might need to be ignored. Where we accept the warning raised, or it is raised in error, we should use the relevant `@warning_ignore`, accompanied with an associated comment justifying the ignoring. 
## Editor Warnings
Where we are generating warnings or errors for an exported variable we should also make these available in the Editor interface. 
# Returning Values
Fewer *meaningful* (i.e. not null) return statements are preferred in a function, as this simplifies the process of bug-hunting and promotes a clear intent. 
# Getters & Setters
Given the preference for explicitness, where setting or getting a value involves some complexity we use a defined function, e.g. `get_value`. Where the action required is exceedingly simple, we use the "hidden" getter and setter. For example:
```
var _target: CombatActor:
	set(value):
		_target = value
		new_target.emit(_target)
```
If a value is dynamically calculated, we use the "hidden" setter to push a warning, informing that the value cannot be set directly. 
```
var can_cast: bool:
	set(_value):
		push_error("CombatActive: Can't set `can_cast` directly.")
	get:
		if is_ready and target_actor is CombatActor:
			return true
		return false
```
# Signals
## Code Over Editor
We should connect signals via code, rather than via the Editor. This makes the signal's connection searchable and limits the number of places to look to find settings or interactions. 