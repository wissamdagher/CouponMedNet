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

contract UserManager is Owner{ 

    struct User { 
    
        uint id;
        string name;
        bool active;
    }
    
    struct Invitation { 
        uint id;
        uint invtype;
    }
    mapping (address => User) public users;
    mapping (uint => Invitation) internal invitationById;
    uint[] invitees;
    
    modifier isInvited(uint _code, uint _id, uint _usertype) {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(invitationById[_code].id == _id && invitationById[_code].invtype == _usertype, "Caller is not invited");
        _;
    }
    function isEmployee(uint _type) private view returns (bool) {
        if (_type ==1) {
            return true;
        }
        else {
            return false;
        }
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
    
    function getInvitations() public view returns (uint[] memory) {
        return invitees;
    }
    
    //function can be called by User with an invitation on the system
    function registerUser(uint _id, string memory _name, uint _code, uint _usertype ) public isInvited(_code,_id, _usertype){
        require(isEmployee(_usertype), "Not an employee type");
        users[msg.sender] = User(_id, _name, true);
        delete invitationById[_code];
        removeByValue(_id);
    }
    
    function getUser(address _address) public view returns (string memory, uint, bool ){
        return( users[_address].name, users[_address].id, users[_address].active);
    }
    
}

contract Coupon {
    
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
  
  mapping(uint => CouponPaper) public coupons;
  
  constructor() public {
    name = "Coupon contract initialised";
    owner = msg.sender;
    couponCount = 0;
    value = 1;
    empCouponMax = 5;
  }
}
  
