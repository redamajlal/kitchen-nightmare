extends RigidBody2D
class_name FoodItem

enum FoodType { BURGER, PIZZA, SUSHI, DONUT, EXPLOSIVE }

@export var food_type: FoodType = FoodType.BURGER
var point_value: int
@onready var sprite = $Sprite2D
@onready var area = $Area2D
@export var bottom_limit: float = 500.0

# Food data - points and textures
var food_data = {
	FoodType.BURGER: {"points": 20, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0091.png")},
	FoodType.PIZZA: {"points": 25, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0106.png")},
	FoodType.SUSHI: {"points": 30, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0103.png")},
	FoodType.DONUT: {"points": 15, "texture": preload("res://assets/kenney_pixel-platformer-food-expansion/Tiles/tile_0014.png")},
	FoodType.EXPLOSIVE: {"points": -100, "texture": preload("res://assets/sprites/explosive.png")}
}

func _ready():
	food_type = FoodType.values()[randi() % FoodType.size()]
	setup_food()
	area.body_entered.connect(_on_player_collision)

func setup_food():
	var data = food_data[food_type]
	point_value = data.points
	sprite.texture = data.texture
	
	# Make all food the same size
	sprite.scale = Vector2(3.0, 3.0)	
	print("Setup food: ", FoodType.keys()[food_type], " with ", point_value, " points")

func _physics_process(_delta):
	if position.y > bottom_limit:
		var game = get_tree().get_first_node_in_group("game_manager")
		if game and game.has_method("add_score"):
			game.add_score(-point_value)  # subtract instead of add
			show_points_popup(-point_value)  # show red negative points
		queue_free()



func _on_player_collision(body):
	if body.name == "Player":
		var game = get_tree().get_first_node_in_group("game_manager")
		if game and game.has_method("add_score"):
			game.add_score(point_value)
			show_points_popup(point_value)  # Show points
		
		queue_free()

func show_points_popup(points):
	var label = Label.new()
	
	# Add "+" if positive, leave as is if negative
	if points > 0:
		label.text = "+" + str(points)
	else:
		label.text = str(points)

	# Green for positive, red for negative
	label.modulate = Color.GREEN if points > 0 else Color.RED

	get_parent().add_child(label)
	label.position = position + Vector2(0, -30)
	
	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -50), 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)

	# Timer attached to label
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	label.add_child(timer)
	timer.start()
	timer.timeout.connect(func(): label.queue_free())
