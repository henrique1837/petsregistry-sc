pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./ItemsERC721.sol";

/**
 * @title DSSRegistry
 * @dev An ERC721 Token see https://eips.ethereum.org/EIPS/eip-721.
 */
 contract Minter is Ownable {
   using SafeMath for uint256;
   ItemsERC721 public erc721;
   uint256 public price;

   event Deposited(address payee, uint256 amount);
   event Withdrawn(address payee, uint256 amount);

   constructor(address erc721_addr,uint256 _price) public {
     erc721 = ItemsERC721(erc721_addr);
     setPrice(_price);
   }
   function setPrice(uint256 _price) public onlyOwner {
     price = _price;
   }

   function doMintMany(address[] memory to,string[] memory uris) public payable {
     require(msg.value == price.mul(to.length));
     erc721.mintMany(to,uris);
     emit Deposited(owner(),msg.value);
   }
   function withdrawFunds() public onlyOwner {
       require(address(this).balance > 0,"Balance is 0");
       msg.sender.transfer(address(this).balance);
       emit Withdrawn(owner(), address(this).balance);
   }
 }
