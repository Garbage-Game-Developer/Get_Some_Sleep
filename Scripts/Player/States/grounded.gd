class_name GroundedState extends Node

""" 
Description
	This state is for when the player is in contact with the ground and not sliding
	The main not action animation for this state is idle, for when x velocity is zero

This state considers movenment

Actions available
- Jump			Gives upward velocity, and leaves the ground
- Dash			Gives a large ammount of horizontal velocity
- Slide			Starts sliding, can jump out of sliding, and can't really slide in low velocity since it has a cutoff point 
- (Punch)		A sub action that can be used while running and walking that has the player punch in the direction they are facing
- (Interact)	A sub action that can be used while running or walking that has the player simply interact with an interactable object
"""


""" Exports """
@onready var P : Player = $"../.."
@onready var Animation_Controller : Node2D = $"../../C"


""" Constants """

##	Function for movenment
##		Temp_Variable = Acceleration Time - (Acceleration Time * Starting Velocity) / (2 * Max Speed)
##		Speed = -1 * (Max Speed - Starting Velocity) * (Frame * (Frame - 2 * Temp Variable) / (Temp Variable * Temp Variable)) + Starting Velocity
##	Frame is the independent variable and speed is the dependent variable of this function

@export var GROUND_MAX_SPEED : float = 300.0	##	Maximum speed (px * s) the player can move
@export var GROUND_MAX_ACC_SPEED : int = 24		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var GROUND_MAX_DEC_SPEED : int = 12		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var SLOW_GROUND_MAX_SPEED : float = 200.0	##	Maximum speed (px * s) the player can move
@export var SLOW_GROUND_MAX_ACC_SPEED : int = 48	##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var SLOW_GROUND_MAX_DEC_SPEED : int = 10	##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var ICE_GROUND_MAX_SPEED : float = 350.0	##	Maximum speed (px * s) the player can move
@export var ICE_GROUND_MAX_ACC_SPEED : int = 60		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var ICE_GROUND_MAX_DEC_SPEED : int = 30		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s


func update(delta : float, new_state : bool = false):
	
	""" Actions Available """
	var new_action = false
	
	
	##	LEFT and RIGHT movenment
	var velocity = P.left_right_priority(Input.is_action_pressed("LEFT"), Input.is_action_pressed("RIGHT")) * P.GROUND_SPEED * P.speed_boost * delta
	P.velocity += velocity
	
	
	##	Check for ground type instead of just using normal surface  *sigh*
	var ground_type : int = 0	##	1 - Normal, 2 - Slow, 3 - Ice
	if(true):
		pass
	
	
	
	if(Input.is_action_just_pressed("JUMP")):
		#P.velocity.y += P.JUMP_FORCE
		#new_action = true
		pass
	
	if(Input.is_action_just_pressed("DASH")):
		pass
	
	if(Input.is_action_just_pressed("SLIDE")):
		pass
	
	if(Input.is_action_just_pressed("ATTACK")):
		pass
	
	##	calls the interaction function in the player parant class
	if(Input.is_action_just_pressed("INTERACT")):
		pass
	
	
	""" Animations to Play """
	
	if(!new_action):
		
		if(P.just_switched_directions):
			Animation_Controller.left_or_right = (1 if P.left_or_right else 0)
		
		##	Check if not dashing before checking if velocity.y < 0, and then setting animation to falling
		
		"""
			Need a more advanced system for detecting if an animation is finished, so swapping between left and right doesn't re do 
			the animation, and just skips to the end frame (Only for one shot animations)
			
			Could have a left and right sprite that show and hide based on left or right to ensure animation is always in sync, and 
			it doesn't need to restart (probably the easiest and best solution for non mirrorable sprites)
			
			Alternativly, I could take the texture overlay approach of just having a model sprite, and then have shaders check from
			the texture node and place the coresponding pixels where they need to be. (Much more complex, but doesn't need 2 sprite 
			sets to work)
			
			Also, could have shaders detect weather or not the leg sprite has gone up a pixel, and move the sprite up respectivly in
			the shader (I really like this solution ngl)
		"""
		pass
	
	""" Physics """
	##	Check for moving platforms
	pass
