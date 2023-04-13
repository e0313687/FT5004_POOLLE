// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PoolleEvent {
    struct Voter {
        uint256 betOption;
        uint256 stake;
    }

    struct Event {
        uint256 id;
        string option1;
        string option2;
        string description;
        uint256 deadline;
        uint256 minimum_bet;
        uint256 outcome;
        address[] voters;
        bool isActive;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => Voter)) public eventVoters;
    uint256 public eventCount;

    function createEvent(
        string memory _option1,
        string memory _option2,
        string memory _description,
        uint256 _deadline,
        uint256 _minimum_bet
    ) public {
        eventCount++;
        events[eventCount] = Event({
            id: eventCount,
            option1: _option1,
            option2: _option2,
            description: _description,
            deadline: _deadline,
            minimum_bet: _minimum_bet,
            outcome: 0,
            voters: new address[](0),
            isActive: true
        });
    }
}
