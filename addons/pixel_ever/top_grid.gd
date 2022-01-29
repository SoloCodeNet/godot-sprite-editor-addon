tool
extends TextureRect
var is_activ:= true setget set_activ
export(int)var ratio:=8 setget change_ratio
export(Color)var grid_color:=Color.white setget set_color

func _ready() -> void:
	grid_color.a = 0.2
	update()
	
func set_activ(value)->void:
	is_activ = value
	update()

func set_color(value:Color)->void:
	grid_color = value
	update()
	
func change_ratio(value:int)->void:
	ratio = value
	update()
	
func _draw() -> void:
	if not is_activ:return
	for x in range(1, rect_size.x / ratio):
		draw_line(Vector2(x * ratio,0), Vector2(x* ratio, rect_size.y),grid_color,1)
	for y in range(1, rect_size.y / ratio):
		draw_line(Vector2(0, y* ratio), Vector2(rect_size.x, y* ratio),grid_color,1)
