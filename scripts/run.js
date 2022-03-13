const main = async()=>{
    const [deployer, randomPerson, person1,person2] = await hre.ethers.getSigners();
    let accountBalance = await deployer.getBalance();
    const nftContractFactory = await hre.ethers.getContractFactory("SkyCityNFT");
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log(randomPerson.address);

    let addWL = await nftContract.addWhitelist([
        randomPerson.address,
        person1.address,
        person2.address
    ])

    

    let mintNFT = await nftContract.whitelistMint({value: ethers.utils.parseEther("0.06")})
    await mintNFT.wait();
    let totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())

    mintNFT = await nftContract.connect(randomPerson).whitelistMint({value: ethers.utils.parseEther("0.06")});
    await mintNFT.wait();
    totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())

    mintNFT = await nftContract.connect(person1).whitelistMint({value: ethers.utils.parseEther("0.06")});
    await mintNFT.wait();
    totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())

    mintNFT = await nftContract.connect(person2).whitelistMint({value: ethers.utils.parseEther("0.06")});
    await mintNFT.wait();
    totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())

    let withdraw = await nftContract.withdraw();
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())
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