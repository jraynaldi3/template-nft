const main = async()=>{
    const [deployer] = await hre.ethers.getSigners();
    const accountBalance = await deployer.getBalance();
    const nftContractFactory = await hre.ethers.getContractFactory("NFTMinting");
    const nftContract = await nftContractFactory.deploy(
        1649210331,
        1649296731,
        "ipfs://QmZe5js8GsE6hMdKdwGE6K9R9qoF7btpD5Cg7ccWmzKYni",
        "ipfs://QmZe5js8GsE6hMdKdwGE6K9R9qoF7btpD5Cg7ccWmzKYni"
    );

    await nftContract.deployed();
    
    //console.log("deployer", (accountBalance.toNumber))
    console.log(nftContract.address);

    let mintNFT = await nftContract.whitelistMint(2,{value: hre.ethers.utils.parseEther("0.06")})
    console.log("minting nft")
    await mintNFT.wait();
    console.log("nft minted")
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