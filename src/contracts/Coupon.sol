// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CouponOriginal {
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

  event CouponPaperOwnerChange (
    uint id,
    address originalOwner,
    address owner,
    bool valid,
    string msg
  );
  
  event exchangeCoupnTrx ( 
      uint _id, 
      address originalOwner, 
      string msg );
  

 mapping(uint => CouponPaper) public coupons;
 //holds the number of coupons issued for the employee
 mapping(address => mapping(uint => uint)) public couponYearlyBalances;
 //stores incremental value of employee coupons value to be paid
 mapping(address => uint) public empCouponsValueToPay;

  constructor() {
    name = "Coupon contract initialised";
    owner = msg.sender;
    couponCount = 0;
    value = 1;
    empCouponMax = 5;
  }

  function setName(string memory _name) public { 
    name = _name;
  }

  function getName() public view returns (string memory) {
    return name;
  }
  //create a parameter for the issueCoupon to create coupons in batch for the intial setup
  function issueCoupon() public {
    couponCount ++;
    coupons[couponCount] = CouponPaper(couponCount,msg.sender, msg.sender, value, "created", true);

    emit CouponPaperCreated(couponCount, msg.sender, true, "success");
  }

  function changeOwnership(uint _id) public {
        address originalOwner;
        //check if employee can still receive free coupons
        if(canreceiveCoupon()) {
        // Fetch the coupon based on the _id
        CouponPaper memory _coupon = coupons[_id];
        originalOwner = _coupon.owner;
        require(_coupon.valid);
        require(originalOwner != msg.sender);
        _coupon.owner = msg.sender;
        _coupon.status = "owned";
        coupons[_id] = _coupon;
        
        // increase employee coupons couponYearlyBalances
        couponYearlyBalances[msg.sender][2021] ++;
        // Trigger an event
        emit CouponPaperOwnerChange(_id, originalOwner, msg.sender, true, "success");
        } else {
            emit CouponPaperOwnerChange(_id, originalOwner, msg.sender, true, "failure");
        }
        
  }

 function canreceiveCoupon() private view returns(bool) {
     if(couponYearlyBalances[msg.sender][2021] < 5) {
         return true;
     } else {
         return false;
     }
 }
 
 function exchangeCoupon(uint _id) public {
     CouponPaper memory _coupon = coupons[_id];
     address originalOwner = _coupon.owner;
     uint couponValue = _coupon.value;
     //reset coupon to HR
     _coupon.owner = owner;
     _coupon.status = "exchanged"; 
     coupons[_id] = _coupon;
     
     //transfer coupon value to employee address for later valuation and payment
     empCouponsValueToPay[originalOwner] += couponValue;
     emit exchangeCoupnTrx(_id, originalOwner, "success");
 }

}