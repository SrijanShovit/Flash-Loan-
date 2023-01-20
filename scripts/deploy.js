const hre = require("hardhat");

async function main() {

  const FlashLoan = await hre.ethers.getContractFactory("FlashLoan");

  //AAVE PoolAddressProvider (Goerli):0xC911B590248d127aD18546B186cC6B324e99F02c
  const flashLoan = await FlashLoan.deploy("0xC911B590248d127aD18546B186cC6B324e99F02c");

  await flashLoan.deployed();
  console.log("Flash loan contract deployed: ",flashLoan.address);//0x2784a06b5F6D6606089808000424cC8340De33ac

  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
