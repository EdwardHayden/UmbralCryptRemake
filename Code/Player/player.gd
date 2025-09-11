extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sensitivity = 0.0015

var interact_distance : float = 2

enum shapes { Line, Circle, Square, Triangle }

var draw_distance : float = 2

var line_width : float = 0.01

var line : ImmediateMesh

var currently_drawing : bool = false
var drawings_mesh : Array[MeshInstance3D] = []
var drawings_points = []
var drawings_normals = []
var drawings_shape : Array[shapes]

@onready var LineMat = preload("res://Art/Materials/TestLineMaterial.tres") 

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	PlayerManager.add_player(0, "Edward")
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

func _input(event: InputEvent) -> void:
	# Input handling for INTERACT action (pressing 'E')
	if event.is_action_pressed("INTERACT"):
		# Logic for Raycasting forward
		var space_state = get_world_3d().direct_space_state
		var from = camera.global_position
		var to = camera.global_position + (-camera.global_transform.basis.z * interact_distance)
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = (1 << 2) 
		var result = space_state.intersect_ray(query)
		if result:
			result.collider.owner.on_interact(0)
	
## Creates new MeshInstance3D with parameters, and sets 'currently_drawing' to true
func start_draw():
	drawings_points.append([]) # creates a new array in drawings_points
	drawings_normals.append([])
	currently_drawing = true
	
	var line_mesh = MeshInstance3D.new()
	get_tree().current_scene.add_child(line_mesh)
	line = ImmediateMesh.new()
	line_mesh.mesh = line
	
	
func stop_draw():
	currently_drawing = false
	# Call Shape Detection Function on most recently drawn line "drawings_points.back()"
	shape_detection(drawings_points.back())
	

func flatten(A):
	var min_x: float = INF
	var max_x: float = 0
	var min_y: float = INF
	var max_y: float = 0
	var min_z: float = INF
	var max_z: float = 0
	for i in range(0, len(A)):
		if A[i].x < min_x:
			min_x = A[i].x
		if A[i].x > max_x:
			max_x = A[i].x
		if A[i].y < min_y:
			min_y = A[i].y
		if A[i].y > max_y:
			max_y = A[i].y
		if A[i].z < min_z:
			min_z = A[i].z
		if A[i].z > max_z:
			max_z = A[i].z
	var x_deviance = max_x-min_x
	var y_deviance = max_y-min_y
	var z_deviance = max_z-min_z
	var flattened_points = []
	if x_deviance < y_deviance && x_deviance < z_deviance:
		for i in range(0, len(A)):
			flattened_points.append(Vector2(A[i].y, A[i].z))
	if y_deviance < x_deviance && y_deviance < z_deviance:
		for i in range(0, len(A)):
			flattened_points.append(Vector2(A[i].x, A[i].z))
	if z_deviance < x_deviance && z_deviance < y_deviance:
		for i in range(0, len(A)):
			flattened_points.append(Vector2(A[i].x, A[i].y))
	return flattened_points
	

func scale_to_square(A, size):
	var min_x: float = INF
	var max_x: float = 0
	var min_y: float = INF
	var max_y: float = 0
	
	for i in range(0, len(A)):
		if A[i].x < min_x:
			min_x = A[i].x
		if A[i].x > max_x:
			max_x = A[i].x
		if A[i].y < min_y:
			min_y = A[i].y
		if A[i].y > max_y:
			max_y = A[i].y
		
	var x_deviance = max_x-min_x
	var y_deviance = max_y-min_y
	
	var new_points = []
	for i in range(0, len(A)):
		new_points.append(Vector2(A[i].x * (size/x_deviance), A[i].y * (size/y_deviance)))
	return new_points

func centroid(A):
	var sum = Vector2(0, 0)
	for i in range(0, len(A)):
		A[i] = A[i]*100
		sum += A[i]
	return sum/len(A)

func translate_to_origin(A):
	var c = centroid(A)
	c = Vector2(c.x-320, c.y-160) # <-- centres in the middle of the screen for debug
	var new_points = []
	for i in range(0, len(A)):
		
		new_points.append(Vector2(A[i].x - c.x, A[i].y - c.y))
		
	
	return new_points
	
func shape_debug(points):
	$ShapeDebug/Line2D.points = points

func shape_detection(query_points):
	shape_debug(translate_to_origin(flatten(query_points)))

func resample(points, n):
	pass

func path_length(A):
	var d : float = 0
	for i in range(1, len(A)):
		pass

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
			
			drawings_points.back().append(result.position)
			drawings_normals.back().append(result.normal)

			var points = drawings_points.back()
			var normals = drawings_normals.back()
			if points.size() > 3:
				line.clear_surfaces()
				line.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, LineMat)
				for x in range(points.size()-1):
					line.surface_set_normal(normals[x])
					line.surface_add_vertex(points[x] + (points[x] - points[x+1]).normalized().cross(-normals[x]).normalized() * (line_width - ((x%2) * 2)*line_width) + normals[x]*0.0001)
				line.surface_end()
		else:
			stop_draw()
		
	#endregion
	#region Player Manager Updates
	PlayerManager.players[0].position = global_position
	#endregion
