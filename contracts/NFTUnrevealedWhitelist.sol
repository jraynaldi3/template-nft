//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
@title A contract to mint NFTs
@notice this contract use to mint NFT with some configuration
@author Julius Raynaldi 
@dev contract is ERC721 using Counters and Ownable from openzeppelin
*/
contract NFTMinting is ERC721URIStorage, Ownable{
    //defining some utility variable
    uint256 public whitelistDuration;
    uint256 public mintStartDate;
    uint256 public mintEndDate;
    uint256 public maxSupply = 100;
    uint256 public mintPrice = 0.06 ether;
    string public defaultName = "SkyCity";
    string public defaultSymbol = "SKY";
    bool public revealed = false;
    bool public paused = false;
    string public notReavealedURI; 
    string public baseURI; 
    string public baseExtention = ".json";

    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    event NewNFTCreated (uint256 _id, string _name, address _minter);

    struct Nft {
        uint256 id;
        string name;
    }
    
    Nft[] public nfts;

    mapping (uint256 => address) public nftOwner;
    mapping (address => bool) public whitelisted;
    mapping (address => uint256) public nftBalance;

    /*
    @dev contructor run when smart contract deployed (check arguments.js)
    @notice make an ERC721 token with name SkyCity and symbol SKY 
    */
    constructor (
        uint256 _mintStartDate,
        uint256 _mintEndDate,
        string memory _nftBaseURI,
        string memory _nftUnrevealedURI
    ) ERC721(defaultName,defaultSymbol) {
        whitelisted[msg.sender] = true;
        setStartDate(_mintStartDate);
        setEndDate(_mintEndDate);
        setBaseURI(_nftBaseURI);
        setNotRevealedURI(_nftUnrevealedURI);
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
        require(nfts.length < maxSupply,"Max Supply Reached");

        if (_whitelistMint) {
            require(whitelisted[msg.sender] == true ,"address not whitelisted");
            require(nftBalance[msg.sender] < 5);
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
    *@dev this function bellow can help to set some parameter of minting NFT
    *
    *@dev setMintPrice to set mintPrice be carefull when added new Price take a look at the zeros
    *@param new price will be set
    */
    function setMintPrice(uint256 _newPrice) public onlyOwner(){
        mintPrice = _newPrice;
    }

    /*
    *@dev to set public mint start date
    *@param the parameters use timestamp unit, make sure to convert the date to timestamp. 
    */
    function setStartDate(uint256 _newStartDate) public onlyOwner(){
        mintStartDate = _newStartDate;
    }

    /**
    *@dev to set public mint end date
    *@param _newEndDate parameters use timestamp unit, make sure to convert the date to timestamp. 
    */
    function setEndDate(uint256 _newEndDate) public onlyOwner(){
        mintEndDate = _newEndDate;
    }

    function setWhitelistDuration(uint256 _newWhitelistDuration) public onlyOwner(){
        whitelistDuration = _newWhitelistDuration;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner(){
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _newNotRevealedURI) public onlyOwner(){
        notReavealedURI = _newNotRevealedURI;
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
        uint256 newId = _tokenId.current();
        _safeMint(msg.sender, newId);
        _tokenId.increment();
        nfts.push(Nft(newId,"James"));
        nftBalance[msg.sender] += 1;
        nftOwner[newId] = msg.sender;
        emit NewNFTCreated(newId,"James",msg.sender);
    }

    /*
    *@dev this will automaticaly set the token URI, there's 2 conditional here 
    *one when revealed is false and other when revealed is true. 
    */
    function tokenURI(uint256 tokenId) public view virtual override returns(string memory){
        require(_exists(tokenId),"Token doesn't exists");
        if(revealed==false){
            return notReavealedURI;
        }

        return string(abi.encodePacked(baseURI,Strings.toString(tokenId),baseExtention));
    }

    //whitelist max mint is 5
    function whitelistMint(uint16 _mintCount) public payable mintRequirement(true){
        require(_mintCount<=5);
        for(uint i = 0;i<_mintCount;i++){
            mintNFT();
        }
        
    }

    //public max mint is 10
    function publicMint(uint16 _mintCount) public payable mintRequirement(false){
        require(_mintCount<=10);
        for (uint i = 0; i<_mintCount; i++){
            mintNFT();
        }
        
    }

    function getTotalMinted() external view returns(uint256){
        return uint256(nfts.length);
    }

    function reveal() external {
        revealed = true;
    }


    /*
    *@notice by default 5% will withdraw to @author wallet  
    */
    function withdraw() external onlyOwner{
        (bool au, ) = payable(0xd7089094233d11C834DF103BED938BB1d4D10652).call{
            value : (address(this).balance * 5/100)
        }("");
        require(au, "Failed to send to author");

        (bool success, ) = msg.sender.call{
            value: address(this).balance
        }("");
        require(success, "Failed to send to Owner.");
    }
}