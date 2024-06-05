extends Navigation

@onready var nav_mesh_instance: NavigationRegion3D = $NavigationRegion3D
@onready var mesh_instance: MeshInstance3D = get_parent().get_node("QodotMap/entity_0_worldspawn/entity_0_mesh_instance")

func _ready():
	nav_mesh_instance.navigation_mesh.create_from_mesh(mesh_instance.mesh)
