// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract Deposit{
    struct DepositedData{
        uint256 amount;
        uint256 depositTime;
    }
    event EtherDeposited(address depositor, uint256 amount, uint256 depositedTime, uint256 depositCount);
    event EtherWithdrawn(address depositor, uint256 amount, uint256 withdrawalTime, uint256 depositCount);

    mapping(address => DepositedData[]) public deposits;
    uint256 public timeForWithdrawal = 20 seconds;

    function deposit() external payable{
        require(msg.value > 0, "Amount cannot be zero!");
        deposits[msg.sender].push(DepositedData(msg.value, block.timestamp));
        emit EtherDeposited(msg.sender, msg.value, block.timestamp, deposits[msg.sender].length + 1);
    }

    function withdraw() external{
        require(deposits[msg.sender].length > 0, "No amount deposited!");
        uint256 actualSize = deposits[msg.sender].length;
        for(uint i = 0; i < deposits[msg.sender].length; i++){
            if((deposits[msg.sender][i].depositTime + timeForWithdrawal) <= block.timestamp){
                payable(msg.sender).transfer(deposits[msg.sender][i].amount);
                emit EtherWithdrawn(msg.sender, deposits[msg.sender][i].amount, block.timestamp, i+1);
                delete deposits[msg.sender][i];
                deposits[msg.sender][i] = deposits[msg.sender][deposits[msg.sender].length - 1];
                deposits[msg.sender].pop();
            }
        }
        require(actualSize > deposits[msg.sender].length, "No any deposit is matured till now!");
    }

}
