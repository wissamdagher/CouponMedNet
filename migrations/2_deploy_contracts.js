/* eslint-disable no-undef */
const MyNet = artifacts.require("MyNet");
//const Doctorvisit = artifacts.require("Doctorvisit");
//const Coupon = artifacts.require("Coupon");
//const Employee = artifacts.require("Employee");


module.exports = function(deployer) {
  deployer.deploy(MyNet);
  //deployer.deploy(Doctorvisit);
 // deployer.deploy(Coupon);
 // deployer.deploy(Employee);

};
