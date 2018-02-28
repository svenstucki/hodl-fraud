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

    Assert.equal(meta.owner(), address(this), "Deployed contract should be owned by test contract.");
  }

  function testDefraudHodler() public {
    Assert.equal(meta.ownerAmount(), 1 ether, "Owner amount should be 1 Eth initially.");

    // hodl 1 Eth for 1000 seconds
    meta.payIn.value(1 ether)(1000);

    Assert.equal(meta.ownerAmount(), 2 ether, "Owner balance should include hodler funds.");

    // steal funds as owner
    uint balance = this.balance;
    meta.ownerWithdrawal();
    uint difference = this.balance - balance;

    Assert.equal(difference, 2 ether, "Owner should be able to steal all funds.");
  }

  function testDefraudOwner() public {
    Assert.equal(meta.ownerAmount(), 1 ether, "Owner amount should be 1 Eth initially.");

    // hodl 1 Eth for 0 seconds
    meta.payIn.value(1 ether)(0);

    Assert.equal(meta.balanceOf(address(this)), 2 ether, "Hodler balance should include owner amount.");

    // steal funds as hodler
    uint balance = this.balance;
    meta.withdraw();
    uint difference = this.balance - balance;

    Assert.equal(difference, 2 ether, "Hodler should be able to steall all funds.");
    return;
  }

  function testStateAssignmentCopiesValues() public {
    Assert.equal(meta.numberOfPayouts(), 0, "Number of payouts should be 0 initially.");

    // hodl 1 Eth
    meta.payIn.value(1 ether)(10);
    Assert.equal(meta.numberOfPayouts(), now + 10, "Number of payouts should've been overwritten by unlock time.");

    meta.increaseUnlockTime(10);
    Assert.equal(meta.numberOfPayouts(), now + 10, "Number of payouts should not change when updating unlock time.");
  }

  // allow Eth transfers to this contract
  function () public payable {}
}
