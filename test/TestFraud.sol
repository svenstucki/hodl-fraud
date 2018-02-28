pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/HodlFraud.sol";

contract TestFraud {
  // supply test contract with Eth
  uint public initialBalance = 10 ether;

  HodlFraud public meta;

  function beforeEach() public {
    // deploy contract with 1 Eth initial owner balance
    meta = (new HodlFraud).value(1 ether)();
  }

  function testDefraudHodler() public {
    Assert.equal(meta.ownerAmount(), 1 ether, "Owner amount should be 1 Eth initially.");

    // hodl 1 Eth for 1000 seconds
    meta.payIn.value(1 ether)(1000);

    Assert.equal(meta.ownerAmount(), 2 ether, "Owner should be able to steal all funds.");
  }

  function testDefraudOwner() public {
    Assert.equal(meta.ownerAmount(), 1 ether, "Owner amount should be 0 initially.");

    // hodl 1 Eth for 1000 seconds
    meta.payIn.value(1 ether)(1000);

    Assert.equal(meta.balanceOf(address(this)), 2 ether, "Hodler should be able to steal all funds.");
  }
}
