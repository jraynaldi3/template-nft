const main = async()=>{
    const [deployer, randomPerson, person1,person2] = await hre.ethers.getSigners();
    const accountBalance = await deployer.getBalance();
    const nftContractFactory = await hre.ethers.getContractFactory("SkyCityNFT");
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log(nftContract.address);

    let mintNFT = await nftContract.whitelistMint({value: ethers.utils.parseEther("0.06")})
    await mintNFT.wait();
    let totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
}

const runMain = async()=>{
    try {
        await main();
        process.exit(0);
    } catch(error){
        console.log(error);
        process.exit(1);
    }
}

runMain();