pragma solidity ^0.5.0;

contract Employee {
  string name; 
  address owner;
  uint public employeeCount; 
  uint familyCounter;
  uint memberCounter;
  
  struct Emp {
    uint id;
    uint empId;
    address owner;
    bool active;
  } 
  
  struct Family {
      uint id;
      uint empId;
      uint count;
      uint activeMembers;
      bool flag;
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
  
  event empFamilyRegistered(
      uint familyCounter,
      uint _empId,
      uint flag,
      string msg
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
  mapping(uint => mapping(uint => Member)) public EmployeeToFamilyMembers;
  mapping(uint => Family[]) public EmployeeFamily;

  constructor() public {
    name = "Employee contract initialised";
    employeeCount = 0;
    memberCounter = 0;
    familyCounter = 0;
    owner = msg.sender;
  }

  function setName(string memory _name) public { 
    name = _name;
  }

  function getName() public view returns (string memory) {
    return name;
  }

  function registerEmployee(uint _empId) public {
    employeeCount ++;
    employees[_empId] = Emp(employeeCount, _empId, msg.sender, false);

    emit employeeRegistered(employeeCount,_empId, msg.sender, false);
  }
  
  function registerFamily(uint _empId, uint _count) public {
      
      if(!familyExists(_empId)) {
      familyCounter ++;
      Family memory _family = Family(familyCounter, _empId, _count, 0, true);
      EmployeeFamily[_empId].push(_family);
      
      emit empFamilyRegistered(familyCounter, _empId, 1, "success");
      } else {
                emit empFamilyRegistered(familyCounter, _empId, 0, "failure");
      }

  }
  
  function registerMember(uint _empId, address _address) public {
          memberCounter ++;
          EmployeeToFamilyMembers[_empId][memberCounter] = Member(memberCounter, _empId, _address, true);
          Family memory _family = EmployeeFamily[_empId][0];
          _family.activeMembers ++;
          EmployeeFamily[_empId][0] = _family;
  }
  
  function familyExists(uint _empId) private view returns(bool){
      if (EmployeeFamily[_empId].length > 0) {
          return true;
      }
      else {
          return false;
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