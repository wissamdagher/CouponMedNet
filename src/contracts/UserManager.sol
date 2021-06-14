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

contract EmployeeBase is UserInvite { 

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
    
    event memberRegistration (uint memberCounter, string msg);
    
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
    mapping (uint => mapping(uint => Member )) EmployeeToFamilyMembers;
    mapping (uint => Member[]) public EmployeeFamilyMembers;
    mapping (address => uint ) memberAddressToEmployeeId;
    uint[] public registeredEmployees;
    
    //Employee Coupons
    mapping (uint => mapping(uint => uint[] )) internal EmployeeToCoupons;
    
    //Employee Doctor Visit, e.g empDoctorVisists[601][0] = 1 (visitId)
    mapping(address => uint[]) public empDoctorVisists;
    
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

    function registerFamilyMember(uint _empId,uint _familyId, address _address) public isRegisteredEmployee(msg.sender) {
              memberCounter ++;
              Member memory _member = Member(memberCounter, _empId, _familyId, _address, true);
              EmployeeToFamilyMembers[_empId][memberCounter] = _member;
              EmployeeFamilyMembers[_empId].push(_member);
              memberAddressToEmployeeId[_address] = _empId;
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
  uint year;
  
  struct CouponPaper {
    uint id;
    address owner;
    address beneficiary;
    //add empID to track coupons for family members
    uint value;
    string status;
    bool valid;
    bool approved;
  } 
  
  event CouponPaperCreated(
    uint id,
    address owner,
    bool valid,
    string msg
  );
  
  
  mapping(uint => CouponPaper) internal coupons;
  mapping(address => uint) public ownershipToCouponCount;
  //Filled when new coupon is created
  mapping(uint => address) public couponIndexToOwner;
  //Filled when new coupon is exchanged
  mapping(uint => address) public couponIndexToOwnerExchanged;
  //Filled when new coupon is redeemed
  mapping(uint => address) public couponIndexToOwnerRedeeemed;
  
  //Filled when a coupon is used in DoctorVisit
  mapping(uint => bool) couponIndexToDoctorVisit;
  
  constructor() {
    name = "Coupon contract initialised";
    owner = msg.sender;
    couponCount = 0;
    value = 1;
    empCouponMax = 5;
    couponPayAmount = 60000;
  }
  
    function setGlobalParameters(uint8 _value, uint8 _maxcoupons, uint _paidamount,uint _year) public isOwner {
        value = _value;
        empCouponMax = _maxcoupons;
        couponPayAmount = _paidamount;
        year = _year;
        
    }
  
    function getName() public isOwner view returns(string memory) {
        return name;
    }
    function issueCoupon() internal returns(uint _couponId) {
    couponCount ++;
    coupons[couponCount] = CouponPaper(couponCount,msg.sender, address(0), value, "created", true, false);
    ownershipToCouponCount[msg.sender] ++;
    couponIndexToOwner[couponCount] = msg.sender;
    emit CouponPaperCreated(couponCount, msg.sender, true, "success");
    return couponCount;
    
    }
    
    function _transfer(address _from, address _to, uint _couponId) internal {
        CouponPaper memory _coupon = coupons[_couponId];
        _coupon.owner = _to;
        ownershipToCouponCount[_to] ++;
        ownershipToCouponCount[_from] --;
        couponIndexToOwner[couponCount] = _to;
    }

    function _owns(address _address, uint _couponId) internal view returns (bool) {
        return(coupons[_couponId].owner == _address);
    }
    
    function _usedInDoctorVisit(uint _couponId) internal view returns (bool) {
        return (couponIndexToDoctorVisit[_couponId]);
    }
    
    function _isBeneficiary(address _address, uint _couponId) internal view returns (bool) {
        return(coupons[_couponId].beneficiary == _address);
    }
    
    function _readyToBeRedeemed(uint _couponId) internal view returns (bool) {
       return((couponIndexToOwnerExchanged[_couponId] > address(0)) && (coupons[_couponId].approved == true));
    }
    
  
    function getCouponById(uint _couponId) public isOwner view returns(uint, address, address) { 
    
        return (coupons[_couponId].id, coupons[_couponId].owner, coupons[_couponId].beneficiary);
    }
    
    function getCouponsByOwner(address _address) internal {
        
    }
    
    
  
  
}

contract DoctorVisitBase {
  uint public visitCount; 

  struct Visit {
    uint id;
    uint empId;
    uint couponId;
    uint doctorId;
  }

  event VisitCreated (
    uint id,
    uint empId,
    uint couponId,
    string msg
  );

  //visits  mapping incremental
  mapping(uint => Visit) public visits;
  //mapping visitDocumentIndex to Visit ID;
  mapping (uint => uint) DoctorVisitIndexToDocumentId;

  constructor() {
    visitCount = 0;
  }

  function createVisit(uint _empId, uint _couponId, uint _doctorId) internal returns(uint visitId) {
    visitCount ++;
    Visit memory _visit;
    _visit = Visit(visitCount, _empId, _couponId, _doctorId);
    visits[visitCount] = _visit;
    emit VisitCreated(visitCount, _empId, _couponId, "success");
    return visits[visitCount].id;
  }
  
  function getDoctorVisit(uint _visitid) public view returns (uint visitid, uint empid, uint couponid, uint doctorid) {
      return (visits[_visitid].id,visits[_visitid].empId,visits[_visitid].couponId,visits[_visitid].doctorId);
  }

}

contract VisitDocumentBase is DoctorVisitBase { 
  uint public VisitDocumentCount;

  struct VisitDoc { 
    uint id; 
    uint _doctorvisitId;
    uint _empId;
    bytes32 _docHash;
    uint flag; //flag is one when created by the contract
  }

  event VisitDocumentAddition (
    uint documentID,
    string msg
  );
  mapping (uint => VisitDoc ) public VisitDocuments;
  mapping (bytes32 => uint ) public VisitDocumentBasehash;
  

  constructor() {
    VisitDocumentCount = 0;
  }

  function addVisitDocument(uint _doctorvisitId, uint _empId,bytes32 _docHash) internal returns(uint documentId) {
     require(!_documentExists(_docHash), "Document already exists"); //check if document hash already exists
        VisitDocumentCount ++;
        VisitDocuments[VisitDocumentCount] = VisitDoc(VisitDocumentCount, _doctorvisitId, _empId, _docHash, 1);
        VisitDocumentBasehash[_docHash] = VisitDocumentCount; 
        DoctorVisitIndexToDocumentId[_doctorvisitId] = VisitDocumentCount;
        emit VisitDocumentAddition(VisitDocumentCount, "success");
        return VisitDocuments[VisitDocumentCount].id;
  }
  
  function _documentExists(bytes32 _docHash) public view returns (bool) {
      if(VisitDocumentBasehash[_docHash] > 0) {
        return true;
      }
      else {
        return false;
      }
  }
  
}



contract EmployeeCore is Coupon,EmployeeBase,VisitDocumentBase {
    
    event EmployeeCouponGeneration(uint initialCouponCount, string msg);
    event couponExchanged(uint _couponId, string msg);
    event doctorVisited(uint visitid, uint documentid, string msg);
    
    function employeeIssueCoupons() public isRegisteredEmployee(msg.sender) {
        Employee memory _employee = getEmployee(msg.sender);
        if (_employee.initialCouponCount == 0) {
            for (uint i =0; i <= empCouponMax -1; i++)
            {
            EmployeeToCoupons[_employee.empid][year].push(issueCoupon());
            _employee.initialCouponCount ++;
            }
            if ((_employee.initialCouponCount-1) == empCouponMax) {
                emit EmployeeCouponGeneration(empCouponMax, "success");
            }
            else { 
                emit EmployeeCouponGeneration(_employee.initialCouponCount, "failure");
            }
        }

    }
    
    function exchangeCoupon(uint _couponId) internal isRegisteredEmployee(msg.sender) {
        require(_owns(msg.sender, _couponId), "Not the owner of the token");
        require(_usedInDoctorVisit(_couponId), "Not used in a visit");
         CouponPaper memory _coupon = coupons[_couponId]; 
         _coupon.status = "Exchanged";
         _coupon.beneficiary = _coupon.owner;
         _coupon.owner = owner;
         couponIndexToOwnerExchanged[_couponId] = msg.sender;
         delete couponIndexToOwner[_couponId];
         delete couponIndexToDoctorVisit[_couponId];
         emit couponExchanged(_couponId, "success");
    }
    
    function redeemCoupon(uint _couponId) public isRegisteredEmployee(msg.sender) {
        require(_isBeneficiary(msg.sender, _couponId), "Not the owner of the token");
        require(_readyToBeRedeemed(_couponId), "Coupon can not be redeemed");
         CouponPaper memory _coupon = coupons[_couponId]; 
         _coupon.status = "Redeemed";
         _coupon.beneficiary = owner;
        couponIndexToOwnerRedeeemed[_couponId] = msg.sender;
        delete couponIndexToOwnerExchanged[_couponId];
    }
    
    function visitDoctor(uint empid, uint couponid, uint doctorid, bytes32 _docHash) public isRegisteredEmployee(msg.sender){
            //visit doctor
            uint _visitId = createVisit(empid, couponid, doctorid);
            couponIndexToDoctorVisit[couponid] = true;
            empDoctorVisists[msg.sender].push(_visitId);
            //submit document
            uint _documentId = addVisitDocument(doctorid, empid, _docHash);
            // then exchange Coupon
            exchangeCoupon(couponid);
            emit doctorVisited( _visitId, _documentId, "success");
    }
}



contract HRManager is Coupon,EmployeeBase {
    mapping(uint => address) couponIndexApproved;
    
    function approveCouponRedemption(uint _couponId) public isOwner {
        require(_readyToBeRedeemed(_couponId), "Coupon can not be redeemed");
        CouponPaper memory _coupon = coupons[_couponId]; 
         _coupon.approved = true;
         couponIndexApproved[_couponId] = msg.sender;
    }
}
 
contract MyNet is EmployeeCore,DoctorManager {
    
    
}
