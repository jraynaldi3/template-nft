const main = async()=>{
    const [deployer] = await hre.ethers.getSigners();
    const accountBalance = await deployer.getBalance();
    const nftContractFactory = await hre.ethers.getContractFactory("NFTLowGas");
    const nftContract = await nftContractFactory.deploy(
        "Solo NFT",
        "SOLO",
        "ipfs://QmZe5js8GsE6hMdKdwGE6K9R9qoF7btpD5Cg7ccWmzKYni",
        "ipfs://QmZe5js8GsE6hMdKdwGE6K9R9qoF7btpD5Cg7ccWmzKYni/100.json"
    );

    await nftContract.deployed();
    
    //console.log("deployer", (accountBalance.toNumber))
    console.log(nftContract.address);

    let mintNFT = await nftContract.mintNFT({value: hre.ethers.utils.parseEther("0.06")})
    console.log("minting nft")
    await mintNFT.wait();
    console.log("nft minted")
    let totalMint = await nftContract.totalSupply();
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