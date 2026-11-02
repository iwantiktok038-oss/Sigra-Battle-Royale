extends CharacterBody3D
@export var speed := 2.4
var target: Node3D
var health := 100
var gravity := 18.0

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        var main = get_tree().current_scene
        if main and main.has_method("add_score"):
            main.add_score(100)
        queue_free()

func _physics_process(delta):
    if not is_instance_valid(target):
        return
    if not is_on_floor():
        velocity.y -= gravity*delta
    var offset = target.global_position - global_position
    offset.y = 0
    if offset.length() > 2.0:
        var dir = offset.normalized()
        velocity.x = dir.x*speed
        velocity.z = dir.z*speed
        rotation.y = atan2(dir.x,dir.z)
    else:
        velocity.x = move_toward(velocity.x,0,speed*delta)
        velocity.z = move_toward(velocity.z,0,speed*delta)
    move_and_slide()
