# Data-Driven
Where possible, static data should be defined in external files.
# Composition-Preferred
We want to be able to build out functionality by adding in additional classes. Parents should as as "container ", with little direct functionality themselves and with its children acting independently - or as much as is possible. 
Components should very closely follow the single responsibility principle. 
# Constants and Enums
Almost all constants and enums are required in multiple places, so they are held in an autoload script called `constants.gd`.
