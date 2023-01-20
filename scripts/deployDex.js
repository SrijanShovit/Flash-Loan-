const hre = require("hardhat");

async function main(){
    const Dex = await hre.ethers.getContractFactory("Dex");
    const dex = await Dex.deploy();

    await dex.deployed();

    //First provide some liquidity to Dex to handle Flash Loan with Arbitrage
    console.log("Dex contract deployed: ",dex.address);//0x1851cDE2C871EC3907dF513A933db2006b13Bb2a
}

main().catch((e)=>{
    console.error(e);
    process.exitCode = 1;
})