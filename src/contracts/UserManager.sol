// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    modifier notOwner() {
       require(msg.sender != owner, "Caller is owner");
        _; 
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

contract UserInvite is Owner{ 


    
    struct Invitation { 
        uint id;
        uint invtype;
    }
    
    event delinvitee (
        string  msg
        );

    mapping (uint => Invitation) internal invitationById;
    uint[] internal invitees;
    
    modifier isInvited(uint _code, uint _id, uint _usertype) {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(invitationById[_code].id == _id && invitationById[_code].invtype == _usertype, "Caller is not invited");
        _;
    }

    function find(uint value) private view returns(uint) {
        uint i = 0;
        while (invitees[i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint value) private {
        uint i = find(value);
        removeByIndex(i);
    }

    function removeByIndex(uint i) private {
            invitees[i] = invitees[invitees.length -1];
            invitees.pop();
        }
    
    
    function addInvitation(uint _code, uint _id, uint _usertype) public isOwner { 
        require(invitationById[_code].id == 0, "Already invitation code exists");
        invitationById[_code].id = _id;
        invitationById[_code].invtype = _usertype;
        
        invitees.push(_id);
    }
    
    function deleteInvitation(uint _code, uint _id) internal {
         delete invitationById[_code];
         removeByValue(_id);
         emit delinvitee("deleted");
    }
    
    function getInvitations() public isOwner view returns (uint[] memory)  {
        return invitees;
    }
    
}

contract EmployeeManager is UserInvite { 

    struct Employee { 
        uint id;
        uint empid; //empid provided by HR
        uint maxfamilycount; //maximum number of family members that can register
        uint initialCouponCount;
        uint extraCouponCount;
        bool active;
    }

    struct Family {
      uint id;
      uint empId;
      uint count;
      bool active;
      uint activeMembers;
    }

    event empFamilyRegistration(uint familyCounter, string msg);
  
  struct Member {
      uint id;
      uint empId;
      uint familyId;
      address owner;
      bool active;
   }
    
    uint employeesCounter;
    uint familyCounter;
    uint memberCounter;
    
    mapping (address => Employee) internal employees;
    mapping (uint => address) internal employeeIndexToOwner;
    mapping (uint => uint) internal employeeIDtoIndex;

    //family
    mapping(uint => Family) public EmployeeFamily;

    //Family Member
    mapping (address => Member) public familyMembers;

    uint[] public registeredEmployees;
    
    constructor() {
        employeesCounter = 0;
        memberCounter = 0;
        familyCounter = 0;
    }

    function isEmployee(uint _type) private pure returns (bool) {
        if (_type ==1) {
            return true;
        }
        else {
            return false;
        }
    }
    
    
    modifier isRegisteredEmployee(address _address) {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(employees[_address].active == true, "Employee Not Registered");
        _;
    }
    
    modifier isNotRegistered(address _address) {
        require(employees[_address].active == false, "Employee  Registered");
        _;
    }

    //function can be called by User with an invitation on the system
    function registerEmployee(uint _empid, uint _maxfamilycount, uint _code, uint _usertype ) public notOwner isInvited(_code,_empid, _usertype) isNotRegistered(msg.sender) {
        require(isEmployee(_usertype), "Not an employee type");
        employeesCounter ++;
        employees[msg.sender] = Employee(employeesCounter, _empid, _maxfamilycount,0,0,true);
        registeredEmployees.push(_empid);
        employeeIndexToOwner[employeesCounter] = msg.sender;
        employeeIDtoIndex[_empid] = employeesCounter;
        deleteInvitation(_code,_empid);
        registerFamily(_empid, _maxfamilycount, msg.sender);
    }

    function getEmployee(address _address) internal view returns (Employee memory){
        return( employees[_address]);
    }

    function registerFamily(uint _empId, uint _count, address _address) internal isRegisteredEmployee(_address) {
        require(_count > 0, "Family members should be more than 0");
        require(!familyExists(_empId), "Family exists");
        familyCounter ++;
        Family memory _family = Family(familyCounter, _empId, _count, true, 0);
        EmployeeFamily[_empId] = _family;
        
        emit empFamilyRegistration(familyCounter, "success");

    }

    function registerFamilyMember(uint _empId,uint _familyId, address _address) internal isRegisteredEmployee(msg.sender) {
          
              memberCounter ++;
              EmployeeToFamilyMembers[_empId][memberCounter] = Member(memberCounter, _empId, _familyId, _address, true);
              Family memory _family = EmployeeFamily[_empId];
              _family.activeMembers ++;
              EmployeeFamily[_empId] = _family;
              emit memberRegistration(memberCounter, "success");
    }

  
  function familyExists(uint _empId) private view returns(bool){
      if (EmployeeFamily[_empId].active == true ) {
          return true;
      }
      else {
          return false;
      }
      
  }
    
}

contract DoctorManager is UserInvite { 
    struct Doctor { 
        uint id;
        uint doctorid;
        string specialty;
        bool active;
    }
    
    uint doctorsCounter;
    
    mapping (address => Doctor) internal doctors;
    mapping (uint => address) internal doctorIndexToOwner;
    uint[] public registeredDoctors;
    
    //events 
    event doctorregistration (uint id, string msg);
    
    constructor() {
        doctorsCounter = 0;
    }

    function isDoctor(uint _type) private pure returns (bool) {
        if (_type ==2) {
            return true;
        }
        else {
            return false;
        }
    }
    
    //function can be called by User with an invitation on the system
    function registerDoctor(uint _doctorid, string memory _speciality, uint _code, uint _usertype ) public isInvited(_code,_doctorid, _usertype) notOwner{
        require(isDoctor(_usertype), "Not a Doctor type");
        doctorsCounter ++;
        doctors[msg.sender] = Doctor(doctorsCounter, _doctorid, _speciality, true);
        registeredDoctors.push(_doctorid);
        doctorIndexToOwner[_doctorid] = msg.sender;
        deleteInvitation(_code,_doctorid);
        emit doctorregistration(doctorsCounter, "success");
    }

    function getDoctor(address _address) public view returns (uint, uint, string memory, bool ){
        return( doctors[_address].doctorid, doctors[_address].id, doctors[_address].specialty ,doctors[_address].active);
    }
}

contract Coupon is Owner {
    
  string name; 
  address owner;
  uint8 value;
  uint8 empCouponMax;
  uint couponPayAmount;
  uint public couponCount; 
  
  struct CouponPaper {
    uint id;
    address owner;
    address beneficiary;
    //add empID to track coupons for family members
    uint value;
    string status;
    bool valid;
  } 
  
  event CouponPaperCreated(
    uint id,
    address owner,
    bool valid,
    string msg
  );
  
  
  mapping(uint => CouponPaper) internal coupons;
  mapping(address => uint) public ownershipToCouponCount;
  mapping(uint => address) public couponIndexToOwner;
  
  
  
  constructor() {
    name = "Coupon contract initialised";
    owner = msg.sender;
    couponCount = 0;
    value = 1;
    empCouponMax = 5;
    couponPayAmount = 60000;
  }
  
    function setGlobalParameters(uint8 _value, uint8 _maxcoupons, uint _paidamount) public isOwner {
        value = _value;
        empCouponMax = _maxcoupons;
        couponPayAmount = _paidamount;
        
    }
  
    function getName() public isOwner view returns(string memory) {
        return name;
    }
    function issueCoupon() internal {
    couponCount ++;
    coupons[couponCount] = CouponPaper(couponCount,msg.sender, address(0), value, "created", true);
    ownershipToCouponCount[msg.sender] ++;
    couponIndexToOwner[couponCount] = msg.sender;
    

    emit CouponPaperCreated(couponCount, msg.sender, true, "success");
    }
    
    function _transfer(address _from, address _to, uint _couponId) internal {
        CouponPaper memory _coupon = coupons[_couponId];
        _coupon.owner = _to;
        ownershipToCouponCount[_to] ++;
        ownershipToCouponCount[_from] --;
        couponIndexToOwner[couponCount] = _to;
    }
    
  
    function getCouponById(uint _id) public isOwner view returns(uint, address, address) { 
    
        return (coupons[_id].id, coupons[_id].owner, coupons[_id].beneficiary);
    }
  
  
}

contract CouponEmployee is Coupon,EmployeeManager {
    
    event EmployeeCouponGeneration(uint initialCouponCount, string msg);
    
    function employeeIssueCoupons() public isRegisteredEmployee(msg.sender){
        Employee memory _employee = getEmployee(msg.sender);
        if (_employee.initialCouponCount == 0) {
            for (uint i =0; i <= empCouponMax; i++)
            {
            issueCoupon();
            _employee.initialCouponCount ++;
            }
            if ((_employee.initialCouponCount-1) == empCouponMax) {
                emit EmployeeCouponGeneration(empCouponMax, "Success");
            }
            else { 
                emit EmployeeCouponGeneration(_employee.initialCouponCount, "failure");
            }
        }

    }
}
 
contract MyNet is CouponEmployee,DoctorManager {
    
    
}
