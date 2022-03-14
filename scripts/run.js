const main = async()=>{
    const [deployer, randomPerson, person1,person2] = await hre.ethers.getSigners();
    let accountBalance = await deployer.getBalance();
    const nftContractFactory = await hre.ethers.getContractFactory("NFTMinting");
    const nftContract = await nftContractFactory.deploy(
        0,
        9999999999,
        "ipfs://QmZe5js8GsE6hMdKdwGE6K9R9qoF7btpD5Cg7ccWmzKYni/",
        "NOT REVEALED URI"
        );
    await nftContract.deployed();
    console.log(randomPerson.address);

    let addWL = await nftContract.addWhitelist([
        randomPerson.address,
        person1.address,
        person2.address
    ])

    let mintNFT = await nftContract.publicMint(5, {value: ethers.utils.parseEther("0.06")})
    await mintNFT.wait();
    let totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())

    mintNFT = await nftContract.connect(randomPerson).publicMint(5,{value: ethers.utils.parseEther("0.06")});
    await mintNFT.wait();
    totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())

    mintNFT = await nftContract.connect(person1).publicMint(1, {value: ethers.utils.parseEther("0.06")});
    await mintNFT.wait();
    totalMint = await nftContract.getTotalMinted();
    console.log(totalMint.toNumber());
    accountBalance = await deployer.getBalance();
    console.log(accountBalance.toString())

    mintNFT = await nftContract.connect(person2).publicMint(1, {value: ethers.utils.parseEther("0.06")});
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