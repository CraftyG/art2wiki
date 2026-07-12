extends PanelContainer


@onready var progress_bar = $RichTextLabel/ProgressBar
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func appear(text:String):
	$RichTextLabel.text = text
	var tween :Tween = create_tween()
	tween.tween_property(self,"modulate:a",1.0,0.15).from(0.0)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(self,"position:y",-12.0,0.5).as_relative()
	#tween.tween_interval(5)
	tween.parallel().tween_method(animate_progress,100.0,0,3.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"modulate:a",0.0,0.4).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	queue_free()

func animate_progress(to: float):
	progress_bar.value = to
