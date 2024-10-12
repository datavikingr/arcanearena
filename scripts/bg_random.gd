extends Sprite2D

# Array of file paths to your background images
var background_images = [
	"res://assets/bgs/autumnruins.png",
	"res://assets/bgs/bg_forest.png",
	"res://assets/bgs/doublefull.png",
	"res://assets/bgs/excavation.png",
	"res://assets/bgs/glade.png",
	"res://assets/bgs/goldentowers.png",
	"res://assets/bgs/jungle.png",
	"res://assets/bgs/mossyvalley.png",
	"res://assets/bgs/observatory.png",
	"res://assets/bgs/peaks.png",
	"res://assets/bgs/plainsoutskirts.png",
	"res://assets/bgs/storm.png",
	"res://assets/bgs/templetoforgottengods.png",
	"res://assets/bgs/thedoorsbetwixtworlds.png",
	"res://assets/bgs/twilight.png",
	"res://assets/bgs/twincastles.png",
	"res://assets/bgs/verdantdale.png",
	"res://assets/bgs/waterwyrms.png"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	var random_index = randi() % background_images.size() # Get a random index
	var background = load(background_images[random_index]) # Load the texture from the random image
	self.texture = background # Set the texture to the sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
