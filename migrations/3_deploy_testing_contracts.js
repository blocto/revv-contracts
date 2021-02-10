const REVVTokenTest = artifacts.require("REVVTokenTest");
const TeleportCustodyTest = artifacts.require("TeleportCustodyTest");

module.exports = async function(deployer) {
  await deployer.deploy(REVVTokenTest);
  await deployer.deploy(TeleportCustodyTest, REVVTokenTest.address);
};
