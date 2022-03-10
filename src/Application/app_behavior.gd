extends Node;
class_name AppBehavior


#---------------------------------
# * Controls the application main state machine behavior
#---------------------------------



# - - - - - - - - - -
# Holds a reference to the application state machine
# - - - - - - - - - -
var __app_machine : StateMachine = null;


# ###################################|
#                PUBLIC              |
# ###################################|


# - - - - - - - - - -
# Starts the app behavior state machine, restore state will be triggered
# - - - - - - - - - -
func start_machine():
	__app_machine.attendTransition('gotoRestoreState');


# - - - - - - - - - -
# - - - - - - - - - -
func change_to_menu():
	if(__app_machine.evaluate_state('gotoMainMenu')):
		var temp_transition = Application.get_transition();
		temp_transition.setUp(
			get_tree().get_current_scene(),
			Application.scene_referencer().getMenuScenePath(),
			funcref(__app_machine, 'attendTransition'),
			['gotoMainMenu']
		);

		temp_transition.trigger_transition();


# ###################################|
#               PRIVATE              |
# ###################################|


# - - - - - - - - - -
# On enter tree Godot Api override
# - - - - - - - - - -
func _enter_tree():
	__app_machine = StateMachine.new(
		'AppMainMachine',
		AppTransitions.new().app_transitions
	);

	if(!__app_machine):
		Application.validate_operation(GameTypes.kERROR.ERR_UNAVAILABLE);
		return;

	Application.validate_operation(__app_machine.connect(
		'stateChanged', self, '__on_machine_changed__', [], CONNECT_DEFERRED
	));


# - - - - - - - - - -
# ! Current Mocked
# Loads a player state information
# Return (Reference): Loaded player object
# - - - - - - - - - -
func __load_player()-> Reference:
	Application.print_msg(
		GameTypes.kTYPES.APPLICATION,
		'Loading player state configuration ...'
	);

	var __inner_player = PlayerClass.PlayState.new('Player');
	return __inner_player;


# - - - - - - - - - -
# Callback funtion for the application state switch
# @new_state (int): New state enum value
# - - - - - - - - - -
func __on_machine_changed__(new_state : int):
	match new_state:
		# - - - - - - - - - -
		# On change to RESTORE
		GameStates.kAPPSTATES.RESTORE:
			Application.set_player(__load_player());

			__app_machine.attendTransition('gotoIntroScene');

	
		# - - - - - - - - - -
		# On change to INTRO
		GameStates.kAPPSTATES.INTRO:
			Application.main_node.start_animation();


		# - - - - - - - - - -
		# On change to MAINMENU
		GameStates.kAPPSTATES.MAIN_MENU:
			pass;
