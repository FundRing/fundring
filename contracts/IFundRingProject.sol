// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFundRingProject {
  function projectName() external view returns (string memory);

  function githubRepoLink() external view returns (string memory);

  function fundingGoal() external view returns (uint256);

  function fundingFrequency() external view returns (string memory);

  function totalFundsRaised() external view returns (uint256);

  function projectOwner() external view returns (address);

  function contributeFunds() external payable;

  function isFundingComplete() external view returns (bool);

  function getTotalFundsRaised() external view returns (uint256);

  function getFundingFrequency() external view returns (string memory);

  function withdrawFunds() external;
}
