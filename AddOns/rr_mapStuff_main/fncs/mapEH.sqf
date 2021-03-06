/*
*	Author: LAxemann
*
*	Desc: 
*   Handles players holding a physical map when accessing their map
*	by regularly pressing M
*
*	Params:
*	0 - Map is opened <BOOL>
*	1 - MapView is forced <BOOL>
*
*	Returns:
*	nil
*
*	Example: 
*   
* =================================================*/

params ["_mapIsOpened", "_mapIsForced"];

if (cameraOn != ace_player) exitWith {};
if !(alive ace_player) exitWith  {};
if !("ItemMap" in (assignedItems ace_player)) exitWith {};
if !(isNull (ace_player getVariable ["RR_mapStuff_openedMap",objNull])) exitWith {};
if !(isNull findDisplay 160) exitWith {};
if ((vehicle ace_player) != ace_player) exitWith {};

if (_mapIsOpened) then {
	private _isProne = ((stance ace_player) == "PRONE");
	private _mainAnim  = ["RR_gesture_holdMapStand","RR_gesture_holdMapProne"] select _isProne;
	private _mapName = switch (worldname) do {
		case "Altis": {"Land_Map_Unfolded_Altis_F"};
		case "Malden": {"Land_Map_Unfolded_Malden_F"};
		case "Tanoa": {"Land_Map_Unfolded_Tanoa_F"};
		case "Enoch": {"Land_Map_Unfolded_Enoch_F"};
		default {"Land_Map_Unfolded_F"};
	};
	private _map = _mapName createVehicle [-1,-1,0];

	/* Create an array of current markers and store it locally on the map */
	[_map] spawn RR_mapStuff_fnc_handleMapState;
	private _markerArray = call RR_mapStuff_fnc_createMarkerArray;
	_map setVariable ["RR_mapStuff_mapMarkers",_markerArray];
	_map setVariable ["RR_mapStuff_ownerClientID",clientOwner,true];
	_map setVariable ["RR_mapStuff_clientsWatching",[]];

	
	/* Try to assign fitting (world) textures to the map */
	if (isText (configFile >> "CfgWorlds" >> worldName >> "pictureMap") && !(worldname in ["Altis","Stratis","Malden","Tanoa","Enoch"])) then {
		_map setObjectTextureGlobal [0, getText (configFile >> "CfgWorlds" >> worldName >> "pictureMap")];
	};

	
	ace_player setVariable ["RR_mapStuff_mapObject",_map];
	ace_player playActionNow _mainAnim;


	/* Handle animation changes */
	[] spawn {
		private _lastStance = stance ace_player;
		while {visibleMap && alive ace_player} do {
			_newStance = stance player;
			if (_newStance != _lastStance) then {
				ace_player playActionNow (["RR_gesture_holdMapStand","RR_gesture_holdMapProne"] select ((stance ace_player) == "PRONE"));
			};
			_lastStance = _newStance;
			sleep 0.5;
		};
	};
} else {
	private _mapObject = ace_player getVariable ["RR_mapStuff_mapObject",objNull];
	if !(isNull _mapObject) then {
		deleteVehicle _mapObject; 
		ace_player playAction "RR_gesture_mapStuffEmpty";
		ace_player setVariable ["RR_mapStuff_mapObject",objNull];
		ace_player setVariable ["RR_mapStuff_openedMap",objNull];
	};
};