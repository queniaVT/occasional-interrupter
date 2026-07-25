extends PanelContainer

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var checkBox: CheckBox = $MarginContainer/HBoxContainer/CheckBox
@onready var soundPlayer: AudioStreamPlayer = $AudioStreamPlayer

var enabled: bool
var soundName: String
var minTimer: String
var minTimerFloat: float
var maxTimer: String
var maxTimerFloat: float
var soundPath: String

signal selected(sound: Control)

var soundSelected := false

func playSound() -> void:
	var loaded := AudioStreamMP3.load_from_file(soundPath)
	if loaded == null:
		push_error("Failed to load MP3 from: %s" % soundPath)
		return
	soundPlayer.stream = loaded
	soundPlayer.play()

func stringToFloat(s: String) -> float:
	if s.is_empty(): return -1.0
	if !s.is_valid_float(): return -1.0
	return float(s)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		set_selected(true)
		emit_signal("selected", self)

func set_selected(value: bool) -> void:
	soundSelected = value
	modulate = Color(1, 1, 1) if !soundSelected else Color(1, 0.95, 0.8)

func _ready() -> void:
	enabled = checkBox.button_pressed
	while enabled:
		minTimerFloat = stringToFloat(minTimer)
		maxTimerFloat = stringToFloat(maxTimer)
		if minTimerFloat < 0.0 && maxTimerFloat < 0.0: return
		await get_tree().create_timer(randf_range(minTimerFloat, maxTimerFloat)).timeout
		playSound()

func _process(_delta: float) -> void:
	#enabled = checkBox.button_pressed
	label.text = soundName

func _on_check_box_toggled(value: bool) -> void:
	enabled = value
	if value: _ready()
