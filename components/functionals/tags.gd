## manage tags on an entity
@icon("res://assets/node_icons/tags.png")
class_name TagsComponent
extends Node


@export var _tags: Array[Constants.COMBAT_TAG] = []


## add a tag.
##
## tags that already exist are ignored.
func add_tag(tag: Constants.COMBAT_TAG) -> void:
	if has_tag(tag):
		return

	_tags.append(tag)

## add an array of tags.
##
## tags that already exist are ignored.
func add_tags(tags: Array[Constants.COMBAT_TAG]) -> void:
	for tag in tags:
		if tag in _tags:
			continue
		_tags.append(tag)

## remove a tag.
##
## tags that do not exist are ignored.
func remove_tag(tag: Constants.COMBAT_TAG) -> void:
	_tags.erase(tag)

## remove an array of tags.
##
## tags that do not exist are ignored.
func remove_tags(tags: Array[Constants.COMBAT_TAG]) -> void:
	for tag in tags:
		_tags.erase(tag)

## check if a tag exists
func has_tag(tag: Constants.COMBAT_TAG) -> bool:
	if tag in _tags:
		return true
	return false

## check if a group of tags all exist
func has_tags(tags: Array[Constants.COMBAT_TAG]) -> bool:
	for tag in tags:
		# if even 1 tag is missing, return false
		if not has_tag(tag):
			return false
	return true
