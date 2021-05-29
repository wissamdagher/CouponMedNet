pragma solidity ^0.5.0;

contract Coupon {
  string name; 
  uint public couponCount; 
  
  struct CouponPaper {
    uint id;
    address owner;
    bool valid;
  } 

  event CouponPaperCreated(
    uint id,
    address owner,
    bool valid
  );

  event CouponPaperOwnerChanged (
    uint id,
    address originalOwner,
    address owner,
    bool valid
  );

 mapping(uint => CouponPaper) public coupons;

  constructor() public {
    name = "Coupon contract initialised";
    couponCount = 0;
  }

  function setName(string memory _name) public { 
    name = _name;
  }

  function getName() public view returns (string memory) {
    return name;
  }

  function issueCoupon() public {
    couponCount ++;
    coupons[couponCount] = CouponPaper(couponCount,msg.sender, true);

    emit CouponPaperCreated(couponCount, msg.sender, true);
  }

  function changeOwnership(uint _id) public {
        address originalOwner;
        // Fetch the product
        CouponPaper memory _coupon = coupons[_id];
        originalOwner = _coupon.owner;
        require(_coupon.valid);
        require(originalOwner != msg.sender);
        _coupon.owner = msg.sender;
        coupons[_id] = _coupon;
        // Trigger an event
        emit CouponPaperOwnerChanged(1, originalOwner, msg.sender, true);

  }

}