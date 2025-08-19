extends MeshInstance3D

@onready var LineMat = preload("res://Art/Materials/TestLineMaterial.tres") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var line = ImmediateMesh.new()
	line.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, LineMat)
	line.surface_add_vertex(Vector3(0, 0, 0))
	line.surface_add_vertex(Vector3(1, 0, 0))
	line.surface_add_vertex(Vector3(1, 1, 0))
	line.surface_add_vertex(Vector3(0, 1, 1))
	line.surface_add_vertex(Vector3(0, 0, 1))
	line.surface_add_vertex(Vector3(0, 0, 0))
	

	
	line.surface_end()
	
	mesh = line


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
