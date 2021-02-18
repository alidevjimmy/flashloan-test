const FlashLoan = artifacts.require("FlashLoan");

module.exports = function (deployer) {
  deployer.deploy(FlashLoan);
  deployer.deploy(FlashLoan, "0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5");
};
