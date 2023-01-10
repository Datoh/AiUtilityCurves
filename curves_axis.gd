extends HBoxContainer

var title: String :
  get:
    return find_child("ButtonAxis").text
  set(value):
    find_child("ButtonAxis").text = value
var method := ""
var type := AiUtility.Curb.Logistic
var m := 10.0
var k := 1.0
var b := 0.0
var c := 0.5

signal need_reload()

func _ready():
  reload()

func reload():
  find_child("MoveAxisPrevious").disabled = get_index() == 0
  find_child("MoveAxisNext").disabled = get_index() == get_parent().get_child_count() - 1
  find_child("Graph").reload([type, m, k, b, c])

func output() -> Dictionary:
  return { "name": title, "method": method, "type": AiUtility.curb_to_string(type), "m": m, "k": k, "b": b, "c": c }

func _on_move_axis_previous_pressed():
  get_parent().move_child(self, get_index() - 1)
  need_reload.emit()

func _on_move_axis_next_pressed():
  get_parent().move_child(self, get_index() + 1)
  need_reload.emit()

func _on_delete_axis_pressed():
  queue_free()
  need_reload.emit()

func _on_button_axis_pressed():
  $CurveEdit.set_and_show(find_child("ButtonAxis").global_position, title, method, type, m, k, b, c)

func _on_curve_edit_popup_hide():
  title = $CurveEdit.title_axis
  method = $CurveEdit.method
  type = $CurveEdit.type
  m = $CurveEdit.m
  k = $CurveEdit.k
  b = $CurveEdit.b
  c = $CurveEdit.c
  reload()
