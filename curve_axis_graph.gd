extends ColorRect

var data = []

func reload(axis_data: Array):
  data.clear()
  for i in range(0, 100):
    var x = float(i) / 100.0
    data.append(Vector2(x, 1.0 - AiUtility.evaluate_axis(axis_data, x)))
  queue_redraw()

func _draw():
  draw_set_transform(Vector2.ZERO, 0.0, size)
  for i in range(1, data.size()):
    draw_line(data[i - 1], data[i], Color.BLUE)
