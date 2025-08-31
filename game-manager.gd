extends Node
class_name GameManager

signal score_changed(new_score)
signal game_over_triggered

@export var start_score: int = 0
@export var score_label_path: NodePath  # drag your Label here in the Inspector

var score: int
var score_label: Label = null

func _ready():
	add_to_group("game_manager") # so FoodItem can find us
	score = start_score
	if score_label_path != NodePath():
		score_label = get_node(score_label_path) as Label
	_update_score_ui()

func add_score(amount: int) -> void:
	score += amount
	_update_score_ui()

	if score <= 0:
		score = 0
		game_over()


func _update_score_ui() -> void:
	emit_signal("score_changed", score)
	if score_label:
		score_label.text = str(score)

func game_over() -> void:
	print("GAME OVER TRIGGERED, score = ", score)
	var menu_scene = preload("res://scenes/gameover_menu.tscn")
	var menu = menu_scene.instantiate()
	get_tree().current_scene.add_child(menu)
	# Optional: freeze gameplay
	get_tree().paused = true
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
