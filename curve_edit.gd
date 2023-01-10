extends PopupPanel

var init_values: Array

var type := AiUtility.Curb.Logistic

var title_axis: String :
  get:
    return find_child("ValueName").text
  set(value):
    find_child("ValueName").text = value

var method: String :
  get:
    return find_child("ValueMethod").text
  set(value):
    find_child("ValueMethod").text = value

var m := 0.0
var k := 0.0
var b := 0.0
var c := 0.0

var presets = {}
var ranges = {}

func _ready():
  ranges[AiUtility.Curb.Linear] = [
    # [min, max, step, description],
    [-10.0, 10.0, 0.01, "Slope of the line -- positive numbers for up, negative for down"], #m
    [-10.0, 10.0, 0.01, "Exponent (for linear, this should be 1)"], #k
    [-10.0, 10.0, 0.01, "y-intercept (Moves the line vertically)"], #b
    [-10.0, 10.0, 0.01, "x-intercept (Moves the line horizontally)"], #c
  ]
  ranges[AiUtility.Curb.Quadratic] = [
    # [min, max, step, description],
    [-10.0, 10.0, 0.01, "Slope of the line (positive numbers for up, negative for down)"], #m
    [-10.0, 10.0, 0.01, "Exponent (changed depth of curve)"], #k
    [-10.0, 10.0, 0.01, "y-intercept (Moves the line vertically)"], #b
    [-10.0, 10.0, 0.01, "x-intercept (Moves the line horizontally)"], #c
  ]
  ranges[AiUtility.Curb.Logistic] = [
    # [min, max, step, description],
    [0.0, 10000.0, 0.01, "Slope of the line at inflection point"], #m
    [-10.0, 10.0, 0.01, "Vertical size of curve, positive numbers for up, negative for down"], #k
    [-10.0, 10.0, 0.01, "y-intercept (Moves the line vertically)"], #b
    [-10.0, 10.0, 0.01, "x-value of inflection point (Moves the line horizontally)"], #c
  ]
  ranges[AiUtility.Curb.Logit] = [
    # [min, max, step, description],
    [-10.0, 10.0, 0.01, "Slope of the line at inflection point"], #m
    [-10.0, 10.0, 0.001, "Vertical size of curve, positive numbers for up, negative for down"], #k
    [-10.0, 10.0, 0.01, "y-intercept (Moves the line vertically)"], #b
    [-10.0, 10.0, 0.01, "x-value of inflection point (Moves the line horizontally)"], #c
  ]
  ranges[AiUtility.Curb.Sin] = [
    # [min, max, step, description],
    [-10.0, 10.0, 0.01, "Frequency of wave"], #m
    [-10.0, 10.0, 0.01, "Vertical size of oscilation"], #k
    [-10.0, 10.0, 0.01, "y-intercept (Moves the line vertically)"], #b
    [-10.0, 10.0, 0.01, "x-intercept (Moves the line horizontally)"], #c
  ]
  ranges[AiUtility.Curb.Exists] = [
    # [min, max, step],
    [0.0, 1.0, 0.001, "Value if not exists"], #m
    [0.0, 1.0, 0.001, "Value if exists"], #k
    [0.0, 0.0, 0.0, "Unused"], #b
    [0.0, 0.0, 0.0, "Unused"], #c
  ]

  presets[AiUtility.Curb.Linear] = [
    ["Up", 1.0, 1.0, 0.0, 0.0],
    ["Down", -1.0, 1.0, 1.0, 0.0],
    ["High Only", 2.0, 1.0, 0.0, 0.5],
    ["Low Only", -2.0, 1.0, 1.0, 0.0]]
  presets[AiUtility.Curb.Quadratic] = [
    ["Up", 1.0, 2.0, 0.0, 0.0],
    ["Down", 1.0, 2.0, 0.0, 1.0],
    ["Inv. Up", -1.0, 2.0, 1.0, 1.0],
    ["Down Inv.", -1.0, 2.0, 1.0, 0.0],
    ["Center", -4.0, 2.0, 1.0, 0.5]]
  presets[AiUtility.Curb.Logistic] = [
    ["Up", 10.0, 1.0, 0.0, 0.5],
    ["Down", 10.0, -1.0, 1.0, 0.5],
    ["Steep Up", 1000.0, 1.0, 0.0, 0.5],
    ["Steep Down", 1000.0, -1.0, 1.0, 0.5],
    ["Down Left", 100.0, -1.0, 1.0, 0.3]]
  presets[AiUtility.Curb.Logit] = [
    ["Standard", 1.0, 2.718, 0.5, 0.5],
    ["Flatter", 1.0, 2.718, 0.7, 0.5],
    ["Steeper", 1.0, 4.0, 0.5, 0.5],
    ["Lower", 1.0, 2.718, 0.3, 0.5],
    ["Higher", 1.0, 2.718, 0.7, 0.5]]
  presets[AiUtility.Curb.Sin] = [
    ["Default", 0.39, 2.5, -0.9, -0.14],
    ["Up", 1.0, 2.0, 0.0, 0.0],
    ["Down", 1.0, 2.0, 0.0, 1.0],
    ["Inv. Up", -1.0, 2.0, 1.0, 1.0],
    ["Down Inv.", -1.0, 2.0, 1.0, 0.0],
    ["Center", -4.0, 2.0, 1.0, 0.5]]
  presets[AiUtility.Curb.Exists] = [
    ["Exists", 0.0, 1.0, 0.0, 0.0],
    ["Not exists", 1.0, 0.0, 0.0, 0.0]]

  var popup_curv_type : PopupMenu = find_child("MenuButtonCurveType").get_popup()
  popup_curv_type.add_item(AiUtility.curb_to_string(AiUtility.Curb.Linear), AiUtility.Curb.Linear)
  popup_curv_type.add_item(AiUtility.curb_to_string(AiUtility.Curb.Quadratic), AiUtility.Curb.Quadratic)
  popup_curv_type.add_item(AiUtility.curb_to_string(AiUtility.Curb.Logistic), AiUtility.Curb.Logistic)
  popup_curv_type.add_item(AiUtility.curb_to_string(AiUtility.Curb.Logit), AiUtility.Curb.Logit)
  popup_curv_type.add_item(AiUtility.curb_to_string(AiUtility.Curb.Sin), AiUtility.Curb.Sin)
  popup_curv_type.add_item(AiUtility.curb_to_string(AiUtility.Curb.Exists), AiUtility.Curb.Exists)
  popup_curv_type.id_pressed.connect(_on_curv_type_pressed)

  var popup_presets : PopupMenu = find_child("MenuButtonPreset").get_popup()
  popup_presets.id_pressed.connect(_on_presets_pressed)

  _set_type(type)

func set_and_show(popup_position: Vector2, new_title: String, new_method: String, new_type: AiUtility.Curb, new_m: float, new_k: float, new_b: float, new_c: float):
  title_axis = new_title
  method = new_method
  _set_type(new_type)
  m = new_m
  k = new_k
  b = new_b
  c = new_c
  visible = true
  init_values = [title_axis, method, type, m, k, b, c]
  _value_changed()
  position.x = clamp(int(popup_position.x), 0, DisplayServer.window_get_size().x - size.x)
  position.y = clamp(int(popup_position.y), 0, DisplayServer.window_get_size().y - size.y)

func _set_type(new_type: AiUtility.Curb):
  type = new_type

  find_child("MenuButtonCurveType").text = "Curve: " + AiUtility.curb_to_string(type)

  var popup_presets : PopupMenu = find_child("MenuButtonPreset").get_popup()
  popup_presets.clear()
  for preset in presets[type]:
    popup_presets.add_item(preset[0])

  find_child("HSliderM").min_value = ranges[type][0][0]
  find_child("HSliderM").max_value = ranges[type][0][1]
  find_child("HSliderM").step = ranges[type][0][2]
  find_child("SpinBoxM").min_value = find_child("HSliderM").min_value
  find_child("SpinBoxM").max_value = find_child("HSliderM").max_value
  find_child("SpinBoxM").step = find_child("HSliderM").step
  find_child("HSliderK").min_value = ranges[type][1][0]
  find_child("HSliderK").max_value = ranges[type][1][1]
  find_child("HSliderK").step = ranges[type][1][2]
  find_child("SpinBoxK").min_value = find_child("HSliderK").min_value
  find_child("SpinBoxK").max_value = find_child("HSliderK").max_value
  find_child("SpinBoxK").step = find_child("HSliderK").step
  find_child("HSliderB").min_value = ranges[type][2][0]
  find_child("HSliderB").max_value = ranges[type][2][1]
  find_child("HSliderB").step = ranges[type][2][2]
  find_child("SpinBoxB").min_value = find_child("HSliderB").min_value
  find_child("SpinBoxB").max_value = find_child("HSliderB").max_value
  find_child("SpinBoxB").step = find_child("HSliderB").step
  find_child("HSliderC").min_value = ranges[type][3][0]
  find_child("HSliderC").max_value = ranges[type][3][1]
  find_child("HSliderC").step = ranges[type][3][2]
  find_child("SpinBoxC").min_value = find_child("HSliderC").min_value
  find_child("SpinBoxC").max_value = find_child("HSliderC").max_value
  find_child("SpinBoxC").step = find_child("HSliderC").step
  find_child("LabelMDescription").text = ranges[type][0][3]
  find_child("LabelKDescription").text = ranges[type][1][3]
  find_child("LabelBDescription").text = ranges[type][2][3]
  find_child("LabelCDescription").text = ranges[type][3][3]

  m = presets[type][0][1]
  k = presets[type][0][2]
  b = presets[type][0][3]
  c = presets[type][0][4]

  _value_changed()

func _value_changed():
  find_child("SpinBoxM").value = m
  find_child("HSliderM").value = m
  find_child("SpinBoxK").value = k
  find_child("HSliderK").value = k
  find_child("SpinBoxB").value = b
  find_child("HSliderB").value = b
  find_child("SpinBoxC").value = c
  find_child("HSliderC").value = c
  find_child("Graph").reload([type, m, k, b, c])

func _on_button_reset_pressed():
  title_axis = init_values[0]
  method = init_values[1]
  _set_type(init_values[2])
  m = init_values[3]
  k = init_values[4]
  b = init_values[5]
  c = init_values[6]
  _value_changed()

func _on_m_value_changed(value: float):
  m = value
  _value_changed()

func _on_k_value_changed(value: float):
  k = value
  _value_changed()

func _on_b_value_changed(value: float):
  b = value
  _value_changed()

func _on_c_value_changed(value: float):
  c = value
  _value_changed()

func _on_curv_type_pressed(new_type: int):
  if type != new_type:
    _set_type(new_type)

func _on_presets_pressed(id: int):
  m = presets[type][id][1]
  k = presets[type][id][2]
  b = presets[type][id][3]
  c = presets[type][id][4]
  _value_changed()
