// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundRingProject {
  string public projectName;
  string public githubRepoLink;
  uint256 public fundingGoal;
  string public fundingFrequency;
  uint256 public totalFundsRaised;
  address public projectOwner;

  mapping(string => uint256) private fundsRaisedByFrequency;
  mapping(uint256 => uint256) private fundsRaisedByMonth;
  mapping(uint256 => uint256) private fundsRaisedByYear;
  uint256 private lastMonth;
  uint256 private lastYear;

  event ProjectDeployed(
    address indexed owner,
    string projectName,
    string githubRepoLink,
    uint256 fundingGoal,
    string fundingFrequency
  );
  event FundsContributed(
    address indexed contributor,
    uint256 amountContributed,
    uint256 totalFundsRaised
  );
  event FundingGoalReached(uint256 totalFundsRaised);

  constructor() {
    string memory _projectName = 'Fund Ring';
    string memory _githubRepoLink = 'https://github.com/oddsdk/fundring.git';
    uint256 _fundingGoal = 300000000000000000000;
    string memory _fundingFrequency = 'monthly';

    require(bytes(_projectName).length > 0, 'Project name cannot be empty.');
    require(
      bytes(_githubRepoLink).length > 0,
      'GitHub repo link cannot be empty.'
    );
    require(_fundingGoal > 0, 'Funding goal must be greater than zero.');
    require(
      compareStrings(_fundingFrequency, 'one-time') ||
        compareStrings(_fundingFrequency, 'monthly') ||
        compareStrings(_fundingFrequency, 'annually'),
      "Invalid funding frequency. Use 'one-time', 'monthly', or 'annually'."
    );

    projectName = _projectName;
    githubRepoLink = _githubRepoLink;
    fundingGoal = _fundingGoal;
    fundingFrequency = _fundingFrequency;
    projectOwner = msg.sender;
    lastMonth = getCurrentMonth();
    lastYear = getCurrentYear();

    emit ProjectDeployed(
      msg.sender,
      _projectName,
      _githubRepoLink,
      _fundingGoal,
      _fundingFrequency
    );
  }

  function compareStrings(
    string memory a,
    string memory b
  ) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) ==
      keccak256(abi.encodePacked((b))));
  }

  function contributeFunds() external payable {
    require(msg.value > 0, 'You must send some ether to contribute.');

    totalFundsRaised += msg.value;
    fundsRaisedByFrequency[fundingFrequency] += msg.value;

    if (compareStrings(fundingFrequency, 'monthly')) {
      updateMonthlyFunds(msg.value);
    } else if (compareStrings(fundingFrequency, 'annually')) {
      updateYearlyFunds(msg.value);
    }

    emit FundsContributed(msg.sender, msg.value, totalFundsRaised);

    if (isFundingComplete()) {
      emit FundingGoalReached(totalFundsRaised);
    }
  }

  function updateMonthlyFunds(uint256 amount) private {
    uint256 currentMonth = getCurrentMonth();
    if (currentMonth > lastMonth) {
      lastMonth = currentMonth;
      fundsRaisedByMonth[currentMonth] = amount;
    } else {
      fundsRaisedByMonth[currentMonth] += amount;
    }
  }

  function updateYearlyFunds(uint256 amount) private {
    uint256 currentYear = getCurrentYear();
    if (currentYear > lastYear) {
      lastYear = currentYear;
      fundsRaisedByYear[currentYear] = amount;
    } else {
      fundsRaisedByYear[currentYear] += amount;
    }
  }

  function getCurrentMonth() private view returns (uint256) {
    return ((block.timestamp / 1 days) % 30) + 1;
  }

  function getCurrentYear() private view returns (uint256) {
    return (block.timestamp / 1 days) / 365;
  }

  function isFundingComplete() public view returns (bool) {
    if (compareStrings(fundingFrequency, 'monthly')) {
      uint256 currentMonth = getCurrentMonth();
      return fundsRaisedByMonth[currentMonth] >= fundingGoal;
    } else if (compareStrings(fundingFrequency, 'annually')) {
      uint256 currentYear = getCurrentYear();
      return fundsRaisedByYear[currentYear] >= fundingGoal;
    } else {
      return totalFundsRaised >= fundingGoal;
    }
  }

  // Getter method to return the totalFundsRaised
  function getTotalFundsRaised() public view returns (uint256) {
    return totalFundsRaised;
  }

  // Getter method to return the fundingFrequency
  function getFundingFrequency() public view returns (string memory) {
    return fundingFrequency;
  }

  function withdrawFunds() external {
    require(
      msg.sender == projectOwner,
      'Only the project owner can withdraw funds.'
    );
    require(isFundingComplete(), 'Funding goal not reached yet.');

    address payable ownerAddress = payable(projectOwner);
    ownerAddress.transfer(address(this).balance);
  }
}
