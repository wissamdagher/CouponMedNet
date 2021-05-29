const Doctorvisit = artifacts.require('./Doctorvisit.sol')

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('Doctorvisit', ([deployer, seller, buyer]) => {
  let doctorvisit

  before(async () => {
    doctorvisit = await Doctorvisit.deployed()
  })
  

  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address = await doctorvisit.address
      assert.notEqual(address, 0x0)
      assert.notEqual(address, '')
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })

    it('has a name', async () => {
      const name = await doctorvisit.getName()
      assert.equal(name, 'Doctorvisit contract initialised')
    })
  })

  describe('visits', async () => {
    let result, visitCount

    before(async () => {
      //result = await doctorvisit.createVisit(601,1000, web3.utils.toWei('1', 'Ether'), { from: seller })
      result = await doctorvisit.createVisit(601,1000)
      visitCount = await doctorvisit.visitCount()
    })

    it('creates visit', async () => {
      // SUCCESS
      assert.equal(visitCount, 1)
      const event = result.logs[0].args
      assert.equal(event.Id.toNumber(), visitCount.toNumber(), 'id is correct')
      assert.equal(event.empId, 601, 'empId is correct')
      assert.equal(event.couponId, 1000, 'couponId is correct')
     // assert.equal(event.owner, seller, 'owner is correct')
    // assert.equal(event.purchased, false, 'purchased is correct')
      /*
      // FAILURE: Product must have a name
      await await Doctorvisit.createProduct('', web3.utils.toWei('1', 'Ether'), { from: seller }).should.be.rejected;
      // FAILURE: Product must have a price
      await await Doctorvisit.createProduct('iPhone X', 0, { from: seller }).should.be.rejected;
      */
    })
    /*
    it('lists products', async () => {
      const product = await Doctorvisit.products(visitCount)
      assert.equal(visit.id.toNumber(), visitCount.toNumber(), 'id is correct')
      assert.equal(visit.name, 'iPhone X', 'name is correct')
      assert.equal(visit.price, '1000000000000000000', 'price is correct')
      assert.equal(visit.owner, seller, 'owner is correct')
      assert.equal(visit.purchased, false, 'purchased is correct')
    }) */

  })
})
