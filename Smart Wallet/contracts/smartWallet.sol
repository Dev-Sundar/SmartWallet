// SPDX-License-Identifier:MIT

pragma solidity 0.8.23;

contract SmartWallet{
    address payable owner;

    mapping (address => uint) public allowance;
    mapping (address => bool) public isAllowedtoSend;
    mapping (address => bool) public Guardian;

    address payable nextowner;
    uint guardianResetCount;
    uint public constant confirmationforGuardiansforReset = 3;

    constructor(){
        owner = payable (msg.sender);
    }

    function proposenewOwner(address payable newOwner) public {

        require(Guardian[msg.sender],"You are not the Guardian");
        if (nextowner != newOwner){
            nextowner = newOwner;
            guardianResetCount = 0;
        }

    }

    function setAllowance(address _from , uint _amount) public {
        require(msg.sender == owner , "You are Not the Owner");
        allowance[_from] = _amount;
        isAllowedtoSend[_from] = true;
    }

    function denySending(address _from) public {
        require(msg.sender == owner,"You are Not the Owner");
        isAllowedtoSend[_from] = false;
    }


    function transfer(address payable _to,uint _amount,bytes memory _payload)   public returns(bytes memory) {

        require(_amount <= address(this).balance,"You are not the owner,Exiting");

        if (msg.sender!= owner ){
            require(isAllowedtoSend[msg.sender] ,"Aborting");
            require(allowance[msg.sender] >= _amount,"You are reached more than your allowed attemps,Exiting!!");
            
            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value:_amount}(_payload);

        require(success,"Aborting,Call Was Not Successfull!!");
        return  returnData ;
    }


    

    receive() external payable { }

}