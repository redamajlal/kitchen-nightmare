extends Node2D

var current_score: int = 0

@onready var spawn_timer = $SpawnTimer
@onready var score_label = $UI/ScoreLabel
@onready var difficulty_timer = $DifficultyTimer

# Food types with different point values
var food_data = {
	"BURGER": {"points": 20, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0091.png")},
	"PIZZA": {"points": 25, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0106.png")},
	"SUSHI": {"points": 30, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0103.png")},
	"DONUT": {"points": 15, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0014.png")}
}

var food_scene = preload("res://scenes/food_item.tscn")
var spawn_width = 1024  # Your screen width

var base_gravity = 0.1
var current_gravity = 0.1
var gravity_increase = 0.1

func _ready():
	add_to_group("game_manager")
	
	# Setup spawner
	spawn_timer.timeout.connect(_spawn_food)
	spawn_timer.wait_time = 1.5
	spawn_timer.start()
	
	# Setup difficulty timer (30 seconds)
	difficulty_timer.timeout.connect(_increase_difficulty)
	difficulty_timer.wait_time = 30.0
	difficulty_timer.start()
	
	# Initialize score
	current_score = 0
	update_score_display()

func _spawn_food():
	var food = food_scene.instantiate()
	
	# Random food type
	var food_types = ["BURGER", "PIZZA", "SUSHI", "DONUT"]
	var random_type = food_types[randi() % food_types.size()]
	var data = food_data[random_type]
	
	# Set food properties
	food.food_type = random_type
	food.gravity_scale = current_gravity
	food.point_value = data.points
	# food.food_texture = data.texture
	
	# Random spawn position (top of screen)
	food.position.x = randi_range(50, spawn_width - 50)
	food.position.y = -50
	
	# Add to scene
	add_child(food)
	
func _increase_difficulty():
		current_gravity += gravity_increase
		print("Difficulty increased! New gravity: ", current_gravity)
	
func add_score(points: int):
	current_score += points
	update_score_display()
	
	if current_score <= 0:
		game_over()

func update_score_display():
	print("Score: ", current_score)
	if score_label:
		score_label.text = "Score: " + str(current_score)

func game_over():
	print("Game Over! Final Score: ", current_score)
	get_tree().change_scene_to_file("res://scenes/gameover_menu.tscn")

func _on_score_changed(new_score):
	score_label.text = "Score: " + str(new_score)
