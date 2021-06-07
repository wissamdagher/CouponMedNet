pragma solidity ^0.5.0;

contract Doctor {
  string name;
  address owner;
  uint public doctorCount; 

  mapping(uint => Doc) public doctors;
  mapping(string => uint) docInvitations;

  struct Doc{
    uint id;
    uint doctorId;
    address owner;
    bool active;
  }

  constructor() public {
    name = "Doctor contract initialised";
    doctorCount = 0;
    owner = msg.sender;
  }

  function inviteDocs(uint _docId, uint _UUID) public {
    if(docInvitations[_UUID] > 0) {
    emit invitationCreated("Doctor invitation", "failure");      
    } else 
    {
    docInvitations[_UUID] = _docId;
    emit invitationCreated("Doctor invitation", "success");
    }
  }

  function registerDoc(uint _doctorId) {
    doctorCount ++;
    doctors[_doctorId] = Doc(doctorCount, _doctorId, msg.sender, true);
    emit doctorRegistration("success");
  }




}