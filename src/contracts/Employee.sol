pragma solidity ^0.5.0;

contract Employee {
  string name; 
  address owner;
  uint public employeeCount; 
  uint memberCount;
  
  struct Emp {
    uint id;
    uint empId;
    address owner;
    bool active;
  } 
  
  struct Family {
      address empAddress;
      uint count;
  }
  
  struct Member {
      uint id;
      uint empId;
      address owner;
      bool active;
  }
  
  event employeeRegistered(
    uint id,
    uint empId,
    address owner,
    bool active
  );

  event employeeNotRegistered(
    uint id,
    uint empId,
    address owner,
    bool active
  );

  event employeeActivated(
    uint id,
    address originalOwner,
    address empAddress,
    bool active
  );

  event employeeDisabled(
    uint id,
    string message
  );

  mapping(uint => Emp) public employees;
  mapping(uint => Member) public members;
  mapping(uint => Family) public families;

  constructor() public {
    name = "Employee contract initialised";
    employeeCount = 0;
    memberCount = 0;
    owner = msg.sender;
  }

  function setName(string memory _name) public { 
    name = _name;
  }

  function getName() public view returns (string memory) {
    return name;
  }

  function registerEmployee(uint _empId) public {
    if (canRegister(_empId)) {
    employeeCount ++;
    employees[employeeCount] = Emp(employeeCount, _empId, msg.sender, false);

    emit employeeRegistered(employeeCount,_empId, msg.sender, false);
    }
    else {
      emit employeeNotRegistered(employeeCount,_empId, msg.sender, false);
    }
  }
  
  function registerMember(uint _empId, address _address) public {
      if (isRegistered(_empId)) {
          memberCount ++;
          members[memberCount] = Member(memberCount, _empId, _address, true);
      }
  }

  function activateEmployee(uint _id) public {
        address originalOwner;
        // Fetch the product
        Emp memory _employee = employees[_id];
        originalOwner = _employee.owner;
        require(!_employee.active);
        require(originalOwner == msg.sender);
        _employee.active = true;
        employees[_id] = _employee;
        // Trigger an event
        emit employeeActivated(_id, originalOwner, msg.sender, true);
  }

  function disableEmployee(uint _id) public {
    Emp memory _employee = employees[_id];
    _employee.active = false;
    employees[_id] = _employee;

    emit employeeDisabled(_id, "employee disabled");
  }

  function canRegister(uint _id) private returns (bool) {
    return true;
  }
  
  function isRegistered(uint _id) private returns (bool) {
      return true;
  }

}