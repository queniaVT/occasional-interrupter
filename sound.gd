extends PanelContainer

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var checkBox: CheckBox = $MarginContainer/HBoxContainer/CheckBox

var enabled: bool
var soundName: String
var minTimerS: String
var minTimerM: String
var minTimerH: String
var minTimerFloat: float
var maxTimerS: String
var maxTimerM: String
var maxTimerH: String
var maxTimerFloat: float
var soundPath: String
var soundVolume: float

signal selected(sound: Control)

var soundSelected := false

func playSound() -> void:
	var loaded := AudioStreamMP3.load_from_file(soundPath)
	if loaded == null:
		push_error("Failed to load MP3 from: %s" % soundPath)
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = loaded
	player.finished.connect(func(): player.queue_free())
	player.volume_linear = soundVolume / 100
	player.play()

func stringToFloat(s: String, m: String, h: String) -> float:
	if s.is_empty(): s = "0.0"
	if m.is_empty(): m = "0.0"
	if h.is_empty(): h = "0.0"
	if !s.is_valid_float() || !m.is_valid_float() || !h.is_valid_float(): return -1.0
	return float(s) + float(m) * 60 + float(h) * 360

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		set_selected(true)
		emit_signal("selected", self)

func set_selected(value: bool) -> void:
	soundSelected = value
	modulate = Color(1, 1, 1) if !soundSelected else Color(1, 0.95, 0.8)

func _ready() -> void:
	if enabled: checkBox.button_pressed = true
	if !enabled: checkBox.button_pressed = false
	while enabled:
		minTimerFloat = stringToFloat(minTimerS, minTimerM, minTimerH)
		maxTimerFloat = stringToFloat(maxTimerS, maxTimerM, maxTimerH)
		if minTimerFloat < 0.0 && maxTimerFloat < 0.0: return
		randomize()
		await get_tree().create_timer(randf_range(minTimerFloat, maxTimerFloat)).timeout
		if enabled: playSound()

func _process(_delta: float) -> void:
	label.text = soundName

func _on_check_box_toggled(value: bool) -> void:
	enabled = value
	if value: _ready()
