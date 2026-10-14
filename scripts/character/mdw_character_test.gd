extends Node3D
## Mixed Dark World 0.3.1: Bagimsiz insan-karakter deneme alani.
## Eski demo, Terrain3D, dunya kaydi ve proje ana sahnesi degismez.

const PLAYER_SCRIPT = preload("res://scripts/character/mdw_player.gd")
var _player: CharacterBody3D
var _status: Label
var _hud_timer: float = 0.0

func _ready() -> void:
    _create_environment()
    _create_training_field()
    _create_player()
    _create_interface()
    _refresh_hud()

func _create_environment() -> void:
    var world := WorldEnvironment.new()
    world.name = "TestOrtamIsigi"
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.60, 0.76, 0.91)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.85, 0.87, 0.93)
    env.ambient_light_energy = 0.7
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.name = "TestGunesi"
    sun.rotation_degrees = Vector3(-52.0, -32.0, 0.0)
    sun.light_energy = 1.2
    sun.shadow_enabled = false  # Ilk surum: eski ekran kartinda hafif kalsin.
    add_child(sun)

func _create_training_field() -> void:
    _make_box("Zemin", Vector3(180.0, 1.0, 180.0), Vector3(0.0, -0.5, 0.0), Color(0.32, 0.40, 0.32))
    _make_box("Engel_01", Vector3(1.5, 1.3, 1.5), Vector3(3.0, 0.65, -7.0), Color(0.53, 0.49, 0.41))
    _make_box("Engel_02", Vector3(3.5, 0.7, 1.5), Vector3(-4.0, 0.35, -9.0), Color(0.52, 0.48, 0.41))
    _make_box("Engel_03", Vector3(1.0, 2.5, 6.0), Vector3(9.0, 1.25, 0.0), Color(0.51, 0.47, 0.39))
    _make_box("Olcek_1_Metre", Vector3(0.12, 1.0, 0.12), Vector3(-3.0, 0.5, -3.0), Color(0.96, 0.79, 0.26))
    _make_box("Olcek_2_Metre", Vector3(0.12, 2.0, 0.12), Vector3(-4.0, 1.0, -3.0), Color(0.93, 0.45, 0.26))

func _make_box(label: String, size: Vector3, place: Vector3, tint: Color) -> void:
    var static_body := StaticBody3D.new()
    static_body.name = label
    static_body.position = place
    add_child(static_body)
    var mesh := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = size
    mesh.mesh = box_mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = 0.95
    mesh.material_override = material
    static_body.add_child(mesh)
    var collision := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    collision.shape = box
    static_body.add_child(collision)

func _create_player() -> void:
    _player = CharacterBody3D.new()
    _player.name = "MixedDarkWorldOyuncusu"
    _player.set_script(PLAYER_SCRIPT)
    add_child(_player)
    _player.global_position = Vector3(0.0, 1.8, 0.0)

func _create_interface() -> void:
    var canvas := CanvasLayer.new()
    canvas.name = "BilgiEkrani"
    add_child(canvas)
    var panel := ColorRect.new()
    panel.color = Color(0.015, 0.022, 0.03, 0.72)
    panel.position = Vector2(12.0, 12.0)
    panel.size = Vector2(730.0, 182.0)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(panel)
    _status = Label.new()
    _status.position = Vector2(22.0, 18.0)
    _status.add_theme_font_size_override("font_size", 16)
    _status.add_theme_color_override("font_color", Color.WHITE)
    _status.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(_status)

func _process(delta: float) -> void:
    _hud_timer -= delta
    if _hud_timer <= 0.0:
        _hud_timer = 0.30
        _refresh_hud()

func _refresh_hud() -> void:
    if _status == null or _player == null:
        return
    var info: String = str(_player.call("get_status_text"))
    _status.text = "MIXED DARK WORLD 0.3.1 - INSAN KARAKTER TESTI" \
        + "\nWASD / OK: Hareket | SHIFT: Kos | SPACE: Zipla" \
        + "\nFare: Kamera | ESC: Imleci birak | C: Kameraya geri don" \
        + "\n1: Diesel | 2: EMA | 3: Fatt Tony" \
        + "\n" + info + "\nFPS: " + str(Engine.get_frames_per_second())
