// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '../lib/forge-std/src/Test.sol';
import '../contracts/FundRingProject.sol';

contract TestFundRingProject is Test {
  FundRingProject fundRingProject;

  function setUp() public {
    // Deploy the FundRingProject contract before each test
    fundRingProject = new FundRingProject(
      'Test Project',
      'https://github.com/test/test-project.git',
      1000,
      'monthly'
    );
  }

  function testDeployment() public {
    assertEq(
      fundRingProject.projectName(),
      'Test Project',
      'Project name should match'
    );
    assertEq(fundRingProject.fundingGoal(), 1000, 'Funding goal should match');
    assertEq(
      fundRingProject.getFundingFrequency(),
      'monthly',
      'Funding frequency should match'
    );
    assertEq(
      fundRingProject.getTotalFundsRaised(),
      0,
      'Total funds raised should be zero initially'
    );
  }

  function testContributeFunds() public {
    uint256 initialBalance = address(this).balance;
    uint256 contributionAmount = 1 ether;

    // Make a contribution
    fundRingProject.contributeFunds{value: contributionAmount}();
    uint256 totalFundsRaised = fundRingProject.getTotalFundsRaised();

    assertEq(
      totalFundsRaised,
      contributionAmount,
      'Total funds raised should match the contribution amount'
    );
    assertEq(
      address(this).balance,
      initialBalance - contributionAmount,
      'Contract balance should decrease by contribution amount'
    );
  }

  function testWithdrawFunds() public {
    uint256 fundingGoal = fundRingProject.fundingGoal();
    uint256 contributionAmount = 1000;

    // Make a contribution
    fundRingProject.contributeFunds{value: contributionAmount}();

    assertEq(
      fundRingProject.isFundingComplete(),
      true,
      'isFundingComplete() should return true'
    );

    if (contributionAmount >= fundingGoal) {
      uint256 initialBalance = address(this).balance;
      address payable projectOwner = payable(fundRingProject.projectOwner());

      // Make the withdrawal
      fundRingProject.withdrawFunds();

      assertEq(
        address(this).balance,
        initialBalance - contributionAmount,
        'Contract balance should decrease by contribution amount'
      );
      assertEq(address(this).balance, 0, 'All funds should be withdrawn');
      assertEq(
        projectOwner.balance,
        contributionAmount,
        'Project owner should receive the funds'
      );
    }
  }
}
