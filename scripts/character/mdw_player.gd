extends CharacterBody3D
## Mixed Dark World 0.3.1 - bagimsiz insan hareket denemesi.
## Oyun modelini ve eski 0.2.3 dunya betiklerini degistirmez.

signal model_changed(model_name: String, resource_path: String)

const MODEL_NAMES: Array[String] = ["Diesel", "EMA", "Fatt Tony"]
const MODEL_FILES: Array[String] = ["Diesel.glb", "EMA.glb", "fatt tony.glb"]

@export var walk_speed: float = 2.2
@export var run_speed: float = 5.0
@export var jump_velocity: float = 5.2
@export var ground_acceleration: float = 14.0
@export var air_acceleration: float = 4.0
@export var gravity_force: float = 14.0
@export var mouse_sensitivity: float = 0.0024
@export var character_height_metres: float = 1.76

var selected_model: int = 0
var current_model_name: String = ""
var current_model_path: String = ""
var model_warning: String = ""
var current_animation: String = "Bekleme"

var _visual: Node3D
var _camera_yaw: Node3D
var _camera_pitch: Node3D
var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D
var _bone_bases: Dictionary = {}
var _motion_time: float = 0.0
var _jump_pressed: bool = false

func _ready() -> void:
    floor_snap_length = 0.35
    var shape := CapsuleShape3D.new()
    shape.radius = 0.30
    shape.height = 1.76
    var collider := CollisionShape3D.new()
    collider.name = "GorunmezCarpismaGovdesi"
    collider.shape = shape
    collider.position.y = 0.88
    add_child(collider)

    _visual = Node3D.new()
    _visual.name = "GorunenInsan"
    add_child(_visual)

    _camera_yaw = Node3D.new()
    _camera_yaw.name = "KameraYon"
    _camera_yaw.position.y = 1.48
    add_child(_camera_yaw)
    _camera_pitch = Node3D.new()
    _camera_pitch.name = "KameraEgilim"
    _camera_yaw.add_child(_camera_pitch)
    _camera_pitch.rotation.x = deg_to_rad(-12.0)

    var camera := Camera3D.new()
    camera.name = "UcuncuSahisKamera"
    camera.position = Vector3(0.0, 0.45, 4.3)
    camera.fov = 68.0
    camera.current = true
    _camera_pitch.add_child(camera)

    load_character(0)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _camera_yaw.rotation.y -= event.relative.x * mouse_sensitivity
        _camera_pitch.rotation.x = clampf(
            _camera_pitch.rotation.x - event.relative.y * mouse_sensitivity,
            deg_to_rad(-65.0), deg_to_rad(30.0)
        )
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        elif event.keycode == KEY_C:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        elif event.keycode == KEY_1:
            load_character(0)
        elif event.keycode == KEY_2:
            load_character(1)
        elif event.keycode == KEY_3:
            load_character(2)

func _physics_process(delta: float) -> void:
    var input_direction := Vector2.ZERO
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        input_direction.y += 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        input_direction.y -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        input_direction.x += 1.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        input_direction.x -= 1.0
    input_direction = input_direction.normalized()

    var direction: Vector3 = _camera_yaw.global_basis * Vector3(input_direction.x, 0.0, -input_direction.y)
    direction.y = 0.0
    direction = direction.normalized()
    var running: bool = Input.is_key_pressed(KEY_SHIFT)
    var speed: float = run_speed if running else walk_speed
    var acceleration: float = ground_acceleration if is_on_floor() else air_acceleration

    velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)

    var jump_down: bool = Input.is_key_pressed(KEY_SPACE)
    if is_on_floor():
        if jump_down and not _jump_pressed:
            velocity.y = jump_velocity
        elif velocity.y < 0.0:
            velocity.y = -0.1
    else:
        velocity.y -= gravity_force * delta
    _jump_pressed = jump_down

    move_and_slide()
    if direction.length_squared() > 0.005:
        var target_yaw: float = atan2(-direction.x, -direction.z)
        _visual.rotation.y = lerp_angle(_visual.rotation.y, target_yaw, minf(1.0, 10.0 * delta))

    var moving: bool = Vector2(velocity.x, velocity.z).length() > 0.25
    var desired: String = "jump" if not is_on_floor() else ("run" if moving and running else ("walk" if moving else "idle"))
    _update_animation(desired, delta)

func _find_model_path(filename: String) -> String:
    for path in ["res://Depo/KarakterModel/" + filename, "res://" + filename]:
        if ResourceLoader.exists(path):
            return path
    return ""

func load_character(index: int) -> void:
    if index < 0 or index >= MODEL_FILES.size():
        return
    var found_path: String = _find_model_path(MODEL_FILES[index])
    selected_model = index
    current_model_name = MODEL_NAMES[index]
    current_model_path = found_path
    _animation_player = null
    _skeleton = null
    _bone_bases.clear()
    model_warning = ""

    for old in _visual.get_children():
        _visual.remove_child(old)
        old.queue_free()

    if found_path.is_empty():
        model_warning = "Model bulunamadi: " + MODEL_FILES[index]
        push_warning(model_warning)
        model_changed.emit(current_model_name, current_model_path)
        return

    var packed: Resource = load(found_path)
    if not packed is PackedScene:
        model_warning = "GLB sahne olarak yuklenemedi: " + found_path
        push_warning(model_warning)
        model_changed.emit(current_model_name, current_model_path)
        return

    var instance: Node = (packed as PackedScene).instantiate()
    _visual.add_child(instance)
    if instance is Node3D:
        _normalise_model_height(instance as Node3D)
    _seek_components(instance)
    _cache_procedural_bones()
    if _skeleton == null:
        model_warning = "Istege bagli kemik canlandirmasi yok: iskelet bulunamadi."
    elif _animation_player == null:
        model_warning = "Hazir animasyon yok; kemiklerle deneysel yuruyus kullaniliyor."
    else:
        var named_anims: PackedStringArray = _animation_player.get_animation_list()
        if not _has_suitable_animation(named_anims):
            model_warning = "Hazir yuruyus bulunamadi; kemik canlandirmasi deneniyor."
    model_changed.emit(current_model_name, current_model_path)

func _normalise_model_height(root: Node3D) -> void:
    var meshes: Array[MeshInstance3D] = []
    _collect_meshes(root, meshes)
    var low: float = INF
    var high: float = -INF
    for mesh_node in meshes:
        var box: AABB = mesh_node.get_aabb()
        for bx in [0.0, 1.0]:
            for by in [0.0, 1.0]:
                for bz in [0.0, 1.0]:
                    var pt: Vector3 = box.position + box.size * Vector3(bx, by, bz)
                    var y: float = root.to_local(mesh_node.to_global(pt)).y
                    low = minf(low, y)
                    high = maxf(high, y)
    if low != INF and high - low > 0.01:
        var factor: float = clampf(character_height_metres / (high - low), 0.01, 100.0)
        root.scale = Vector3.ONE * factor
        root.position.y = -low * factor

func _collect_meshes(node: Node, meshes: Array[MeshInstance3D]) -> void:
    if node is MeshInstance3D:
        meshes.append(node as MeshInstance3D)
    for child in node.get_children():
        _collect_meshes(child, meshes)

func _seek_components(node: Node) -> void:
    if _animation_player == null and node is AnimationPlayer:
        _animation_player = node as AnimationPlayer
    if _skeleton == null and node is Skeleton3D:
        _skeleton = node as Skeleton3D
    for child in node.get_children():
        _seek_components(child)

func _has_suitable_animation(names: PackedStringArray) -> bool:
    for label in names:
        var key: String = String(label).to_lower()
        if "walk" in key or "run" in key or "idle" in key:
            return true
    return false

func _matching_animation(kind: String) -> StringName:
    if _animation_player == null:
        return &""
    for label in _animation_player.get_animation_list():
        var key: String = String(label).to_lower()
        if kind in key and not "start" in key and not "stop" in key:
            return StringName(label)
    return &""

func _update_animation(kind: String, delta: float) -> void:
    current_animation = {"idle":"Bekleme", "walk":"Yurume", "run":"Kosma", "jump":"Ziplama"}[kind]
    var candidate: StringName = _matching_animation(kind)
    if candidate == &"" and kind == "run":
        candidate = _matching_animation("walk")
    if candidate != &"":
        if _animation_player.current_animation != String(candidate) or not _animation_player.is_playing():
            _animation_player.play(candidate, 0.18)
        return
    if _animation_player != null and _animation_player.is_playing():
        _animation_player.stop()
    _animate_bones(kind, delta)

func _cache_procedural_bones() -> void:
    if _skeleton == null:
        return
    for i in range(_skeleton.get_bone_count()):
        var raw: String = String(_skeleton.get_bone_name(i)).to_lower().replace("_", "").replace(":", "")
        var id: String = ""
        if "leftupleg" in raw or "leftthigh" in raw:
            id = "left_leg"
        elif "rightupleg" in raw or "rightthigh" in raw:
            id = "right_leg"
        elif "leftarm" in raw and not "forearm" in raw:
            id = "left_arm"
        elif "rightarm" in raw and not "forearm" in raw:
            id = "right_arm"
        if not id.is_empty() and not _bone_bases.has(id):
            _bone_bases[id] = {"index": i, "base": _skeleton.get_bone_pose_rotation(i)}

func _animate_bones(kind: String, delta: float) -> void:
    if _skeleton == null or _bone_bases.is_empty():
        return
    var amount: float = 0.0
    var rhythm: float = 6.0
    if kind == "walk":
        amount = 0.38
        rhythm = 7.0
    elif kind == "run":
        amount = 0.64
        rhythm = 12.0
    elif kind == "jump":
        amount = 0.13
    _motion_time += delta * rhythm
    var wave: float = sin(_motion_time) * amount
    for bone_id in _bone_bases:
        var data: Dictionary = _bone_bases[bone_id]
        var sign_value: float = 1.0 if bone_id in ["left_leg", "right_arm"] else -1.0
        var angle: float = wave * sign_value
        var idx: int = int(data["index"])
        var base: Quaternion = data["base"]
        _skeleton.set_bone_pose_rotation(idx, base * Quaternion(Vector3.RIGHT, angle))

func get_status_text() -> String:
    var status: String = "Karakter: " + current_model_name + "\nHareket: " + current_animation
    status += "\nModel: " + (current_model_path if not current_model_path.is_empty() else "BULUNAMADI")
    if not model_warning.is_empty():
        status += "\nUyari: " + model_warning
    return status
