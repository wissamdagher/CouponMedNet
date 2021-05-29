const { assert } = require('chai')

const Employee = artifacts.require('./Employee.sol')

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('Employee', ([deployer, seller, buyer]) => {
  let employee

  before(async () => {
    employee = await Employee.deployed()
    console.log("seller " +seller)
    console.log("buyer" +buyer)
  })
  

  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address = await employee.address
      assert.notEqual(address, 0x0)
      assert.notEqual(address, '')
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })

    it('has a name', async () => {
      const name = await employee.getName()
      assert.equal(name, 'Employee contract initialised')
    })
  })

  describe('employees', async () => {
    let result, employeeCount

    before(async () => {
      //result = await Employee.createVisit(601,1000, web3.utils.toWei('1', 'Ether'), { from: seller })
      result = await employee.registerEmployee(601,{ from: seller })
      employeeCount = await employee.employeeCount()
    })

    it('register Employee', async () => {
      // SUCCESS
      assert.equal(employeeCount, 1)
      const event = result.logs[0].args
      assert.equal(event.id.toNumber(), employeeCount.toNumber(), 'id is correct')
      assert.equal(event.owner, seller, 'owner is correct')
      assert.equal(event.active, false, 'valid is correct')
    })

    it('activate Employee', async() => {
      result = await employee.activateEmployee(employeeCount, { from: seller })
      //SUCCESS
      assert.equal(employeeCount, 1)
      const event = result.logs[0].args
      assert.equal(event.id.toNumber(), employeeCount.toNumber(), 'id is correct')
      assert.equal(event.originalOwner, seller, 'owner is correct')
      assert.equal(event.active, true, 'active is correct')
    })

  })
})
