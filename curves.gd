extends VBoxContainer

const action_scene = preload("res://curves_action.tscn")

func _ready():
  pass

func reload():
  for child in find_child("ActionsContainer").get_children():
    child.reload()

func _on_button_add_action_pressed():
  var new_action = action_scene.instantiate()
  new_action.need_reload.connect(_on_action_container_need_reload)
  find_child("ActionsContainer").add_child(new_action)
  reload()

func _on_action_container_need_reload():
  reload()

func _on_button_clipboard_copy_pressed():
  var output = []
  for child in find_child("ActionsContainer").get_children():
    output.append(child.output())
  DisplayServer.clipboard_set(JSON.stringify(output, "  ", false))


func _on_button_clipboard_load_pressed():
  var actions_container = find_child("ActionsContainer")
  for action_node in actions_container.get_children():
    action_node.queue_free()

  var actions = JSON.parse_string(DisplayServer.clipboard_get())
  for action in actions:
    var new_action = action_scene.instantiate()
    new_action.need_reload.connect(_on_action_container_need_reload)
    new_action.title = action.name
    new_action.clear_axis()
    for axis in action.axis:
      new_action.add_axis(axis.name, axis.method, AiUtility.string_to_curb(axis.type), axis.m, axis.k, axis.b, axis.c)
    actions_container.add_child(new_action)
  reload()

