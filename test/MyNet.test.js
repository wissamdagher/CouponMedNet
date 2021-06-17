const { assert } = require('chai')

const MyNet = artifacts.require('MyNet')

require('chai')
  .use(require('chai-as-promised'))
  .should()

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
  

  describe('Smart Contract deployment', async () => {
    it('deploys successfully', async () => {
      const address = await mynet.address
      assert.notEqual(address, 0x0)
      assert.notEqual(address, '')
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })

    it('has a name', async () => {
      const name = await mynet.getName()
      assert.equal(name, 'MyNet Contract is initialised')
    })
  })

  describe('MyNet HR Role', async () => {
    let result, inviteDoctor, invitations

    before(async () => {
      //result = await MyNet.createVisit(601,1000, web3.utils.toWei('1', 'Ether'), { from: seller })
      result = await mynet.addInvitation(123,601,1, { from: deployer })
      inviteDoctor = await mynet.addInvitation(1234,1001,2, {from: deployer})
      invitations = await mynet.getInvitations()
    })

    it('Invite Employee to MyNet', async () => {
      // SUCCESS
      //assert.equal(couponCount, 0)
     // console.log("Invitations "+invitations[0])
      assert.equal(invitations[0],601)
      const event = result.logs[0].args
      assert.equal(event.msg, 'success', 'invitation is correct')
    })

    it('Invite Doctor to MyNet', async () => {
      // SUCCESS
      //console.log("Invitations "+invitations[0])
      assert.equal(invitations[1],1001)
      const event = inviteDoctor.logs[0].args
      assert.equal(event.msg, 'success', 'invitation is correct')
    })
  })

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
      //assert.equal(couponCount, 1)familyCounter
      const event = result.logs[0].args
      //console.log(event)
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
      //console.log("length" + requestCoupons.logs.length)
      const event = requestCoupons.logs[requestCoupons.logs.length -1].args
      assert.equal(event.initialCouponCount,5, 'Coupon Copunter is correct')
      assert.equal(event.msg,'success', 'Request result is success')

    })


  })

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

  describe('Doctor Visit', async() => {
    let result, emp, doctorid, couponid, employeeCoupons, md5

    before(async () => {
      //result = await MyNet.createVisit(601,1000, web3.utils.toWei('1', 'Ether'), { from: seller })
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

  describe('Coupon validation', async() =>{
    let result, exchangedCoupons, couponid
    before(async()=> {
      //status 2 is for exchanged coupons
      exchangedCoupons = await mynet.getCouponsByStatus(2)
      console.log(exchangedCoupons.length)
      console.log(exchangedCoupons[0])
      couponid = exchangedCoupons[0]
      result = await mynet.approveCouponRedemption(1, {from: deployer})
      console.log(result)
    })
    it('Validate Coupon Exchanged', async() => {
      //1-created, 2-exchanged, 3-redeemed, 4-paid
      console.log(result.logs)
      const event = result.logs[0].args
      assert.equal(event.msg, 'success', 'Coupon Validated success')

    })
  })


//end of contract test
})

