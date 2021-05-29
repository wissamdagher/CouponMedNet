pragma solidity ^0.5.0;

contract Doctorvisit {
  string name;
  uint public visitCount; 
  struct Visit {
    uint id;
    uint empId;
    uint couponId;
  }

  event VisitCreated (
    uint Id,
    uint empId,
    uint couponId
  );


  mapping(uint => Visit) public visits;

  constructor() public {
    name = "Doctorvisit contract initialised";
    visitCount = 0;
  }

  function setName(string memory _name) public { 
    name = _name;
  }

  function getName() public view returns (string memory) {
    return name;
  }

  function createVisit(uint _empId, uint _couponId) public {
    visitCount ++;
    Visit(visitCount, _empId, _couponId);

    emit VisitCreated(visitCount, _empId, _couponId);
  }

}