@tool
extends EditorPlugin
var spr:Sprite2D
var dock 
var eds = get_editor_interface().get_selection()

func _enter_tree() -> void:
	eds.selection_changed.connect(_on_selection_changed)
	dock = preload("res://addons/pixel_ever/sprite_editor.tscn").instantiate()
	add_control_to_bottom_panel(dock,"Sprite_Editor")
	dock.saved.connect(set_path_file)

func _exit_tree() -> void:
#	remove_control_from_docks(dock)
	remove_control_from_bottom_panel(dock)
	dock.free()
	
func _on_selection_changed():
	var selected = eds.get_selected_nodes()
	if selected.size()==1:
		if selected[0] is Sprite2D:
			spr = selected[0]
			if spr.texture!= null:
				var path_to_file = spr.texture.get_path()
				dock.change_path_file(path_to_file,true)
			else:
				dock.change_path_file("res://addons/pixel_ever/empty.png",false)
			dock.visible = true
		else:
			dock.visible= false
			
func set_path_file(path)->void:
#	get_editor_interface().get_resource_filesystem().update_file(path)
	get_editor_interface().get_resource_filesystem().scan()
	await(get_tree().create_timer(0.1).timeout)
	var selected = eds.get_selected_nodes()
	if selected.size()==1:
		if selected[0] is Sprite2D:
			selected[0].texture = load(path)
