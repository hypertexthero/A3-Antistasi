/*  Starts the timer used by Wurzel to determine testing quality

    Execution on: Server

    Scope: External

    Params:
        None

    Returns:
        Nothing
*/

private _fileName = "testingTimer";

[
    3,
    "Starting testing timer now",
    _fileName
] call A3A_fnc_log;

testingTimerIsActive = true;
private _testedTime = 0;

private _peopleOnline = [];
{
    _peopleOnline pushBack [_x, getPos _x];
} forEach (allPlayers - (entities "HeadlessClient_F"));
private _playersActive = 0;

while {true} do
{
    //Sleep if no player is online
    if (isMultiplayer && (count (allPlayers - (entities "HeadlessClient_F")) == 0)) then
    {
        waitUntil {sleep 10; (count (allPlayers - (entities "HeadlessClient_F")) > 0)};
    };

    //Sleep 5 minutes
    sleep 300;

    private _newOnline = [];
    private _index = 0;
    {
        private _player = _x;
        //Check if player was online before
        _index = _peopleOnline findIf {(_x select 1) isEqualTo _player};
        if(_index != -1) then
        {
            //If online, check if the player has moved at least 5 meters in the mean time
            if((_peopleOnline select _index select 1) distance (getPos _player) > 5) then
            {
                _playersActive = _playersActive + 1;
            };
        };
        _newOnline pushBack [_player, getPos _player];
    } forEach (allPlayers - (entities "HeadlessClient_F"));

    //Replace array with new data
    _playersActive = _newOnline;

    //Limit counted players to a maximum of 10
    _playersActive = _playersActive min 10;

    //Add new testing time
    _testedTime = _testedTime + (_playersActive * 300);

    [
        3,
        format ["Total testing time: %1 Testing time last cycle: %2 Active players: %3", _testedTime/3600, (_playersActive * 300)/3600, _playersActive],
        _fileName
    ] call A3A_fnc_log;

    //Reset counter
    _playersActive = 0;
};