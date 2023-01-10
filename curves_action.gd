extends VBoxContainer

const axis_scene = preload("res://curves_axis.tscn")

signal need_reload()

var title: String :
  get:
    return find_child("LabelAction").text
  set(value):
    find_child("LabelAction").text = value

func _ready():
  reload()

func reload():
  find_child("MoveActionPrevious").disabled = get_index() == 0
  find_child("MoveActionNext").disabled = get_index() == get_parent().get_child_count() - 1
  for child in find_child("AxisContainer").get_children():
    child.reload()

func output() -> Dictionary:
  var axis_output = []
  for child in find_child("AxisContainer").get_children():
    axis_output.append(child.output())
  return { "name": title, "axis": axis_output }

func clear_axis():
  for axis in find_child("AxisContainer").get_children():
    axis.queue_free()

func add_axis(axis_title: String, method: String, type: AiUtility.Curb, m: float, k: float, b: float, c: float):
  var new_axis = axis_scene.instantiate()
  new_axis.title = axis_title
  new_axis.method = method
  new_axis.type = type
  new_axis.m = m
  new_axis.k = k
  new_axis.b = b
  new_axis.c = c
  new_axis.need_reload.connect(_on_axis_container_need_reload)
  find_child("AxisContainer").add_child(new_axis)

func _on_button_add_axis_pressed():
  var new_axis = axis_scene.instantiate()
  new_axis.need_reload.connect(_on_axis_container_need_reload)
  find_child("AxisContainer").add_child(new_axis)
  need_reload.emit()

func _on_move_action_previous_pressed():
  get_parent().move_child(self, get_index() - 1)
  need_reload.emit()

func _on_move_action_next_pressed():
  get_parent().move_child(self, get_index() + 1)
  need_reload.emit()

func _on_delete_action_pressed():
  queue_free()
  need_reload.emit()

func _on_axis_container_need_reload():
  reload()
