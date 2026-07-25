extends Control

@onready var soundNameBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/soundName/TextEdit
@onready var minTimerBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/minTimer/TextEdit
@onready var maxTimerBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/maxTimer/TextEdit
@onready var soundPathBox: TextEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/soundPath/TextEdit
@onready var soundContainer: VBoxContainer = $HSplitContainer/sounds/MarginContainer/ScrollContainer/soundContainer
@onready var fileDialog: FileDialog = $FileDialog

const soundScene = preload("res://sound.tscn")
var selectedSound: Control = null

func _ready() -> void:
	pass

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
	selectedSound.duplicate() # doesnt work for some reason idk fix it later

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
