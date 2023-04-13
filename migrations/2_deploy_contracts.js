const PoolleEvent = artifacts.require("PoolleEvent");
const User = artifacts.require("User");

module.exports = (deployer, network, accounts) => {
    deployer.deploy(PoolleEvent).then(function() {
        return deployer.deploy(User, PoolleEvent.address, 1);
    });
};