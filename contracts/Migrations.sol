// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Migrations {
    address public owner;
    uint256 public last_completed_migration;

    constructor() {
        owner = msg.sender;
    }

    function setCompleted(uint256 completed) public {
        require(msg.sender == owner, "Only the contract owner can call this function");
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public {
        require(msg.sender == owner, "Only the contract owner can call this function");
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}
