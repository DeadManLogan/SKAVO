extends Node2D

@onready var _dig_site: DigSite = $DigSite
@onready var _digs_label: Label = $DigsLabel
@onready var _run_over_label: Label = $RunOverLabel


func _ready() -> void:
	# Integer scaling can't go below 1x, so a window smaller than the viewport crops the game
	# and clicks stop lining up with what's drawn. content_scale_size is the 640x360 viewport size.
	get_window().min_size = get_window().content_scale_size
	# Children are ready before their parent, so DigSite's grid already exists here.
	_show_digs_left(_dig_site.grid.digs_left())
	_print_artifacts()


func _on_dig_site_digs_left_changed(digs_left: int) -> void:
	_show_digs_left(digs_left)


func _on_dig_site_run_ended() -> void:
	_run_over_label.show()


func _show_digs_left(digs_left: int) -> void:
	_digs_label.text = "Digs left: %d" % digs_left


# TEMP (feature 5): checks that artifacts load. Remove once feature 6 uses load_all().
func _print_artifacts() -> void:
	var artifacts := Artifact.load_all()
	print("Loaded %d artifacts:" % artifacts.size())
	for artifact: Artifact in artifacts:
		print("  %s | %s | sprite: %s" % [artifact.name, artifact.era, artifact.sprite != null])
