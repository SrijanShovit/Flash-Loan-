// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

//using interface for Dex.sol
interface IDex {
    function depositUSDC(uint256 _amount) external;

    function depositDAI(uint256 _amount) external;

    function buyDAI() external;

    function sellDAI() external;
}

contract FlashLoanArbitrage is FlashLoanSimpleReceiverBase {

    //Aave ERC20 Token addresses on Goerli network
    address private immutable daiAddress = 0xBa8DCeD3512925e52FE67b1b5329187589072A55;
    address private immutable usdcAddress = 0x65aFADD39029741B3b8f0756952C74678c9cEC93;
    address private dexContractAddress = 0xac0E471eF1bD4F889828f0a266FA527A28Bd9f90;

    IERC20 private dai;
    IERC20 private usdc;
    IDex private dexContract;
    address payable owner;

    constructor(address _addressProvider) 
    FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
        dai = IERC20(daiAddress);
        usdc = IERC20(usdcAddress);
        dexContract = IDex(dexContractAddress);
    }


    //STEP 2
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
       //we have got 1000 USDC loan from aave

       //deposit those funds into dexA
       dexContract.depositUSDC(1000000000);

       //buy some DAI for those USDC deposited at discounted rate
       dexContract.buyDAI();

       //deposit those DAI to dexB
       dexContract.depositDAI(dai.balanceOf(address(this)));

       //get USDC for those deposited DAI at dexB at higher rates
       dexContract.sellDAI();

        uint256 amountOwed = amount + premium;

    
        IERC20(asset).approve(address(POOL),amountOwed);

        
        return true;
    }


    //STEP 1
    function requestFlashLoan(address _token,uint256 _amount) public{
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }


    //allowance is giving back money 
    //approval is taking money

    function approveUSDC(uint256 _amount) external returns (bool){
        return usdc.approve(dexContractAddress,_amount);
    }

    function allowanceUSDC() external view returns (uint256){
        return usdc.allowance(address(this),dexContractAddress);

    }

    function approveDAI(uint256 _amount) external returns(bool){
        return dai.approve(dexContractAddress,_amount);
    }

    function allowanceDAI() external view returns (uint256){
        return dai.allowance(address(this),dexContractAddress);
    }



  
    function getBalance(address _tokenAddress) external view returns(uint256){
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    
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