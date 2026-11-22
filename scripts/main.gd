extends Node2D

@onready var _dig_site: DigSite = $DigSite
@onready var _digs_label: Label = $DigsLabel
@onready var _run_over_label: Label = $RunOverLabel
# TEMP (feature 7): shows the latest find until the popup (feature 9) replaces it.
@onready var _found_label: Label = $FoundLabel


func _ready() -> void:
	# Integer scaling can't go below 1x, so a window smaller than the viewport crops the game
	# and clicks stop lining up with what's drawn. content_scale_size is the 640x360 viewport size.
	get_window().min_size = get_window().content_scale_size
	# Children are ready before their parent, so DigSite's grid already exists here.
	_show_digs_left(_dig_site.grid.digs_left())


func _on_dig_site_digs_left_changed(digs_left: int) -> void:
	_show_digs_left(digs_left)


func _on_dig_site_run_ended() -> void:
	_run_over_label.show()


func _on_dig_site_artifact_found(artifact: Artifact, _cell: Vector2i) -> void:
	_found_label.text = "Found: %s" % artifact.name


func _show_digs_left(digs_left: int) -> void:
	_digs_label.text = "Digs left: %d" % digs_left
