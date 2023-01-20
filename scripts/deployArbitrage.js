const hre = require("hardhat");

async function main(){
    const FlashLoanArbitrage = await hre.ethers.getContractFactory("FlashLoanArbitrage");
    const flashLoanArbitrage = await FlashLoanArbitrage.deploy("0xC911B590248d127aD18546B186cC6B324e99F02c");

    await flashLoanArbitrage.deployed();

    console.log("Flash loan arbitrage contract deployed: ",flashLoanArbitrage.address);//0x632C10293fBcd8Fb4A784D80d70c5a7C6EfE9c6a
}

main().catch((e)=>{
    console.error(e);
    process.exit = 1;
})