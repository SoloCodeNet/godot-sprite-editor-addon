tool
extends Control
onready var sc    := $scroll/hb/vb2/sc
onready var center:= $scroll/hb/vb2/sc/center
onready var back  := $scroll/hb/vb2/sc/center/back
onready var top   := $scroll/hb/vb2/sc/center/top
onready var slid  := $scroll/hb/vb2/hb2/HSlider
onready var lblzm := $scroll/hb/vb2/hb2/zoom
onready var lblx  := $scroll/hb/vb2/hb2/size_x
onready var lbly  := $scroll/hb/vb2/hb2/size_y
onready var pal   := $scroll/hb/vb/pal
onready var palist:= $scroll/hb/vb/pal_list
onready var colpic:= $scroll/hb/vb/ColorPickerButton
onready var cursor = $scroll/hb/vb2/sc/center/top/cursor

var cursor_visu:= false
var pal_path:= "res://addons/pixel_ever/pal/"
var sprite_exist:= false
var sprite_path := ""
var zoom := 8
var size:=Vector2(32,32)
#var img:Image
#var tex:Texture
var clickL := false
var clickR := false
var col1:= Color.black
var col2:= Color.transparent
var old_color:= Color.pink
var idtool:= 0
var old_pos:=-Vector2.ONE
var path_file:=""
var dial: FileDialog
var grab:= false
var pop
signal saved

var draw  = load("res://addons/pixel_ever/draw.png")
var pick  = load("res://addons/pixel_ever/pick.png")
var drag  = load("res://addons/pixel_ever/drag.png")
var repl  = load("res://addons/pixel_ever/fill.png")
var fill  = load("res://addons/pixel_ever/buck.png")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_B:
			$scroll/hb/vb/Button.pressed=true
		if event.scancode == KEY_I:
			$scroll/hb/vb/Button2.pressed=true
		if event.scancode == KEY_G:
			$scroll/hb/vb/Button3.pressed=true

func _ready() -> void:
	pop = palist.get_popup()
	pop.connect("index_pressed", self,"_on_pallist_index_pressed")
	load_palettes()
	top.connect("gui_input", self, "_on_top_gui_input")
	apply_size( size, zoom)

func _on_pallist_index_pressed(index:int)->void:
	palist.text = pop.get_item_text(index).rstrip(".png")
	var txt = pop.get_item_text(index)
	pal.texture = load(pal_path + txt)
	print(index)
	
func load_palettes():
	pop.clear()
	var dir = Directory.new()
	dir.open(pal_path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".png"):
			pop.add_radio_check_item(file)

	dir.list_dir_end()

func apply_size(size:Vector2, zoom:int)->void:
	if slid.value != zoom:slid.value = zoom
	lblzm.text = "Zoom: " + str(zoom)
	center.rect_size = size * zoom
	center.rect_min_size= size * zoom
	top.rect_size = size
	top.rect_scale = Vector2(zoom, zoom)
	top.change_ratio(zoom)
	back.rect_size = size
	back.rect_scale = Vector2(zoom, zoom)
	lblx.text = str(floor(size.x ))
	lbly.text = str(floor(size.y ))

func _on_top_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		grab =  event.pressed and event.button_index == BUTTON_MIDDLE
		clickL = event.pressed and event.button_index == BUTTON_LEFT
		clickR = event.pressed and event.button_index == BUTTON_RIGHT

		if event.pressed and event.button_index == BUTTON_WHEEL_DOWN:
			zoom +=1
			slid.value = zoom
			apply_size(size,zoom)
		if event.pressed and event.button_index == BUTTON_WHEEL_DOWN:
			zoom -=1
			slid.value = zoom
			apply_size(size,zoom)
		
	if event is InputEventMouse:
		cursor.rect_position = event.position + Vector2(0, -32)

	if clickL and event is InputEventMouse:
		if idtool == 0:
			draw_pixel( event.position, col1)
		if idtool == 1:
			col1 = pick_color(event.position)
			colpic.color = col1
		if idtool == 2:
			replace_color(event.position)
		if idtool == 3:
			var old = pick_color(event.position)
			var img = top.texture.get_data()
			var sz  = img.get_size()
			img.lock()
			var exact_pos= Vector2(floor(event.position.x / zoom), floor(event.position.y / zoom))
			floodfill(img,exact_pos, old)
			img.unlock()
			apply_img_to_texture(img)

	if clickR and event is InputEventMouse:
		if idtool == 0:
			draw_pixel( event.position, col2)
			
	if event is InputEventMouseMotion:
		
		var x = str(floor(event.position.x / zoom)+1.0)
		var y = str(floor(event.position.y / zoom)+1.0)
		$scroll/hb/vb/Label2.text = 'pos X: ' + x + ', Y: ' + y
		if grab:
			sc.scroll_horizontal-= event.relative.x
			sc.scroll_vertical  -= event.relative.y

func replace_color(pos:Vector2)->void:
	var img = top.texture.get_data()
	img.lock()
	var old = img.get_pixelv(pos / zoom)
	for x in  img.get_size().x:
		for y in img.get_size().y:
			if img.get_pixel(x,y)== old:
				img.set_pixel(x,y, col1)
	img.unlock()
	apply_img_to_texture(img)
	
func apply_img_to_texture(img)->void:
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	texture.flags = texture.FLAG_MIPMAPS
	top.set_texture(texture)
	
	
func floodfill(img:Image,pos:Vector2, old_color:Color)->void:
	var sz  = img.get_size() - Vector2.ONE
	if pos.x <0 or pos.x >sz.x or pos.y < 0 or pos.y > sz.y:return
	var test = img.get_pixelv(pos)
	if test!= old_color:return 
	img.set_pixelv(pos, col1)
	floodfill(img,Vector2(pos.x+1, pos.y), old_color)
	floodfill(img,Vector2(pos.x, pos.y+1), old_color)
	floodfill(img,Vector2(pos.x-1, pos.y), old_color)
	floodfill(img,Vector2(pos.x, pos.y-1), old_color)

func pick_color(pos)->Color:
	var col:Color
	var i = top.texture.get_data()
	i.lock()
	col = i.get_pixelv(pos / zoom)
	i.unlock()
	return  col
	
func _on_pal_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			var i = pal.get_texture().get_data()
			i.lock()
			col1 = i.get_pixelv(event.position)
			i.unlock()
			colpic.color = col1
			cursor.modulate = col1

func draw_pixel(pos, color):
	var p = Vector2(floor(pos.x), floor(pos.y))
	if p != old_pos or color != old_color:
		old_pos = p
		old_color = color
		var img = top.texture.get_data()
		img.lock()
		img.set_pixelv(pos/ zoom, color)
		img.unlock()
		apply_img_to_texture(img)

func _on_ColorPickerButton_color_changed(color: Color) -> void:
	col1 = color
	cursor.modulate = col1

func free():
	queue_free()
	
func change_path_file(_path:String,existing:bool)->void:
	top.texture = load(_path)
	sprite_exist = existing
	sprite_path = _path
	var ref_image = top.texture.get_data()
	size = ref_image.get_size()
	apply_size(size, zoom )
	
func _on_tool_toggled(button_pressed: bool, extra_arg_0: int) -> void:
	if button_pressed:
		idtool = extra_arg_0
		match idtool:
			0:cursor.texture = draw 
			1:cursor.texture = pick
			2:cursor.texture = repl
			3:cursor.texture = fill


func _on_HSlider_value_changed(value: float) -> void:
	zoom = value
	apply_size(size, zoom)

func _on_FileDialog_confirmed() -> void:
	var file = $FileDialog.current_path
	if ! file.ends_with(".png"):
		file+=".png"

	var image = top.get_texture().get_data()
	image.crop(size,size)
	image.save_png(file)
	emit_signal("saved", file)

func _on_btn_save_pressed() -> void:
	if not sprite_exist:
		$FileDialog.popup_centered()
	else:
		var image = top.get_texture().get_data()
		image.crop(size.x,size.y)
		image.save_png(sprite_path)
		emit_signal("saved", sprite_path)

func _on_top_mouse_entered() -> void:
	cursor.visible = true

func _on_top_mouse_exited() -> void:
	cursor.visible = false

func _on_resize_pressed() -> void:
	if lblx.text.is_valid_integer() and lbly.text.is_valid_integer():
		var x = int(lblx.text)
		var y = int(lbly.text)
		var img = top.get_texture().get_data()
		img.crop(x,y)
		apply_img_to_texture(img)
		size = Vector2(x,y)
		apply_size(size,zoom)
	else:
		lblx.text = str(size.x)
		lbly.text = str(size.y)


func _on_grid_toggled(button_pressed: bool) -> void:
	top.is_activ = button_pressed
