extends Node3D
const PLAYER = preload("res://scripts/Player.gd")
const BOT = preload("res://scripts/Bot.gd")
var player
var bots := []
var score := 0
var hud

func _ready():
    var world = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.035, 0.045, 0.065)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.7, 0.75, 0.85)
    world.environment = env
    add_child(world)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    add_child(sun)
    _box("Ground", Vector3(0,-0.5,0), Vector3(50,1,50), Color(0.16,0.22,0.19))
    _box("NorthWall", Vector3(0,1,-25), Vector3(50,2,1), Color(0.25,0.28,0.34))
    _box("SouthWall", Vector3(0,1,25), Vector3(50,2,1), Color(0.25,0.28,0.34))
    _box("EastWall", Vector3(25,1,0), Vector3(1,2,50), Color(0.25,0.28,0.34))
    _box("WestWall", Vector3(-25,1,0), Vector3(1,2,50), Color(0.25,0.28,0.34))
    var covers = [Vector3(-8,1,-7),Vector3(8,1,-8),Vector3(-10,1,8),Vector3(10,1,8),Vector3(0,1,-13),Vector3(0,1,13)]
    for i in range(covers.size()):
        _box("Cover_%d" % i, covers[i], Vector3(3,2,3), Color(0.3,0.33,0.38))
    _make_player()
    _make_bots()
    _make_hud()

func _box(label, pos, size, color):
    var body = StaticBody3D.new()
    body.name = label
    body.position = pos
    add_child(body)
    var mesh = MeshInstance3D.new()
    var shape_mesh = BoxMesh.new()
    shape_mesh.size = size
    mesh.mesh = shape_mesh
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    body.add_child(mesh)
    var collision = CollisionShape3D.new()
    var box = BoxShape3D.new()
    box.size = size
    collision.shape = box
    body.add_child(collision)

func _make_player():
    player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PLAYER)
    player.position = Vector3(0,1,5)
    add_child(player)
    _character_visual(player, Color(0.08,0.58,1.0))
    var pivot = Node3D.new()
    pivot.name = "CameraPivot"
    pivot.position.y = 1.5
    player.add_child(pivot)
    var cam = Camera3D.new()
    cam.position = Vector3(0,2.2,6)
    cam.rotation_degrees.x = -12
    cam.current = true
    pivot.add_child(cam)
    player.camera = cam

func _character_visual(parent, color):
    var mesh = MeshInstance3D.new()
    var capsule = CapsuleMesh.new()
    capsule.radius = 0.45
    capsule.height = 1.8
    mesh.mesh = capsule
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    mesh.position.y = 0.9
    parent.add_child(mesh)
    var collision = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.radius = 0.45
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    parent.add_child(collision)

func _make_bots():
    var positions = [Vector3(-12,1,-12),Vector3(12,1,-12),Vector3(-13,1,12),Vector3(13,1,12)]
    for i in range(positions.size()):
        var bot = CharacterBody3D.new()
        bot.name = "Bot_%d" % (i+1)
        bot.set_script(BOT)
        bot.position = positions[i]
        bot.target = player
        add_child(bot)
        _character_visual(bot, Color(1,0.2,0.13))
        bots.append(bot)

func _make_hud():
    hud = CanvasLayer.new()
    add_child(hud)
    var title = Label.new()
    title.text = "WANZ XRY  |  BATTLE ROYALE"
    title.position = Vector2(22,15)
    title.add_theme_font_size_override("font_size",25)
    title.add_theme_color_override("font_color",Color(1,0.2,0.13))
    hud.add_child(title)
    var info = Label.new()
    info.name = "Info"
    info.position = Vector2(22,55)
    info.add_theme_font_size_override("font_size",18)
    hud.add_child(info)
    _button("◀", Vector2(25,540), "left")
    _button("▶", Vector2(185,540), "right")
    _button("▲", Vector2(105,460), "forward")
    _button("▼", Vector2(105,620), "back")
    _button("JUMP", Vector2(1010,570), "jump")
    _button("FIRE", Vector2(1130,490), "fire")

func _button(label, pos, action):
    var b = Button.new()
    b.text = label
    b.position = pos
    b.size = Vector2(90,70)
    b.add_theme_font_size_override("font_size",19)
    b.modulate = Color(1,0.3,0.22,0.9)
    b.button_down.connect(func(): player.set_action(action,true))
    b.button_up.connect(func(): player.set_action(action,false))
    hud.add_child(b)

func _process(_delta):
    var left = 0
    for b in bots:
        if is_instance_valid(b):
            left += 1
    var info = hud.get_node_or_null("Info")
    if info:
        info.text = "BOTS LEFT: %d   |   SCORE: %d" % [left,score]

func add_score(points):
    score += points
