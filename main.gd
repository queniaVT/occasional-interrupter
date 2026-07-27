extends Control

@onready var soundNameBox: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/soundName/LineEdit
@onready var minTimerBoxS: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/minTimer/HBoxContainer/LineEdit
@onready var minTimerBoxM: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/minTimer/HBoxContainer/LineEdit2
@onready var minTimerBoxH: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/minTimer/HBoxContainer/LineEdit3
@onready var maxTimerBoxS: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/maxTimer/HBoxContainer/LineEdit
@onready var maxTimerBoxM: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/maxTimer/HBoxContainer/LineEdit2
@onready var maxTimerBoxH: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/maxTimer/HBoxContainer/LineEdit3
@onready var soundPathBox: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/soundPath/HBoxContainer/LineEdit
@onready var soundVolumeBox: LineEdit = $HSplitContainer/options/MarginContainer/VBoxContainer/soundVolume/HBoxContainer/LineEdit
@onready var volumeSlider: HSlider = $HSplitContainer/options/MarginContainer/VBoxContainer/soundVolume/HBoxContainer/volumeSlider

@onready var searchBar: LineEdit = $HSplitContainer/sounds/MarginContainer/VBoxContainer/LineEdit
@onready var soundContainer: VBoxContainer = $HSplitContainer/sounds/MarginContainer/VBoxContainer/ScrollContainer/soundContainer
@onready var fileDialog: FileDialog = $FileDialog

const soundScene = preload("res://sound.tscn")
var selectedSound: Control = null
var savePath = "user://data.json"

func _ready() -> void:
	for le in get_tree().get_nodes_in_group("le"): le.text_submitted.connect(_on_text_submitted.bind(le))
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
		instance.minTimerS = sound.minTimerS
		instance.minTimerM = sound.minTimerM
		instance.minTimerH = sound.minTimerH
		instance.maxTimerS = sound.maxTimerS
		instance.maxTimerM = sound.maxTimerM
		instance.maxTimerH = sound.maxTimerH
		instance.soundPath = sound.soundPath
		instance.soundVolume = sound.soundVolume
		soundContainer.add_child(instance)
		instance.set_selected(true)
		_on_sound_selected(instance)

func _on_text_submitted(_text: String, le: LineEdit) -> void: le.release_focus()

func _on_sound_selected(sound: Control) -> void:
	selectedSound = sound
	soundNameBox.text = selectedSound.soundName
	minTimerBoxS.text = selectedSound.minTimerS
	minTimerBoxM.text = selectedSound.minTimerM
	minTimerBoxH.text = selectedSound.minTimerH
	maxTimerBoxS.text = selectedSound.maxTimerS
	maxTimerBoxM.text = selectedSound.maxTimerM
	maxTimerBoxH.text = selectedSound.maxTimerH
	soundPathBox.text = selectedSound.soundPath
	volumeSlider.value = selectedSound.soundVolume
	for child in soundContainer.get_children(): if child.has_method("set_selected"): child.set_selected(child == sound)

func _process(_delta: float) -> void:
	if selectedSound:
		selectedSound.soundName = soundNameBox.text
		selectedSound.minTimerS = minTimerBoxS.text
		selectedSound.minTimerM = minTimerBoxM.text
		selectedSound.minTimerH = minTimerBoxH.text
		selectedSound.maxTimerS = maxTimerBoxS.text
		selectedSound.maxTimerM = maxTimerBoxM.text
		selectedSound.maxTimerH = maxTimerBoxH.text
		selectedSound.soundPath = soundPathBox.text
		selectedSound.soundVolume = volumeSlider.value
	for sound in soundContainer.get_children(): if !sound.is_connected("selected", _on_sound_selected): sound.connect("selected", _on_sound_selected)
	if soundVolumeBox.has_focus(): 
		if !soundVolumeBox.text.is_valid_float(): return
		volumeSlider.value = float(soundVolumeBox.text)
	else: soundVolumeBox.text = str(volumeSlider.value).trim_suffix(".0")
	for sound in soundContainer.get_children():
		if sound.soundName.strip_edges().to_lower().contains(searchBar.text.strip_edges().to_lower()) || searchBar.text.is_empty(): sound.visible = true
		else: sound.visible = false

func _on_add_pressed() -> void:
	var instance = soundScene.instantiate()
	soundContainer.add_child(instance)
	instance.set_selected(true)
	_on_sound_selected(instance)

func _on_dupe_pressed() -> void:
	var instance = soundScene.instantiate()
	instance.enabled = selectedSound.enabled
	instance.soundName = selectedSound.soundName
	instance.minTimerS = selectedSound.minTimerS
	instance.minTimerM = selectedSound.minTimerM
	instance.minTimerH = selectedSound.minTimerH
	instance.maxTimerS = selectedSound.maxTimerS
	instance.maxTimerM = selectedSound.maxTimerM
	instance.maxTimerH = selectedSound.maxTimerH
	instance.soundPath = selectedSound.soundPath
	instance.soundVolume = selectedSound.soundVolume
	soundContainer.add_child(instance)
	instance.set_selected(true)
	_on_sound_selected(instance)

func _on_del_pressed() -> void: selectedSound.queue_free()

func _on_test_pressed() -> void: if selectedSound: selectedSound.playSound()

func _on_browse_pressed() -> void:
	fileDialog.filters = PackedStringArray(["*.mp3;*.MP3"])
	fileDialog.popup_centered_ratio(0.7)

func _on_file_dialog_file_selected(path: String) -> void: soundPathBox.text = path

func _on_save_pressed() -> void:
	var soundData = []
	for sound in soundContainer.get_children():
		soundData.push_back({
			"enabled": sound.enabled,
			"soundName": sound.soundName,
			"minTimerS": sound.minTimerS,
			"minTimerM": sound.minTimerM,
			"minTimerH": sound.minTimerH,
			"maxTimerS": sound.maxTimerS,
			"maxTimerM": sound.maxTimerM,
			"maxTimerH": sound.maxTimerH,
			"soundPath": sound.soundPath,
			"soundVolume": sound.soundVolume
		})
	var data := {"sounds": soundData}
	var jsonText := JSON.stringify(data, "\t")
	var file := FileAccess.open(savePath, FileAccess.WRITE)
	file.store_string(jsonText)
	file.close()
