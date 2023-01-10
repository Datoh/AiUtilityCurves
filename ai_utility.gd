#Based on talks by Dave Mark (https://twitter.com/IADaveMark) at GCD: 
# - https://www.gdcvault.com/play/1021848/Building-a-Better-Centaur-AI
# - http://www.gdcvault.com/play/1018040/Architecture-Tricks-Managing-Behaviors-in (third part)

extends Object
class_name AiUtility

enum Curb { Linear = 0, Quadratic, Logistic, Logit, Sin, Exists }

var _actions := []

static func curb_to_string(type: Curb) -> String:
  match type:
    Curb.Linear: return "Linear"
    Curb.Quadratic: return "Quadratic"
    Curb.Logistic: return "Logistic"
    Curb.Logit: return "Logit"
    Curb.Sin: return "Sin"
    Curb.Exists: return "Exists"
  return ""

static func string_to_curb(type: String) -> int:
  match type:
    "Linear": return Curb.Linear
    "Quadratic": return Curb.Quadratic
    "Logistic": return Curb.Logistic
    "Logit": return Curb.Logit
    "Sin": return Curb.Sin
    "Exists": return Curb.Exists
  return Curb.Linear

# actions [ type, "name", input_action, axis[], result ]
# axis data [ "name", [input_callable(), input_data, min_input, max_input], [curb, m, k, b, c], [input_result, input_normalized, result] ]

func add_action(type: int, name: String, input_action: Variant = null) -> int:
  _actions.append([ type, name, input_action, [], 0.0 ])
  return _actions.size() - 1

func add_axis(action_id: int, name: String, input_callable: Callable, input_data: Variant, min_input: float, max_input: float, curb: Curb, m: float, k: float, b: float = 0.0, c: float = 0.0):
  _actions[action_id][3].append([ name, [input_callable, input_data, min_input, max_input], [curb, m, k, b, c], [ 0.0, 0.0, 0.0 ] ])

func sorted_actions() -> Array:
  _actions.sort_custom(func(a, b): return a[4] > b[4])
  for action in _actions:
    action[3].sort_custom(func(a, b): return a[3][2] > b[3][2])
  return _actions

func evaluate(store_result: bool = false) -> Array:
  var value_selected_action := -1.0
  var selected_action := 0
  for action_id in range(_actions.size()):
    var action = _actions[action_id]
    var value_action := 1.0 if not action[3].is_empty() else 0.0
    for axis in action[3]:
      var axis_value = _evaluate_axis(axis[1], axis[2], axis[3], store_result)
      value_action *= axis_value
      if not store_result and (value_action <= value_selected_action or value_action <= 0.0):
        break
    if store_result:
      action[4] = value_action
    if value_selected_action < value_action:
      value_selected_action = value_action
      selected_action = action_id
  return [ selected_action, _actions[selected_action][0], _actions[selected_action][2] ]

static func evaluate_axis(curb_array: Array, input: float) -> float:
  var result := 0.0
  match curb_array[0]:
    Curb.Linear: result = (curb_array[1] * pow(input - curb_array[4], curb_array[2])) + curb_array[3]
    Curb.Quadratic: result = (curb_array[1] * pow(input - curb_array[4], curb_array[2])) + curb_array[3]
    Curb.Logistic: result = curb_array[3] + (curb_array[2] * (1.0 / (1.0 + pow(2718 * curb_array[1], -1.0 * input + curb_array[4]))))
    Curb.Logit:
      var input_aux = clamp(input, 0.0001, 0.9999)
      result = ((log(input_aux / (1.0 - input_aux)) / log(curb_array[2])) + (10.0 * curb_array[3])) / (10.0 / curb_array[1])
    Curb.Sin: result = (sin((input - curb_array[4]) * curb_array[1] * 2.0 * PI) * (curb_array[2] / 2.0) + (curb_array[3] + 0.5))
    Curb.Exists: result = curb_array[1] if input == 0.0 else curb_array[2]
  return clamp(result, 0.0, 1.0)

func _evaluate_axis(input_array: Array, curb_array: Array, result_array: Array, store_result: bool) -> float:
  var input = input_array[0].call(input_array[1])
  var input_normalized = clamp(input - input_array[2], 0.0, input_array[3]) / input_array[3] # Normalize input
  var result = AiUtility.evaluate_axis(curb_array, input_normalized)
  if store_result:
    result_array[0] = input
    result_array[1] = input_normalized
    result_array[2] = result
  return result
