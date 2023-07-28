// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '../lib/forge-std/src/Test.sol';
import '../contracts/FundRingProject.sol';

// contract CounterTest is Test {
//   Counter public counter;

//   function setUp() public {
//     counter = new Counter();
//     counter.setNumber(0);
//   }

//   function testIncrement() public {
//     counter.increment();
//     assertEq(counter.number(), 1);
//   }

//   function testSetNumber(uint256 x) public {
//     counter.setNumber(x);
//     assertEq(counter.number(), x);
//   }
// }

contract TestFundRingProject is Test {
  FundRingProject public fundRingProject;
  string expectedProjectName = 'Fund Ring';
  string expectedGithubRepoLink = 'https://github.com/fundring.git';
  uint256 expectedFundingGoal = 300000000000000000000;
  string expectedFundingFrequency = 'monthly';

  function setUp() public {
    fundRingProject = new FundRingProject();
  }

  // Test case: Check project details after deployment
  function testProjectDetails() public {
    assertEq(
      fundRingProject.projectName(),
      expectedProjectName,
      'Incorrect project name'
    );
    assertEq(
      fundRingProject.githubRepoLink(),
      expectedGithubRepoLink,
      'Incorrect GitHub repo link'
    );
    assertEq(
      fundRingProject.fundingGoal(),
      expectedFundingGoal,
      'Incorrect funding goal'
    );
    assertEq(
      fundRingProject.fundingFrequency(),
      expectedFundingFrequency,
      'Incorrect funding frequency'
    );
    assertEq(
      fundRingProject.projectOwner(),
      address(this),
      'Incorrect project owner'
    );
  }

  // Test case: Contribute funds and check the total funds raised
  function testContributeFunds() public payable {
    uint256 contributionAmount = 50 ether;

    fundRingProject.contributeFunds{value: contributionAmount}();
    uint256 totalFundsRaised = fundRingProject.totalFundsRaised();

    assertEq(
      totalFundsRaised,
      contributionAmount,
      'Incorrect total funds raised after contribution'
    );
  }

  // Test case: Check if the funding goal is reached
  function testFundingGoalReached() public {
    uint256 fundingGoal = fundRingProject.fundingGoal();
    bool isFundingComplete = fundRingProject.isFundingComplete();

    assertEq(
      isFundingComplete,
      false,
      'Funding goal should not be reached yet'
    );

    uint256 remainingFunds = fundingGoal - fundRingProject.totalFundsRaised();
    fundRingProject.contributeFunds{value: remainingFunds}();
    isFundingComplete = fundRingProject.isFundingComplete();

    assertEq(isFundingComplete, true, 'Funding goal should be reached');
  }

  // Test case: Withdraw funds after the funding goal is reached
  function testWithdrawFunds() public {
    uint256 initialBalance = address(this).balance;

    fundRingProject.withdrawFunds();

    assertEq(
      address(this).balance,
      initialBalance + fundRingProject.totalFundsRaised(),
      'Incorrect contract balance after withdrawal'
    );
  }
}
