@tool
extends FlowcharterElement
class_name ElectroElement

@export var lock_design : bool = false ## Disable the user from customizing this component.

func debug_visual():
	return  # Override debug so it doesn't draw anything.


#region Component Simulation
var updated : bool = true  # Checking for this flag ensures that feedback loops don't run-away.
## Do something when the timer ticks.
func tick_update():
	updated = false
## Do something when a device propagates to this device.
func device_update():
	if updated:
		return
	else:
		updated = true
	operation()
	propagate()
## Call to update devices connected to this one.
func propagate():
	#for slot in slots:
		#if slot is WireSourceSlot:
			pass
			#for dev in slot.devices:
				#dev.device_update()
## The action that this component perform on its signals.
func operation():
	pass
#endregion
