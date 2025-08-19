extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sensitivity = 0.0015

enum shapes { Line, Circle, Square, Triangle }

var draw_distance : float = 2

var line : ImmediateMesh

var currently_drawing : bool = false
var drawings_mesh : Array[MeshInstance3D] = []
var drawings_points = []
var drawings_shape : Array[shapes]

@onready var LineMat = preload("res://Art/Materials/TestLineMaterial.tres") 

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				print("MouseButtonDown")
				start_draw()
				
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				print("MouseButtonUp")
				stop_draw()

## Creates new MeshInstance3D with parameters, and sets 'currently_drawing' to true
func start_draw():
	drawings_points.append([]) # creates a new array in drawings_points
	
	currently_drawing = true
	
	var line_mesh = MeshInstance3D.new()
	get_tree().current_scene.add_child(line_mesh)
	line = ImmediateMesh.new()
	line_mesh.mesh = line
	
	
func stop_draw():
	currently_drawing = false
	# Call Shape Detection Function on most recently drawn line "drawings_points.back()"


func _physics_process(delta: float) -> void:
	#region Escape Quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	#endregion
	#region Movement Handling
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("MOVE-Left", "MOVE-Right", "MOVE-Forward", "MOVE-Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
	#endregion
	#region Drawing
	if currently_drawing:
		
		var space_state = get_world_3d().direct_space_state
		var from = camera.global_position
		var to = camera.global_position + (-camera.global_transform.basis.z * draw_distance)
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = (1 << 1)
		var result = space_state.intersect_ray(query)
		if result:
			#print("Adding point at " + str(result.position) )
			
			
			drawings_points.back().append(result.position)
			line.clear_surfaces()
			line.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, LineMat)
			for x in drawings_points.back():
				line.surface_add_vertex(x)
			line.surface_end()
		else:
			stop_draw()
		
	#endregion
