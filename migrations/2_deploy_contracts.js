/* eslint-disable no-undef */
const Marketplace = artifacts.require("Marketplace");
const Doctorvisit = artifacts.require("Doctorvisit");
const Coupon = artifacts.require("Coupon");
const Employee = artifacts.require("Employee");


module.exports = function(deployer) {
  deployer.deploy(Marketplace);
  deployer.deploy(Doctorvisit);
  deployer.deploy(Coupon);
  deployer.deploy(Employee);

};
