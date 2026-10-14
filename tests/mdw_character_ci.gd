extends SceneTree
## GitHub Actions: Godot 4.7.2 headless character load smoke test.

func _initialize() -> void:
    call_deferred("_check")

func _check() -> void:
    var scene_resource: Resource = load("res://scenes/MDW_Character_Test.tscn")
    if not scene_resource is PackedScene:
        push_error("KARAKTER_TEST: test sahnesi yuklenemedi.")
        quit(1)
        return

    var scene: Node = (scene_resource as PackedScene).instantiate()
    root.add_child(scene)
    await process_frame

    var player: Node = scene.get_node_or_null("MixedDarkWorldOyuncusu")
    if player == null or not player.has_method("load_character"):
        push_error("KARAKTER_TEST: oyuncu denetleyicisi bulunamadi.")
        quit(2)
        return

    for i in range(3):
        player.call("load_character", i)
        var path: String = str(player.get("current_model_path"))
        if path.is_empty():
            push_error("KARAKTER_TEST: %s modeli yuklenemedi." % str(i))
            quit(3)
            return
        print("KARAKTER_TEST: model bulundu: ", path)
        var skeleton: Variant = player.get("_skeleton")
        var animator: Variant = player.get("_animation_player")
        var bones: int = 0
        var animation_names: PackedStringArray = PackedStringArray()
        if skeleton is Skeleton3D:
            bones = (skeleton as Skeleton3D).get_bone_count()
        if animator is AnimationPlayer:
            animation_names = (animator as AnimationPlayer).get_animation_list()
        print("KARAKTER_TEST: eklem = ", bones, ", animasyon = ", animation_names, ", uyari = ", str(player.get("model_warning")))

    print("KARAKTER_TEST: sahne ve 3 GLB model yuklemesi basarili.")
    quit(0)
