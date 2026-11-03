extends CharacterBody3D
@export var speed := 7.0
@export var jump_velocity := 5.5
@export var gravity := 18.0
var camera: Camera3D
var actions = {"left":false,"right":false,"forward":false,"back":false,"jump":false,"fire":false}
var cooldown := 0.0

func set_action(action: String, pressed: bool):
    if actions.has(action):
        actions[action] = pressed

func _physics_process(delta):
    cooldown = maxf(0.0,cooldown-delta)
    var x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    var z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    x += float(actions["right"]) - float(actions["left"])
    z += float(actions["back"]) - float(actions["forward"])
    var dir = Vector3(x,0,z).normalized()
    velocity.x = dir.x * speed if dir.length() > 0.05 else move_toward(velocity.x,0,speed*5*delta)
    velocity.z = dir.z * speed if dir.length() > 0.05 else move_toward(velocity.z,0,speed*5*delta)
    if dir.length() > 0.05:
        rotation.y = atan2(dir.x,dir.z)
    if not is_on_floor():
        velocity.y -= gravity*delta
    elif Input.is_action_just_pressed("ui_accept") or actions["jump"]:
        velocity.y = jump_velocity
    if (Input.is_key_pressed(KEY_F) or actions["fire"]) and cooldown <= 0:
        _fire()
        cooldown = 0.35
    move_and_slide()

func _fire():
    if camera == null:
        return
    var start = camera.global_position
    var finish = start + (-camera.global_transform.basis.z * 60.0)
    var query = PhysicsRayQueryParameters3D.create(start,finish)
    query.exclude = [self]
    var hit = get_world_3d().direct_space_state.intersect_ray(query)
    if hit and hit.collider and hit.collider.has_method("take_damage"):
        hit.collider.take_damage(25)
