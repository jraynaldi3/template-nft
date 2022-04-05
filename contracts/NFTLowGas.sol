//SPDX-License-Identifier: NOLICENSE

pragma solidity ^0.8.4;

/**
@author Julius Raynaldi
@dev Low gas version for minting NFT
@notice gas is big thing to consider
*/

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFTLowGas is ERC721Enumerable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event MintNFT(uint id, address minter);

    //Constants
    uint mintPrice = 0.06 ether;
    uint maxSupply = 100;
    bool revealed = false;
    bool paused = false;
    string baseURI;
    string baseExtension = ".json";
    string notRevealedURI;
    address private owner; //owner cannot be transfered

    constructor (
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        string memory _notRevealedURI
    ) ERC721(_name,_symbol){
        baseURI = _baseURI;
        notRevealedURI = _notRevealedURI;
        owner = msg.sender;
    }

    /**
    *@dev give some modifier for minting
     */
    modifier mintReq(){
        require(paused == false,"Minting paused");
        require(maxSupply>totalSupply(),"Max Supply Reached");
        require(msg.value>=mintPrice,"Not Enought ETH payed");
        _;
    }

    /**
    *@dev modifier for onlyOwner
    */
    modifier onlyOwner(){
        require(owner == msg.sender,"Unauthorized");
        _;
    }

    function mintNFT() public payable mintReq {
        uint newId = _tokenIds.current();
        _safeMint(msg.sender, newId);
        _tokenIds.increment();
        emit MintNFT(newId, msg.sender);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns(string memory){
        require(_exists(tokenId),"Token doesn't exists");
        if(revealed==false){
            return notRevealedURI;
        }

        return string(abi.encodePacked(baseURI,Strings.toString(tokenId),baseExtension));
    }

    function pause() external onlyOwner{
        paused = true;
    }

    function reveal() external onlyOwner{
        revealed = true;
    }
}