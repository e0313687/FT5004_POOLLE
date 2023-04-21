const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var User = artifacts.require("../contracts/User.sol");
var Event = artifacts.require("../contracts/Event.sol");

contract('Event', function(accounts) {
    let eventInstance;
    let userInstance;
    let userAddress;


    before(async () => {
        console.log("Testing Event and User Contract");
        eventInstance = await Event.deployed();
        userInstance = await User.deployed();
        userAddress = accounts[0];
    });

    it('Test createUser() function', async () => {
        // Call the createUser() function with sample arguments
        let username = "user1";
        let password = "password1";
        await userInstance.createUser(username, password, { from: userAddress });
        
        // Assert that the user was created
        let user = await userInstance.getUser(userAddress);
        assert.equal(user.username, username, "Username should match");
        assert.equal(user.password, password, "Password should match");
    });

    it('Test getUser() function', async () => {
        // Call the createUser() function to create a user
        let username = "user1";
        let password = "password1";
        await userInstance.createUser(username, password, { from: userAddress });
        
        // Call the getUser() function with user's address
        let user = await userInstance.getUser(userAddress);
        
        // Assert that the returned user data matches the expected data
        assert.equal(user.username, username, "Username should match");
        assert.equal(user.password, password, "Password should match");
    });

    it('Test createEvent() function', async () => {
        // Call the createEvent() function with sample arguments
        await eventInstance.createEvent("Trump", "Biden", "US President Election ", block.timestamp + 3600, 1 , { from: accounts[0] });
        
        // Assert that an event with ID 1 was created
        let eventIDs = await eventInstance.listEvents();
        let expectedEventID = 1;
        assert.equal(eventIDs.length, 1, "Number of events should be 1");
        assert.equal(eventIDs[0], expectedEventID, "Event ID should be 1");
    });

    it('Test placeBet() function', async () => {
        // Call the placeBet() function with sample arguments
        await eventInstance.placeBet(1, 1, { from: accounts[1], value: 1  });
        
        // Assert that a bet was placed for the event
        let bets = await eventInstance.getEventBets(1);
        let expectedOption = 1;
        assert.equal(bets.length, 1, "Number of bets should be 1");
        assert.equal(bets[0], expectedOption, "Bet option should be 1");
    });

    it('Test dispense() function', async () => {
        // Call the dispense() function
        await eventInstance.dispense(1, { from: accounts[0] });
        
        // Assert that the event outcome was dispensed
        let outcomeDispensed = await eventInstance.isOutcomeDispensed(1);
        assert.isTrue(outcomeDispensed, "Event outcome should be dispensed");
    });

    it('Test verify() function', async () => {
        // Call the verify() function with sample arguments
        await eventInstance.verify(1, "Option 1", { from: accounts[0] });
        
        // Assert that the event outcome was verified
        let outcomeVerified = await eventInstance.isOutcomeVerified(1);
        assert.isTrue(outcomeVerified, "Event outcome should be verified");
    });

});
