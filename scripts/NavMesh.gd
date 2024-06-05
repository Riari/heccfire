extends NavigationRegion3D

@onready var mesh_instance: MeshInstance3D = get_parent().get_node("QodotMap/entity_0_worldspawn/entity_0_mesh_instance")

func _ready():
	self.navigation_mesh.clear_polygons()
	self.navigation_mesh.create_from_mesh(mesh_instance.mesh)
	self.bake_navigation_mesh(false)
