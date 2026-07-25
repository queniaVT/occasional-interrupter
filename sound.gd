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

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_selected(true)
		emit_signal("selected", self)

func set_selected(value: bool) -> void:
	soundSelected = value
	modulate = Color(1, 1, 1) if not soundSelected else Color(1, 0.95, 0.8)

func _process(_delta: float) -> void:
	label.text = soundName
	enabled = checkBox.button_pressed
