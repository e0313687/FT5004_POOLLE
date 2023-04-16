// User.sol
pragma solidity ^0.8.0;

import "./Event.sol";

contract User {
    struct UserStruct {
        address user_wallet_address;
        string username;
        string password;
        uint[] bet_id;
        uint[] bet_amount;
    }

    mapping (address => UserStruct) users;
    address[] user_addresses;
    Event eventContract;

    constructor(address _eventContractAddress) {
        eventContract = Event(_eventContractAddress);
    }

    function createUser(string memory _username, string memory _password) public {
        require(users[msg.sender].user_wallet_address == address(0), "User already exists");
        users[msg.sender] = UserStruct(
            msg.sender,
            _username,
            _password,
            new uint[](0),
            new uint[](0)
        );
        user_addresses.push(msg.sender);
    }

    function getUser(address _userAddress) public view returns (address, string memory, string memory, uint[] memory, uint[] memory) {
        UserStruct memory user = users[_userAddress];
        return (user.user_wallet_address, user.username, user.password, user.bet_id, user.bet_amount);
    }

    function createEvent(string memory _option1, string memory _option2, string memory _description, uint _deadline, uint _minimum_bet) public {
        eventContract.createEvent(_option1, _option2, _description, _deadline, _minimum_bet);
    }

    function placeBet(uint _eventId, uint _option) public payable {
        (bool success, ) = address(eventContract).call{value: msg.value}(abi.encodeWithSignature("placeBet(uint256,uint256)", _eventId, _option));
        require(success, "Failed to place bet");
        users[msg.sender].bet_id.push(_eventId);
        users[msg.sender].bet_amount.push(msg.value);
    }

    function listEvents() public view returns (Event.EventStruct[] memory) {
        return eventContract.listEvents();
    }
}