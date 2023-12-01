// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.22;

contract CryptoPets {
    // owner Parent
    address owner;

    event LogPetFundingReceived(address addr, uint amount, uint contractBalance);

    constructor(){
        owner = msg.sender;
    }
/*
    msg.sender; // address of sender
    msg.value;  // amount of ether provided to this contract in wei, the function sould be marked "payable"
    msg.data;   // bytes, complete call data
    msg.gas;    // remain gass
*/
    // define Pet    
    struct Pet{
        address payable walletAddress;
        string petname;
        string bio;
        string serialTag;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    Pet[] public pets;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can add Pets");
        _;
    }


    // add pet to contract
   function addPet(address payable walletAddress, string memory petname, string memory bio, string memory serialTag, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner{
    pets.push(Pet(
        walletAddress,
        petname,
        bio,
        serialTag,
        releaseTime,
        amount,
        canWithdraw
    ));
   }
    

    function balanceOf() public view returns(uint){
        return address(this).balance;
    }

    // deposit funds to contract, specifically to pet's account
    function deposit(address walletAddress) payable public {
        addToPetBalance(walletAddress);
    }

    function addToPetBalance(address walletAddress)  private {
        for(uint i=0; i < pets.length; i++){
            if(pets[i].walletAddress == walletAddress){
                pets[i].amount += msg.value;
                emit LogPetFundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint){
        for(uint i=0;i < pets.length; i++){
            if(pets[i].walletAddress==walletAddress)
                return i;
        }
        return 999;
    }
    // pet checks if able to withdraw
    function avaiableToWithdraw(address walletAddress) public returns(bool){
        uint i = getIndex(walletAddress);
        require(block.timestamp > pets[i].releaseTime, "You cannot withdraw yet");
        if (block.timestamp > pets[i].releaseTime){
            pets[i].canWithdraw = true;
            return true;
        }else{
            return false;
        }        
    }

    // withdraw money
    function withdraw(address walletAddress) payable public{        
        uint i = getIndex(walletAddress);
        require(msg.sender == pets[1].walletAddress, "You must be the pet to withdraw");
        require(pets[i].canWithdraw == true, "You are not able to withdraw at this time");
        pets[i].walletAddress.transfer((pets[i].amount));
    }

    // transfer to foundation wallet
}

// Thank you for reference source code https://gist.github.com/rodgtr1/427a6e0cea78281fb9ad8ea9980bb5a2.js