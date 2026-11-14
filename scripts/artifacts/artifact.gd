class_name Artifact
extends Resource

const DIRECTORY := "res://data/artifacts/"

@export var name: String
@export var era: String
@export var sprite: Texture2D
@export_multiline var blurb: String


# list_directory() instead of DirAccess: exported builds convert .tres to binary and
# remap the file names, which DirAccess would see but list_directory() resolves.
static func load_all() -> Array[Artifact]:
	var artifacts: Array[Artifact] = []
	var file_names := Array(ResourceLoader.list_directory(DIRECTORY))
	file_names.sort()  # Stable order makes logs and debugging repeatable.
	for file_name: String in file_names:
		if file_name.ends_with("/"):
			continue
		var artifact := load(DIRECTORY + file_name) as Artifact
		if artifact == null:
			push_warning("Skipped, not an Artifact: %s" % file_name)
			continue
		artifacts.append(artifact)
	return artifacts
