const { assert } = require('chai')

const Coupon = artifacts.require('./Coupon.sol')

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('Coupon', ([deployer, seller, buyer]) => {
  let coupon

  before(async () => {
    coupon = await Coupon.deployed()
    console.log("seller " +seller)
    console.log("buyer" +buyer)
  })
  

  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address = await coupon.address
      assert.notEqual(address, 0x0)
      assert.notEqual(address, '')
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })

    it('has a name', async () => {
      const name = await coupon.getName()
      assert.equal(name, 'Coupon contract initialised')
    })
  })

  describe('coupons', async () => {
    let result, couponCount

    before(async () => {
      //result = await Coupon.createVisit(601,1000, web3.utils.toWei('1', 'Ether'), { from: seller })
      result = await coupon.issueCoupon({ from: seller })
      couponCount = await coupon.couponCount()
    })

    it('issue Coupon', async () => {
      // SUCCESS
      assert.equal(couponCount, 1)
      const event = result.logs[0].args
      assert.equal(event.id.toNumber(), couponCount.toNumber(), 'id is correct')
      assert.equal(event.owner, seller, 'owner is correct')
      assert.equal(event.valid, true, 'valid is correct')
    })

    it('change Coupon ownership', async () => {
      
      result = await coupon.changeOwnership(couponCount, { from: buyer })

      // SUCCESS
      assert.equal(couponCount, 1)
      const event = result.logs[0].args
      assert.equal(event.id.toNumber(), couponCount.toNumber(), 'id is correct')
      assert.equal(event.originalOwner, seller, 'Original owner is correct')
      assert.equal(event.owner, buyer, 'owner is correct')
      assert.equal(event.valid, true, 'valid is correct')
    })


    /*
    it('lists products', async () => {
      const product = await Coupon.products(couponCount)
      assert.equal(visit.id.toNumber(), couponCount.toNumber(), 'id is correct')
      assert.equal(visit.name, 'iPhone X', 'name is correct')
      assert.equal(visit.price, '1000000000000000000', 'price is correct')
      assert.equal(visit.owner, seller, 'owner is correct')
      assert.equal(visit.purchased, false, 'purchased is correct')
    }) */

  })
})
