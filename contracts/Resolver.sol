pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;
import "./ItemsERC721.sol";


contract Resolver {

    ItemsERC721 internal _registry;

    event Set(uint256 indexed preset, string indexed key, string value, uint256 indexed tokenId);
    event SetPreset(uint256 indexed preset, uint256 indexed tokenId);

    // Mapping from token ID to preset id to key to value
    mapping (uint256 => mapping (uint256 =>  mapping (string => string))) internal _records;

    // Mapping from token ID to current preset id
    mapping (uint256 => uint256) _tokenPresets;


    constructor(ItemsERC721 registry) public {
      _registry = registry;
    }


    function registry() external view returns (address) {
        return address(_registry);
    }

    /**
     * @dev Throws if called when not the resolver.
     */
    modifier whenResolver(uint256 tokenId) {
        require(address(this) == _registry.resolverOf(tokenId),
                "Resolver: is not the resolver");
        _;
    }

    function presetOf(uint256 tokenId) external view returns (uint256) {
        return _tokenPresets[tokenId];
    }


    function reset(uint256 tokenId) external {
        require(_registry.isApprovedOrOwner(msg.sender, tokenId) || msg.sender == address(_registry),
                "Not aproved, owner or ERC721 contract to reset presets");
        _setPreset(now, tokenId);
    }

    /**
     * @dev Function to get record.
     * @param key The key to query the value of.
     * @param tokenId The token id to fetch.
     * @return The value string.
     */
    function get(string memory key, uint256 tokenId) public view whenResolver(tokenId) returns (string memory) {
        return _records[tokenId][_tokenPresets[tokenId]][key];
    }



    /**
     * @dev Function to get multiple record.
     * @param keys The keys to query the value of.
     * @param tokenId The token id to fetch.
     * @return The values.
     */
    function getMany(string[] calldata keys, uint256 tokenId) external view whenResolver(tokenId) returns (string[] memory) {
        uint256 keyCount = keys.length;
        string[] memory values = new string[](keyCount);
        uint256 preset = _tokenPresets[tokenId];
        for (uint256 i = 0; i < keyCount; i++) {
            values[i] = _records[tokenId][preset][keys[i]];
        }
        return values;
    }

    function setMany(
        string[] memory keys,
        string[] memory values,
        uint256 tokenId
    ) public {
        require(_registry.isApprovedOrOwner(msg.sender, tokenId));
        _setMany(_tokenPresets[tokenId], keys, values, tokenId);
    }

    function _setPreset(uint256 presetId, uint256 tokenId) internal {
        _tokenPresets[tokenId] = presetId;
        emit SetPreset(presetId, tokenId);
    }

    /**
     * @dev Internal function to to set record. As opposed to set, this imposes
     * no restrictions on msg.sender.
     * @param preset preset to set key/values on
     * @param key key of record to be set
     * @param value value of record to be set
     * @param tokenId uint256 ID of the token
     */
    function _set(uint256 preset, string memory key, string memory value, uint256 tokenId) internal {
        _records[tokenId][preset][key] = value;
        emit Set(preset, key, value, tokenId);
    }

    /**
     * @dev Internal function to to set multiple records. As opposed to setMany, this imposes
     * no restrictions on msg.sender.
     * @param preset preset to set key/values on
     * @param keys keys of record to be set
     * @param values values of record to be set
     * @param tokenId uint256 ID of the token
     */
    function _setMany(uint256 preset, string[] memory keys, string[] memory values, uint256 tokenId) internal {
        uint256 keyCount = keys.length;
        for (uint256 i = 0; i < keyCount; i++) {
            _set(preset, keys[i], values[i], tokenId);
        }
    }
}
