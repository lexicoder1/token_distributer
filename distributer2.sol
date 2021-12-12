pragma solidity 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

interface token_{
    function transfer(address recipient, uint256 amount) external returns (bool);
    function numberofholders()external view returns(uint);
    function checkstartingholderblocknum(address add)external view returns(uint);
    function updatestartingholderblocknum(address add)external ;
    function checkifholder(address add)external view returns(bool);

}

contract distributer is Ownable{
  
     token_ _token;

   constructor(address tokenaddress){
    _token =token_(tokenaddress);

   }


    mapping(address=>mapping(uint=>uint)) feesbyblock;
 
    mapping(address=>uint) shares;
    mapping (address=>uint) mostrecentblocknumber;
   
    mapping (address=>uint) transferedshare;
    
    function sendfees(uint fees)public{
     uint s=_token.numberofholders();     
     uint _fees=fees/s;
     feesbyblock[address(this)][block.number]+=_fees;
     mostrecentblocknumber[address(this)]=block.number;
    

    }

    function getshares(address add)public returns(uint){

    if (_token.checkstartingholderblocknum(add)>0){
       uint _feesbyblock= feesbyblock[address(this)][_token.checkstartingholderblocknum(add)];

       shares[add]=feesbyblock[address(this)][mostrecentblocknumber[address(this)]]-_feesbyblock;

       return  shares[add];
    }

    }

    
    function updatetokenaddress(address add)public onlyOwner{
       _token =token_(add);
    }

    function claimshares()public{
       bool check=_token.checkifholder(msg.sender);
    require(check==true,"can't claim share not an holder");
      uint _shares=getshares(msg.sender)+ transferedshare[msg.sender];
       _token.updatestartingholderblocknum(msg.sender);
      _token.transfer(msg.sender, _shares);

    }

    function transfershare(address add)public {
      transferedshare[add]+=getshares(msg.sender);
       _token.updatestartingholderblocknum(msg.sender);
    
       
       
    
    }

   
}