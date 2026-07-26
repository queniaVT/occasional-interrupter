extends Control

@onready var soundNameBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/soundName/TextEdit
@onready var minTimerBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/minTimer/TextEdit
@onready var maxTimerBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/maxTimer/TextEdit
@onready var soundPathBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/soundPath/TextEdit
@onready var soundContainer: VBoxContainer = $HSplitContainer/sounds/MarginContainer/ScrollContainer/soundContainer
@onready var fileDialog: FileDialog = $FileDialog

const soundScene = preload("res://sound.tscn")
var selectedSound: Control = null
var savePath = "user://data.json"

func _ready() -> void:
	if !FileAccess.file_exists(savePath): return
	var file := FileAccess.open(savePath, FileAccess.READ)
	var jsonText := file.get_as_text()
	file.close()
	var result: Variant = JSON.parse_string(jsonText)
	if typeof(result) != TYPE_DICTIONARY: return
	var soundData = result.get("sounds", [])
	if typeof(soundData) != TYPE_ARRAY: return
	for sound in soundData:
		var instance = soundScene.instantiate()
		instance.enabled = sound.enabled
		instance.soundName = sound.soundName
		instance.minTimer = sound.minTimer
		instance.maxTimer = sound.maxTimer
		instance.soundPath = sound.soundPath
		soundContainer.add_child(instance)
		instance.set_selected(true)
		_on_sound_selected(instance)

func _on_sound_selected(sound: Control) -> void:
	selectedSound = sound
	soundNameBox.text = selectedSound.soundName
	minTimerBox.text = selectedSound.minTimer
	maxTimerBox.text = selectedSound.maxTimer
	soundPathBox.text = selectedSound.soundPath
	for child in soundContainer.get_children():
		if child.has_method("set_selected"):
			child.set_selected(child == sound)

func _process(_delta: float) -> void:
	if selectedSound:
		selectedSound.soundName = soundNameBox.text
		selectedSound.minTimer = minTimerBox.text
		selectedSound.maxTimer = maxTimerBox.text
		selectedSound.soundPath = soundPathBox.text
	for sound in soundContainer.get_children():
		if !sound.is_connected("selected", _on_sound_selected):
			sound.connect("selected", _on_sound_selected)

func _on_add_pressed() -> void:
	var instance = soundScene.instantiate()
	soundContainer.add_child(instance)
	instance.set_selected(true)
	_on_sound_selected(instance)

func _on_dupe_pressed() -> void:
	var instance = soundScene.instantiate()
	instance.enabled = selectedSound.enabled
	instance.soundName = selectedSound.soundName
	instance.minTimer = selectedSound.minTimer
	instance.maxTimer = selectedSound.maxTimer
	instance.soundPath = selectedSound.soundPath
	soundContainer.add_child(instance)
	instance.set_selected(true)
	_on_sound_selected(instance)

func _on_del_pressed() -> void:
	selectedSound.queue_free()

func _on_test_pressed() -> void:
	if selectedSound:
		selectedSound.playSound()

func _on_browse_pressed() -> void:
	fileDialog.filters = PackedStringArray(["*.mp3;*.MP3"])
	fileDialog.popup_centered_ratio(0.7)

func _on_file_dialog_file_selected(path: String) -> void:
	soundPathBox.text = path

func _on_save_pressed() -> void:
	var soundData = []
	for sound in soundContainer.get_children():
		soundData.push_back({
			"enabled": sound.enabled,
			"soundName": sound.soundName,
			"minTimer": sound.minTimer,
			"maxTimer": sound.maxTimer,
			"soundPath": sound.soundPath
		})
	var data := {"sounds": soundData}
	var jsonText := JSON.stringify(data, "\t")
	var file := FileAccess.open(savePath, FileAccess.WRITE)
	file.store_string(jsonText)
	file.close()
