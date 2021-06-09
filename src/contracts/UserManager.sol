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
        string name;
        bool active;
    }
    
    mapping (address => Employee) internal employees;
    uint[] public registeredEmployees;
    
    function isEmployee(uint _type) private pure returns (bool) {
        if (_type ==1) {
            return true;
        }
        else {
            return false;
        }
    }
    
    //function can be called by User with an invitation on the system
    function registerEmployee(uint _id, string memory _name, uint _code, uint _usertype ) public isInvited(_code,_id, _usertype) notOwner{
        require(isEmployee(_usertype), "Not an employee type");
        employees[msg.sender] = Employee(_id, _name, true);
        registeredEmployees.push(_id);
        deleteInvitation(_code,_id);
    }
    
    
    function getEmployee(address _address) public view returns (string memory, uint, bool ){
        return( employees[_address].name, employees[_address].id, employees[_address].active);
    }
    
}


contract Coupon is Owner {
    
  string name; 
  address owner;
  uint8 value;
  uint8 empCouponMax;
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
  
  constructor() {
    name = "Coupon contract initialised";
    owner = msg.sender;
    couponCount = 0;
    value = 1;
    empCouponMax = 5;
  }
  
    function getName() public isOwner view returns(string memory) {
        return name;
    }
    function issueCoupon() public isOwner{
    couponCount ++;
    coupons[couponCount] = CouponPaper(couponCount,msg.sender, address(0), value, "created", true);

    emit CouponPaperCreated(couponCount, msg.sender, true, "success");
    }
    
    function getCouponById(uint _id) public isOwner view returns(uint, address, address) { 
    
        return (coupons[_id].id, coupons[_id].owner, coupons[_id].beneficiary);
    }
  
  
  
}
 
contract MyNet is Coupon,EmployeeManager {
    
    
}
