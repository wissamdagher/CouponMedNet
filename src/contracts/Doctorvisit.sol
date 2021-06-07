pragma solidity ^0.5.0;

contract Doctorvisit {
  string name;
  address owner;
  uint public visitCount; 

  struct Visit {
    uint id;
    uint empId;
    uint couponId;
    uint doctorId;
  }

  event VisitCreated (
    uint Id,
    uint empId,
    uint couponId,
    string msg
  );

  //visits  mapping incremental
  mapping(uint => Visit) public visits;
  //employee doctor visits array
  mapping(address => Visit[]) public empDoctorVisists;

  constructor() public {
    name = "Doctorvisit contract initialised";
    visitCount = 0;
    owner = msg.sender;
  }

  function setName(string memory _name) public { 
    name = _name;
  }

  function getName() public view returns (string memory) {
    return name;
  }

  function createVisit(uint _empId, uint _couponId, uint _doctorId) public {
    visitCount ++;
    Visit memory _visit;
    _visit = Visit(visitCount, _empId, _couponId, _doctorId);
    visits[visitCount] = _visit;
    empDoctorVisists[msg.sender].push(_visit);

    emit VisitCreated(visitCount, _empId, _couponId, "success");
  }

  function validateVisit(uint _visitId) {
    
  }

}