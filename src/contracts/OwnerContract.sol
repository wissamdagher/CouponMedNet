// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract OwnerContract {    address public owner = msg.sender;
    uint public creationTime = block.timestamp;    modifier onlyBy(address _account) {
        require(
            msg.sender == _account,
            "Sender not authorized."
        );
        _;
    }    modifier onlyAfter(uint _time) {
        require(
            block.timestamp >= _time,
            "Function called too early."
        );
        _;
    }    function disown() public onlyBy(owner) onlyAfter(creationTime + 6 weeks) {
        delete owner;
    }}