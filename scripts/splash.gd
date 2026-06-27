extends Control

# Duration of splash in seconds
const SPLASH_TIME = 2.0

func _ready() -> void:
    # Fade in logo (optional) using AnimationPlayer if present
    if has_node("Anim"):
        $Anim.play("fade_in")
    # Set a timer to transition
    var timer = get_tree().create_timer(SPLASH_TIME)
    timer.timeout.connect(_go_to_home)
    # Allow user to skip by any input
    get_viewport().gui_input.connect(_on_input_skip)

func _go_to_home() -> void:
    get_tree().change_scene_to_file("res://scenes/home_menu.tscn")

func _on_input_skip(event: InputEvent) -> void:
    if event is InputEventMouseButton or event is InputEventScreenTouch:
        _go_to_home()
