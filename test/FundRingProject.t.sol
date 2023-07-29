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
    // Test that the contract is deployed with the correct values
    assertEq(
      fundRingProject.projectName(),
      'Test Project',
      'Incorrect project name'
    );
    assertEq(
      fundRingProject.githubRepoLink(),
      'https://github.com/test/test-project.git',
      'Incorrect GitHub repo link'
    );
    assertEq(fundRingProject.fundingGoal(), 1000, 'Incorrect funding goal');
    assertEq(
      fundRingProject.fundingFrequency(),
      'monthly',
      'Incorrect funding frequency'
    );
    assertEq(
      fundRingProject.totalFundsRaised(),
      0,
      'Initial funds raised should be 0'
    );
    assertEq(
      fundRingProject.projectOwner(),
      address(this),
      'Incorrect project owner'
    );
  }

  function testContributeFunds() public {
    // Test that funds can be contributed to the contract
    fundRingProject.contributeFunds{value: 500}();
    fundRingProject.contributeFunds{value: 300}();
    fundRingProject.contributeFunds{value: 200}();

    assertEq(
      fundRingProject.totalFundsRaised(),
      1000,
      'Total funds raised should be equal to the funding goal'
    );

    assertTrue(
      fundRingProject.isFundingComplete(),
      'Funding goal should be reached'
    );
  }

  function testMonthlyFunding() public {
    // Test monthly funding functionality
    fundRingProject = new FundRingProject(
      'Test Monthly Project',
      'https://github.com/test/monthly-project.git',
      500,
      'monthly'
    );

    fundRingProject.contributeFunds{value: 100}();
    fundRingProject.contributeFunds{value: 200}();
    fundRingProject.contributeFunds{value: 100}();

    assertFalse(
      fundRingProject.isFundingComplete(),
      'Funding goal should not be reached yet'
    );

    // Wait for one month (30 days) to pass
    uint256 thirtyDays = 30 * 1 days;
    uint256 futureTime = block.timestamp + thirtyDays;
    // while (block.timestamp < futureTime) {
    //   block.timestamp += 1;
    // }

    fundRingProject.contributeFunds{value: 100}();

    assertTrue(
      fundRingProject.isFundingComplete(),
      'Funding goal should be reached after one month'
    );
  }

  // Add more tests as needed...
}
