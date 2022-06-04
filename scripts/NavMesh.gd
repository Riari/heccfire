extends Navigation

onready var nav_mesh_instance: NavigationMeshInstance = $NavigationMeshInstance
onready var mesh_instance: MeshInstance = get_parent().get_node("QodotMap/entity_0_worldspawn/entity_0_mesh_instance")

func _ready():
	nav_mesh_instance.navmesh.create_from_mesh(mesh_instance.mesh)
