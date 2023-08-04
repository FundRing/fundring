// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './DateTime.sol';
import './IFundRingProject.sol';

contract FundRingProject is IFundRingProject {
  string public projectName;
  string public githubRepoLink;
  uint256 public fundingGoal;
  string public fundingFrequency;
  uint256 public totalFundsRaised;
  address public projectOwner;

  DateTime public DT;

  mapping(string => uint256) private fundsRaisedByFrequency;
  mapping(string => uint256) private fundsRaisedByMonth;
  mapping(uint256 => uint256) private fundsRaisedByYear;
  string private lastMonth;
  uint256 private lastYear;

  event FundRingProjectDeployed(
    address indexed owner,
    string projectName,
    string githubRepoLink,
    uint256 fundingGoal,
    string fundingFrequency
  );
  event FundRingFundsContributed(
    address indexed contributor,
    uint256 amountContributed,
    uint256 totalFundsRaised
  );
  event FundRingFundingGoalReached(
    uint256 totalFundsRaised,
    string frequency,
    string currentPeriod
  );

  constructor(
    string memory _projectName,
    string memory _githubRepoLink,
    uint256 _fundingGoal,
    string memory _fundingFrequency
  ) {
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

    DT = new DateTime();

    projectName = _projectName;
    githubRepoLink = _githubRepoLink;
    fundingGoal = _fundingGoal;
    fundingFrequency = _fundingFrequency;
    projectOwner = msg.sender;
    lastMonth = getCurrentMonth();
    lastYear = getCurrentYear();

    emit FundRingProjectDeployed(
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

  function contributeFunds() external payable override {
    require(msg.value > 0, 'You must send some ether to contribute.');

    totalFundsRaised += msg.value;
    fundsRaisedByFrequency[fundingFrequency] += msg.value;

    if (compareStrings(fundingFrequency, 'monthly')) {
      updateMonthlyFunds(msg.value);
    } else if (compareStrings(fundingFrequency, 'annually')) {
      updateYearlyFunds(msg.value);
    }

    emit FundRingFundsContributed(msg.sender, msg.value, totalFundsRaised);

    if (isFundingComplete()) {
      if (compareStrings(fundingFrequency, 'monthly')) {
        emit FundRingFundingGoalReached(
          totalFundsRaised,
          fundingFrequency,
          getCurrentMonth()
        );
      } else if (compareStrings(fundingFrequency, 'annually')) {
        emit FundRingFundingGoalReached(
          totalFundsRaised,
          fundingFrequency,
          uint2str(getCurrentYear())
        );
      } else {
        emit FundRingFundingGoalReached(
          totalFundsRaised,
          fundingFrequency,
          'all time'
        );
      }
    }
  }

  function updateMonthlyFunds(uint256 amount) private {
    string memory currentMonth = getCurrentMonth();
    if (fundsRaisedByMonth[currentMonth] == 0) {
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

  function getCurrentMonth() public view returns (string memory) {
    uint256 monthNumber = DT.getMonth(block.timestamp);
    if (monthNumber == 1) return 'january';
    if (monthNumber == 2) return 'february';
    if (monthNumber == 3) return 'march';
    if (monthNumber == 4) return 'april';
    if (monthNumber == 5) return 'may';
    if (monthNumber == 6) return 'june';
    if (monthNumber == 7) return 'july';
    if (monthNumber == 8) return 'august';
    if (monthNumber == 9) return 'september';
    if (monthNumber == 10) return 'october';
    if (monthNumber == 11) return 'november';
    if (monthNumber == 12) return 'december';
    return '';
  }

  function getCurrentYear() public view returns (uint256) {
    return DT.getYear(block.timestamp);
  }

  function isFundingComplete() public view override returns (bool) {
    if (compareStrings(fundingFrequency, 'monthly')) {
      string memory currentMonth = getCurrentMonth();
      return fundsRaisedByMonth[currentMonth] >= fundingGoal;
    } else if (compareStrings(fundingFrequency, 'annually')) {
      uint256 currentYear = getCurrentYear();
      return fundsRaisedByYear[currentYear] >= fundingGoal;
    } else {
      return totalFundsRaised >= fundingGoal;
    }
  }

  function getFundingFrequency() public view override returns (string memory) {
    return fundingFrequency;
  }

  function getTotalFundsRaised() public view override returns (uint256) {
    return totalFundsRaised;
  }

  function getFundsRaisedByMonth(
    string memory month
  ) public view returns (uint256) {
    return fundsRaisedByMonth[month];
  }

  function getFundsRaisedByYear(uint256 year) public view returns (uint256) {
    return fundsRaisedByYear[year];
  }

  function uint2str(
    uint _i
  ) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return '0';
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len;
    while (_i != 0) {
      k = k - 1;
      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }

  function withdrawFunds() external override {
    require(
      msg.sender == projectOwner,
      'Only the project owner can withdraw funds.'
    );
    require(isFundingComplete(), 'Funding goal not reached yet.');

    address payable ownerAddress = payable(projectOwner);
    ownerAddress.transfer(address(this).balance);
  }
}
