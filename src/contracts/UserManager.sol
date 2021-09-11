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
        uint256 id;
        uint256 invtype;
    }
    
    event delinvitee (
        string  msg
        );
        
    event InvitationAdded(string msg);

    mapping (uint256 => Invitation) internal invitationById;
    uint[] internal invitees;
    
    modifier isInvited(uint256 _code, uint256 _id, uint256 _usertype) {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(invitationById[_code].id == _id && invitationById[_code].invtype == _usertype, "Caller is not invited");
        _;
    }

    function find(uint256 value) private view returns(uint) {
        uint256 i = 0;
        while (invitees[i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint256 value) private {
        uint256 i = find(value);
        removeByIndex(i);
    }

    function removeByIndex(uint256 i) private {
            invitees[i] = invitees[invitees.length -1];
            invitees.pop();
        }
    
    
    function addInvitation(uint256 _code, uint256 _id, uint256 _usertype) public isOwner { 
        require(invitationById[_code].id == 0, "Already invitation code exists");
        invitationById[_code].id = _id;
        invitationById[_code].invtype = _usertype;
        
        invitees.push(_id);
        emit InvitationAdded("success");
    }
    
    function deleteInvitation(uint256 _code, uint256 _id) internal {
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
        uint256 id;
        uint256 empid; //empid provided by HR
        uint256 maxfamilycount; //maximum number of family members that can register
        uint256 initialCouponCount;
        uint256 extraCouponCount;
        bool active;
    }

    struct Family {
      uint256 id;
      uint256 empId;
      uint256 count;
      bool active;
      uint256 activeMembers;
    }

    
  
  struct Member {
      uint256 id;
      uint256 empId;
      uint256 familyId;
      address owner;
      uint256 initialCouponCount;
      uint256 extraCouponCount;
      bool active;
   }
    event empRegistration(uint256 employeesCounter, string msg);
    event empFamilyRegistration(uint256 familyCounter, string msg);
    event memberRegistration (uint256 memberCounter, string msg);
    
    uint256 employeesCounter;
    uint256 familyCounter;
    uint256 memberCounter;
    
    mapping (address => Employee) internal employees;
    mapping (uint256 => address) internal employeeIndexToOwner;
    mapping (uint256 => uint) internal employeeIDtoIndex;

    //family
    mapping(uint256 => Family) public EmployeeFamily;

    //Family Member
    mapping (address => Member) internal familyMembers;
    mapping (uint256 => mapping(uint256 => Member )) EmployeeToFamilyMembers;
    mapping (uint256 => Member[]) public EmployeeFamilyMembers;
    mapping (address => uint256 ) memberAddressToEmployeeId;
    uint[] public registeredEmployees;
    
    //Employee Coupons
    mapping (uint256 => mapping(uint256 => uint[] )) internal EmployeeToCoupons;
    
    //Member Coupons
    mapping (uint256 => mapping(uint256 => uint[] )) internal MemberToCoupons;
    
    //Employee Doctor Visit, e.g empDoctorVisists[601][0] = 1 (visitId)
    mapping(address => uint[]) public empDoctorVisists;
    
    constructor() {
        employeesCounter = 0;
        memberCounter = 0;
        familyCounter = 0;
    }

    function isEmployee(uint256 _type) private pure returns (bool) {
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
    function registerEmployee(uint256 _empid, uint256 _maxfamilycount, uint256 _code, uint256 _usertype ) public notOwner isInvited(_code,_empid, _usertype) isNotRegistered(msg.sender) {
        require(isEmployee(_usertype), "Not an employee type");
        employeesCounter ++;
        employees[msg.sender] = Employee(employeesCounter, _empid, _maxfamilycount,0,0,true);
        registeredEmployees.push(_empid);
        employeeIndexToOwner[employeesCounter] = msg.sender;
        employeeIDtoIndex[_empid] = employeesCounter;
        deleteInvitation(_code,_empid);
        registerFamily(_empid, _maxfamilycount, msg.sender);
        emit empRegistration(employeesCounter, "success");
    }

    function getEmployee(address _address) internal view returns (Employee storage){
        return( employees[_address]);
    }
    
    function getMember(address _address) internal view returns (Member storage){
        return( familyMembers[_address]);
    }
    

    function registerFamily(uint256 _empId, uint256 _count, address _address) internal isRegisteredEmployee(_address) {
        require(_count > 0, "Family members should be more than 0");
        require(!familyExists(_empId), "Family exists");
        familyCounter ++;
        Family memory _family = Family(familyCounter, _empId, _count, true, 0);
        EmployeeFamily[_empId] = _family;
        
        emit empFamilyRegistration(familyCounter, "success");

    }

    function registerFamilyMember(uint256 _empId,uint256 _familyId, address _address) public isRegisteredEmployee(msg.sender) {
              memberCounter ++;
              Member memory _member = Member(memberCounter, _empId, _familyId, _address,0,0, true);
              familyMembers[_address] = _member;
              EmployeeToFamilyMembers[_empId][memberCounter] = _member;
              EmployeeFamilyMembers[_empId].push(_member);
              memberAddressToEmployeeId[_address] = _empId;
              Family memory _family = EmployeeFamily[_empId];
              _family.activeMembers ++;
              EmployeeFamily[_empId] = _family;
              emit memberRegistration(memberCounter, "success");
    }
  
  function familyExists(uint256 _empId) private view returns(bool){
      if (EmployeeFamily[_empId].active == true ) {
          return true;
      }
      else {
          return false;
      }
      
  }
    
}

contract DoctorBase is UserInvite { 

    struct Doctor { 
        uint256 id;
        uint256 doctorid;
        string specialty;
        uint256 couponcoeficient;
        bool active;
    }
    
    uint256 internal doctorsCounter;
    
    mapping (address => Doctor) internal doctors;
    mapping (uint256 => address) internal doctorIndexToOwner;
    mapping (uint256 => bytes32) internal doctorIndexToKeyHash;
    uint[] internal registeredDoctors;
    
    //events 
    event doctorregistration (uint256 id, string msg);
    
    constructor() {
        doctorsCounter = 0;
    }

    function isDoctor(uint256 _type) private pure returns (bool) {
        if (_type ==2) {
            return true;
        }
        else {
            return false;
        }
    }
    
    //function can be called by User with an invitation on the system
    function registerDoctor(uint256 _doctorid, string memory _speciality, uint256 _code, uint256 _usertype, uint256 _couponcoeficient) public isInvited(_code,_doctorid, _usertype) notOwner{
        require(isDoctor(_usertype), "Not a Doctor type");
        doctorsCounter ++;
        bytes32 _keyhash = sha256(abi.encodePacked(doctorsCounter+_doctorid));
        doctorIndexToKeyHash[doctorsCounter] = _keyhash;
        doctors[msg.sender] = Doctor(doctorsCounter, _doctorid, _speciality,_couponcoeficient, true);
        registeredDoctors.push(_doctorid);
        doctorIndexToOwner[_doctorid] = msg.sender;
        deleteInvitation(_code,_doctorid);
        emit doctorregistration(doctorsCounter, "success");
    }

    function getDoctor(address _address) internal view returns (uint, uint, string memory, uint256, bool ){
        return( doctors[_address].doctorid, doctors[_address].id, doctors[_address].specialty ,doctors[_address].couponcoeficient,doctors[_address].active);
    }
    function getDoctor(uint256 _id) internal view returns(bytes32 _keyhash) {
        return doctorIndexToKeyHash[_id];
    }
}

contract Coupon is Owner {
    
  address owner;
  uint256 value;
  uint256 empCouponMax;
  uint256 couponPayAmount;
  uint256 couponCount; 
  uint256 couponExchangedCount;
  uint256 couponRedeemedCount;
  uint256 couponPaidCount;
  uint256 year;
  
  struct CouponPaper {
    uint256 id;
    address owner;
    address beneficiary;
    //add empID to track coupons for family members
    uint256 value;
    string status;
    bool valid;
    bool approved;
  } 
  
  event CouponPaperCreated(
    uint256 id,
    address owner,
    bool valid,
    string msg
  );

  event GlobalParametersSet(
      uint256 value, 
      uint256 maxcoupons, 
      uint256 paidamount,
      uint256 year,
      string msg
  );
  
  
  mapping(uint256 => CouponPaper) internal coupons;
  mapping(address => uint) internal ownershipToCouponCount;
  //Filled when new coupon is created
  mapping(uint256 => address) internal couponIndexToOwner;
  //Filled when new coupon is exchanged
  mapping(uint256 => address) internal couponIndexToOwnerExchanged;
  //Filled when new coupon is redeemed
  mapping(uint256 => address) internal couponIndexToOwnerRedeeemed;
  //Track coupon status
  mapping(uint256 => uint256) internal couponIndexToStatus;
  
  //Filled when a coupon is used in DoctorVisit
  mapping(uint256 => bool) couponIndexToDoctorVisit;
  
  //Stores the balances to be paid for the employee;
  mapping(address => uint) balances;
  
  constructor() {
    owner = msg.sender;
    couponCount = 0;
    value = 1;
    empCouponMax = 5;
    couponPayAmount = 60000;
  }
  
    function setGlobalParameters(uint256 _value, uint256 _maxcoupons, uint256 _paidamount,uint256 _year) public isOwner {
        value = _value;
        empCouponMax = _maxcoupons;
        couponPayAmount = _paidamount;
        year = _year;
        emit GlobalParametersSet(value, empCouponMax, couponPayAmount, year, "success" );
    }
  

    function issueCoupon(address _couponowner, address _couponbeneficiary ) internal returns(uint256 _couponId) {
    couponCount ++;
    coupons[couponCount] = CouponPaper(couponCount,_couponowner, _couponbeneficiary, value, "created", true, false);
    ownershipToCouponCount[_couponowner] ++;
    couponIndexToOwner[couponCount] = _couponowner;
    couponIndexToStatus[couponCount] = 1;
    emit CouponPaperCreated(couponCount, _couponowner, true, "success");
    return couponCount;
    
    }
    
    function _transfer(address _from, address _to, uint256 _couponId) internal {
        CouponPaper storage _coupon = coupons[_couponId];
        _coupon.owner = _to;
        ownershipToCouponCount[_to] ++;
        ownershipToCouponCount[_from] --;
        couponIndexToOwner[couponCount] = _to;
    }

    function _owns(address _address, uint256 _couponId) internal view returns (bool) {
        return(coupons[_couponId].owner == _address);
    }
    
    function _usedInDoctorVisit(uint256 _couponId) internal view returns (bool) {
        return (couponIndexToDoctorVisit[_couponId]);
    }
    
    function _isBeneficiary(address _address, uint256 _couponId) internal view returns (bool) {
        return(coupons[_couponId].beneficiary == _address);
    }
    
    //coupon status is exchanged
    function _readyToBeRedeemed(uint256 _couponId) internal view returns (bool) {
       return((couponIndexToOwnerExchanged[_couponId] > address(0)) && (couponIndexToStatus[_couponId] == 2));
    }
    
  
    function getCouponById(uint256 _couponId) public isOwner view returns(uint256 id, address, address, string memory status) { 
    
        return (coupons[_couponId].id, coupons[_couponId].owner, coupons[_couponId].beneficiary, coupons[_couponId].status);
    }
    
    function getCoupon(uint256 _couponId) internal isOwner view returns(CouponPaper storage){
        return coupons[_couponId];
    }

    function couponBalanceOf(address _address) internal view returns (uint256 count) {
        return ownershipToCouponCount[_address];
    }

    function totalCoupons() internal view returns (uint256 count) {
        return couponCount;
        
    }

    function totalCouponsByStatus(uint256 _status) internal view returns (uint256 countExchanged) {
        require(_status < 5 && _status >0, "Invalid status provided");
        //1 - created, 2- exchanged, 3-redeemed, 4-paid
        if (_status == 1) return couponCount;
        if (_status == 2) return couponExchangedCount;
        if (_status == 3) return couponRedeemedCount;
        if (_status == 4) return couponPaidCount;
    }

    function getCouponsByStatus(uint256 _status) external view returns (uint256[] memory statusCoupons) {
        
        uint256 count = totalCouponsByStatus(_status);
        if (count == 0) {
            return new uint256[](0);
        }
        else {
            uint256[] memory result = new uint256[](count);
            uint256 total = totalCoupons();
            uint256 resultIndex = 0;
            //we count all coupons
            uint256 couponId;

            for (couponId = 1; couponId <= total; couponId++) {
                if (couponIndexToStatus[couponId] == _status) {
                    result[resultIndex] = couponId;
                    resultIndex++;
                }
            }

            return result;
        }

    }

    
    function getCouponsByOwner(address _owner) external view returns (uint256[] memory ownerCoupons) {
        uint256 count = couponBalanceOf(_owner);
        if (count == 0) {
            return new uint[](0);
        }
        else {
            uint256[] memory result = new uint256[](count);
            uint256 total = totalCoupons();
            uint256 resultIndex = 0;
            //we count all coupons
            uint256 couponId;

            for (couponId = 1; couponId <= total; couponId++) {
                if (couponIndexToOwner[couponId] == _owner) {
                    result[resultIndex] = couponId;
                    resultIndex++;
                }
            }

            return result;
        }

    }
    
    
  
  
}

contract DoctorVisitBase {
  uint256 public visitCount; 

  struct Visit {
    uint256 id;
    uint256 empId;
    uint256 couponId;
    uint256 doctorId;
  }

  event VisitCreated (
    uint256 id,
    uint256 empId,
    uint256 couponId,
    string msg
  );

  //visits  mapping incremental
  mapping(uint256 => Visit) public visits;
  //mapping visitDocumentIndex to Visit ID;
  mapping (uint256 => uint) DoctorVisitIndexToDocumentId;

  constructor() {
    visitCount = 0;
  }

  function createVisit(uint256 _empId, uint256 _couponId, uint256 _doctorId) internal returns(uint256 visitId) {
    visitCount ++;
    Visit memory _visit;
    _visit = Visit(visitCount, _empId, _couponId, _doctorId);
    visits[visitCount] = _visit;
    emit VisitCreated(visitCount, _empId, _couponId, "success");
    return visits[visitCount].id;
  }
  
  function getDoctorVisit(uint256 _visitid) public view returns (uint256 visitid, uint256 empid, uint256 couponid, uint256 doctorid) {
      return (visits[_visitid].id,visits[_visitid].empId,visits[_visitid].couponId,visits[_visitid].doctorId);
  }

}

contract VisitDocumentBase is DoctorVisitBase { 
  uint256 public VisitDocumentCount;

  struct VisitDoc { 
    uint256 id; 
    uint256 _doctorvisitId;
    uint256 _empId;
    bytes32 _docHash;
    uint256 flag; //flag is one when created by the contract
  }

  event VisitDocumentAddition (
    uint256 documentID,
    string msg
  );
  mapping (uint256 => VisitDoc ) public VisitDocuments;
  mapping (bytes32 => uint256 ) public VisitDocumentBasehash;
  

  constructor() {
    VisitDocumentCount = 0;
  }

  function addVisitDocument(uint256 _doctorvisitId, uint256 _empId,bytes32 _docHash) internal returns(uint256 documentId) {
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
    
    event EmployeeCouponGeneration(uint256 initialCouponCount, string msg);
    event MemberCouponGeneration(uint256 initialCouponCount, string msg);
    event couponExchanged(uint256 _couponId, string msg);
    event doctorVisited(uint256 visitid, uint256 documentid, string msg);
    event couponRedeemed(uint256 couponId, string msg);

    
    //get Employee info
    function getEmployeeInfo(address _employee) external isRegisteredEmployee(msg.sender) view returns (Employee memory) {
        return getEmployee(_employee);
    }
    //issue inital coupons
    function employeeIssueCoupons() public isRegisteredEmployee(msg.sender) {
        require((employees[msg.sender].initialCouponCount == 0), "Initial Coupons already issued");
        Employee storage _employee = getEmployee(msg.sender);
            for (uint256 i =1; i <= empCouponMax; i++)
            {
            //Employee is the owner and beneficiary of his initial coupons
            EmployeeToCoupons[_employee.empid][year].push(issueCoupon(msg.sender,msg.sender));
            _employee.initialCouponCount ++;
            }
            if ((_employee.initialCouponCount) == empCouponMax) {
                emit EmployeeCouponGeneration(empCouponMax, "success");
            }
            else { 
                emit EmployeeCouponGeneration(_employee.initialCouponCount, "failure");
            }
        

    }
    
    function employeeIssueMembersCoupons(address _memberaddress) public isRegisteredEmployee(msg.sender) {
        require((familyMembers[_memberaddress].initialCouponCount == 0), "Initial Coupons already issued");
        Member storage _member = getMember(_memberaddress);
            for (uint256 i =1; i <= empCouponMax; i++)
            {
            //Employee is the owner and beneficiary of his initial coupons
            MemberToCoupons[_member.id][year].push(issueCoupon(_memberaddress,msg.sender));
            _member.initialCouponCount ++;
            }
            if ((_member.initialCouponCount) == empCouponMax) {
                emit MemberCouponGeneration(empCouponMax, "success");
            }
            else { 
                emit MemberCouponGeneration(_member.initialCouponCount, "failure");
            }
        

    }
    
     function exchangeCoupon(uint256 _couponId, address _owner) public isRegisteredEmployee(msg.sender) {
        require(_owns(_owner, _couponId), "Not the owner of the token");
         CouponPaper memory _coupon = coupons[_couponId]; 
         _coupon.status = "Exchanged";
         //_coupon.beneficiary = _coupon.owner;
         //_coupon.owner = owner;
         coupons[_couponId] = _coupon;
         couponIndexToStatus[_couponId] = 2;
         couponExchangedCount ++;
         couponIndexToOwnerExchanged[_couponId] = _owner;
         couponIndexToOwner[_couponId];
    }
    
    function redeemCoupon(uint256 _couponId, address _owner) public isRegisteredEmployee(msg.sender) {
        require(_owns(_owner, _couponId), "Not the owner of the token");
        require(_readyToBeRedeemed(_couponId), "Coupon can not be redeemed");
         CouponPaper memory _coupon = coupons[_couponId]; 
         _coupon.status = "Redeemed";
         couponIndexToStatus[couponCount] = 3;
         couponExchangedCount --;
         couponRedeemedCount ++;
         //_coupon.beneficiary = owner;
        coupons[_couponId] = _coupon;
        couponIndexToOwnerRedeeemed[_couponId] = msg.sender;
        delete couponIndexToOwnerExchanged[_couponId];
        emit couponRedeemed(_couponId, "success");
    }
    
    function visitDoctor(uint256 empid, uint256 couponid, uint256 doctorid, string memory _md5, address _address) public isRegisteredEmployee(msg.sender){
            //employee should have a family relation with _address
            //visit doctor
            uint256 _visitId = createVisit(empid, couponid, doctorid);
            couponIndexToDoctorVisit[couponid] = true;
            empDoctorVisists[msg.sender].push(_visitId);
            //submit document
            bytes32 _docHash = sha256(bytes(_md5));
            uint256 _documentId = addVisitDocument(doctorid, empid, _docHash);
            // then exchange Coupon
            exchangeCoupon(couponid, _address);
            emit doctorVisited( _visitId, _documentId, "success");
    }
}

contract HRManager is Coupon,EmployeeBase,DoctorBase {
    mapping(uint256 => bool) public couponIndexApproved;

    event approveCoupon(uint256 couponid, string msg);
    event paidCoupon(uint256 _couponId, string msg);
   // event DoctorPricing(string msg);

    function approveCouponRedemption(uint256 _couponId) public isOwner {
        require(_readyToBeRedeemed(_couponId), "Coupon can not be redeemed");
        require(!couponIndexApproved[_couponId], "Coupon already approved");
        CouponPaper storage _coupon = coupons[_couponId]; 
         _coupon.approved = true;
         couponIndexApproved[_couponId] = true;
         emit approveCoupon(_couponId, "success");
    }
    
    function prepareCouponPayment(uint256 _couponId) public isOwner {
        CouponPaper storage _coupon = coupons[_couponId]; 
        _coupon.valid = false;
        _coupon.status = "Paid";
        _coupon.beneficiary = _coupon.owner;
        _coupon.owner = owner;
        couponIndexToStatus[couponCount] = 4;
        couponRedeemedCount --;
        couponPaidCount ++;
        uint256 _balance = balances[_coupon.owner];
        balances[_coupon.owner] = _balance + couponPayAmount;

        emit paidCoupon(_couponId, "success");
        
    }
}
 
contract MyNet is EmployeeCore,HRManager {
    string name;

    constructor() {
        name = "MyNet Contract is initialised";
    }

    function getName() public view returns(string memory _name) {
        return name;
    }
    
    
}
