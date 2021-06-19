/* eslint-disable no-undef */
const MyNet = artifacts.require("MyNet");
const DoctorVisitBase = artifacts.require("DoctorVisitBase");
const Coupon = artifacts.require("Coupon");
const DoctorBase = artifacts.require("DoctorBase");


module.exports = function(deployer) {
  deployer.deploy(MyNet);
  deployer.deploy(Coupon);
  deployer.deploy(DoctorBase);
  deployer.deploy(DoctorVisitBase);

};
