//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

/*
@title A contract to mint NFTs
@notice this contract use to mint NFT with some configuration
@author Julius Raynaldi 
@dev contract is ERC721 using Counters and Ownable from openzeppelin
*/
contract SkyCityNFT is ERC721URIStorage, Ownable{
    //defining some utility variable
    uint256 internal mintStartDate  = 1646231820;
    uint256 internal mintEndDate = 1646318220;
    uint256 internal maxSupply = 100;
    uint256 internal mintPrice = 0.06 ether;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    event NewSkyCreated (uint256 _id, string _name, address _minter);

    struct SkyNft {
        uint256 id;
        string name;
    }
    
    SkyNft[] public skyNfts;

    mapping (uint256 => address) public skyOwner;
    mapping (address => bool) public whitelisted;
    mapping (address => uint256) public skyBalance;

    /*
    @dev contructor run when smart contract deployed
    @notice make an ERC721 token with name SkyCity and symbol SKY 
    */
    constructor () ERC721("SkyCity","SKY") {
        whitelisted[msg.sender] = true;
        console.log("deployed");
    }

    /*
    *@notice this is the require of minting function 
    *@dev minting requirement use this in every minting function 
    *use the modifier to throw and error if condition not fulfilled
    *the requirement is minting price , date and max supply of NFT
    *devide it with whitelist address or not whitelist address can ming 1 day before the normal minting
    * @params boolean to decide that the mint is for whitelist minting or for non-whitelist minting
    */
    modifier mintRequirement(bool _whitelistMint){
        require(msg.value >= mintPrice,"Not Enought ETH" );
        require(skyNfts.length < maxSupply,"Max Supply Reached");

        if (_whitelistMint) {
            require(whitelisted[msg.sender] == true ,"address not whitelisted");
            //date for whitelist mint
            require(mintStartDate>block.timestamp && block.timestamp>(mintStartDate-86400),"Not in Whitelist Minting Date");
        } else {
            //date for non whitelist mint 
            require(mintEndDate>block.timestamp && block.timestamp> mintStartDate,"Not in Minting Date");
        }
        _;
    }

    /*
    @notice function will deliver the value of minting price
    @dev function return mintPrice for website usage and others
    this function will help in website building to synchronize the price in website and in smartcontract
    */
    function getMintingPrice() external view returns(uint256){
        return mintPrice;
    }

     /*
    @notice function will deliver the value of maximal number of NFT
    @dev function return maxSupply for website usage and others
    this function will help in website building to synchronize the supply in website and in smartcontract
    */
    function getMaxSupply() external view returns(uint256){
        return maxSupply;
    }

    /*
    * WARNING DELETE THIS FUNCTION FOR REAL DEPLOYMENT
    *@dev its helping for testing but will make contract vulnerable so DELETE this function before 
    *the real deployement
    *this function will be set the variable in the beginning 
    *
    *@notice its just for testing to ease setting without redeploy of smartContract
    *@params _newPrice is new minting price, 0newStartDate is new minting start date
    * _newEndDate is new minting end date, _newSupply is new max supply.
    */
    function testSetting(
        uint256 _newPrice,
        uint256 _newStartDate,
        uint256 _newEndDate ,
        uint256 _newSupply
        ) private onlyOwner(){
            //declared the new setting 
            mintPrice = _newPrice;
            mintStartDate = _newStartDate;
            mintEndDate = _newEndDate;
            maxSupply = _newSupply;
    }

    /*
    *@notice this is for add address to whitelist minting 
    *@dev address will added to whitelist array
    *@params _newWhitelist is array of addresses will be added to the whitelist array
     */
    function addWhitelist(address[] memory _newWhitelist) external onlyOwner() {
        for (uint i = 0; i < _newWhitelist.length; i++){
            whitelisted[_newWhitelist[i]] = true;
        }
    }

    /*
    *@notice this function will reset and clear the whitelist 
    *@dev whitelist array will set to default which is empty array, address can be added by addWhitelist
    * function
     */
    function removeWhitelist(address[] memory _removeAddress) external onlyOwner() {
        for (uint i = 0; i < _removeAddress.length; i++){
            whitelisted[_removeAddress[i]] = false;
        }
    }

    /*
    *@notice function to minting nfts to wallet
    *@dev this function will execute minting use this to make other function like whitelist minting 
    *and normal minting 
     */
    function mintNFT() private {
        console.log(block.timestamp);
        uint256 newId = _tokenId.current();
        _safeMint(msg.sender, newId);
        
        _tokenId.increment();
        skyNfts.push(SkyNft(newId,"James"));
        bytes memory newURI = abi.encodePacked("ipfs://QmZe5js8GsE6hMdKdwGE6K9R9qoF7btpD5Cg7ccWmzKYni/",Strings.toString(skyNfts.length),".json");
        _setTokenURI(newId, string(newURI));
        console.log(string(newURI));
        skyBalance[msg.sender] += 1;
        skyOwner[newId] = msg.sender;
        emit NewSkyCreated(newId,"James",msg.sender);
    }


    function whitelistMint() public payable mintRequirement(true){
        mintNFT();
    }

    function publicMint() public payable mintRequirement(false){
        mintNFT();
    }

    function getTotalMinted() external view returns(uint256){
        return uint256(skyNfts.length);
    }

    function withdraw() external onlyOwner{
        (bool success, ) = msg.sender.call{
            value: address(this).balance
        }("");
        require(success, "Failed to send to Owner.");
    }
}