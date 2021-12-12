pragma solidity 0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./distributer2.sol";


contract token is Context, IERC20, IERC20Metadata ,Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address=>uint) startingholderblocknum; 
     mapping(address=>bool) _checkholder; 

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address[] public holders;

    uint holdersamount;  
    
    distributer _distributer;
    

    
    constructor(string memory name_, string memory symbol_,uint amount) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender,amount);
       _distributer= new distributer(address(this));
    }

   
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount); 
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

  
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

   
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function setholdersamount(uint amount)public onlyOwner {
       holdersamount=amount;
    }

   

    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

         bool check;
    if ( _balances[recipient]>=holdersamount){
        check=true;
    }

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        
        if ( _balances[recipient] >=holdersamount && check==false) {
        holders.push(recipient);    
        _checkholder[recipient]=true;
        startingholderblocknum[recipient]=block.number;
    }
       
       removeholders(sender);
   
         emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
     
     function removeholders(address sender)internal returns(bool){
            if (_balances[sender]<holdersamount){
        for (uint i; i<=holders.length-1;i++){
            if (holders[i]==sender){
            holders[i]=holders[holders.length-1];
            holders.pop();
            _checkholder[sender]=false;
            startingholderblocknum[sender]=0;
            return true;
            }
        }
    }
       return true;
     }

     function checkifholder(address add)external view returns(bool){
           return _checkholder[add];
     }
 
     function checkstartingholderblocknum(address add)external view returns(uint){
       
      return  startingholderblocknum[add];

     
     }

   function checkholder() public view returns(address[]  memory){
    
    return holders;
    
    }

    function numberofholders()external view returns(uint){
    
       return holders.length;
    }

    function checkdistributercontractaddress()public view returns(address){
        return address(_distributer);
    }

    function updatestartingholderblocknum(address add)external {
       require (msg.sender==address(_distributer), "you are not distributer contract");

        startingholderblocknum[add]=block.number;
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

  
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
