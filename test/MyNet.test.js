const { assert } = require('chai')

const MyNet = artifacts.require('MyNet')

require('chai')
  .use(require('chai-as-promised'))
  .should()
//deploy smart contract and set accounts addresses
contract('MyNet', ([deployer, employee1, employee2, doctor1, member1, member2]) => {
  let mynet

  before(async () => {
    mynet = await MyNet.deployed()
    console.log("HR admin " + deployer)
    console.log("Employee 1 " +employee1)
    console.log("Employee 2 " +employee2)
    console.log("Member 1 " +member1)
    console.log("Member 2 " +member2)
    console.log("Doctor " +doctor1)
  })
  
  //check smart contract is deployed
  describe('Smart Contract deployment', async () => {
    it('deploys successfully', async () => {
      const address = await mynet.address
      assert.notEqual(address, 0x0)
      assert.notEqual(address, '')
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })
    //check returned value
    it('has a name', async () => {
      const name = await mynet.getName()
      assert.equal(name, 'MyNet Contract is initialised')
    })
  })
  //HR role scenario testing
  describe('MyNet HR Role', async () => {
    let setParamResult, result, inviteDoctor, invitations
    //call smart contract functions
    before(async () => {
      setParamResult = await mynet.setGlobalParameters(1,5,80000,2021);
      result = await mynet.addInvitation(123,601,1, { from: deployer })
      inviteDoctor = await mynet.addInvitation(1234,1001,2, {from: deployer})
      invitations = await mynet.getInvitations()
    })
    //check return status and paidamount value
    it('Set MyNet Coupon Parameters', async () => {
      //check value returned from event
      const event = setParamResult.logs[0].args
      assert.equal(event.msg, 'success', 'Parameters are set')
      assert.equal(event.paidamount,80000, "Paid amount set to 80000")
    })
    //invite employee
    it('Invite Employee to MyNet', async () => {
      assert.equal(invitations[0],601)
      const event = result.logs[0].args
      assert.equal(event.msg, 'success', 'invitation is correct')
    })
    //invite doctor
    it('Invite Doctor to MyNet', async () => {
      assert.equal(invitations[1],1001)
      const event = inviteDoctor.logs[0].args
      assert.equal(event.msg, 'success', 'invitation is correct')
    })
  })
  //Employee role scenario
  describe('Employee Role', async () => {
    let result, familyCounter,requestCoupons

    it('Register Employee', async () => {
      result = await mynet.registerEmployee(601,2,123,1, { from: employee1 })
      // SUCCESS
      //assert.equal(couponCount, 1)
      const event = result.logs[2].args
      familyCounter = result.logs[1].args.familyCounter.toNumber()
      //console.log(event)
      assert.equal(event.employeesCounter.toNumber(), 1, 'Employee counter is correct')
      assert.equal(familyCounter,1, 'Family created success')
      assert.equal(event.msg, 'success', 'success is correct')
    })

    it('Register Family Member', async () => {
      
      result = await mynet.registerFamilyMember(601,familyCounter,member1, { from: employee1 })

      // SUCCESS
      const event = result.logs[0].args
      assert.equal(event.memberCounter.toNumber(), 1, 'Member counter is correct')
      assert.equal(event.msg, 'success', 'success is correct')
    })

    it('Request Initial coupons', async() => {
      //request intial coupons
      requestCoupons = await mynet.employeeIssueCoupons({from: employee1})
      //console.log("length" + requestCoupons.logs.length)
      const event = requestCoupons.logs[requestCoupons.logs.length -1].args
      assert.equal(event.initialCouponCount,5, 'Coupon Copunter is correct')
      assert.equal(event.msg,'success', 'Request result is success')

    })

    it('Request coupons for family member', async() => {
      //request intial coupons
      requestCoupons = await mynet.employeeIssueMembersCoupons(member1, {from: employee1})
      const event = requestCoupons.logs[requestCoupons.logs.length -1].args
      assert.equal(event.initialCouponCount,5, 'Coupon Copunter is correct')
      assert.equal(event.msg,'success', 'Request result is success')
    })

  })
  //Doctor role scenario test
  describe('Doctor Role', async() => {
      let result

      before(async () => {
        //result = await MyNet.createVisit(601,1000, web3.utils.toWei('1', 'Ether'), { from: seller })
        result = await mynet.registerDoctor(1001,"Cardiology",1234,2,1, {from: doctor1})
      })
      it('Register Doctor', async() => {
        const event = result.logs[1].args
        assert.equal(event.msg, 'success', 'Doctor registration success')
      })
  })
  //Doctor visit scenario
  describe('Doctor Visit', async() => {
    let result, emp, doctorid, couponid, employeeCoupons, md5

    before(async () => {
      employeeCoupons = await mynet.getCouponsByOwner(employee1)
      emp = await mynet.getEmployeeInfo(employee1, {from: employee1})
      couponid = employeeCoupons[0]
      doctorid = 1001
      md5 = '5d41402abc4b2a76b9719d911017c592' //hello
      result = await mynet.visitDoctor(emp.empid, couponid, doctorid, md5, employee1, {from: employee1})
    })
    it('Employee Exchange Coupon', async() => {
      const event = result.logs[2].args
      assert.equal(event.msg, 'success', 'Doctor Visit success')
      assert.equal(event.visitid,1,"First visit created")
      assert.equal(event.documentid,1,"First Document hash registered")
    })
    //end doctor visit test
  })
  //HR admin coupon valudation scenario
  describe('Coupon validation by HR Admin', async() =>{
    let result, exchangedCoupons, couponid,isCouponApproved,couponStatus
    before(async()=> {
      //status 2 is for exchanged coupons
      exchangedCoupons = await mynet.getCouponsByStatus(2)
      couponid = exchangedCoupons[0]
      couponStatus = await mynet.getCouponById(couponid);
      result = await mynet.approveCouponRedemption(1, {from: deployer})
      isCouponApproved = await mynet.couponIndexApproved(couponid)
    })
    it('Validate Coupon Exchanged', async() => {
      //1-created, 2-exchanged, 3-redeemed, 4-paid
      const event = result.logs[0].args
      assert.equal(event.msg, 'success', 'Coupon Validated success')
      assert.equal(isCouponApproved,true, 'Coupon Redeem Approved')
    })
  //end coupon validation
  })

  //HR admin redeem coupon scenario
  describe('Redeem Coupon by Employee', async() => {
    let result, emp, couponid, employeeCoupons,couponStatus

    before(async () => {
      employeeCoupons = await mynet.getCouponsByOwner(employee1)
      couponid = employeeCoupons[0]
      result = await mynet.redeemCoupon(couponid, employee1, {from: employee1}) 
    })
    it('Employee Redeem Coupon', async() => {
      const event = result.logs[0].args
      assert.equal(event.msg, 'success', 'Coupon Redeem success')
      assert.equal(event.couponId.toNumber(),couponid," Coupon Redeemed")
    })
    //end coupon redeem test
  })

//end of contract test
})

