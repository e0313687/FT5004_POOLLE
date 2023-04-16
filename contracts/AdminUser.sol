pragma solidity ^0.8.0;

import "./User.sol";
import "./Event.sol";

contract AdminUser is User {
    
    // Verify the outcome of an event and dispense winnings to voters
    function verify(uint _eventID, string memory _outcome) public onlyAdmin {
        // Verify that the event exists and is not active
        require(_eventID < nextEventID, "Event does not exist");
        require(!events[_eventID].isActive, "Event is still active");
        
        // Verify that the outcome is valid (either "option1" or "option2")
        require(
            keccak256(abi.encodePacked(_outcome)) == keccak256(abi.encodePacked("option1")) ||
            keccak256(abi.encodePacked(_outcome)) == keccak256(abi.encodePacked("option2")),
            "Invalid outcome"
        );
        
        // Update the event with the verified outcome
        events[_eventID].outcome = keccak256(abi.encodePacked(_outcome));
        
        // Dispense winnings to voters who bet on the correct outcome
        Event eventInstance = Event(events[_eventID].instanceAddress);
        eventInstance.dispense(_eventID);
    }
    
    // Modifier to only allow admin users to call a function
    modifier onlyAdmin() {
        require(msg.sender == owner, "Only admin user can call this function");
        _;
    }
}