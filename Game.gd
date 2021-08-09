extends Node2D

var map = [
	[0,1,0,1,0],
	[1,3,1,1,0],
	[0,0,2,3,1],
	[0,0,1,0,1],
	[0,3,1,1,1],
]

var visual_map = [
	[0,0,0,0,0],
	[0,0,0,0,0],
	[0,0,2,0,0],
	[0,0,0,0,0],
	[0,0,0,0,0],
]

var room_colors = {
	0 : null,
	1 : Color(1,0,0),
	2 : Color(0,1,0),
	3 : Color(1,1,1)
}

var player_pos = Vector2()

func _ready():
	for line in range(map.size()):
		for colum in range(map[line].size()):
			if map[line][colum]==2:
				player_pos = Vector2(colum,line)

	next_move_decision()



func _draw():
	for line in range(visual_map.size()):
		for colum in range(visual_map[line].size()):
			if visual_map[line][colum]!=0:
				var block_pos = Vector2(colum*175,line*175)
				var block_size = Vector2(50,50)
				draw_rect(Rect2(block_pos,block_size),room_colors[visual_map[line][colum]])
				for i in [Vector2.UP,Vector2.DOWN,Vector2.RIGHT,Vector2.LEFT]:
					if line + i.y < 0 or line + i.y >= map.size():continue
					if colum + i.x < 0 or colum + i.x >= map[line].size():continue
					if map[line+i.y][colum+i.x]==0:continue

					draw_line(block_pos+block_size/2+i*45,block_pos+block_size/2+i*90,
					Color(.5,.5,.5),15)

	var block_offset = Vector2(175,175)
	var block_size = Vector2(50,50)
	draw_circle(player_pos*block_offset + block_size/2,50,Color(0,0,0))
	draw_circle(player_pos*block_offset + block_size/2,40,Color(1,1,0))

func _process(delta):
	var block_offset = Vector2(175,175)
	var block_size = Vector2(50,50)
	$Camera2D.position = player_pos*block_offset + block_size/2
	update()

func dialogic_signal(argument):
	if argument=="Move_Right":
		_move(Vector2.RIGHT)
	if argument=="Move_Left":
		_move(Vector2.LEFT)
	if argument=="Move_Up":
		_move(Vector2.UP)
	if argument=="Move_Down":
		_move(Vector2.DOWN)

func _move(direction: Vector2):
	if $Tween.is_active():return
	var block_offset = Vector2(175,175)
	var block_size = Vector2(50,50)
	var next_pos = player_pos + direction
	if next_pos.y < 0 or next_pos.y >= map.size():return
	if next_pos.x < 0 or next_pos.x >= map[next_pos.y].size():return
	if map[next_pos.y][next_pos.x]==0:return
	visual_map[next_pos.y][next_pos.x] = map[next_pos.y][next_pos.x]
	$Tween.interpolate_property(self,"player_pos",player_pos,next_pos,0.25)
	$Tween.start()

func _on_tween_all_completed():
	# PLAYER REACH NEXT ROOM
	# SOMETHING HAPPEN
	# TO GAME THE VALUE OF THE ROOM DO -> map[player_pos.y][player_pos.x]

	next_move_decision()


func next_move_decision():
	var dialog = Dialogic.start("DecideMove")
	add_child(dialog)
	dialog.connect("dialogic_signal",self,"dialogic_signal")

	var directions = {
		Vector2.UP : "up_available",
		Vector2.DOWN : "down_available",
		Vector2.RIGHT : "right_available",
		Vector2.LEFT : "left_available"
	}

	for direction in [Vector2.UP,Vector2.DOWN,Vector2.RIGHT,Vector2.LEFT]:
		var next_pos = player_pos + direction
		if next_pos.y < 0 or next_pos.y >= map.size():continue
#		print("line OK")
		if next_pos.x < 0 or next_pos.x >= map[next_pos.y].size():continue
#		print("colum OK")
		if map[next_pos.y][next_pos.x]==0:continue
#		print("value OK")
		
		Dialogic.set_variable(directions[direction],1)
#		print(Dialogic.get_variable(directions[direction]))



