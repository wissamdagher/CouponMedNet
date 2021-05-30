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
    bool flag;
  } 
  
  struct Family {
      uint id;
      uint empId;
      uint count;
      bool active;
      uint activeMembers;
      bool flag;
  }
  
  struct Member {
      uint id;
      uint empId;
      address owner;
      bool active;
  }
  
  event employeeRegistration(
    uint id,
    uint empId,
    bool active,
    string msg
  );

  event employeeNotRegistered(
    uint id,
    uint empId,
    address owner,
    bool active
  );
  
  event empFamilyRegistration(
      uint familyCounter,
      uint _empId,
      uint flag,
      string msg
  );
  
  event memberRegistration(
      uint memberCounter, 
      string msg );
  

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
     if(canRegister(_empId)) {
        employeeCount ++;
        employees[_empId] = Emp(employeeCount, _empId, msg.sender, false, true);
    
        emit employeeRegistration(employeeCount,_empId, false, "success"); 
     }
     else {
         emit employeeRegistration(employeeCount,_empId, false, "failure"); 
     }
  }
  
  function registerFamily(uint _empId, uint _count) public {
      
      if(!familyExists(_empId) && (isRegistered(_empId))) {
      familyCounter ++;
      Family memory _family = Family(familyCounter, _empId, _count, true, 0, true);
      EmployeeFamily[_empId].push(_family);
      
      emit empFamilyRegistration(familyCounter, _empId, 1, "success");
      } else {
                emit empFamilyRegistration(familyCounter, _empId, 0, "failure");
      }

  }
  
  function registerMember(uint _empId, address _address) public {
          if(canRegisterMember(_empId)) {
              memberCounter ++;
              EmployeeToFamilyMembers[_empId][memberCounter] = Member(memberCounter, _empId, _address, true);
              Family memory _family = EmployeeFamily[_empId][0];
              _family.activeMembers ++;
              EmployeeFamily[_empId][0] = _family;
              
              emit memberRegistration(memberCounter, "success");
          } else
          {
              emit memberRegistration(memberCounter, "failure");
          }

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
  //check if employee can register, not already registered
  function canRegister(uint _id) private view returns (bool) {
      if(employees[_id].flag) {
          return false;
      }
      else {
          return true;          
      }
  }
  //check if employee is already registered and activated
  function isRegistered(uint _id) private view returns (bool) {
      if(employees[_id].flag && employees[_id].active) {
          return true;          
      } else {
          return false;
      }
  }
  
  //check if family member can register, activeMembers allows
  function canRegisterMember(uint _id) private view returns(bool) {
      //set the family of the employee
      Family memory _family = EmployeeFamily[_id][0];
      if(_family.active) {
        if ((_family.activeMembers < _family.count)) {
              return true;
          } else {
              return false;
          } 
      } else {
          return false;
      }

  }

}