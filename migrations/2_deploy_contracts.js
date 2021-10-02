/* eslint-disable no-undef */
const MyNet = artifacts.require("MyNet");
const Owner = artifacts.require("Owner");
const userInvite = artifacts.require("UserInvite");
const HRManager = artifacts.require("HRManager");
const EmployeeBase = artifacts.require("EmployeeBase");
const EmployeeCore = artifacts.require("EmployeeCore");
const DoctorVisitBase = artifacts.require("DoctorVisitBase");
const Coupon = artifacts.require("Coupon");
const DoctorBase = artifacts.require("DoctorBase");


module.exports = function(deployer) {
  deployer.deploy(MyNet);
  deployer.deploy(Owner);
  deployer.deploy(Coupon);
  deployer.deploy(DoctorBase);
  deployer.deploy(DoctorVisitBase);
  deployer.deploy(EmployeeCore);
  deployer.deploy(EmployeeBase);
  deployer.deploy(HRManager);
  deployer.deploy(userInvite);


};
