// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title
 * @authors
 */
contract Gold is IERC20 {

    /**
     * @dev 
     */
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 internal TotalSupply;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimal;
    }

    /**
     * @dev     Standard ERC20
     * @return  The total amount of tokens that are on the contract
     */
    function totalSupply() public override view returns (uint256) {return TotalSupply;}

    /**
     * @dev     Standard ERC20
     * @param   _owner The account to querey
     * @return  The total amount of tokens that the user has
     */
    function balanceOf(
        address _owner
    ) public override view returns (uint256) {
        return balances[_owner];
    }

    /**
     * @dev 
     */
    function transfer(address _delegate, uint256 _value) public override returns (bool) {
        require(_value <= balances[msg.sender], "Not enough Eth to transfer");
        balances[msg.sender] -= _value;
        balances[_delegate] += _value;
        emit Transfer(msg.sender, _delegate, _value);
        return true;
    }

    /**
     * @dev 
     */
    function approve(address _delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][_delegate] += numTokens;
        emit Approval(msg.sender, _delegate, numTokens);
        return true;
    }

    /**
     * @dev 
     */
    function allowance(address _owner, address delegate) public override view returns (uint) {
        return allowed[_owner][delegate];
    }

    /**
     * @dev 
     */
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}


contract DEX {

    event Bought(uint256 amount);
    event Sold(uint256 amount);


    IERC20 public token;

    /**
     * @dev 
     */
    constructor(        
        string memory _name,
        string memory _symbol,
        uint8 _decimal
    ){
        token = new ERC20Basic(
            _name,
            _symbol,
            _decimal
        );
    }

    /**
     * @dev 
     */
    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    /**
     * @dev 
     */
    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }

}
