extends "res://addons/godot-xr-tools/objects/Object_pickable.gd"

export (PackedScene) var bullet = null
export var initial_bullet_speed = 300.0

onready var twohanded = $TwoHandedAnchor/TwoHanded
var can_shoot = true

func pick_up(by, with_controller):
	.pick_up(by, with_controller)
	twohanded.enabled = true
	
	with_controller.connect('button_pressed', self, 'button_pressed')
	
	$Scope.render_target_update_mode = Viewport.UPDATE_ALWAYS

func let_go(starting_linear_velocity = Vector3(0.0, 0.0, 0.0)):
	twohanded.enabled = false
	if picked_up_by:
		picked_up_by.disconnect('button_pressed', self, 'button_pressed')
	
	.let_go(starting_linear_velocity)
	
	$Scope.render_target_update_mode = Viewport.UPDATE_DISABLED

func button_pressed(button):
	if (button == 1):
		$Scope/Camera.fov = clamp($Scope/Camera.fov + 1, 1, 6)
	if (button == 7):
		$Scope/Camera.fov = clamp($Scope/Camera.fov - 1, 1, 6)
	
	$Scope/ScopeUI.set_scope($Scope/Camera.fov)

func action():
	if can_shoot and bullet:
		# shoot our bullet
		var new_bullet = bullet.instance()
		get_node("/root/Main/Viewport-VR/Spawns").add_child(new_bullet)
		
		var new_transform = $Pivot/Muzzle.global_transform
		new_bullet.linear_velocity = -new_transform.basis.z * initial_bullet_speed
		new_bullet.set_start_transform(new_transform)
		
		# play our gunshot sound
		$AudioStreamPlayer3D.play()
		
		# start cooldown
		can_shoot = false
		$cooldown.start()

func _process(_delta):
	if twohanded.is_picked_up():
		$Pivot/GunHand.visible = true
		var target = twohanded.global_transform.origin + (global_transform.basis.y * $TwoHandedAnchor/Target.transform.origin.y)
		$Pivot.look_at(target, global_transform.basis.y)
	else:
		$Pivot/GunHand.visible = false
		$Pivot.transform.basis = Basis()

func _on_cooldown_timeout():
	can_shoot = true
