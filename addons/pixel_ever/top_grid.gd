@tool
extends TextureRect
var is_activ:bool = true :set=set_activ
var ratio:int = 8 :set=change_ratio
var grid_color:Color = Color.WHITE :set=set_color

func _ready() -> void:
	grid_color.a = 0.2
	queue_redraw()
	
func set_activ(value)->void:
	is_activ = value
	queue_redraw()

func set_color(value:Color)->void:
	grid_color = value
	queue_redraw()
	
func change_ratio(value:int)->void:
	ratio = value
	queue_redraw()
	
func _draw() -> void:
	if not is_activ:return
	for x in range(1, size.x / ratio):
		draw_line(Vector2(x * ratio,0), Vector2(x* ratio, size.y),grid_color,1)
	for y in range(1, size.y / ratio):
		draw_line(Vector2(0, y* ratio), Vector2(size.x, y* ratio),grid_color,1)
