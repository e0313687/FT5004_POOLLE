pragma solidity ^0.8.0;

contract Event {
    struct EventStruct {
        uint eventID;
        string option1;
        string option2;
        string description;
        uint deadline;
        uint minimum_bet;
        uint8 outcome;
        mapping(address => uint8) voters;
        bool isActive;
        uint option1_pool;
        uint option2_pool;
    }

    mapping(uint => EventStruct) events;

    uint nextEventID;

    function createEvent(string memory _option1, string memory _option2, string memory _description, uint _deadline, uint _minimum_bet) public {
        nextEventID++;

        events[nextEventID].eventID = nextEventID;
        events[nextEventID].option1 = _option1;
        events[nextEventID].option2 = _option2;
        events[nextEventID].description = _description;
        events[nextEventID].deadline = _deadline;
        events[nextEventID].minimum_bet = _minimum_bet;
        events[nextEventID].isActive = true;
    }

    function getEvent(uint _eventID) public view returns (string memory option1, string memory option2, string memory description, uint deadline, uint minimum_bet, bool isActive) {
        option1 = events[_eventID].option1;
        option2 = events[_eventID].option2;
        description = events[_eventID].description;
        deadline = events[_eventID].deadline;
        minimum_bet = events[_eventID].minimum_bet;
        isActive = events[_eventID].isActive;
    }

    function listEvents() public view returns (uint[] memory eventIDs) {
        eventIDs = new uint[](nextEventID);

        for (uint i = 1; i <= nextEventID; i++) {
            if (events[i].isActive) {
                eventIDs[i-1] = events[i].eventID;
            }
        }
    }

    function placeBet(uint _eventID, uint8 _option) public payable {
        require(events[_eventID].isActive, "Event is not active");
        require(block.timestamp <= events[_eventID].deadline, "Event has already ended");
        require(msg.value >= events[_eventID].minimum_bet, "Bet amount is below minimum");

        if (_option == 1) {
            events[_eventID].option1_pool += msg.value;
        } else if (_option == 2) {
            events[_eventID].option2_pool += msg.value;
        } else {
            revert("Invalid option");
        }

        events[_eventID].voters[msg.sender] = _option;
    }

    function getBets(uint _eventID) public view returns (uint option1_pool, uint option2_pool) {
        option1_pool = events[_eventID].option1_pool;
        option2_pool = events[_eventID].option2_pool;
    }

    function dispense(uint _eventID) public {
        require(!events[_eventID].isActive, "Event is still active");

        uint winning_pool;
        uint losing_pool;
        uint winning_option;
        uint losing_option;

        if (events[_eventID].outcome == 1) {
            winning_pool = events[_eventID].option1_pool;
            losing_pool = events[_eventID].option2_pool;
            winning_option = 1;
            losing_option = 2;
        } else {
            winning_pool = events[_eventID].option2_pool;
            losing_pool = events[_eventID].option1_pool;
            winning_option = 2;
            losing_option = 1;
        }

        uint admin_fee = calculateAdminFee(winning_pool.add(losing_pool));

        uint total_payout = winning_pool.add(losing_pool).sub(admin_fee);

        uint total_winners = events[_eventID].votersByOption[winning_option].length;

        if (total_winners > 0) {
            uint payout_per_winner = total_payout.div(total_winners);

            for (uint i = 0; i < events[_eventID].votersByOption[winning_option].length; i++) {
                address payable voter_address = payable(events[_eventID].votersByOption[winning_option][i]);
                voter_address.transfer(payout_per_winner);
            }
        }

        uint total_losers = events[_eventID].votersByOption[losing_option].length;

        if (total_losers > 0) {
            for (uint i = 0; i < events[_eventID].votersByOption[losing_option].length; i++) {
                address payable voter_address = payable(events[_eventID].votersByOption[losing_option][i]);
                voter_address.transfer(events[_eventID].voters[voter_address]);
            }
        }

        uint admin_address = admin_fee.div(2);
        payable(adminAddress).transfer(admin_address);
        payable(owner).transfer(admin_fee.sub(admin_address));

        events[_eventID].isActive = false;
    }

    public function verify(uint _eventID, string memory _outcome) {
        require(events[_eventID].isActive == false, "Event is still active");

        if (keccak256(abi.encodePacked(_outcome)) == keccak256(abi.encodePacked(events[_eventID].option1))) {
            events[_eventID].outcome = 1;
        } else if (keccak256(abi.encodePacked(_outcome)) == keccak256(abi.encodePacked(events[_eventID].option2))) {
            events[_eventID].outcome = 2;
        } else {
            revert("Invalid outcome");
        }
    }
}