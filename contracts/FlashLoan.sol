// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

//for executing flash loan
import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";

//for referring to liquidity pool address(abstraction over it in this smart contract)
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

//for using approve function
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

//using interface form IFlashLoanSimpleReceiver.sol

contract FlashLoan is FlashLoanSimpleReceiverBase {

    address payable owner;
    constructor(address _addressProvider) 
    FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
    }


    //STEP 2
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
        //we have loan funds in hands
        //add a logic to use those funds

        //approve the pool to pull funds once loan money is used by my logic
        //POOL variable is defined in constructor of FlashLoanSimpleReceiverBase.sol
        uint256 amountOwed = amount + premium;

        //we just have to approve ; no need to send to pool
        IERC20(asset).approve(address(POOL),amountOwed);

        initiator = address(0);
        // params = bytes(0);

        return true;
    }


    //STEP 1
    //request for loan
    function requestFlashLoan(address _token,uint256 _amount) public{
        //we recieve loan on this contract's address
        address receiverAddress = address(this);
        //which token to recive as loan
        address asset = _token;
        //how much of that token to get in loan
        uint256 amount = _amount;

        bytes memory params = "";
        uint16 referralCode = 0;

        // use flashLoanSimple from IPool.sol
        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }


    //utility functions
    function getBalance(address _tokenAddress) external view returns(uint256){
        //give this contract's balance of the token specified
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    //withdraw funds once loan+premium returned
    function withdraw(address _tokenAddress) external onlyOwner{
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender,token.balanceOf(address(this)));
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Only the contract owner can call this owner");
        _;
    }

    receive() external payable{}

}