pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Controller.sol";
import "./Resolver.sol";

/**
 * @title DSSRegistry
 * @dev An ERC721 Token see https://eips.ethereum.org/EIPS/eip-721.
 */
contract ItemsERC721 is ERC721,ERC721Burnable,Controller {

    address public RESOLVER_ADDRESS;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;


    mapping (uint256 => address) internal _tokenResolvers;


    event Resolve(uint256 indexed tokenId, address indexed to);
    event ResolverDefined(address resolver);
    event Minted(address from,address indexed to,uint256 tokenId);

    modifier onlyApprovedOrOwner(uint256 tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) public {

      _setBaseURI("ipfs://ipfs/");
      _setupRole(DEFAULT_ADMIN_ROLE,msg.sender);

    }


    /// Ownership

    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool) {
        return _isApprovedOrOwner(spender, tokenId);
    }



    /// Minting

    function mint(address to,string memory uri) public onlyMinter {
      require(uint256(RESOLVER_ADDRESS) != 0,"Need to set default resolver address to be able to mint");
      _tokenIds.increment();
      uint256 newItemId = _tokenIds.current();
      _mint(to, newItemId);
      _setTokenURI(newItemId, uri);
      _resolveTo(RESOLVER_ADDRESS,newItemId);
      emit Minted(msg.sender,to,newItemId);
    }

    function mintMany(address[] memory to,string[] memory uris) public onlyMinter{
      for (uint256 i = 0; i < uris.length; i++) {
        mint(to[i],uris[i]);
      }
    }

    // Transfer

    function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721)  {
      _resetResolver(tokenId);
      super.transferFrom(from,to,tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721) {
      _resetResolver(tokenId);
      super.safeTransferFrom(from,to,tokenId);
    }

    // Burning

    function burn(uint256 tokenId) public virtual override onlyApprovedOrOwner(tokenId) {
        super.burn(tokenId);
        // Clear resolver (if any)
        if (_tokenResolvers[tokenId] != address(0x0)) {
          delete _tokenResolvers[tokenId];
        }
    }

    /// Resolution

    function setResolver(address resolver) public  {
      require(hasRole(DEFAULT_ADMIN_ROLE,msg.sender),"Sender must be super admin");
      RESOLVER_ADDRESS = resolver;
      emit ResolverDefined(resolver);
    }

    function resolverOf(uint256 tokenId) external view returns (address) {
      return(_tokenResolvers[tokenId]);
    }

    function resolveTo(address to, uint256 tokenId) external onlyApprovedOrOwner(tokenId) {
        _resolveTo(to, tokenId);
    }

    function _resolveTo(address to, uint256 tokenId) private {
        require(_exists(tokenId));
        emit Resolve(tokenId, to);
        _tokenResolvers[tokenId] = to;
    }

    function _resetResolver(uint256 tokenId) private {
      Resolver resolver = Resolver(RESOLVER_ADDRESS);
      resolver.reset(tokenId);
    }


}
