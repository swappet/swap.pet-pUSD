// contracts/pUSD.sol
// Copyright (C) 2020, 2021, 2022 Swap.Pet@pm.me
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0; 
 
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev inherit from the ERC20Snapshot contract for supporting snapshot
 *      inherit from the Ownable contract for make snapshot controll
 */
contract pUSD is ERC20 {
    using SafeMath for uint256; 
    IERC20 public immutable usd1; // default:usdt(ERC20)
    // address payable public immutable usd2; // default:'' 

    constructor(
        string memory name,  
        string memory symbol,  
        address payable usd1_  
    ) public ERC20(name, symbol) {
        usd1 = IERC20(usd1_);  
    } 

    event  Deposit(address indexed from, uint amount);
    event  Withdrawal(address indexed to, uint amount); 

    function deposit(address _token,uint256 amount) public payable {
        // Only the USDT contract may send USDT via a call to deposit.
        require( IERC20(_token) == usd1, 'USDT_ONLY'); 
        require(usd1.balanceOf(_msgSender()) >= amount);
        // need approve at first
        usd1.transferFrom(msg.sender,address(this),amount);
        _mint(_msgSender(), amount); // 1:1 exchange for pegging
        emit Deposit(_msgSender(), amount);
    } 

    function withdraw(uint256 amount) public {
        // Only the USDT contract may send USDT via a call to withdraw.
        // require(_msgSender() == usd1, 'USDT_ONLY'); 
        require(usd1.balanceOf(address(this)) >= amount);
        _burn(_msgSender(), amount); // clear pUSD
        usd1.transfer(_msgSender(), amount); // refund USDT
        emit Withdrawal(_msgSender(), amount);
    } 

    // receive() external payable {
    //     deposit();
    // } 

    // used for overflow testing
    function testSetBalance(address account, uint amount) external {
        _mint(account, amount);
    }

}