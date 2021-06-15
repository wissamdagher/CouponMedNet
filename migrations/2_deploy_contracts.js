/* eslint-disable no-undef */
const UserManager = artifacts.require("UserManager");
//const Doctorvisit = artifacts.require("Doctorvisit");
//const Coupon = artifacts.require("Coupon");
//const Employee = artifacts.require("Employee");


module.exports = function(deployer) {
  deployer.deploy(UserManager);
  //deployer.deploy(Doctorvisit);
 // deployer.deploy(Coupon);
 // deployer.deploy(Employee);

};
