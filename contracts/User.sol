// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PoolleEvent.sol";

contract User {
    address public userAddress;
    string public username;
    string private password; 
    
    PoolleEvent private poolleEvent;

    constructor(address _poolleEventAddress, string memory _username, string memory _password) {
        userAddress = msg.sender;
        username = _username;
        password = _password;
        poolleEvent = PoolleEvent(_poolleEventAddress);
    }

    function createEvent(
        string memory _option1,
        string memory _option2,
        string memory _description,
        uint256 _deadline,
        uint256 _minimum_bet
    ) public {
        require(msg.sender == userAddress, "Only the owner can create events.");
        poolleEvent.createEvent(_option1, _option2, _description, _deadline, _minimum_bet);
    }

    // Add a voteEvent function to interact with the PoolleEvent contract
}
