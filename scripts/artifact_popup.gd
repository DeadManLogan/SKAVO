class_name ArtifactPopup
extends ColorRect
## Full-screen backdrop that blurs the game behind it and, with Mouse Filter = Stop,
## swallows clicks so nothing underneath can be dug while the artifact window is open.

@onready var _sprite: TextureRect = %Sprite
@onready var _sprite_placeholder: ColorRect = %SpritePlaceholder
@onready var _name_label: Label = %NameLabel
@onready var _era_label: Label = %EraLabel
@onready var _blurb_label: Label = %BlurbLabel


func show_artifact(artifact: Artifact) -> void:
	_sprite.texture = artifact.sprite
	# Sprites stay null until the art pass (feature 10).
	_sprite_placeholder.visible = artifact.sprite == null
	_name_label.text = artifact.name
	_era_label.text = artifact.era
	_blurb_label.text = artifact.blurb
	show()


func _on_close_button_pressed() -> void:
	hide()
